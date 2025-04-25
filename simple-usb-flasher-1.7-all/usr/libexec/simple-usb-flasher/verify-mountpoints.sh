#!/bin/bash

device="$1"
verbose="$2"

source /usr/libexec/simple-usb-flasher/funcs/log.sh

if [[ ! -b "$device" ]]
then
    logerror "ERROR: '${device}' is not a block device."
    exit 2
fi

mountpoints="$(lsblk -no MOUNTPOINT "$device")"
while IFS= read -r mountpoint
do
    if ! [[ "$mountpoint" == '/media/'* || "$mountpoint" == '/mnt/'* || -z "$mountpoint" ]]
    then
        logerror "ERROR: Device ${device} is mounted at '${mountpoint}', which is NOT /media or /mnt, meaning it can be reasonably assumed that device ${device} is NOT an external block device, but rather an internal drive. Therefore, flashing to or erasing this drive is not allowed."
        exit 1
    fi
done <<< "$mountpoints"

mapfile -t devices <<< "$(bash /usr/libexec/simple-usb-flasher/get-devices-info/get-devices.sh)"
if [[ ! " ${devices[@]} " =~ " $device " ]]
then
    logerror "ERROR: Device $device exists but is not mounted. Please mount the device to be able to properly flash or erase it."
    exit 1
fi

