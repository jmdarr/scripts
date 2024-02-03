## renew_certificates.sh

This script uses some variables (described below) to renew LetsEncrypt certificates on a bitnami server. To use the script, set your variables in the script and then run the script.

### Variables
* `DOMAINS` - this variable is a "list" (array) of domains to check certificates for and potentially renew.
  * _format_: DOMAINS=( "domain1" "domain2" ... )
* `EMAIL` - the email address you'd like associated with the certificates issued.
* `BASEDIR` - The base directory for _letsencrypt_ content on your server.
* `LEGO_BIN` - The path for the `lego` binary used to issue certificates.
* `BN_SVC_SCRIPT` - The path for the bitnami control script `ctlscript.sh`.
* `OPENSSL_BIN` - The path to the `openssl` binary on your server.
* `EXPIRY_THRESHOLD` - The number of seconds you want as a threshhold for certificate renewal. letsencrypt certificates are issued for 90 days, so we set a default of _6480000_, or 75 days. This means certs will be renewed with 15 days left until expiration.
* `LOG_FILE` - The path to the log file you would like to log to.
* `LOG_LEVEL` - The level of detail written to the log file. Possible values, in increasing verbosity, are `ERROR`, `WARN`, `INFO`, and `DEBUG`. Each level will include all previous levels of messaging.
* `LOG_DATEFORMAT` - The timestamp format used for logging. The default, `%Y-%m-%d %H:%M:%S`, provides a timestamp of `2024-01-03 18:16:00`.