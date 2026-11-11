#!/bin/bash

device="$1"
verbose="$2"

source /usr/libexec/simple-usb-flasher/funcs/check-root.sh

lockfile="/run/simple-usb-flasher/locks/${device:5}"
if [[ ! -f "$lockfile" ]]
then
    if $verbose
    then
        logerror "ERROR: Cannot unlock device '${device}' because it is not locked."
    fi
    exit 1
else
    rm -f "$lockfile"
    if ! find /run/simple-usb-flasher/locks -mindepth 1 -maxdepth 1 -print -quit | grep -q .
    then
        rmdir /run/simple-usb-flasher/locks
        rmdir /run/simple-usb-flasher
    fi
fi
