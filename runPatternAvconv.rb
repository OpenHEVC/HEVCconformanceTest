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
$sourceList = {}
#=========================================================================
#=========                        i_main                         =========
#=========================================================================
$sourceList["i_main"] = [
  "BlowingBubbles_416x240_50_qp37.bin",
  "BasketballDrive_1920x1080_50_qp37.bin",
  "Traffic_2560x1600_30_crop_qp37.bin",
  "FourPeople_1280x720_60_qp22.bin",
  "SlideEditing_1280x720_30_qp32.bin",
  "ParkScene_1920x1080_24_qp37.bin",
  "Cactus_1920x1080_50_qp22.bin",
  "FourPeople_1280x720_60_qp32.bin",
  "SlideShow_1280x720_20_qp37.bin",
  "Johnny_1280x720_60_qp27.bin",
  "SlideEditing_1280x720_30_qp37.bin",
  "BQSquare_416x240_60_qp37.bin",
  "BQMall_832x480_60_qp37.bin",
  "BQTerrace_1920x1080_60_qp32.bin",
  "ChinaSpeed_1024x768_30_qp22.bin",
  "RaceHorses_416x240_30_qp37.bin",
  "BQMall_832x480_60_qp27.bin",
  "BasketballDrive_1920x1080_50_qp27.bin",
  "NebutaFestival_2560x1600_60_10bit_crop_qp32.bin",
  "BQSquare_416x240_60_qp22.bin",
  "BQTerrace_1920x1080_60_qp37.bin",
  "BasketballDrillText_832x480_50_qp22.bin",
  "Johnny_1280x720_60_qp32.bin",
  "RaceHorses_416x240_30_qp22.bin",
  "Kimono1_1920x1080_24_qp27.bin",
  "PartyScene_832x480_50_qp22.bin",
  "SlideShow_1280x720_20_qp22.bin",
  "BQSquare_416x240_60_qp27.bin",
  "Cactus_1920x1080_50_qp32.bin",
  "PeopleOnStreet_2560x1600_30_crop_qp22.bin",
  "ParkScene_1920x1080_24_qp22.bin",
  "Kimono1_1920x1080_24_qp32.bin",
  "RaceHorses_416x240_30_qp27.bin",
  "KristenAndSara_1280x720_60_qp37.bin",
  "BasketballPass_416x240_50_qp27.bin",
  "BlowingBubbles_416x240_50_qp22.bin",
  "ParkScene_1920x1080_24_qp27.bin",
  "NebutaFestival_2560x1600_60_10bit_crop_qp37.bin",
  "BasketballDrillText_832x480_50_qp27.bin",
  "RaceHorses_832x480_30_qp37.bin",
  "SteamLocomotiveTrain_2560x1600_60_10bit_crop_qp22.bin",
  "BasketballPass_416x240_50_qp37.bin",
  "BasketballDrill_832x480_50_qp37.bin",
  "BasketballDrillText_832x480_50_qp32.bin",
  "RaceHorses_832x480_30_qp22.bin",
  "SlideShow_1280x720_20_qp32.bin",
  "Kimono1_1920x1080_24_qp37.bin",
  "SlideEditing_1280x720_30_qp27.bin",
  "PartyScene_832x480_50_qp32.bin",
  "BasketballPass_416x240_50_qp32.bin",
  "BQMall_832x480_60_qp22.bin",
  "BQSquare_416x240_60_qp32.bin",
  "BlowingBubbles_416x240_50_qp27.bin",
  "Johnny_1280x720_60_qp37.bin",
  "SlideShow_1280x720_20_qp27.bin",
  "Traffic_2560x1600_30_crop_qp27.bin",
  "PartyScene_832x480_50_qp37.bin",
  "RaceHorses_832x480_30_qp27.bin",
  "BasketballDrive_1920x1080_50_qp22.bin",
  "SteamLocomotiveTrain_2560x1600_60_10bit_crop_qp32.bin",
  "Traffic_2560x1600_30_crop_qp32.bin",
  "KristenAndSara_1280x720_60_qp22.bin",
  "PeopleOnStreet_2560x1600_30_crop_qp37.bin",
  "FourPeople_1280x720_60_qp27.bin",
  "SlideEditing_1280x720_30_qp22.bin",
  "RaceHorses_416x240_30_qp32.bin",
  "ChinaSpeed_1024x768_30_qp32.bin",
  "BQTerrace_1920x1080_60_qp27.bin",
  "KristenAndSara_1280x720_60_qp32.bin",
  "NebutaFestival_2560x1600_60_10bit_crop_qp22.bin",
  "PeopleOnStreet_2560x1600_30_crop_qp32.bin",
  "BasketballPass_416x240_50_qp22.bin",
  "BlowingBubbles_416x240_50_qp32.bin",
  "BasketballDrill_832x480_50_qp27.bin",
  "BQMall_832x480_60_qp32.bin",
  "SteamLocomotiveTrain_2560x1600_60_10bit_crop_qp37.bin",
  "BasketballDrillText_832x480_50_qp37.bin",
  "FourPeople_1280x720_60_qp37.bin",
  "BasketballDrill_832x480_50_qp22.bin",
  "BQTerrace_1920x1080_60_qp22.bin",
  "Traffic_2560x1600_30_crop_qp22.bin",
  "KristenAndSara_1280x720_60_qp27.bin",
  "SteamLocomotiveTrain_2560x1600_60_10bit_crop_qp27.bin",
  "ParkScene_1920x1080_24_qp32.bin",
  "PartyScene_832x480_50_qp27.bin",
  "NebutaFestival_2560x1600_60_10bit_crop_qp27.bin",
  "BasketballDrill_832x480_50_qp32.bin",
  "Cactus_1920x1080_50_qp37.bin",
  "ChinaSpeed_1024x768_30_qp37.bin",
  "ChinaSpeed_1024x768_30_qp27.bin",
  "BasketballDrive_1920x1080_50_qp32.bin",
  "Cactus_1920x1080_50_qp27.bin",
  "PeopleOnStreet_2560x1600_30_crop_qp27.bin",
  "RaceHorses_832x480_30_qp32.bin",
  "Kimono1_1920x1080_24_qp22.bin",
  "Johnny_1280x720_60_qp22.bin"]
