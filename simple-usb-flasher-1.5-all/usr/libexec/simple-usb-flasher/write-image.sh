#!/bin/bash

image="$1"
device="$2"
method="$3"
verbose="$4"

source /usr/libexec/simple-usb-flasher/funcs/check-root.sh

function handle_error {
local returncode="$?"
logerror "ERROR: Failed to flash image '${image}' to device ${device}. dd exited with return code ${returncode}."
exit $returncode
}

function unknown_method {
logerror "ERROR: Unknown method '${method}'"
exit 1
}

/usr/libexec/simple-usb-flasher/verify-mountpoints.sh "$device" || exit "$?"

if [[ ! -f "$image" ]]
then
    logerror "ERROR: File '${image}' does not exist."
    exit 1
fi

/usr/libexec/simple-usb-flasher/unmount-device.sh "$device" --verbose || exit "$?"

file_type="$(/usr/libexec/simple-usb-flasher/get-image-info/get-file-type.sh "$image")"
log 'Writing image...'
case "$file_type" in
    .7z)
        case "$method" in
            '7z')
                7z x -so "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            '7za')
                7za x -so "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            *)
                unknown_method
                ;;
        esac
        ;;
    .bz2)
        case "$method" in
            'bzcat')
                bzcat "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            'bzip2')
                bzip2 -dc "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            'bunzip2')
                bunzip2 -c "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            *)
                unknown_method
                ;;
        esac
        ;;
    .gz)
        case "$method" in
            'zcat')
                zcat "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            'gzip')
                gzip -dc "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            'gunzip')
                gunzip -c "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            *)
                unknown_method
                ;;
        esac
        ;;
    .lzma)
        case "$method" in
            'lzcat')
                lzcat "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            'xzcat')
                xzcat "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            'xz')
                xz -dc "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            'lzma')
                lzma -dc "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            'unzlma')
                unzlma -c "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            *)
                unknown_method
                ;;
        esac
        ;;
    .rar)
        unrar p "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
        ;;
    '.tar'*)
        tar -O -xf "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
        ;;
    .xz)
        case "$method" in
            xzcat)
                xzcat "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            xz)
                xz -dc "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            *)
                unknown_method
                ;;
        esac
        ;;
    .zip)
        unzip -p "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
        ;;
    .zst)
        case "$method" in
            'zstdcat')
                zstdcat "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            'zstd')
                zstd -dc "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            'unzstd')
                unzstd -dc "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            'pzstd')
                pzstd -dc "$image" | dd of="$device" bs=4M iflag=fullblock oflag=direct status=progress
                ;;
            *)
                unknown_method
                ;;
        esac
        ;;
    *)
        dd if="$image" of="$device" bs=4M iflag=fullblock oflag=direct status=progress
        ;;
esac || handle_error
sync
sudo umount "$device"*
eject "$device" || udisksctl power-off -b "$device"
echo "SUCCESS! Image '$(basename "$image")' has successfully been flashed to device ${device}. You can now safely remove the device."

