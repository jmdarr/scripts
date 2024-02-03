#!/bin/bash

## This script uses the `lego` binary to issue certificates for the
## domains present in the list below.

####### VARIABLES
DOMAINS=(
  "domain1"
  "domain2"
)
EMAIL="youremail@domain.com"
BASEDIR="/opt/bitnami/letsencrypt"
LEGO_BIN="${BASEDIR}/lego"
CERT_DIR="${BASEDIR}/certificates"
BN_SVC_SCRIPT="/opt/bitnami/ctlscript.sh"
OPENSSL_BIN="/usr/bin/openssl"
EXPIRY_THRESHOLD=6480000 # in seconds
LOG_FILE="/var/log/renew_certificates.log"
LOG_LEVEL="INFO"
LOG_DATEFORMAT="%Y-%m-%d %H:%M:%S"

####### FUNCTIONS
function logError() {
  # shellcheck disable=SC2145   # function arguments reference
  _log "[ERROR] ${@}"
}
function logWarn() {
  if [ "${LOG_LEVEL}x" == "WARNx" ] ||
     [ "${LOG_LEVEL}x" == "INFOx" ] ||
     [ "${LOG_LEVEL}x" == "DEBUGx" ]; then
    # shellcheck disable=SC2145   # function arguments reference
    _log "[ WARN] ${@}"
  fi
}
function logInfo() {
  if [ "${LOG_LEVEL}x" == "INFOx" ] ||
     [ "${LOG_LEVEL}x" == "DEBUGx" ]; then
    # shellcheck disable=SC2145   # function arguments reference
    _log "[ INFO] ${@}"
  fi
}
function logDebug() {
  if [ "${LOG_LEVEL}x" == "DEBUGx" ]; then
    # shellcheck disable=SC2145   # function arguments reference
    _log "[DEBUG] ${@}"
  fi
}
function _log() {
  printf "[%19s] %s\n" "$(date +"${LOG_DATEFORMAT}")" "${@}" 2>&1 | tee -a "${LOG_FILE}" 2>/dev/null
}

####### MAIN

# check to see if we are ran as root
if [ "${USER}" != "root" ]; then
  logError "This script must be ran as root, or via sudo."
  exit 1
fi

logInfo "Starting certificate renewal run."
startTime=$(date +%s)
domains_to_renew=()

logInfo "Checking certificates for expiry."
## check for certificate expiry
for domain in "${DOMAINS[@]}"; do
  logInfo "Checking certificate for '${domain}'."
  logDebug "Domain ${domain} cert path: ${CERT_DIR}/${domain}.crt"
  logDebug "Command: ${OPENSSL_BIN} x509 -in "${CERT_DIR}/${domain}.crt" -noout -checkend ${EXPIRY_THRESHOLD}"

  if output=$(${OPENSSL_BIN} x509 -in "${CERT_DIR}/${domain}.crt" -noout -checkend ${EXPIRY_THRESHOLD}); then
    logInfo "Certificate does not expire within the next ${EXPIRY_THRESHOLD} seconds. Moving on."
    logDebug "${output}"
  else
    logWarn "Certificate will expire within the next ${EXPIRY_THRESHOLD} seconds. We will attempt renewal for this domain."
    logDebug "${output}"
    domains_to_renew+=("${domain}")
  fi
done
logInfo "Expiry check complete."

## time to renew things
if [ ${#domains_to_renew[@]} -eq 0 ]; then
  logInfo "No certificates are expiring, work complete."
  logDebug "domains_to_renew length: ${#domains_to_renew[@]}"
  exit 0
else
  logInfo "Certificate renewal commencing."
fi

logInfo "Attempting to stop Apache web server..."
# 1. stop apache. if we can't stop, we don't need to do anything but exit.
if ! output=$(${BN_SVC_SCRIPT} stop apache); then
  # failed to stop apache, lets exit
  logError "Failed to stop Apache web server, exiting."
  logDebug "${output}"
  exit 1
fi
logInfo "Apache successfully stopped."

for domain in "${domains_to_renew[@]}"; do
  # 2. renew certificates
  logInfo "Attempting to renew certificate for '${domain}'..."
  if ! output=$(${LEGO_BIN} --tls --email="${EMAIL}" --domains="${domain}" --domains="www.${domain}" --path="${BASEDIR}" run); then
    logWarn "Failed to renew certificate, continuing."
    logDebug "${output}"
  else
    logInfo "Successfully renewed certificate."
  fi
done

# 3. start apache
logInfo "Attempting to start Apache web server..."
if ! output=$(${BN_SVC_SCRIPT} start apache); then
  logError "Failed to start Apache web server, exiting."
  logDebug "${output}"
  exit 1
fi
logInfo "Apache successfully started."

endTime=$(date +%s)
totalTime=$((endTime - startTime))
logInfo "Completed certificate renewal run, took ${totalTime} seconds."
exit 0