#=========================================================================
#=========                        ld_main                        =========
#=========================================================================
$sourceList["ld_main"] = [
  "BlowingBubbles_416x240_50_qp37.bin",
  "BasketballDrive_1920x1080_50_qp37.bin",
  "Traffic_2560x1600_30_crop_qp37.bin",
  "FourPeople_1280x720_60_qp22.bin",
  "SlideEditing_1280x720_30_qp32.bin",
  "ParkScene_1920x1080_24_qp37.bin",
  "Cactus_1920x1080_50_qp22.bin",
  "FourPeople_1280x720_60_qp32.bin",
  "SlideShow_1280x720_20_qp37.bin",
  "Johnny_1280x720_60_qp27.bin",
  "SlideEditing_1280x720_30_qp37.bin",
  "BQSquare_416x240_60_qp37.bin",
  "BQMall_832x480_60_qp37.bin",
  "BQTerrace_1920x1080_60_qp32.bin",
  "ChinaSpeed_1024x768_30_qp22.bin",
  "RaceHorses_416x240_30_qp37.bin",
  "BQMall_832x480_60_qp27.bin",
  "BasketballDrive_1920x1080_50_qp27.bin",
  "NebutaFestival_2560x1600_60_10bit_crop_qp32.bin",
  "BQSquare_416x240_60_qp22.bin",
  "BQTerrace_1920x1080_60_qp37.bin",
  "BasketballDrillText_832x480_50_qp22.bin",
  "Johnny_1280x720_60_qp32.bin",
  "RaceHorses_416x240_30_qp22.bin",
  "Kimono1_1920x1080_24_qp27.bin",
  "PartyScene_832x480_50_qp22.bin",
  "SlideShow_1280x720_20_qp22.bin",
  "BQSquare_416x240_60_qp27.bin",
  "Cactus_1920x1080_50_qp32.bin",
  "PeopleOnStreet_2560x1600_30_crop_qp22.bin",
  "ParkScene_1920x1080_24_qp22.bin",
  "Kimono1_1920x1080_24_qp32.bin",
  "RaceHorses_416x240_30_qp27.bin",
  "KristenAndSara_1280x720_60_qp37.bin",
  "BasketballPass_416x240_50_qp27.bin",
  "BlowingBubbles_416x240_50_qp22.bin",
  "ParkScene_1920x1080_24_qp27.bin",
  "NebutaFestival_2560x1600_60_10bit_crop_qp37.bin",
  "BasketballDrillText_832x480_50_qp27.bin",
  "RaceHorses_832x480_30_qp37.bin",
  "SteamLocomotiveTrain_2560x1600_60_10bit_crop_qp22.bin",
  "BasketballPass_416x240_50_qp37.bin",
  "BasketballDrill_832x480_50_qp37.bin",
  "BasketballDrillText_832x480_50_qp32.bin",
  "RaceHorses_832x480_30_qp22.bin",
  "SlideShow_1280x720_20_qp32.bin",
  "Kimono1_1920x1080_24_qp37.bin",
  "SlideEditing_1280x720_30_qp27.bin",
  "PartyScene_832x480_50_qp32.bin",
  "BasketballPass_416x240_50_qp32.bin",
  "BQMall_832x480_60_qp22.bin",
  "BQSquare_416x240_60_qp32.bin",
  "BlowingBubbles_416x240_50_qp27.bin",
  "Johnny_1280x720_60_qp37.bin",
  "SlideShow_1280x720_20_qp27.bin",
  "Traffic_2560x1600_30_crop_qp27.bin",
  "PartyScene_832x480_50_qp37.bin",
  "RaceHorses_832x480_30_qp27.bin",
  "BasketballDrive_1920x1080_50_qp22.bin",
  "SteamLocomotiveTrain_2560x1600_60_10bit_crop_qp32.bin",
  "Traffic_2560x1600_30_crop_qp32.bin",
  "KristenAndSara_1280x720_60_qp22.bin",
  "PeopleOnStreet_2560x1600_30_crop_qp37.bin",
  "FourPeople_1280x720_60_qp27.bin",
  "SlideEditing_1280x720_30_qp22.bin",
  "RaceHorses_416x240_30_qp32.bin",
  "ChinaSpeed_1024x768_30_qp32.bin",
  "BQTerrace_1920x1080_60_qp27.bin",
  "KristenAndSara_1280x720_60_qp32.bin",
  "NebutaFestival_2560x1600_60_10bit_crop_qp22.bin",
  "PeopleOnStreet_2560x1600_30_crop_qp32.bin",
  "BasketballPass_416x240_50_qp22.bin",
  "BlowingBubbles_416x240_50_qp32.bin",
  "BasketballDrill_832x480_50_qp27.bin",
  "BQMall_832x480_60_qp32.bin",
  "SteamLocomotiveTrain_2560x1600_60_10bit_crop_qp37.bin",
  "BasketballDrillText_832x480_50_qp37.bin",
  "FourPeople_1280x720_60_qp37.bin",
  "BasketballDrill_832x480_50_qp22.bin",
  "BQTerrace_1920x1080_60_qp22.bin",
  "Traffic_2560x1600_30_crop_qp22.bin",
  "KristenAndSara_1280x720_60_qp27.bin",
  "SteamLocomotiveTrain_2560x1600_60_10bit_crop_qp27.bin",
  "ParkScene_1920x1080_24_qp32.bin",
  "PartyScene_832x480_50_qp27.bin",
  "NebutaFestival_2560x1600_60_10bit_crop_qp27.bin",
  "BasketballDrill_832x480_50_qp32.bin",
  "Cactus_1920x1080_50_qp37.bin",
  "ChinaSpeed_1024x768_30_qp37.bin",
  "ChinaSpeed_1024x768_30_qp27.bin",
  "BasketballDrive_1920x1080_50_qp32.bin",
  "Cactus_1920x1080_50_qp27.bin",
  "PeopleOnStreet_2560x1600_30_crop_qp27.bin",
  "RaceHorses_832x480_30_qp32.bin",
  "Kimono1_1920x1080_24_qp22.bin",
  "Johnny_1280x720_60_qp22.bin"]
  #=========================================================================
  #=========                        lp_main                        =========
  #=========================================================================
  $sourceList["lp_main"] = [
  "BlowingBubbles_416x240_50_qp37.bin",
  "BasketballDrive_1920x1080_50_qp37.bin",
  "Traffic_2560x1600_30_crop_qp37.bin",
  "FourPeople_1280x720_60_qp22.bin",
  "SlideEditing_1280x720_30_qp32.bin",
  "ParkScene_1920x1080_24_qp37.bin",
  "Cactus_1920x1080_50_qp22.bin",
  "FourPeople_1280x720_60_qp32.bin",
  "SlideShow_1280x720_20_qp37.bin",
  "Johnny_1280x720_60_qp27.bin",
  "SlideEditing_1280x720_30_qp37.bin",
  "BQSquare_416x240_60_qp37.bin",
  "BQMall_832x480_60_qp37.bin",
  "BQTerrace_1920x1080_60_qp32.bin",
  "ChinaSpeed_1024x768_30_qp22.bin",
  "RaceHorses_416x240_30_qp37.bin",
  "BQMall_832x480_60_qp27.bin",
  "BasketballDrive_1920x1080_50_qp27.bin",
  "NebutaFestival_2560x1600_60_10bit_crop_qp32.bin",
  "BQSquare_416x240_60_qp22.bin",
  "BQTerrace_1920x1080_60_qp37.bin",
  "BasketballDrillText_832x480_50_qp22.bin",
  "Johnny_1280x720_60_qp32.bin",
  "RaceHorses_416x240_30_qp22.bin",
  "Kimono1_1920x1080_24_qp27.bin",
  "PartyScene_832x480_50_qp22.bin",
  "SlideShow_1280x720_20_qp22.bin",
  "BQSquare_416x240_60_qp27.bin",
  "Cactus_1920x1080_50_qp32.bin",
  "PeopleOnStreet_2560x1600_30_crop_qp22.bin",
  "ParkScene_1920x1080_24_qp22.bin",
  "Kimono1_1920x1080_24_qp32.bin",
  "RaceHorses_416x240_30_qp27.bin",
  "KristenAndSara_1280x720_60_qp37.bin",
  "BasketballPass_416x240_50_qp27.bin",
  "BlowingBubbles_416x240_50_qp22.bin",
  "ParkScene_1920x1080_24_qp27.bin",
  "NebutaFestival_2560x1600_60_10bit_crop_qp37.bin",
  "BasketballDrillText_832x480_50_qp27.bin",
  "RaceHorses_832x480_30_qp37.bin",
  "SteamLocomotiveTrain_2560x1600_60_10bit_crop_qp22.bin",
  "BasketballPass_416x240_50_qp37.bin",
  "BasketballDrill_832x480_50_qp37.bin",
  "BasketballDrillText_832x480_50_qp32.bin",
  "RaceHorses_832x480_30_qp22.bin",
  "SlideShow_1280x720_20_qp32.bin",
  "Kimono1_1920x1080_24_qp37.bin",
  "SlideEditing_1280x720_30_qp27.bin",
  "PartyScene_832x480_50_qp32.bin",
  "BasketballPass_416x240_50_qp32.bin",
  "BQMall_832x480_60_qp22.bin",
  "BQSquare_416x240_60_qp32.bin",
  "BlowingBubbles_416x240_50_qp27.bin",
  "Johnny_1280x720_60_qp37.bin",
  "SlideShow_1280x720_20_qp27.bin",
  "Traffic_2560x1600_30_crop_qp27.bin",
  "PartyScene_832x480_50_qp37.bin",
  "RaceHorses_832x480_30_qp27.bin",
  "BasketballDrive_1920x1080_50_qp22.bin",
  "SteamLocomotiveTrain_2560x1600_60_10bit_crop_qp32.bin",
  "Traffic_2560x1600_30_crop_qp32.bin",
  "KristenAndSara_1280x720_60_qp22.bin",
  "PeopleOnStreet_2560x1600_30_crop_qp37.bin",
  "FourPeople_1280x720_60_qp27.bin",
  "SlideEditing_1280x720_30_qp22.bin",
  "RaceHorses_416x240_30_qp32.bin",
  "ChinaSpeed_1024x768_30_qp32.bin",
  "BQTerrace_1920x1080_60_qp27.bin",
  "KristenAndSara_1280x720_60_qp32.bin",
  "NebutaFestival_2560x1600_60_10bit_crop_qp22.bin",
  "PeopleOnStreet_2560x1600_30_crop_qp32.bin",
  "BasketballPass_416x240_50_qp22.bin",
  "BlowingBubbles_416x240_50_qp32.bin",
  "BasketballDrill_832x480_50_qp27.bin",
  "BQMall_832x480_60_qp32.bin",
  "SteamLocomotiveTrain_2560x1600_60_10bit_crop_qp37.bin",
  "BasketballDrillText_832x480_50_qp37.bin",
  "FourPeople_1280x720_60_qp37.bin",
  "BasketballDrill_832x480_50_qp22.bin",
  "BQTerrace_1920x1080_60_qp22.bin",
  "Traffic_2560x1600_30_crop_qp22.bin",
  "KristenAndSara_1280x720_60_qp27.bin",
  "SteamLocomotiveTrain_2560x1600_60_10bit_crop_qp27.bin",
  "ParkScene_1920x1080_24_qp32.bin",
  "PartyScene_832x480_50_qp27.bin",
  "NebutaFestival_2560x1600_60_10bit_crop_qp27.bin",
  "BasketballDrill_832x480_50_qp32.bin",
  "Cactus_1920x1080_50_qp37.bin",
  "ChinaSpeed_1024x768_30_qp37.bin",
  "ChinaSpeed_1024x768_30_qp27.bin",
  "BasketballDrive_1920x1080_50_qp32.bin",
  "Cactus_1920x1080_50_qp27.bin",
  "PeopleOnStreet_2560x1600_30_crop_qp27.bin",
  "RaceHorses_832x480_30_qp32.bin",
  "Kimono1_1920x1080_24_qp22.bin",
  "Johnny_1280x720_60_qp22.bin"]
