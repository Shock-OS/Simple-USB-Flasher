#!/bin/bash

image="$1"
verbose="$2"

source /usr/libexec/simple-usb-flasher/funcs/log.sh

if [[ ! -f "$image" ]]
then
    logerror "ERROR: '${image}': No such file"
    exit 1
elif [[ -d "$image" ]]
then
    logerror "ERROR: '${image}' is a directory, not a file"
    exit 1
fi

