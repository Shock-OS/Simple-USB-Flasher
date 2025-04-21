#!/bin/bash

image="$1"
verbose="$2"

source /usr/libexec/simple-usb-flasher/funcs/log.sh

/usr/libexec/simple-usb-flasher/get-image-info/check-file-exists.sh "$image" || exit "$?"

mapfile -t archive_types <<< "$(cat /usr/share/simple-usb-flasher/supported-file-types.txt)"
for type in "${archive_types[@]}"
do
    if [[ "$image" == *"$type" ]]
    then
        echo "$type"
        exit
    fi
done
log "WARNING: File '${image}' is not a supported file type."
exit 1