#=========================================================================
#=========                        ra_main                        =========
#=========================================================================
$sourceList["ra_main"] = [
  "BlowingBubbles_416x240_50_qp37.bin",
  "BasketballDrive_1920x1080_50_qp37.bin",
  "Traffic_2560x1600_30_crop_qp37.bin",
  "FourPeople_1280x720_60_qp22.bin",
  "SlideEditing_1280x720_30_qp32.bin",
  "ParkScene_1920x1080_24_qp37.bin",
  "Cactus_1920x1080_50_qp22.bin",
  "FourPeople_1280x720_60_qp32.bin",
  "SlideShow_1280x720_20_qp37.bin",
  "Johnny_1280x720_60_qp27.bin",
  "SlideEditing_1280x720_30_qp37.bin",
  "BQSquare_416x240_60_qp37.bin",
  "BQMall_832x480_60_qp37.bin",
  "BQTerrace_1920x1080_60_qp32.bin",
  "ChinaSpeed_1024x768_30_qp22.bin",
  "RaceHorses_416x240_30_qp37.bin",
  "BQMall_832x480_60_qp27.bin",
  "BasketballDrive_1920x1080_50_qp27.bin",
  "NebutaFestival_2560x1600_60_10bit_crop_qp32.bin",
  "BQSquare_416x240_60_qp22.bin",
  "BQTerrace_1920x1080_60_qp37.bin",
  "BasketballDrillText_832x480_50_qp22.bin",
  "Johnny_1280x720_60_qp32.bin",
  "RaceHorses_416x240_30_qp22.bin",
  "Kimono1_1920x1080_24_qp27.bin",
  "PartyScene_832x480_50_qp22.bin",
  "SlideShow_1280x720_20_qp22.bin",
  "BQSquare_416x240_60_qp27.bin",
  "Cactus_1920x1080_50_qp32.bin",
  "PeopleOnStreet_2560x1600_30_crop_qp22.bin",
  "ParkScene_1920x1080_24_qp22.bin",
  "Kimono1_1920x1080_24_qp32.bin",
  "RaceHorses_416x240_30_qp27.bin",
  "KristenAndSara_1280x720_60_qp37.bin",
  "BasketballPass_416x240_50_qp27.bin",
  "BlowingBubbles_416x240_50_qp22.bin",
  "ParkScene_1920x1080_24_qp27.bin",
  "NebutaFestival_2560x1600_60_10bit_crop_qp37.bin",
  "BasketballDrillText_832x480_50_qp27.bin",
  "RaceHorses_832x480_30_qp37.bin",
  "SteamLocomotiveTrain_2560x1600_60_10bit_crop_qp22.bin",
  "BasketballPass_416x240_50_qp37.bin",
  "BasketballDrill_832x480_50_qp37.bin",
  "BasketballDrillText_832x480_50_qp32.bin",
  "RaceHorses_832x480_30_qp22.bin",
  "SlideShow_1280x720_20_qp32.bin",
  "Kimono1_1920x1080_24_qp37.bin",
  "SlideEditing_1280x720_30_qp27.bin",
  "PartyScene_832x480_50_qp32.bin",
  "BasketballPass_416x240_50_qp32.bin",
  "BQMall_832x480_60_qp22.bin",
  "BQSquare_416x240_60_qp32.bin",
  "BlowingBubbles_416x240_50_qp27.bin",
  "Johnny_1280x720_60_qp37.bin",
  "SlideShow_1280x720_20_qp27.bin",
  "Traffic_2560x1600_30_crop_qp27.bin",
  "PartyScene_832x480_50_qp37.bin",
  "RaceHorses_832x480_30_qp27.bin",
  "BasketballDrive_1920x1080_50_qp22.bin",
  "SteamLocomotiveTrain_2560x1600_60_10bit_crop_qp32.bin",
  "Traffic_2560x1600_30_crop_qp32.bin",
  "KristenAndSara_1280x720_60_qp22.bin",
  "PeopleOnStreet_2560x1600_30_crop_qp37.bin",
  "FourPeople_1280x720_60_qp27.bin",
  "SlideEditing_1280x720_30_qp22.bin",
  "RaceHorses_416x240_30_qp32.bin",
  "ChinaSpeed_1024x768_30_qp32.bin",
  "BQTerrace_1920x1080_60_qp27.bin",
  "KristenAndSara_1280x720_60_qp32.bin",
  "NebutaFestival_2560x1600_60_10bit_crop_qp22.bin",
  "PeopleOnStreet_2560x1600_30_crop_qp32.bin",
  "BasketballPass_416x240_50_qp22.bin",
  "BlowingBubbles_416x240_50_qp32.bin",
  "BasketballDrill_832x480_50_qp27.bin",
  "BQMall_832x480_60_qp32.bin",
  "SteamLocomotiveTrain_2560x1600_60_10bit_crop_qp37.bin",
  "BasketballDrillText_832x480_50_qp37.bin",
  "FourPeople_1280x720_60_qp37.bin",
  "BasketballDrill_832x480_50_qp22.bin",
  "BQTerrace_1920x1080_60_qp22.bin",
  "Traffic_2560x1600_30_crop_qp22.bin",
  "KristenAndSara_1280x720_60_qp27.bin",
  "SteamLocomotiveTrain_2560x1600_60_10bit_crop_qp27.bin",
  "ParkScene_1920x1080_24_qp32.bin",
  "PartyScene_832x480_50_qp27.bin",
  "NebutaFestival_2560x1600_60_10bit_crop_qp27.bin",
  "BasketballDrill_832x480_50_qp32.bin",
  "Cactus_1920x1080_50_qp37.bin",
  "ChinaSpeed_1024x768_30_qp37.bin",
  "ChinaSpeed_1024x768_30_qp27.bin",
  "BasketballDrive_1920x1080_50_qp32.bin",
  "Cactus_1920x1080_50_qp27.bin",
  "PeopleOnStreet_2560x1600_30_crop_qp27.bin",
  "RaceHorses_832x480_30_qp32.bin",
  "Kimono1_1920x1080_24_qp22.bin",
  "Johnny_1280x720_60_qp22.bin"]

