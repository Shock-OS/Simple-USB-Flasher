#!/bin/bash

device="$1"
fs="$2"
label="$3"
verbose="$4"

source /usr/libexec/simple-usb-flasher/funcs/check-root.sh

if ! [[ "$fs" == 'exfat' || "$fs" == 'ext4' || "$fs" == 'fat32' || "$fs" == 'ntfs' ]]
then
    log "ERROR: '$fs' is not a valid filesystem. Filesystem must be 'exfat', 'ext4', 'fat32', or 'ntfs'."
    exit 1
fi

/usr/libexec/simple-usb-flasher/verify-mountpoints.sh "$device" || exit "$?"

label="${label::10}"
label="${label//[^a-zA-Z0-9_-]/}"
if [[ "$fs" == 'fat32' ]]
then
    label="${label^^}"
fi
if [[ -z "$label" ]]
then
    label='USB_STICK'
fi
log "Using label '${label}' for device $device"
log "Reformatting device $device with $fs filesystem..."
set -e
/usr/libexec/simple-usb-flasher/unmount-device.sh "$device" || exit "$?"
wipefs --all --force "$device"
dd if=/dev/zero of="$device" bs=1M count=10 status=progress
parted "$device" --script mklabel msdos
case "$fs" in
    fat32|exfat) sudo parted "$device" --script mkpart primary fat32 1MiB 100% ;;
    *) sudo parted "$device" --script mkpart primary "$fs" 1MiB 100% ;;
esac
part1="$(lsblk -pnro NAME "$device" | tail -n 1)"
case "$fs" in
    exfat) sudo mkfs.exfat -n "$label" "$part1" ;;
    ext4) sudo mkfs.ext4 -F -L "$label" "$part1" ;;
    fat32) sudo mkfs.vfat -I -F 32 -n "$label" "$part1" ;;
    ntfs) sudo mkfs.ntfs -f -L "$label" "$part1" ;;
esac
sync
set +e
eject "$device"
echo "SUCCESS! Device $device was successfully formatted with the $fs filesystem. You can now safely remove the device."

