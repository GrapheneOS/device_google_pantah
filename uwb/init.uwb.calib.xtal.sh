#!/vendor/bin/sh
# only use xtal_trim from factory calibration
if [ -z "$2" ]
then
    echo "usage is $0 input-calibration output_calibration"
    exit 0
fi
OUTPUT_CALIB="$2"
if [ ! -f "$OUTPUT_CALIB" ]; then
    touch $OUTPUT_CALIB
    chmod 0644 $OUTPUT_CALIB
    file="$1"
    while IFS=, read -r f1 f2
    do
        case $f1 in
            "UWB_cal_tx_xtal_reg_final_value")
                if [ $((0x$f2)) -gt 63 ]; then
                    f2=63
                fi
                echo 'xtal_trim=0x'$f2 >> $OUTPUT_CALIB
                ;;
        esac
    done <"$file"
    exit 0
fi
