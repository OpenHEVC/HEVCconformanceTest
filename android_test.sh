#!/bin/bash
HEVC="/data/local/tmp/openhevc -c -n "
FILES=/sdcard/avconv/*
#md5 in android, md5sum in linux
MD5=md5
for f in $FILES
do
    no_ext=${f%.*}
    no_path=${f##*/}
    base=${no_ext##*/}
    org=`cat tests/${base}.md5`
    arr=(${org//=/ })
    echo -n $no_path" "
    refmd5=${arr[1]}
#    echo -n $refmd5" "
    $HEVC -i $f -o yuv > /dev/null 2>&1
    res=(`$MD5 yuv`)
    yuvmd5=${res[0]}
#   echo ${newmd5}
    if [ "${refmd5}" = "${yuvmd5}" ]; then
        echo "OK"
    else
        echo "Fail"
    fi
done

