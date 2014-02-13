#!/usr/bin/ruby
require "runPatternCommon.rb"
###############################################################################
# grep_msg
###############################################################################
def grep_msg (msg, log)
  cmd = "grep \"#{msg}\" #{log}"
  ret = sysIO(cmd)
  if ret[0] != nil then
    puts " #{msg}"
    return -1
  end
  return 0
end
###############################################################################
# check_yuv
###############################################################################
def check_yuv (binFile)
  return if grep_msg("Segmentation fault", "error") == -1

  md5 = "#{File.basename(binFile, File.extname(binFile))}.md5"
  if $appliIdx == AVCONV_IDX or $appliIdx == FFMPEG_IDX then
    save_md5(md5)
    cmd  = "grep MD5 #{$appli[$appliIdx]["label"]}/#{md5}"
  else
    yuv = getFileNameYUV(binFile)
    cmd = "openssl md5 #{yuv}"
  end
  ret = sysIO(cmd)
  val1 = ret[ret.size-1].scan(/MD5.*= *(.*)/)[0][0]
  cmd  = "grep MD5 tests/#{md5}"
  ret = sysIO(cmd)
  val2 = ret[ret.size-1].scan(/MD5=(.*)/)[0][0]
  if val1 != val2 then
    puts " error ="
    exit if $stop == true
  else
    puts " ok    ="
  end
end
###############################################################################
# check_error
###############################################################################
def check_error (binFile)
  return if grep_msg("Segmentation fault", "error") == -1
  
  cmd = "grep \"Correct\" error"
  ret = sysIO(cmd)
  if ret[1] == nil and $appliIdx != HM_IDX then

    md5 = "#{File.basename(binFile, File.extname(binFile))}.md5"
    save_md5(md5)

    if File.exist?("#{$appli[HM_IDX]["label"]}/#{md5}") then
      cmd = "grep -v \"POC\" #{$appli[$appliIdx]["label"]}/#{md5} > #{$appli[$appliIdx]["label"]}_#{md5}"
      sysIO(cmd)
      cmd = "grep -v \"POC\" #{$appli[HM_IDX]["label"]}/#{md5} > #{$appli[HM_IDX]["label"]}_#{md5}"
      sysIO(cmd)
      cmd = "diff #{$appli[$appliIdx]["label"]}_#{md5} #{$appli[HM_IDX]["label"]}_#{md5}"
      ret = sysIO(cmd)
      File.delete("#{$appli[$appliIdx]["label"]}_#{md5}")
      File.delete("#{$appli[HM_IDX]["label"]}_#{md5}")
      if ret[1] != nil then
	puts " error ="
	exit if $stop == true
      else
	puts " ok    ="
      end
    else
      puts " ="
    end
    
  elsif $appliIdx != HM_IDX then
    
    cmd = "grep \"Incorrect\" error"
    ret = sysIO(cmd)
    if ret[1] != nil then
      puts " error ="
      exit if $stop == true
    else
      puts " ok    ="
    end
    
  else

    md5 = "#{File.basename(binFile, File.extname(binFile))}.md5"
    save_md5(md5)
    puts " ="
  
  end

end
###############################################################################
# check_perfs
###############################################################################
def check_perfs (binFile)
  if $appliIdx == OPEN_HEVC_IDX then
    cmd     = "grep frame log"
    ret     = sysIO(cmd)
    puts " #{ret}"
  elsif $appliIdx == HM_IDX then
    cmd     = "grep POC log"
    ret     = sysIO(cmd)
    puts sprintf(" frame= #{ret.size} fps= #{(ret.size/$runTime).round} time= %.2f", $runTime )
  else
    cmd     = "grep frame error"
    ret     = sysIO(cmd)
    val     = ret[0].scan(/.*frame= *([0-9]*)/)[0][0].to_i
    puts sprintf(" frame= #{val} fps= #{(val/$runTime).round} time= %.2f", $runTime )
  end
end
###############################################################################
# main
###############################################################################
main()
