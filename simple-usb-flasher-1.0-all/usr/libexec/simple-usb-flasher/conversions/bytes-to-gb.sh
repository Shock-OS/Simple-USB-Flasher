#!/bin/bash

size="$1"
bytes_in_gb=$(( 1024 * 1024 * 1024 ))
size="$(echo "scale=1; ($size/$bytes_in_gb + 0.05)/1" | bc)"
echo "$size"

