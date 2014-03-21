###############################################################################
# Constant
###############################################################################
OPEN_HEVC_IDX   = 1
AVCONV_IDX      = 2
HM_IDX          = 3
FFMPEG_IDX      = 4
###############################################################################
# Global
###############################################################################
#
$appli          = []
#
$appli[OPEN_HEVC_IDX]             = {}
$appli[OPEN_HEVC_IDX]["option"]   = "-n -i"
$appli[OPEN_HEVC_IDX]["output"]   = ""
$appli[OPEN_HEVC_IDX]["label"]    = "openHEVC"
#
#
$appli[AVCONV_IDX]                = {}
$appli[AVCONV_IDX]["option"]      = "-decode-checksum 1 -thread_type \"slice\" -i"
$appli[AVCONV_IDX]["output"]      = "-f null -"
$appli[AVCONV_IDX]["label"]       = "avconv"
#
$appli[HM_IDX]                    = {}
$appli[HM_IDX]["option"]          = "-b"
$appli[HM_IDX]["output"]          = ""
$appli[HM_IDX]["label"]           = "HM"
#
$appli[FFMPEG_IDX]                = {}
$appli[FFMPEG_IDX]["option"]      = "-decode-checksum 1 -thread_type \"slice\" -i"
$appli[FFMPEG_IDX]["output"]      = "-vsync drop -f null -"
$appli[FFMPEG_IDX]["label"]       = "ffmpeg"
#
###############################################################################
# getopts
###############################################################################
def getopts (argv)
  help() if argv.size == 0
  $sourcePattern = nil
  $exec          = nil
  $stop          = true
  $check         = true
  $yuv           = false
  $nbThreads     = 1
  $threadType    = 1
  $layers        = 0
  $b10           = false
  $idx           = 0
  for i in (0..argv.size) do
    case argv[i]
    when "-h"         then help();
    when "-dir"       then $sourcePattern = argv[i+1]
    when "-exec"      then $exec          = argv[i+1]
    when "-noStop"    then $stop          = false
    when "-noCheck"   then $check         = false
    when "-yuv"       then $yuv           = true
    when "-p"         then $nbThreads     = argv[i+1].to_i
    when "-f"         then $threadType    = argv[i+1].to_i
    when "-l"         then $layers        = argv[i+1].to_i
    when "-10b"       then $b10           = true
    when "-idx"       then $idx           = argv[i+1].to_i
    end
  end
  help() if $sourcePattern == nil or $exec == nil or ($threadType!=1 and $threadType!=2 and $threadType!=4) 
  $appliIdx = if /hevc/ =~ $exec then OPEN_HEVC_IDX 
              elsif /TAppDecoder/ =~ $exec then HM_IDX
              elsif /ffmpeg/ =~ $exec then FFMPEG_IDX
              else AVCONV_IDX end

  if $appliIdx == OPEN_HEVC_IDX then
    $appli[$appliIdx]["option"] = "-p #{$nbThreads} -f #{$threadType} -l #{$layers} #{$appli[$appliIdx]["option"]}"
    if $check == false or $yuv == true then
      $appli[$appliIdx]["option"] = "-c #{$appli[$appliIdx]["option"]}"
    end
  elsif $appliIdx == AVCONV_IDX or  $appliIdx == FFMPEG_IDX  then
    if $threadType == 1 then
      $appli[$appliIdx]["option"] = "-threads #{$nbThreads} -thread_type \"frame\" -i"
    elsif $threadType == 2 then
      $appli[$appliIdx]["option"] = "-threads #{$nbThreads} -thread_type \"slice\" -i"
    else
      $appli[$appliIdx]["option"] = "-threads #{$nbThreads} -thread_type \"frameslice\" -i"
    end
    if $check == true and $yuv == false then
      $appli[$appliIdx]["option"] = "-decode-checksum 1 #{$appli[$appliIdx]["option"]}"
    end
  end
end
###############################################################################
# help
###############################################################################
def help ()
  puts "==========================================================================="
  puts "== runPattern options :                                                  =="
  puts "==             -h         : help                                         =="
  puts "==             -dir       : pattern directory path                       =="
  puts "==             -exec      : exec path                                    =="
  puts "==             -noStop    : not stop when diff is not ok                 =="
  puts "==             -noCheck   : no check  md5                                =="
  puts "==             -yuv       : check yuv md5                                =="
  puts "==             -p         : nombre of threads for Slice                  =="
  puts "==             -f         : thread type (1:Frame, 2:Slice, 4:FrameSlice) =="
  puts "==             -l         : layers id to decode                          =="
  puts "==             -10b       : 10 bits filter                               =="
  puts "==             -idx       : test only idx source                         =="
  puts "==========================================================================="
  exit
end

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
# getListFile
###############################################################################
def getListFile ()
  if File.exists?($sourcePattern) then
    pwd   = Dir.pwd
    Dir.chdir($sourcePattern)
    list  = Dir.glob("*.bin")
    list += Dir.glob("*.bit")
    list += Dir.glob("*.265")
    list += Dir.glob("*.mp4")
    list += Dir.glob("*.hvc")
    list += Dir.glob("*.hevc")
    list += Dir.glob("*.shvc")
    Dir.chdir(pwd)
    return list.sort
  end
  return []
