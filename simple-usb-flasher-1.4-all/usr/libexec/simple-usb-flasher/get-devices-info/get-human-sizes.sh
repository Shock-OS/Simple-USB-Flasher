#!/bin/bash

sizes=()
mapfile -t devices <<< "$(/usr/libexec/simple-usb-flasher/get-devices-info/get-devices.sh)"

for device in "${devices[@]}"
do
    size="$(lsblk -no SIZE "$device" | head -n 1)"
    sizes+=("$size")
done

for size in "${sizes[@]}"
do
    echo "$size"
done

