#!/bin/bash

labels=()
mapfile -t devices <<< "$(/usr/libexec/simple-usb-flasher/get-devices-info/get-devices.sh)"

for device in "${devices[@]}"
do
    label=''
    names="$(lsblk -no LABEL "$device")"
    while IFS= read -r line
    do
        if [[ -n "$line" ]]
        then
            if [[ -z "$label" ]]
            then
                label="$line"
            else
                label+=", $line"
            fi
        fi
    done <<< "$names"
    if [[ -z "$label" ]]
    then
        label='NO LABEL'
    fi
    labels+=("$label")
done

for label in "${labels[@]}"
do
    echo "$label"
done

