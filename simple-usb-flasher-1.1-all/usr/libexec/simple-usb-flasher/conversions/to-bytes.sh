#!/bin/bash

size="$1"
verbose="$2"

source /usr/libexec/simple-usb-flasher/funcs/log.sh

if [[ "$2" == 'MiB' || "$2" == 'GiB' ]]
then
    unit="$2"
elif [[ "$size" =~ ' ' ]]
then
    unit="${size#* }"
    size="${size%% *}"
else
    unit='MiB'
fi      
size=$(echo "$size" | sed 's/,//g' | awk '{print int($1 + 0.9999)}')
case "$unit" in
    'MiB')
        size=$(( size * 1024 * 1024 ))
        ;;
    'GiB')
        size=$(( size * 1024 * 1024 * 1024))
        ;;
    *)
        log "ERROR: '${unit}' is not a vaild unit type."
        exit 1
        ;;
esac
echo "$size"

