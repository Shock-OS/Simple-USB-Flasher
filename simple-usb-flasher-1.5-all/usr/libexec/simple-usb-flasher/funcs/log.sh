#!/bin/bash

if [[ "$verbose" == '--verbose' ]] || [[ "$verbose" == 'true' ]]
then
    verbose=true
else
    verbose=false
fi

function log {
if $verbose
then
    echo "$1" > /dev/tty
fi
}

function logerror {
echo "$1" >&2
}

