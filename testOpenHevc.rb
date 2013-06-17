#!/usr/bin/ruby
###############################################################################
# Constant
###############################################################################
HEVC_VERSION    = "HEVC_HM-10"
WORK_DIR        = "#{ENV['HOME']}/07-Work"
SOURCE_PATTERN  = "#{ENV['HOME']}/06-Videos/03-HEVC/#{HEVC_VERSION}"
###############################################################################
# Global
###############################################################################
$appli             = {}
$appli["dir"]      = "#{WORK_DIR}/git/openHEVC"
$appli["build"]    = "#{$appli["dir"]}/build/"
$appli["exe"]      = "./build/hevc"
$appli["option"]   = "-n -c -p 2 -i"
$appli["outFile"]  = "TraceDec.txt"
$appli["label"]    = "openHEVC"
###############################################################################
# mySystem
###############################################################################
def mySystem (cmd)
#  puts cmd
  system(cmd)
end
###############################################################################
# getListFile
###############################################################################
def getListFile (subDir)
  pwd   = Dir.pwd
  Dir.chdir("#{SOURCE_PATTERN}/#{subDir}")
  list  = Dir.glob("*.bin")
  Dir.chdir(pwd)
  return list.sort
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
  for i in 0 ... sizeOfLineAll-1 do print "#" end; puts "#"
end
###############################################################################
# printSubDir
###############################################################################
def printSubDir(subDir, nbFile, maxSize)
  sizeOfLine    = nbFile.to_s.size + 1
  sizeOfLineAll = sizeOfLine + 1 + maxSize
  printLine(sizeOfLineAll)
  for i in 0 ... sizeOfLine do print "#" end
  print "#{subDir.center(sizeOfLineAll-2*sizeOfLine)}"
  for i in 0 ... sizeOfLine-1 do print "#" end; puts "#"
  printLine(sizeOfLineAll)
end
###############################################################################
# getTime
###############################################################################
def getTime ()
  pwd     = Dir.pwd
  Dir.chdir($appli["dir"])
  # getTime
  cmd     = "grep time #{$appli["outFile"]}"
  ret     = IO.popen(cmd).readlines
  from    = /time : ([0-9]*) ms/
  time    = (ret[0].scan(from))[0][0].to_i
  Dir.chdir(pwd)
  return 1.0*time / 1000.0
end
###############################################################################
# getNbFrame
###############################################################################
def getNbFrame ()
  pwd     = Dir.pwd
  Dir.chdir($appli["dir"])
  cmd     = "grep nbFrame #{$appli["outFile"]}"
  ret     = IO.popen(cmd).readlines
  from    = /nbFrame : ([0-9]*)/
  Dir.chdir(pwd)
  return (ret[0].scan(from))[0][0].to_i
end
###############################################################################
# getFget_qPy_pred(s,x0,y0);//rameRate
###############################################################################
def getFrameRate ()
  time    = getTime()
  nbFrame = getNbFrame()
  return "#{(nbFrame / time).to_i} fps"
end
###############################################################################
# getBitRateAppli
###############################################################################
def getBitRateAppli ( binFile )
  time    = getTime()
  size    = File.size(binFile)
  return "#{(size*8 / time).to_i/1024} kbps"
end
###############################################################################
# getBitRateFile
###############################################################################
def getBitRateFile ( binFile )
  from      = /.*_.*_([0-9]*)_.*/
  frameRate = (File.basename(binFile).scan(from))[0][0].to_i
  nbFrame   = getNbFrame()
  time      = nbFrame / frameRate
  size      = File.size(binFile)
  return "#{(size*8 / time).to_i/1024} kbps"
end
###############################################################################
# runAppli
###############################################################################
def runAppli ( binFile )
  pwd = Dir.pwd
  Dir.chdir($appli["dir"])
  if File.exists?($appli["outFile"]) then
    cmd = "rm #{$appli["outFile"]}"
    mySystem(cmd)
  end
  cmd = "#{$appli["exe"]} #{$appli["option"]} #{binFile} > #{$appli["outFile"]}"
  mySystem(cmd)
  Dir.chdir(pwd)
end
###############################################################################
# main
###############################################################################
def main (subDir, binFile , maxSize)
  print binFile.ljust(maxSize)
  runAppli("#{SOURCE_PATTERN}/#{subDir}/#{binFile}")
  frameRate    = getFrameRate()
  bitRateAppli = getBitRateAppli("#{SOURCE_PATTERN}/#{subDir}/#{binFile}")
  bitRateFile  = getBitRateFile("#{SOURCE_PATTERN}/#{subDir}/#{binFile}")
  puts "\t\t#{getNbFrame()} Frame\t#{frameRate.rjust(7)}\t\t#{bitRateAppli.rjust(11)}\t#{bitRateFile.rjust(11)}"
end
###############################################################################
# main
###############################################################################
subDirTab = []
#subDirTab << "i_main"
subDirTab << "ld_main"
subDirTab << "lp_main"
subDirTab << "ra_main"
subDirTab << "i_main"
subDirTab.each do |subDir|
  listFile = getListFile(subDir)
  maxSize  = getMaxSizeFileName(listFile)
  printSubDir(subDir, listFile.length, maxSize)
  listFile.each do |binFile|
    main(subDir, binFile, maxSize)
  end
end
