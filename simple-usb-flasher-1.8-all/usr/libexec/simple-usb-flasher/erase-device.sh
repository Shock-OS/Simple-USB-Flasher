#!/bin/bash

device="$1"
fs="$2"
label="$3"
verbose="$4"

source /usr/libexec/simple-usb-flasher/funcs/check-root.sh

if ! [[ "$fs" == 'exfat' || "$fs" == 'ext4' || "$fs" == 'fat32' || "$fs" == 'ntfs' ]]
then
    logerror "ERROR: '$fs' is not a valid filesystem. Filesystem must be 'exfat', 'ext4', 'fat32', or 'ntfs'."
    exit 1
fi

/usr/libexec/simple-usb-flasher/verify-mountpoints.sh "$device" || exit "$?"

function parse_label {
local action="$1"
if ! [[ "$action" == 'keep' || "$action" == 'remove' ]]
then
    logerror "SYNTAX ERROR: parse_chars argument 1 must be either 'keep' or 'remove'."
    exit 1
fi
local match_chars="$2"
local charlimit="$3"
local old_label="$4"
local new_label=''
while IFS= read -r -n1 char
do
    if [[ "$action" == 'keep' ]]
    then
        if [[ "$char" =~ [[:alnum:]] ]] || [[ " ${match_chars} " == *" ${char} "* ]]
        then
            new_label+="${char}"
        fi
    else # remove
        if [[ ! " ${match_chars} " == *" ${char} "* ]]
        then
            new_label+="${char}"
        fi
    fi
    if ((${#new_label}==${charlimit}))
    then
        break
    fi
done <<< "$old_label"
echo "$new_label"
}

if [[ "$fs" == 'exfat' ]]
then
    label="$(parse_label remove '" * / : < > ? \ |' 11 "$label")"
elif [[ "$fs" == 'ext4' ]]
then
    label="$(echo "$label" | tr -cd '\0-\177')" # convert to ASCII
    label="${label// /_}" # replace spaces w underscores
    label="$(parse_label keep '- _ . ~' 16 "$label")"
elif [[ "$fs" == 'fat32' ]]
then
    label="$(echo "$label" | tr -cd '\0-\177')" # convert to ASCII
    label="${label// /_}" # replace spaces w underscores
    label="$(parse_label keep '$ % '\'' - _ @ ~ ! ( ) { } ^ # &' 11 "$label")"
    label="${label^^}"
elif [[ "$fs" == 'ntfs' ]]
then
    label="$(parse_label remove '? " / \ | * < >' 32 "$label")"
fi
if [[ -z "$label" ]]
then
    if [[ "$fs" == 'ext4' ]]
    then
        if [[ "$device" == '/dev/mmcblk'* ]]
        then
            label='SD_Card'
        else
            label='USB_Stick'
        fi
    elif [[ "$fs" == 'fat32' ]]
    then
        if [[ -z "$label" ]]
        then
            if [[ "$device" == '/dev/mmcblk'* ]]
            then
                label='SD_CARD'
            else
                label='USB_STICK'
            fi
        fi
    else # exfat and ntfs
        if [[ -z "$label" ]]
        then
            if [[ "$device" == '/dev/mmcblk'* ]]
            then
                label='SD Card'
            else
                label='USB Stick'
            fi
        fi
    fi
fi
log "Using label '${label}' for device $device"
log "Reformatting device $device with $fs filesystem..."
set -e
trap "echo 'FAILED! An error occurred while erasing device $device'" ERR
/usr/libexec/simple-usb-flasher/unmount-device.sh "$device" --verbose || exit "$?"
wipefs --all --force "$device"
dd if=/dev/zero of="$device" bs=1M count=10 status=progress
parted "$device" --script mklabel msdos
case "$fs" in
    'fat32'|'exfat') sudo parted "$device" --script mkpart primary fat32 1MiB 100% ;;
    *) sudo parted "$device" --script mkpart primary "$fs" 1MiB 100% ;;
esac
part1="$(lsblk -pnro NAME "$device" | tail -n 1)"
case "$fs" in
    'exfat') sudo mkfs.exfat -n "$label" "$part1" ;;
    'ext4') sudo mkfs.ext4 -F -L "$label" "$part1" ;;
    'fat32') sudo mkfs.vfat -I -F 32 -n "$label" "$part1" ;;
    'ntfs') sudo mkfs.ntfs -f -L "$label" "$part1" ;;
esac
sync
set +e
trap - ERR
sudo umount "$device"*
eject "$device" || udisksctl power-off -b "$device"
echo "SUCCESS! Device $device was successfully formatted with the $fs filesystem. You can now safely remove the device."

