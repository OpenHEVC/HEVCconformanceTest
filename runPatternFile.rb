#!/usr/bin/ruby
require "runPatternCommon.rb"
###############################################################################
# run
###############################################################################
def run (binFile , idxFile, nbFile, maxSize)
  print "= #{idxFile.to_s.rjust(nbFile.to_s.size)}/#{nbFile} = #{binFile.ljust(maxSize)}"
  cmd = "#{$exec} #{$appli[$appliIdx]["option"]} #{$sourcePattern}/#{binFile} #{$appli[$appliIdx]["output"]} > log 2> error"
  system(cmd)
  check_error("log", "error", binFile)
  File.delete("log")
  File.delete("error")
end
###############################################################################
# main
###############################################################################
main()