###############################################################################
# getopts
###############################################################################
def getopts (argv)
  help() if argv.size == 0
  $listEnable    = false
  $sourcePattern = nil
  $exec          = nil
  $stop          = true
  for i in (0..argv.size) do
    case argv[i]
    when "-h"         : help();
    when "-list"      : $listEnable    = true
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
# check_error
###############################################################################
def check_error ()
  cmd = "grep -n \"Incorrect\" log"
  ret = IO.popen(cmd).readlines
  val = ret[ret.size-1].to_s.split(':')
  if val[1] != nil then
    puts val[1]
    exit if $stop == true 
  end
end
###############################################################################
# main
###############################################################################
def main (subDir, binFile , idxFile, nbFile, maxSize)
  puts "= #{idxFile.to_s.rjust(nbFile.to_s.size)}/#{nbFile} = #{binFile.ljust(maxSize)}"
  cmd = "#{$exec} #{$appli[$appliIdx]["option"]} #{$sourcePattern}/#{subDir}/#{binFile} #{$appli[$appliIdx]["output"]} > #{$appli[$appliIdx]["label"]}/#{File.basename(binFile, File.extname(binFile))}.md5"
  system(cmd)
  check_error()
end
###############################################################################
# main
###############################################################################
getopts(ARGV)
if File.exist?($appli[$appliIdx]["label"]) then
    system("rm -r #{$appli[$appliIdx]["label"]}")
end
Dir.mkdir($appli[$appliIdx]["label"])

if $listEnable == false then
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
else
  $sourceList.each_key do |subDir|
    if $sourceList[subDir].length != 0 then
      maxSize  = getMaxSizeFileName($sourceList[subDir])
      printSubDir(subDir, $sourceList[subDir].length, maxSize)
      $sourceList[subDir].each_with_index do |binFile,idxFile|
	main(subDir,binFile, idxFile+1, $sourceList[subDir].length, maxSize)
      end
    end
  end
end
