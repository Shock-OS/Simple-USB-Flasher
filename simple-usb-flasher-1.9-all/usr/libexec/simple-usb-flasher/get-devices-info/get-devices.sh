#!/bin/bash

devices=()
all_devices=($(lsblk -o PATH,SIZE,TYPE | awk 'NR == 1 || ($2 != "0B" && $3 == "disk")' | awk '{print $1}' | tail -n +2))

for device in "${all_devices[@]}"
do
    lockfile="/run/simple-usb-flasher/locks/${device:5}"
    if [[ ! -f "$lockfile" ]]
    then
        mapfile -t mountpoints < <(lsblk -no MOUNTPOINT "$device" | tail -n +2)
        if ((${#mountpoints[@]}>0))
        then
            for mountpoint in "${mountpoints[@]}"
            do
                if ! [[ "$mountpoint" == '/media/'* || "$mountpoint" == '/mnt/'* || -z "$mountpoint" ]]
                then
                    continue 2
                fi
            done
        fi
        devices+=("$device")
    fi
done

for device in "${devices[@]}"
do
    echo "$device"
done

