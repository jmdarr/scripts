#!/bin/env bash

ip=$(/bin/curl -s icanhazip.com)
echo "VPN IP Lookup: ${ip}"
output=$(/bin/geoiplookup "${ip}")
echo "VPN Location: ${output}"
[[ "${output}" =~ "Canada" ]] && {
  output=$(ps aux | grep -i transmission | grep -v grep)
  [ "x${output}" == "x" ] && {
    echo "Did not find running transmission-daemon, starting"
    systemctl start transmission-daemon;
    logger "Starting transmission as openvpn is running just fine";
  } || { echo "Transmission running, keep on keeping on"; }
} || {
  output=$(ps aux | grep -i transmission | grep -v grep)
  [ "x${output}" != "x" ] && {
    echo "Found running transmission-daemon, stopping"
    systemctl stop transmission-daemon;
    logger openvpn-killswitch "Stopping transmission as openvpn is not running right";
  } || { echo "Transmission dead, all is well"; }
}
