#!/bin/bash

image="$1"
device="$2"
verbose="$3"

source /usr/libexec/simple-usb-flasher/funcs/check-root.sh

/usr/libexec/simple-usb-flasher/verify-mountpoints.sh "$device" || exit "$?"

if [[ ! -f "$image" ]]
then
    logerror "ERROR: File '${image}' does not exist."
    exit 1
fi

/usr/libexec/simple-usb-flasher/unmount-device.sh "$device" --verbose || exit "$?"

log "Installing Ventoy to device ${device}..."

printf 'y\ny\n' | /usr/libexec/simple-usb-flasher/ventoy/Ventoy2Disk.sh -I "$device"

log "Re-mounting device ${device}..."

mount "${device}1" "$(mktemp -d /tmp/simple-usb-flasher.XXXXXX)"

mountpoint="$(findmnt -n -o TARGET "${device}1")"

log "Copying $image to ${device}..."

if $verbose
then
    pv "$image" | dd of="${mountpoint}/$(basename "$image")" bs=16M oflag=sync status=none
else
    pv -n "$image" | dd of="${mountpoint}/$(basename "$image")" bs=16M oflag=sync status=none
fi

sync
sudo umount "$device"* &> /dev/null
eject "$device" || udisksctl power-off -b "$device"
rmdir "$mountpoint"
log "SUCCESS! Image '$(basename "$image")' has successfully been flashed to device ${device}. You can now safely remove the device."

