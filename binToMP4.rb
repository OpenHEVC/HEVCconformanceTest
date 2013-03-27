#!/usr/bin/ruby
###############################################################################
# getopts
###############################################################################
def getopts (argv)
  help() if argv.size != 2
  for i in (0..argv.size) do
    case argv[i]
    when "-h"         : help()
    when "-dir"       : $sourcePattern = argv[i+1]
    end
  end
end
###############################################################################
# help
###############################################################################
def help ()
  puts "======================================================================"
  puts "== binToMP options :                                                =="
  puts "==             -h         : help                                    =="
  puts "==             -dir       : pattern directory path                  =="
  puts "======================================================================"
  exit
end
###############################################################################
# getListFile
###############################################################################
def getListFile (subDir)
  pwd   = Dir.pwd
  Dir.chdir("#{$sourcePattern}/#{subDir}")
  list  = Dir.glob("*.bin")
  Dir.chdir(pwd)
  return list
end
###############################################################################
# createSubDir
###############################################################################
def createSubDir (subDir)
  pwd   = Dir.pwd
  Dir.chdir($sourcePattern)
  if not File.exists?("#{$sourcePattern}/MP4") then
    Dir.mkdir("#{$sourcePattern}/MP4")
  end
  if not File.exists?("#{$sourcePattern}/MP4/#{subDir}") then
    Dir.mkdir("#{$sourcePattern}/MP4/#{subDir}")
  end
  Dir.chdir(pwd)
end
###############################################################################
# getListFile
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
# getFrameRate
###############################################################################
def getFrameRate(binFile)
  from = /.*_.*_([0-9]*)_.*/
  return binFile.scan(from)
end
###############################################################################
# main
###############################################################################
def main (subDir, binFile , idxFile, nbFile, maxSize)
  createSubDir(subDir)
  pwd      = Dir.pwd
  Dir.chdir($sourcePattern)
  puts "= #{idxFile.to_s.rjust(nbFile.to_s.size)}/#{nbFile} = #{binFile.ljust(maxSize)} = #{getFrameRate(binFile)} fps"
  mp4File  = "#{File.basename(binFile, File.extname(binFile))}.mp4"
  cmd      ="MP4Box -new -fps #{getFrameRate(binFile)} -add #{$sourcePattern}/#{subDir}/#{binFile}:fmt=HEVC #{$sourcePattern}/MP4/#{subDir}/#{mp4File} 2> log"
  system(cmd)
  Dir.chdir(pwd)
end
###############################################################################
# main
###############################################################################
getopts(ARGV)
subDirTab = []
subDirTab << "i_main"
subDirTab << "ld_main"
subDirTab << "lp_main"
subDirTab << "ra_main"
subDirTab.each do |subDir|
  listFile = getListFile(subDir)
  maxSize  = getMaxSizeFileName(listFile)
  printSubDir(subDir, listFile.length, maxSize)
  listFile.each_with_index do |binFile,idxFile|
    main(subDir,binFile, idxFile+1, listFile.length, maxSize)
  end
end
