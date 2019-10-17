#!/usr/bin/ruby

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

def play(targets)
  path = "~/white-noise"
  targets.each do |target|
    fname = target[:fname]
    volume = target[:volume]
    fpath = "#{path}/#{fname}"
    kill_olds("afplay.+#{fname}")
    if volume == 0
      next
    end
    pid = spawn("while true; do sleep 0.1; afplay #{fpath} -t 100000 -v #{volume}; done")
    puts "[Log] Playing #{fpath}"
    Process.detach(pid)
  end
end

def gen_target(fname, vol)
  return {:fname => fname, :volume => vol}
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
end

play(targets)
