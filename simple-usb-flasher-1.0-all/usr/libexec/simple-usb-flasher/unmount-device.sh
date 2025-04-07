#!/bin/bash

source /usr/libexec/simple-usb-flasher/funcs/check-root.sh

device="$1"

/usr/libexec/simple-usb-flasher/verify-mountpoints.sh "$device" || exit "$?"

log "Unmounting all partitions of ${device}..."

sudo umount "$device"*
exit 0 # needed because of 'not mounted' messages

