#!/usr/bin/ruby
###############################################################################
# Constant
###############################################################################
OPEN_HEVC_IDX   = 1
AVCONV_IDX      = 2
HM_IDX      = 3
###############################################################################
# Global
###############################################################################
#
$appli          = []
#
$appli[OPEN_HEVC_IDX]             = {}
$appli[OPEN_HEVC_IDX]["option"]   = " -i"
$appli[OPEN_HEVC_IDX]["output"]   = ""
$appli[OPEN_HEVC_IDX]["label"]    = "openHEVC"
#
#
$appli[AVCONV_IDX]                = {}
$appli[AVCONV_IDX]["option"]      = "-decode-checksum 1 -i"
$appli[AVCONV_IDX]["output"]      = "-f null -"
$appli[AVCONV_IDX]["label"]       = "avconv"
#
$appli[HM_IDX]                = {}
$appli[HM_IDX]["option"]      = "-b"
$appli[HM_IDX]["output"]      = ""
$appli[HM_IDX]["label"]       = "HM"
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
    when "-h"         : help();
    when "-dir"       : $sourcePattern = argv[i+1]
    when "-exec"      : $exec          = argv[i+1]
    when "-noStop"    : $stop          = false
    end
  end
  help() if $sourcePattern == nil or $exec == nil
  $appliIdx = if /hevc/ =~ $exec then OPEN_HEVC_IDX elsif /TAppDecoder/ =~ $exec then HM_IDX else AVCONV_IDX end
end
###############################################################################
# help
###############################################################################
def help ()
  puts "======================================================================"
  puts "== runPattern options :                                             =="
  puts "==             -h         : help                                    =="
  puts "==             -dir       : pattern directory path                  =="
  puts "==             -exec      : exec path                               =="
  puts "==             -noStop    : not stop when diff is not ok            =="
  puts "======================================================================"
  exit
end
###############################################################################
# getListFile
###############################################################################
def getListFile (subDir)
  pwd   = Dir.pwd
  if File.exists?("#{$sourcePattern}/#{subDir}") then
    Dir.chdir("#{$sourcePattern}/#{subDir}")
    list  = Dir.glob("*.bin")
    list += Dir.glob("*.bit")
    Dir.chdir(pwd)
    return list
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
# printLine
###############################################################################
def printLine(sizeOfLineAll)
  for i in 0 ... sizeOfLineAll-1 do print "=" end; puts "="
end
###############################################################################
# printSubDir
###############################################################################
def printSubDir(subDir, nbFile, maxSize)
  sizeOfLine    = "= ".size + nbFile.to_s.size*2 + 1 + " =".size
  sizeOfLineAll = sizeOfLine + 1 + maxSize + "      ok =".size
  printLine(sizeOfLineAll)
  for i in 0 ... sizeOfLine do print "=" end
  print "#{subDir.center(sizeOfLineAll-2*sizeOfLine)}"
  for i in 0 ... sizeOfLine-1 do print "=" end; puts "="
  printLine(sizeOfLineAll)
end
###############################################################################
# main
###############################################################################
def main (subDir, binFile , idxFile, nbFile, maxSize)
  puts "= #{idxFile.to_s.rjust(nbFile.to_s.size)}/#{nbFile} = #{binFile.ljust(maxSize)}"
  cmd = "#{$exec} #{$appli[$appliIdx]["option"]} #{$sourcePattern}/#{subDir}/#{binFile} #{$appli[$appliIdx]["output"]} > #{$appli[$appliIdx]["label"]}/log_#{File.basename(binFile)}"
  system(cmd)
end
###############################################################################
# main
###############################################################################
getopts(ARGV)
if !File.exist?($appli[$appliIdx]["label"]) then
  Dir.mkdir($appli[$appliIdx]["label"])
end

subDirTab = []
subDirTab << "."
subDirTab << "i_main"
subDirTab << "ld_main"
subDirTab << "lp_main"
subDirTab << "ra_main"
subDirTab.each do |subDir|
  listFile = getListFile(subDir)
  if listFile.length != 0 then
    maxSize  = getMaxSizeFileName(listFile)
    printSubDir(subDir, listFile.length, maxSize)
    listFile.each_with_index do |binFile,idxFile|
      main(subDir,binFile, idxFile+1, listFile.length, maxSize)
    end
  end
end
