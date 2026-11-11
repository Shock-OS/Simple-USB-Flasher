#!/bin/bash

device="$1"
verbose="$2"

source /usr/libexec/simple-usb-flasher/funcs/check-root.sh

lockfile="/run/simple-usb-flasher/locks/${device:5}"
if ! /usr/libexec/simple-usb-flasher/verify-mountpoints.sh "$device" "$verbose"
then
    exit 1
elif [[ -f "$lockfile" ]]
then
    if $verbose
    then
        logerror "ERROR: Cannot lock device '${device}' because it is already locked."
    fi
    exit 1
else
    mkdir -p /run/simple-usb-flasher/locks
    touch "$lockfile"
fi
