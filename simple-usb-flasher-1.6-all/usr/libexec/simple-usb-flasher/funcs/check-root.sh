#!/bin/bash

source /usr/libexec/simple-usb-flasher/funcs/log.sh

if [[ "$EUID" != '0' ]]
then
    logerror 'ERROR: Script must be run as root.'
    exit 1
fi

