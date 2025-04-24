#!/bin/bash

device="$1"
verbose="$2"

source /usr/libexec/simple-usb-flasher/funcs/log.sh

if [[ "$device" =~ [0-9]$ ]]
then
    device="$(lsblk -pno PKNAME "$device")" || exit 1
fi
/usr/libexec/simple-usb-flasher/verify-mountpoints.sh "$device" "$verbose" || exit "$?"
echo "$device"

