#!/bin/bash

image="$1"
device="$2"

source /usr/libexec/simple-usb-flasher/funcs/check-root.sh

/usr/libexec/simple-usb-flasher/verify-mountpoints.sh "$device" || exit "$?"

if [[ ! -f "$image" ]]
then
    logerror "ERROR: File '${image}' does not exist."
    exit 1
fi

/usr/libexec/simple-usb-flasher/unmount-device.sh "$device" --verbose || exit "$?"

woeusb --device "$image" "$device" --for-gui

