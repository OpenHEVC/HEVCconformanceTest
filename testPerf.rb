#!/usr/bin/ruby
require "runPatternCommon.rb"
###############################################################################
# Global
###############################################################################
#
$appli[OPEN_HEVC_IDX]             = {}
$appli[OPEN_HEVC_IDX]["option"]   = "-c -n -i"
$appli[OPEN_HEVC_IDX]["output"]   = ""
$appli[OPEN_HEVC_IDX]["label"]    = "openHEVC_perf"
#
$appli[HM_IDX]                    = {}
$appli[HM_IDX]["option"]          = "-b"
$appli[HM_IDX]["output"]          = ""
$appli[HM_IDX]["label"]           = "HM_perf"

###############################################################################
# check_error
###############################################################################
def check_error (binFile)
  if $appliIdx == OPEN_HEVC_IDX then
    cmd     = "grep frame log"
    ret     = IO.popen(cmd).readlines
    puts " #{ret}"
  else
    cmd     = "grep POC log"
    ret     = IO.popen(cmd).readlines
    puts sprintf(" frame= #{ret.size} fps= #{(ret.size/$runTime).round} time=%.2f", $runTime )
  end
end
###############################################################################
# main
###############################################################################
main()
