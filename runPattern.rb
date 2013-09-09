#!/usr/bin/ruby
require "runPatternCommon.rb"
###############################################################################
# check_error
###############################################################################
def check_error (binFile)
  cmd = "grep \"Correct\" error"
  ret = IO.popen(cmd).readlines
  if ret[1] == nil and $appliIdx != HM_IDX then

    md5 = "#{File.basename(binFile, File.extname(binFile))}.md5"
    save_md5(md5)

    if File.exist?("#{$appli[HM_IDX]["label"]}/#{md5}") then
      cmd = "grep -v \"POC\" #{$appli[$appliIdx]["label"]}/#{md5} > #{$appli[$appliIdx]["label"]}_#{md5}"
      system(cmd)
      cmd = "grep -v \"POC\" #{$appli[HM_IDX]["label"]}/#{md5} > #{$appli[HM_IDX]["label"]}_#{md5}"
      system(cmd)
      cmd = "diff #{$appli[$appliIdx]["label"]}_#{md5} #{$appli[HM_IDX]["label"]}_#{md5}"
      ret = IO.popen(cmd).readlines
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
    ret = IO.popen(cmd).readlines
    if ret[1] != nil then
      puts " error ="
      exit if $stop == true
    else
      puts " ok    ="
    end
    
  else
  
    puts " ="
  
  end

end
###############################################################################
# main
###############################################################################
main()
