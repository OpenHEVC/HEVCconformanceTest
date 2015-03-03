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
  $numLayers = 1
  for i in (0..argv.size) do
    case argv[i]
    when "-h"         then help()
    when "-idir"      then $yuv_dir   = argv[i+1]
    when "-odir"      then $out_dir   = argv[i+1]
    when "-name"      then $yuv_name  = argv[i+1]
    when "-mode"      then $mode      = argv[i+1]
    when "-ratio"     then $ratio     = argv[i+1]
    when "-wpp"       then $wpp       = true
    when "-l"         then $numLayers = argv[i+1].to_i
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
  when "ra" then $encoder_cfg = "#{$encoder_cfg}/encoder_randomaccess_main.cfg"
  when "lp" then $encoder_cfg = "#{$encoder_cfg}/encoder_lowdelay_P_main.cfg"
  when "ld" then $encoder_cfg = "#{$encoder_cfg}/encoder_lowdelay_main.cfg"
  when "i"  then $encoder_cfg = "#{$encoder_cfg}/encoder_intra_main.cfg"
  end

  $per_sequence_svc = "#{ENV['SHVC_DIR']}/cfg/per-sequence-svc/#{$yuv_name}-#{$ratio}.cfg"
  $per_layer = "#{ENV['SHVC_DIR']}/cfg/layers.cfg"
  $suffix_i0 = ""
  if $ratio != "SNR" then
    $suffix_i0 = "_zerophase_0.9pi"
  end
    
  if $numLayers == 1 then # single layer configuration
    $QPEL = [20, 22, 24, 26, 28, 30, 32, 34, 38]
  else # multiple-layer configuration
      if $ratio == "SNR" then
          $QPBL = [26, 26, 30, 30, 34, 34, 38, 38]
          $QPEL = [20, 22, 24, 26, 28, 30, 32, 34]
      else
          $QPBL = [22, 22, 26, 26, 30, 30, 34, 34]
          $QPEL = [22, 24, 26, 28, 30, 32, 34, 36]
      end
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
# getOutputLog
###############################################################################
def getOutputLog ()
  $outputLog = "#{$out_dir}/#{$yuv_name}"
  if $numLayers != 1 then
    $outputLog = "#{$outputLog}_#{$ratio}"
  end
  $outputLog = "#{$outputLog}_#{$mode}"
  if $wpp then
    $outputLog = "#{$outputLog}_wpp"
  end
  $outputLog = "#{$outputLog}.txt"
  if $numLayers != 1 then
    sysIO("echo \"QPBL\tQPEL\tBitrate\tPSNRY\tPSNRU\tPSNRV\tBitrate\tPSNRY\tPSNRU\tPSNRV\" >> #{$outputLog}")
  else
    sysIO("echo \"QPEL\tBitrate\tPSNRY\tPSNRU\tPSNRV\" >> #{$outputLog}")
  end
end
###############################################################################
# getOutputStream
###############################################################################
def getOutputStream (i)
  out = "#{$out_dir}/#{$yuv_name}_#{$width}x#{$height}"
  if $numLayers != 1 then
    out = "#{out}_#{$QPBL[i]}_#{$QPEL[i]}_#{$ratio}"
  else
    out = "#{out}_#{$QPEL[i]}"
  end
  out = "#{out}_#{$fps}"
  if $wpp then
    out = "#{out}_wpp.shvc"
  else
    out = "#{out}.shvc"
  end
  return out
end
###############################################################################
# getEncoderCmd
###############################################################################
def getEncoderCmd (stream_out, i)
    name_i0 = "#{$yuv_dir}/#{$yuv_name}/#{$yuv_name}_#{$BLwidth}x#{$BLheight}_#{$fps}#{$suffix_i0}.yuv"
    name_i1 = "#{$yuv_dir}/#{$yuv_name}/#{$yuv_name}_#{$width}x#{$height}_#{$fps}.yuv"
    if $numLayers != 1 then
        cmd = "#{$exec} -c #{$encoder_cfg} -c #{$per_sequence_svc} -c #{$per_layer} -b #{stream_out} -i0 #{name_i0} -i1 #{name_i1}"
        cmd = "#{cmd} -q0 #{$QPBL[i]} -q1 #{$QPEL[i]} --NumLayers=#{$numLayers}"
        else
		cmd = "#{$exec} -c #{$encoder_cfg} -c #{$per_sequence_svc}  -b #{stream_out} -i0 #{name_i1} -wdt0 #{$width} -hgt0 #{$height}"
        cmd = "#{cmd} -q0 #{$QPEL[i]} -q1 #{$QPEL[i]}"
    end
    cmd = "#{cmd} --SEIDecodedPictureHash=1"
    if $wpp then
      cmd = "#{cmd} --WaveFrontSynchro0=1 --WaveFrontSynchro1=1"
    end
    cmd = "#{cmd} > #{$outputLog}.log"
  return cmd
end
###############################################################################
# parserResult
###############################################################################
def parserResult (i)
  cmd     = "grep -n SUMMARY #{$outputLog}.log"
  ret     = sysIO(cmd)
  numLine = ret[ret.size-1].scan(/([0-9]*):.*/)[0][0].to_i
  cmd     = "head -n #{numLine+3} #{$outputLog}.log | tail -n 4 > #{$outputLog}.sum"
  ret     = sysIO(cmd)

  cmd     = "grep  L0 #{$outputLog}.sum"
  ret     = sysIO(cmd)
  l0      = ret[ret.size-1].scan(/[\t| ]*L0[\t| ]*[0-9]*[\t| ]*a[\t| ]*([0-9|\.]*)[\t| ]*([0-9|\.]*)[\t| ]*([0-9|\.]*)[\t| ]*([0-9|\.]*)/)[0]

  if $numLayers != 1 then
    cmd   = "grep  L1 #{$outputLog}.sum"
    ret   = sysIO(cmd)
    l1    = ret[ret.size-1].scan(/[\t| ]*L1[\t| ]*[0-9]*[\t| ]*a[\t| ]*([0-9|\.]*)[\t| ]*([0-9|\.]*)[\t| ]*([0-9|\.]*)[\t| ]*([0-9|\.]*)/)[0]
    line  = "#{$QPBL[i]}\t#{$QPEL[i]}\t#{l0[0]}\t#{l0[1]}\t#{l0[2]}\t#{l0[3]}\t#{l1[0]}\t#{l1[1]}\t#{l1[2]}\t#{l1[3]}"
  else
    line  = "#{$QPEL[i]}\t#{l0[0]}\t#{l0[1]}\t#{l0[2]}\t#{l0[3]}"
  end
  sysIO("echo \"#{line}\" >> #{$outputLog}")
  File.delete("#{$outputLog}.log")
  File.delete("#{$outputLog}.sum")
end
###############################################################################
# main
###############################################################################
getopts(ARGV)
setParam()
getOutputLog()
for i in (0 ... $QPEL.size) do
  stream_out = getOutputStream(i)
  puts stream_out
  if !File.exists?(stream_out) then
    cmd = getEncoderCmd(stream_out, i)
      #       puts cmd
    sysIO(cmd)
    parserResult(i)
  end
end

