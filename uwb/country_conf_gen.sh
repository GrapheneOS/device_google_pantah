#!/bin/bash

# This script is used to generate uwb conuntry configuration file,
# and the PRODUCT_COPY_FILES list in uwb.mk based on uwb_country.conf
# Bug: 196073172, 233619860

count=1

mkdir -p $2

while read line ; do
    if [[ "$line" =~ ^"*" ]]; then
        header=${line:1}
    elif [[ "$line" =~ ^"\"" ]]; then
        #line=$(echo ${line/,} | tr -d "\"")
        country[count]=$(echo $line | cut -d ':' -f1 | tr -d "\"")
        code[count]=$(echo $line | cut -d ':' -f2 | tr -d "\"" | tr -d " ")
            if [ "$header" = "FCC" ]; then
                cp $1/UWB-calibration-fcc.conf $2/UWB-calibration-${code[$count]}.conf
            elif [ "$header" = "CE" ]; then
                cp $1/UWB-calibration-ce.conf $2/UWB-calibration-${code[$count]}.conf
            elif [ "$header" = "JP" ]; then
                cp $1/UWB-calibration-jp.conf $2/UWB-calibration-${code[$count]}.conf
            elif [ "$header" = "TW" ]; then
                cp $1/UWB-calibration-tw.conf $2/UWB-calibration-${code[$count]}.conf
            elif [ "$header" = "Restricted" ]; then
                cp $1/UWB-calibration-restricted.conf $2/UWB-calibration-${code[$count]}.conf
            fi
    fi
((count++))
done < $1/uwb_country.conf
