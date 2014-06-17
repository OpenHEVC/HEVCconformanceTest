#!/usr/bin/ruby
require "./runPatternCommon.rb"
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
def check_yuv (binFile, idxFile, nbFile, maxSize)
  print "= #{(idxFile).to_s.rjust(nbFile.to_s.size)}/#{nbFile} = #{binFile.ljust(maxSize)}"
  return true if grep_msg("Segmentation fault", "error") == -1
  begin
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
    return false
  ensure
    return true
  end
end
###############################################################################
# check_error
###############################################################################
def check_error (binFile, idxFile, nbFile, maxSize)
  print "= #{(idxFile).to_s.rjust(nbFile.to_s.size)}/#{nbFile} = #{binFile.ljust(maxSize)}"
  return true if grep_msg("Segmentation fault", "error") == -1
  
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
  return false
end
###############################################################################
# check_perfs
###############################################################################
def check_perfs (binFile, idxFile, nbFile, maxSize)
  begin
    timeEND = 0
    if $appliIdx == OPEN_HEVC_IDX then
      cmd     = "grep frame log"
      ret     = sysIO(cmd)
      frame   = ret[0].scan(/.*frame= *([0-9]*)/)[0][0].to_i
      fps     = ret[0].scan(/.*fps= *([0-9]*)/)[0][0].to_i
      if ret[0] =~ /Times/ then
        timeEND = ret[0].scan(/.*time= *([0-9]*)/)[0][0]
        timeBL  = ret[0].scan(/.*Times ([0-9]*)  [0-9]*  [0-9]*/)[0][0]
        timeEL  = ret[0].scan(/.*Times [0-9]*  ([0-9]*)  [0-9]*/)[0][0]
        timeUP  = ret[0].scan(/.*Times [0-9]*  [0-9]*  ([0-9]*)/)[0][0]
        time    = "#{timeBL},#{timeEL},#{timeUP},#{timeEND}"
      else
        time = ret[0].scan(/.*time= *([0-9|\.]*)/)[0][0].to_f
      end
    elsif $appliIdx == HM_IDX then
      cmd     = "grep POC log"
      ret     = sysIO(cmd)
      frame   = ret.size
      fps     = (frame/$runTime).round
      time    = "#{format("%.2f", $runTime)}"
    else
      cmd     = "grep \"frame= \" error"
      ret     = sysIO(cmd)
      frame   = ret[0].scan(/.*frame= *([0-9]*)/)[0][0].to_i
      fps     = (frame/$runTime).round
      time    = "#{format("%.2f", $runTime)}"
    end

    csv_name = "#{$sourcePattern}/#{$appli[$appliIdx]["label"]}_l#{$layers}_f#{$threadType}_p#{$nbThreads}.csv"
    if idxFile == 1 then
      puts "Generate #{csv_name}"
      File.open(csv_name, "w") do |io|
        if timeEND != 0 then
          io.write("name,frame,fps,Time BL,Time EL,Time UP,Total Time\n")
        else
          io.write("name,frame,fps,Total Time\n")
        end
        io.close
      end
    end
    print "= #{(idxFile).to_s.rjust(nbFile.to_s.size)}/#{nbFile} = #{binFile.ljust(maxSize)}"
    puts " frame= #{frame} fps= #{fps} time= #{time}"
    File.open(csv_name, "a") do |io|
      io.write("#{binFile},#{frame},#{fps},#{time}\n")
      io.close
    end
    return false
  rescue
    return true
  end
end
###############################################################################
# main
###############################################################################
main()
