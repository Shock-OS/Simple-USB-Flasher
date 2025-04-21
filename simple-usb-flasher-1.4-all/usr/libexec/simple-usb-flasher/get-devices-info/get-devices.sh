#!/bin/bash

devices=()

function findmps {
dir="$1"
if [ -d "$dir"/* ]
then
    for mountpoint in "$dir"/*
    do
        mpdirs+=("$mountpoint")
    done
    for dir in "${mpdirs[@]}"
    do
        if (( $(ls "$dir" | wc -l) > 0 ))
        then
            for mountpoint in "$dir"/*
            do
                device="$(df | grep "$mountpoint" | head -n 1 | awk '{print $1}')"
                if [[ "$device" =~ [0-9]$ ]]
                then
                    device="$(lsblk -pno PKNAME "$device")" || continue
                fi
                if [[ -n "$device" ]] && [[ ! " ${devices[@]} " =~ " $device " ]]
                then
                    devices+=("$device")
                fi
            done
        fi
    done
fi
}

findmps /media
findmps /mnt

mapfile -t devices < <(printf "%s\n" "${devices[@]}" | sort -u)

for device in "${devices[@]}"
do
    echo "$device"
done

