#!/usr/bin/ruby
require "runPatternCommon.rb"
###############################################################################
# Global
###############################################################################
$appli[AVCONV_IDX]                = {}
$appli[AVCONV_IDX]["option"]      = "-threads 4 -thread_type \"slice\" -i"
$appli[AVCONV_IDX]["output"]      = "-f md5 -"
$appli[AVCONV_IDX]["label"]       = "avconv"
###############################################################################
# check_error
###############################################################################
def check_error (binFile)

  md5 = "#{File.basename(binFile, File.extname(binFile))}.md5"
  save_md5(md5)

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
main()
