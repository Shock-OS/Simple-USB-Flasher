#!/bin/bash

device="$1"
verbose="$2"

source /usr/libexec/simple-usb-flasher/funcs/check-root.sh

/usr/libexec/simple-usb-flasher/verify-mountpoints.sh "$device" || exit "$?"
log "Unmounting all partitions of ${device}..."
report="$(sudo umount "$device"* 2>&1 >/dev/null)"
while IFS= read -r line
do
    if [[ "$line" == *"umount: "* ]] && [[ "$line" != *"${device}"*": not mounted"* ]]
    then
        logerror "ERROR: ${line}"
        exit 1
    fi
done <<< "$report"

