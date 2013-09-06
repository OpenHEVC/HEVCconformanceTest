#!/usr/bin/ruby
###############################################################################
# Constant
###############################################################################
OPEN_HEVC_IDX   = 1
AVCONV_IDX      = 2
###############################################################################
# Global
###############################################################################
#
$appli          = []
#
$appli[OPEN_HEVC_IDX]             = {}
$appli[OPEN_HEVC_IDX]["option"]   = "-i"
$appli[OPEN_HEVC_IDX]["output"]   = ""
$appli[OPEN_HEVC_IDX]["label"]    = "openHEVC"
#
#
$appli[AVCONV_IDX]                = {}
$appli[AVCONV_IDX]["option"]      = " -threads 1  -i"
$appli[AVCONV_IDX]["output"]      = "-f md5 -"
$appli[AVCONV_IDX]["label"]       = "avconv"
#

###############################################################################
# getopts
###############################################################################
def getopts (argv)
  help() if argv.size == 0
  $sourcePattern = nil
  $exec          = nil
  $stop          = true
  for i in (0..argv.size) do
    case argv[i]
    when "-h"         : help()
    when "-dir"       : $sourcePattern = argv[i+1]
    when "-exec"      : $exec          = argv[i+1]
    when "-noStop"    : $stop          = false
    end
  end
  help() if $sourcePattern == nil or $exec == nil
  $appliIdx = if /hevc/ =~ $exec then OPEN_HEVC_IDX else AVCONV_IDX end
end
###############################################################################
# help
###############################################################################
def help ()
  puts "======================================================================"
  puts "== runPattern options :                                             =="
  puts "==             -h         : help                                    =="
  puts "==             -list      : used internal list source pattern       =="
  puts "==             -dir       : pattern directory path                  =="
  puts "==             -exec      : exec path                               =="
  puts "==             -noStop    : not stop when diff is not ok            =="
  puts "======================================================================"
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
    Dir.chdir(pwd)
    return list.sort
  end
  return []
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
# check_error
###############################################################################
def check_error (md5)
  cmd  = "grep MD5 #{$appli[$appliIdx]["label"]}/#{md5}"
  ret  = IO.popen(cmd).readlines
  val1 = ret[ret.size-1].to_s.split('=')
  
  cmd  = "grep MD5 tests/#{md5}"
  ret  = IO.popen(cmd).readlines
  val2 = ret[ret.size-1].to_s.split('=')
  
  if val1[1] != val2[1] then
    puts " error ="
    exit if $stop == true
  else
    puts " ok    ="
  end
end
###############################################################################
# main
###############################################################################
def main (binFile, idxFile, nbFile, maxSize)
  print "= #{idxFile.to_s.rjust(nbFile.to_s.size)}/#{nbFile} = #{binFile.ljust(maxSize)}"
  cmd = "#{$exec} #{$appli[$appliIdx]["option"]} #{$sourcePattern}/#{binFile} #{$appli[$appliIdx]["output"]} 2> log > #{$appli[$appliIdx]["label"]}/#{File.basename(binFile, File.extname(binFile))}.md5"
  system(cmd)
  check_error("#{File.basename(binFile, File.extname(binFile))}.md5")
end
###############################################################################
# main
###############################################################################
getopts(ARGV)
if File.exist?($appli[$appliIdx]["label"]) then
    system("rm -r #{$appli[$appliIdx]["label"]}")
end
Dir.mkdir($appli[$appliIdx]["label"])

listFile = getListFile()
if listFile.length != 0 then
  maxSize = getMaxSizeFileName(listFile)
  listFile.each_with_index do |binFile,idxFile|
    main(binFile, idxFile+1, listFile.length, maxSize)
  end
end
