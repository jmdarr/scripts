#!/bin/env bash

wanted_country='Canada'
svc='transmission-daemon'

function check_for_running_transmission() {
  pscount=$(ps aux | grep -i transmission | grep -v grep | grep -v killswitch | wc -l)
  rval=1
  if [ ${pscount} -gt 0 ]; then rval=0; fi
  return ${rval}
}

function start_transmission() {
  rval=-1
  echo -n 'Starting transmission... '
  if check_for_running_transmission; then
    echo 'already running.'
    rval=1
  else
    if systemctl start ${svc} >/dev/null 2>&1; then
      echo 'started.'
      rval=0
    else
      echo 'failed.'
      rval=1
    fi
  fi
  return ${rval}
}

function stop_transmission() {
  rval=-1
  echo -n 'Stopping transmission... '
  if check_for_running_transmission; then
    if systemctl stop ${svc} >/dev/null 2>&1; then
      echo 'stopped.'
      rval=0
    else
      echo 'failed.'
      rval=1
    fi
  else
    echo 'already stopped.'
    rval=1
  fi
  return ${rval}
}

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
echo -n "Ensuring we're pinned to '${wanted_country}'... "

# if we're not, then we want to stop transmission.
if [[ "${output}" =~ "Canada" ]]; then
  echo "look at that. Fancy. Let's make sure things are moving along."
  start_transmission
else
  echo "oops, guess not. Let's stop the downloader, I guess."
  stop_transmission
fi