end
###############################################################################
# deleteDir
###############################################################################
def deleteDir (dir)
  pwd   = Dir.pwd
  Dir.chdir(dir)
  list  = Dir.glob("*")
  list.each do |file|
    File.delete(file)
  end
  Dir.chdir(pwd)
  Dir.delete(dir)
end
###############################################################################
# printLine
###############################################################################
def printLine(sizeOfLineAll)
  for i in 0 ... sizeOfLineAll-1 do print "=" end; puts "="
end
###############################################################################
# getMaxSizeFileName
###############################################################################
def getMaxSizeFileName (listFile)
  maxSize = 0
  listFile.each do |binFile|
    maxSize = binFile.size if binFile.size > maxSize
  end
  return maxSize
end
###############################################################################
# getFileNameYUV
###############################################################################
def getFileNameYUV (binFile)
  return "#{File.basename(binFile, File.extname(binFile))}" if !File.exists?("log")
  cmd     = "grep frame log"
  ret     = sysIO(cmd)
  size    = ret[ret.size-1].scan(/.*video_size= ([0-9]*x[0-9]*)/)[0][0]
  return "#{File.basename(binFile, File.extname(binFile))}_#{size}.yuv"
end
###############################################################################
# save_md5
###############################################################################
def save_md5(md5) 
  if $appliIdx == AVCONV_IDX or $appliIdx == FFMPEG_IDX then
    sysIO("cp log #{$appli[$appliIdx]["label"]}/#{md5}")
  else
    ret     = sysIO("wc -l log")
    nbLine  = (ret[0].scan(/([0-9]*) */))[0][0].to_i
    if $appliIdx == HM_IDX then
      sysIO("head -n #{nbLine - 2} log     > log_tmp")
      sysIO("tail -n #{nbLine - 4} log_tmp > #{$appli[$appliIdx]["label"]}/#{md5}")
      File.delete("log_tmp")
    elsif $appliIdx == OPEN_HEVC_IDX then
      sysIO("head -n #{nbLine - 1} log     > #{$appli[$appliIdx]["label"]}/#{md5}")
    end
  end
end
###############################################################################
# run
###############################################################################
def run (binFile, idxFile, nbFile, maxSize)
  File.delete("log")   if File.exists?("log")
  File.delete("error") if File.exists?("error")
  if $check == true and $yuv == true then 
    if $appliIdx ==  AVCONV_IDX then
      $appli[$appliIdx]["output"] = "-f md5 -"
    elsif $appliIdx ==  FFMPEG_IDX then
      $appli[$appliIdx]["output"] = "-vsync drop -f md5 -"
    else
      $appli[$appliIdx]["output"] = "-o #{getFileNameYUV(binFile)}"
    end
  end

  cmd = "#{$exec} #{$appli[$appliIdx]["option"]} #{$sourcePattern}/#{binFile} #{$appli[$appliIdx]["output"]} > log 2> error"
  #  puts cmd
  timeStart = Time.now
  sysIO(cmd)
  $runTime = Time.now - timeStart

  if $check == true then
    if $yuv == true then
      check_yuv(binFile, idxFile, nbFile, maxSize)
    else
      check_error(binFile, idxFile, nbFile, maxSize)
    end
  else
    check_perfs(binFile, idxFile, nbFile, maxSize)
  end
  if $check == true and $yuv == true then
    if $appliIdx !=  AVCONV_IDX and $appliIdx !=  FFMPEG_IDX then
      File.delete(getFileNameYUV(binFile))
    end
  end
  File.delete("log")
  File.delete("error")
end
###############################################################################
# main
###############################################################################
def main ()
  getopts(ARGV)
  if File.exist?($appli[$appliIdx]["label"]) then
    deleteDir($appli[$appliIdx]["label"])
  end
  Dir.mkdir($appli[$appliIdx]["label"])
  
  listFile = getListFile()
  nbFile = listFile.length
  if nbFile != 0 then
    maxSize  = getMaxSizeFileName(listFile)
    if $check == true and $yuv == true then 
      if $appliIdx ==  AVCONV_IDX then
        $appli[$appliIdx]["output"] = "-f md5 -"
      elsif $appliIdx ==  FFMPEG_IDX then
        $appli[$appliIdx]["output"] = "-vsync drop -f md5 -"
      else
        $appli[$appliIdx]["output"] = "-o yuv"
      end
    end
    
    cmd = "#{$exec} #{$appli[$appliIdx]["option"]} binFile #{$appli[$appliIdx]["output"]} > log 2> error"
    printLine(cmd.size)
    puts cmd
    printLine(cmd.size)
    listFile.each_with_index do |binFile,idxFile|
      if ($idx == 0 or $idx == idxFile+1) then
        if ($b10 == false or binFile =~ /.*MAIN10.*/ ) then
          run(binFile, idxFile+1, listFile.length, maxSize) 
        end
      elsif ($idx == 0) then
        if ($b10 == false or binFile =~ /.*MAIN10.*/ ) then
          print "= #{(idxFile+1).to_s.rjust(nbFile.to_s.size)}/#{nbFile} = #{binFile.ljust(maxSize)}"
          puts " skip  ="
        end
      end
    end
  end
end
