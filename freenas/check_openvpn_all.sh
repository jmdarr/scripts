#!/bin/bash

while read id name; do
    echo "${name}"
    echo "-------------------------------"
    jexec ${id} "/root/check_vpn.sh"
    echo "-------------------------------"
done < <(jls | grep transmission | awk '{ print $1" "$3 }')
