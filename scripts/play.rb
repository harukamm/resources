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

def play(fname, volume)
  path = "~/white-noise"
  fpath = "#{path}/#{fname}"
  kill_olds("afplay.+#{fname}")
  if volume == 0
    return
  end
  pid = spawn("while true; do sleep 0.1; afplay #{fpath} -t 100000 -v #{volume}; done")
  puts "[Log] Playing #{fpath}"
  Process.detach(pid)
end

vol = (ARGV[0] ? ARGV[0] : 1).to_f
fname = "white-noise.mp3"

case ARGV[1]
when "talk"
  fname = "nz_talk.mp3"
when "cafe"
  fname = "nz_cafe.mp3"
when "nami"
  fname = "nami.mp3"
when "seki"
  fname = "seki.mp3"
end

play(fname, vol)
