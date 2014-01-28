#!/usr/bin/ruby
###############################################################################
# Check SHVC_DIR
###############################################################################
if (ENV['SHVC_DIR'] == nil)
  puts "SHVC_DIR is not defined"
  exit(0)
end
###############################################################################
# Global variable
###############################################################################
$exec = "#{ENV['SHVC_DIR']}/bin/TAppEncoderStatic"
###############################################################################
# sysIO
###############################################################################
def sysIO (cmd)
    sys = IO.popen(cmd)
    ret = sys.readlines
    sys.close_read
    return ret
end
###############################################################################
# help
###############################################################################
def help ()
  puts "==========================================================================="
  puts "== runPattern options :                                                  =="
  puts "==             -h         : help                                         =="
  puts "==             -idir      : YUV dir path                                 =="
  puts "==             -odir      : Output dir path                              =="
  puts "==             -name      : Video Name                                   =="
  puts "==             -mode      : ra, ld, lp, i                                =="
  puts "==             -ratio     : SNR, 1.5x, 2x                                =="
  puts "==             -wpp       : wpp enable                                   =="
  puts "==             -l         : Num of Layers                                =="
  puts "==========================================================================="
  exit
end
###############################################################################
# getopts
###############################################################################
def getopts (argv)
  help() if argv.size == 0
  $yuv_dir   = nil
  $out_dir   = nil
  $yuv_name  = nil
  $mode      = "ra"
  $ratio     = "SNR"
  $wpp       = false
  $numLayers = "1"
  for i in (0..argv.size) do
    case argv[i]
    when "-h"         : help()
    when "-idir"      : $yuv_dir   = argv[i+1]
    when "-odir"      : $out_dir   = argv[i+1]
    when "-name"      : $yuv_name  = argv[i+1]
    when "-mode"      : $mode      = argv[i+1]
    when "-ratio"     : $ratio     = argv[i+1]
    when "-wpp"       : $wpp       = true
    when "-l"         : $numLayers = argv[i+1]
    end
  end
  if $yuv_dir == nil or $out_dir == nil or $yuv_name == nil then
    help()
  end
end
###############################################################################
# setParam
###############################################################################
def setParam ()
  $encoder_cfg = "#{ENV['SHVC_DIR']}/cfg"
  case $mode
  when "ra" : $encoder_cfg = "#{$encoder_cfg}/encoder_randomaccess_main.cfg"
  when "lp" : $encoder_cfg = "#{$encoder_cfg}/encoder_lowdelay_P_main.cfg"
  when "ld" : $encoder_cfg = "#{$encoder_cfg}/encoder_lowdelay_main.cfg"
  when "i"  : $encoder_cfg = "#{$encoder_cfg}/encoder_intra_main.cfg"
  end

  $per_sequence_svc = "#{ENV['SHVC_DIR']}/cfg/per-sequence-svc/#{$yuv_name}-#{$ratio}.cfg"
  $suffix_i0 = ""
  if $ratio != "SNR" then
    $suffix_i0 = "_zerophase_0.9pi"
  end
  if $ratio == "SNR" then
    $QPBL = [26, 26, 30, 30, 34, 34, 38, 38]
    $QPEL = [20, 22, 24, 26, 28, 30, 32, 34]
  else
    $QPBL = [22, 22, 26, 26, 30, 30, 34, 34]
    $QPEL = [22, 24, 26, 28, 30, 32, 34, 36]
  end

  if !File.exists?($per_sequence_svc) then
    puts "File #{$per_sequence_svc} not exist"
    exit(0)
  end

  getSize()

  if !File.exists?($out_dir) then
      Dir.mkdir($out_dir)
  end
  if !File.exists?("#{$out_dir}/#{$mode}_main") then
      Dir.mkdir("#{$out_dir}/#{$mode}_main")
  end
  $out_dir = "#{$out_dir}/#{$mode}_main"
end
###############################################################################
# getSize
###############################################################################
def getSize ()
  cmd        = "grep SourceWidth0 #{$per_sequence_svc}"
  ret        = sysIO(cmd)
  $BLwidth   = ret[ret.size-1].scan(/SourceWidth0 *: ([0-9]*)/)[0][0]
  cmd        = "grep SourceHeight0 #{$per_sequence_svc}"
  ret        = sysIO(cmd)
  $BLheight  = ret[ret.size-1].scan(/SourceHeight0 *: ([0-9]*)/)[0][0]
  cmd        = "grep SourceWidth1 #{$per_sequence_svc}"
  ret        = sysIO(cmd)
  $width     = ret[ret.size-1].scan(/SourceWidth1 *: ([0-9]*)/)[0][0]
  cmd        = "grep SourceHeight1 #{$per_sequence_svc}"
  ret        = sysIO(cmd)
  $height    = ret[ret.size-1].scan(/SourceHeight1 *: ([0-9]*)/)[0][0]
  cmd        = "grep FrameRate0 #{$per_sequence_svc}"
  ret        = sysIO(cmd)
  $fps       = ret[ret.size-1].scan(/FrameRate0 *: ([0-9]*)/)[0][0]
end
###############################################################################
# main
###############################################################################
getopts(ARGV)
setParam()

for i in (0 ... $QPBL.size) do

  stream_out = "#{$out_dir}/#{$yuv_name}_#{$width}x#{$height}_#{$QPBL[i]}_#{$QPEL[i]}_#{$fps}_#{$ratio}"
  if $wpp then
    stream_out = "#{stream_out}_wpp.shvc"
  else
    stream_out = "#{stream_out}.shvc"
  end

  cmd = "#{$exec} -c #{$encoder_cfg} -c #{$per_sequence_svc} -b #{stream_out} -i0 #{$yuv_dir}/#{$yuv_name}/#{$yuv_name}_#{$BLwidth}x#{$BLheight}_#{$fps}#{$suffix_i0}.yuv -i1 #{$yuv_dir}/#{$yuv_name}/#{$yuv_name}_#{$width}x#{$height}_#{$fps}.yuv -q0 #{$QPBL[i]} -q1 #{$QPEL[i]} --NumLayers=#{$numLayers} --SEIDecodedPictureHash=1"
  if $wpp then
    cmd = "#{cmd} --WaveFrontSynchro=1"
  end
  puts cmd
  system(cmd)
  exit(0)
end
