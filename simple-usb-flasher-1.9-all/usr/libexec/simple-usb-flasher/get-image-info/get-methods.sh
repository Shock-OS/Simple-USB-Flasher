#!/bin/bash

image="$1"

/usr/libexec/simple-usb-flasher/get-image-info/check-file-exists.sh "$image" || exit "$?"

type="$(/usr/libexec/simple-usb-flasher/get-image-info/get-file-type.sh "$image")"

case "$type" in
    '.7z')
        echo '7z'
        echo '7za'
        ;;
    '.bz2')
        echo 'bzcat'
        echo 'bzip2'
        echo 'bunzip2'
        ;;
    '.gz')
        echo 'zcat'
        echo 'gzip'
        echo 'gunzip'
        ;;
    '.lzma')
        echo 'lzcat'
        echo 'xzcat'
        echo 'xz'
        echo 'lzma'
        echo 'unzlma'
        ;;
    '.xz')
        echo 'xzcat'
        echo 'xz'
        ;;
    '.zst')
        echo 'zstdcat'
        echo 'zstd'
        echo 'unzstd'
        echo 'pzstd'
        ;;
    *)
        exit 1
        ;;
esac

