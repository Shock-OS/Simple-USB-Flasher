#!/bin/bash

image="$1"
device="$2"
method="$3"
image_size="$4"
verbose="$5"

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

if $verbose
then
    pv_args=(-s "$image_size")
    pv_args_iso=()
else
    pv_args=(-n -s "$image_size")
    pv_args_iso=(-n)
fi

file_type="$(/usr/libexec/simple-usb-flasher/get-image-info/get-file-type.sh "$image")"
log 'Writing image...'
case "$file_type" in
    '.7z')
        case "$method" in
            '7z')
                7z x -so "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            '7za')
                7za x -so "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            *)
                unknown_method
                ;;
        esac
        ;;
    '.bz2')
        case "$method" in
            'bzcat')
                bzcat "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            'bzip2')
                bzip2 -dc "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            'bunzip2')
                bunzip2 -c "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            *)
                unknown_method
                ;;
        esac
        ;;
    '.gz')
        case "$method" in
            'zcat')
                zcat "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            'gzip')
                gzip -dc "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            'gunzip')
                gunzip -c "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            *)
                unknown_method
                ;;
        esac
        ;;
    '.lzma')
        case "$method" in
            'lzcat')
                lzcat "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            'xzcat')
                xzcat "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            'xz')
                xz -dc "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            'lzma')
                lzma -dc "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            'unzlma')
                unzlma -c "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            *)
                unknown_method
                ;;
        esac
        ;;
    '.rar')
        unrar p "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
        ;;
    '.tar'*)
        tar -O -xf "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
        ;;
    '.xz')
        case "$method" in
            'xzcat')
                xzcat "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            'xz')
                xz -dc "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            *)
                unknown_method
                ;;
        esac
        ;;
    '.zip')
        unzip -p "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
        ;;
    '.zst')
        case "$method" in
            'zstdcat')
                zstdcat "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            'zstd')
                zstd -dc "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            'unzstd')
                unzstd -dc "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            'pzstd')
                pzstd -dc "$image" | pv "${pv_args[@]}" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
                ;;
            *)
                unknown_method
                ;;
        esac
        ;;
    *)
        pv "${pv_args_iso[@]}" "$image" | dd of="$device" bs=4M iflag=fullblock oflag=sync status=none
        ;;
esac || handle_error
sync
sudo umount "$device"* &> /dev/null
eject "$device" || udisksctl power-off -b "$device"
log "SUCCESS! Image '$(basename "$image")' has successfully been flashed to device ${device}. You can now safely remove the device."

