#!/bin/env bash

# check for IP via dns resolution
echo -n 'Checking for VPN IP... '
ip=$(dig @resolver1.opendns.com myip.opendns.com +short) || { echo "dig command failed, exiting."; exit 1; }
[ "${ip}x" == "x" ] && { echo "IP lookup returned empty, exiting."; exit 1; }
echo "found: ${ip}"

# locate where our IP is, geographically speaking
echo -n 'Checking for GeoIP location... '
output=$(/bin/geoiplookup "${ip}") || { echo 'geoiplookup command failed, exiting.'; exit 1; }
[ "${output}x" == "x" ] && { echo "geoiplookup returned empty, exiting."; exit 1; }
echo "found: ${output}"

# check to make sure we're resolving from Canadia... for reasons
# TODO: make this more readable
#[[ "${output}" =~ "Canada" ]] && {
#  output=$(ps aux | grep -i transmission | grep -v grep | grep -v killswitch | wc -l)
#  [ ${output} -eq 0 ] && {
#    echo "Did not find running transmission-daemon, starting"
#    systemctl start transmission-daemon;
#    logger transmission-killswitch "Starting transmission as openvpn is running just fine";
#  } || { echo "Transmission running, keep on keeping on"; }
#} || {
#  output=$(ps aux | grep -i transmission | grep -v grep | grep -v killswitch | wc -l)
#  [ ${output} -ne 0 ] && {
#    echo "Found running transmission-daemon, stopping"
#    systemctl stop transmission-daemon;
#    logger transmission-killswitch "Stopping transmission as openvpn is not running right";
#  } || { echo "Transmission dead, all is well"; }
#}
