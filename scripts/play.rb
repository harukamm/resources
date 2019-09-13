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

def play(fnames, volume)
  path = "~/white-noise"
  p volume
  fnames.each do |fname|
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

vol = (ARGV[0] ? ARGV[0] : 1).to_f
fnames = ["white-noise.mp3"]

case ARGV[1]
when "talk"
  fnames = ["nz_talk.mp3"]
when "cafe"
  fnames = ["nz_cafe.mp3"]
when "nami"
  fnames = ["nami.mp3"]
when "seki"
  fnames = ["seki1.mp3", "seki2.mp3"]
end

play(fnames, vol)
