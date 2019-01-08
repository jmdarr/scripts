transmission_killswitch.sh

This script uses curl and geoip to geolocate, to the country,
the location openvpn has connected to. If this matches a string,
it will start transmission. If it does not match, it stops
transmission.
