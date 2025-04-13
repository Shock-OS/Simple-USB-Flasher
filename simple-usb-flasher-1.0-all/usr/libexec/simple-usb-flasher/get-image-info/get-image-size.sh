#!/bin/bash

image="$1"

/usr/libexec/simple-usb-flasher/get-image-info/check-file-exists.sh "$1" || exit "$?"

time_takers=(
'.bz2'
'.gz'
'.lzma'
)

type="$(/usr/libexec/simple-usb-flasher/get-image-info/get-file-type.sh "$image")"
if [[ " $* " =~ ' --takes-time ' ]]
then
    if [[ "$image" == *'.tar'* ]] || [[ " ${time_takers[@]} " =~ " $type " ]]
    then
        exit
    else
        exit 1
    fi
fi
if [[ " ${time_takers[@]} " =~ " $type " ]]
then
    echo 'Getting uncompressed size of image, this may take a while...' > /dev/tty
fi
case "$type" in
    .7z)
        size="$(7z l "$image" | tail -n 1 | awk '{print $3}')"
        ;;
    .bz2)
        size="$(bzcat "$image" | wc -c)"
        ;;
    .gz)
        size="$(zcat -l "$image" | awk 'NR==2 {print $2}')"
        ;;
    .iso)
        tempdir="$(mktemp -d)"
    .lzma)
        size="$(lzcat "$image" | wc -c)"
        ;;
    .rar)
        size="$(unrar l "$image" | tail -n 2 | head -n 1 | awk '{print $1}')"
        ;;
    'tar'*)
        size="$(tar -tvf "$image" | awk '{s += $3} END {print s}')"
        ;;
    .xz)
        size="$(xz -l "$image" | awk 'NR==2 {print $5,$6}')"
        size="$(/usr/libexec/simple-usb-flasher/conversions/to-bytes.sh "$size")"
        ;;
    .zip)
        size="$(unzip -l "$image" | tail -n 1 | awk '{print $1}')"
        ;;
    .zst)
        size="$(zstd -l "$image" | awk 'NR==2 {print $5,$6}')"
        size="$(/usr/libexec/simple-usb-flasher/conversions/to-bytes.sh "$size")"
        ;;
    *)
        size="$(stat --format="%s" "$image")"
        ;;
esac
size=$(( size + $(( 512 * 1024 * 1024 )) ))
echo "$size"

