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
  $ThreadType    = 1
  for i in (0..argv.size) do
    case argv[i]
    when "-h"         : help();
    when "-dir"       : $sourcePattern = argv[i+1]
    when "-exec"      : $exec          = argv[i+1]
    when "-noStop"    : $stop          = false
    when "-noCheck"   : $check         = false
    when "-yuv"       : $yuv           = true
    when "-p"         : $nbThreads     = argv[i+1].to_i
    when "-f"         : $ThreadType    = argv[i+1].to_i
    end
  end
  help() if $sourcePattern == nil or $exec == nil
  $appliIdx = if /hevc/ =~ $exec then OPEN_HEVC_IDX 
	      elsif /TAppDecoder/ =~ $exec then HM_IDX
	      elsif /ffmpeg/ =~ $exec then FFMPEG_IDX
	      else AVCONV_IDX end

  if $appliIdx == OPEN_HEVC_IDX then
    $appli[$appliIdx]["option"] = "-p #{$nbThreads} -f #{$ThreadType} #{$appli[$appliIdx]["option"]}"
    if $check == false and $yuv == false then
      $appli[$appliIdx]["option"] = "-c #{$appli[$appliIdx]["option"]}"
    end
  elsif $appliIdx == AVCONV_IDX or  $appliIdx == FFMPEG_IDX  then
    if $ThreadType == 3 then
      $appli[$appliIdx]["option"] = "-threads #{$nbThreads} -thread_type \"frameslice\" -i"
    elsif $ThreadType == 2 then
      $appli[$appliIdx]["option"] = "-threads #{$nbThreads} -thread_type \"slice\" -i"
    else
      $appli[$appliIdx]["option"] = "-threads #{$nbThreads} -thread_type \"frame\" -i"
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
  puts "==             -f         : thread type (1:Frame, 2:Slice, 3:FrameSlice) =="
  puts "==========================================================================="
  exit
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
    list += Dir.glob("*.hvc")
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
# save_md5
###############################################################################
def save_md5(md5) 
  if $appliIdx == AVCONV_IDX or $appliIdx == FFMPEG_IDX then
    system("cp log #{$appli[$appliIdx]["label"]}/#{md5}")
  else
    ret     = IO.popen("wc -l log").readlines
    nbLine  = (ret[0].scan(/([0-9]*) */))[0][0].to_i
    if $appliIdx == HM_IDX then
      system("head -n #{nbLine - 2} log     > log_tmp")
      system("tail -n #{nbLine - 4} log_tmp > #{$appli[$appliIdx]["label"]}/#{md5}")
      File.delete("log_tmp")
    elsif $appliIdx == OPEN_HEVC_IDX then
      system("head -n #{nbLine - 1} log     > #{$appli[$appliIdx]["label"]}/#{md5}")
    end
  end
end
###############################################################################
# run
###############################################################################
def run (binFile, idxFile, nbFile, maxSize)
  print "= #{idxFile.to_s.rjust(nbFile.to_s.size)}/#{nbFile} = #{binFile.ljust(maxSize)}"

  yuv = "#{File.basename(binFile, File.extname(binFile))}.yuv"
  if $check == true and $yuv == true then 
    if $appliIdx ==  AVCONV_IDX then
      $appli[$appliIdx]["output"] = "-f md5 -"
    elsif $appliIdx ==  FFMPEG_IDX then
      $appli[$appliIdx]["output"] = "-vsync drop -f md5 -"
    else
      $appli[$appliIdx]["output"] = "-o #{yuv}"
    end
  end

  cmd = "#{$exec} #{$appli[$appliIdx]["option"]} #{$sourcePattern}/#{binFile} #{$appli[$appliIdx]["output"]} > log 2> error"
  timeStart = Time.now
  system(cmd)
  $runTime = Time.now - timeStart

  if $check == true then
    if $yuv == true then
      check_yuv(binFile)
    else
      check_error(binFile)
    end
  else
    check_perfs(binFile)
  end
  if $check == true and $yuv == true then
    if $appliIdx !=  AVCONV_IDX and $appliIdx !=  FFMPEG_IDX then
      File.delete(yuv)
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
  if listFile.length != 0 then
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
      run(binFile, idxFile+1, listFile.length, maxSize)
    end
  end
end
