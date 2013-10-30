#!/usr/bin/ruby
require "runPatternCommon.rb"
###############################################################################
# 
###############################################################################
exec      = []
exec[0]   = "#{ENV['HOME']}/07-Work/git/openHEVC/build/release/hevc"
exec[1]   = "#{ENV['HOME']}/07-Work/workspace/HEVC/HM-12.0-dev/bin/TAppDecoderStatic"
output    = []
output[0] = "openHEVC"
output[1] = "HM"
pattern   = "#{ENV['HOME']}/06-Videos/03-HEVC/HEVC_HM-11"

###############################################################################
# 
###############################################################################
if File.exist?("perf") then
  deleteDir("perf")
end
Dir.mkdir("perf")

["i_main", "ld_main", "lp_main", "ra_main"].each do |dir|
  for i in 0 .. 1 do
    cmd = "./runPattern.rb -exec #{exec[i]} -dir #{pattern}/#{dir} -noCheck > perf/#{output[i]}_#{dir}.txt"
    system(cmd)
  end
end
