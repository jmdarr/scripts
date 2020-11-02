#!/bin/env bash

ip=$(dig @resolver1.opendns.com myip.opendns.com +short) || { echo "Could not get IP, exiting."; exit 1; }
[ "${ip}x" == "x" ] && { echo "Could not get IP, exiting."; exit 1; }
echo "VPN IP Lookup: ${ip}"
output=$(/bin/geoiplookup "${ip}")
echo "VPN Location: ${output}"
[[ "${output}" =~ "Canada" ]] && {
  output=$(ps aux | grep -i transmission | grep -v grep | grep -v killswitch | wc -l)
  [ ${output} -eq 0 ] && {
    echo "Did not find running transmission-daemon, starting"
    systemctl start transmission-daemon;
    logger transmission-killswitch "Starting transmission as openvpn is running just fine";
  } || { echo "Transmission running, keep on keeping on"; }
} || {
  output=$(ps aux | grep -i transmission | grep -v grep | grep -v killswitch | wc -l)
  [ ${output} -ne 0 ] && {
    echo "Found running transmission-daemon, stopping"
    systemctl stop transmission-daemon;
    logger transmission-killswitch "Stopping transmission as openvpn is not running right";
  } || { echo "Transmission dead, all is well"; }
}
