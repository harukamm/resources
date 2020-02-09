#!/usr/bin/ruby

require 'rbconfig'

def os
  @os ||= (
    host_os = RbConfig::CONFIG['host_os']
    case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    when /darwin|mac os/
      :macosx
    when /linux/
      :linux
    when /solaris|bsd/
      :unix
    else
      :unknown
    end
  )
end

def kill_olds(pattern)
  IO.popen("ps ax | grep -E \"#{pattern}\" | grep -v grep | awk '{ print $1 }'") do |pipe|
    pipe.each do |pid|
      puts pid
      begin
        Process.kill(9, pid.to_i)
        puts "[Log] Killed process #{pid}"
      rescue => e
        puts "[Error] Failed to kill pid #{pid} with error #{e}"
        raise e
      end
    end
  end
end

def kill_old_play_processes(fname)
  command = play_command("", 0).split.first
  kill_olds("#{command}.+#{fname}")
end

def play_command(fpath, volume)
  case os
  when :mac
    # for mac
    return "afplay #{fpath} -t 100000 -v #{volume}"
  when :linux
    # for linux
    # volume size will be ignored
    return "mpg123 -q #{fpath} >/dev/null 2>&1"
  else
    puts "not-supported"
    exit 1
  end
end

def play(targets)
  path = "~/white-noise"
  targets.each do |target|
    fname = target[:fname]
    volume = target[:volume]
    kill_old_play_processes(fname)

    if volume == 0
      next
    end

    fpath = "#{path}/#{fname}"
    pid = spawn("while true; do sleep 0.1; #{play_command(fpath, volume)}; done")
    puts "[Log] Playing #{fpath}"
    Process.detach(pid)
  end
end

def gen_target(fname, vol)
  return {:fname => fname, :volume => vol}
end

if ARGV.length != 2
  puts "Usage: ruby script <volume> <type>"
  exit 1
end

vol = (ARGV[0] ? ARGV[0] : 1).to_f
targets = []

case ARGV[1]
when 'talk'
  targets.push(gen_target('nz_talk.mp3', vol * 0.4))
when 'cafe'
  targets.push(gen_target('nz_cafe.mp3', vol * 0.4))
when 'nami'
  targets.push(gen_target('nz_nami.mp3', vol * 0.4))
when 'seki'
  targets.push(gen_target('seki1.mp3', vol * 0.6))
  targets.push(gen_target('seki2.mp3', vol * 0.6))
  targets.push(gen_target('josei_seki1.mp3', vol * 1.0))
  targets.push(gen_target('josei_seki2.mp3', vol * 1.0))
when 'elec2'
  targets.push(gen_target('weskyrollin.mp3', vol * 1.0))
when 'noise'
  targets.push(gen_target('noise.mp3', vol))
end

play(targets)
