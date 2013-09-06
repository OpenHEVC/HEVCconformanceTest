#!/usr/bin/ruby
###############################################################################
# Constant
###############################################################################
OPEN_HEVC_IDX   = 1

###############################################################################
# Global
###############################################################################
#
$appli          = []
#
$appli[OPEN_HEVC_IDX]             = {}
$appli[OPEN_HEVC_IDX]["option"]   = "-c -p 4 -n -i"
$appli[OPEN_HEVC_IDX]["output"]   = "log"
$appli[OPEN_HEVC_IDX]["label"]    = "openHEVC"
#

###############################################################################
# getopts
###############################################################################
def getopts (argv)
  help() if argv.size == 0
  $sourcePattern = nil
  $exec          = nil
  for i in (0..argv.size) do
    case argv[i]
    when "-h"         : help()
    when "-dir"       : $sourcePattern = argv[i+1]
    when "-exec"      : $exec          = argv[i+1]
    end
  end
  help() if $sourcePattern == nil or $exec == nil
  $appliIdx = OPEN_HEVC_IDX
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
# getInfo
###############################################################################
def getInfo ()
  # getTime
  cmd     = "grep frame #{$appli[$appliIdx]["output"]}"
  ret     = IO.popen(cmd).readlines
  return ret
end
###############################################################################
# main
###############################################################################
def main (binFile, idxFile, nbFile, maxSize)
  print "= #{idxFile.to_s.rjust(nbFile.to_s.size)}/#{nbFile} = #{binFile.ljust(maxSize)}"
  cmd = "#{$exec} #{$appli[$appliIdx]["option"]} #{$sourcePattern}/#{binFile} > #{$appli[$appliIdx]["output"]}"
  system(cmd)
  puts " #{getInfo()}"
end
###############################################################################
# main
###############################################################################
getopts(ARGV)

listFile = getListFile()
if listFile.length != 0 then
  maxSize = getMaxSizeFileName(listFile)
  listFile.each_with_index do |binFile,idxFile|
    main(binFile, idxFile+1, listFile.length, maxSize)
  end
end
