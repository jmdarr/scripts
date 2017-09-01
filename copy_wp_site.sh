#!/usr/bin/env bash


echo '###### INPUT ACCOUNT DATA ######'
read -p 'Enter source username: ' SOURCEUSER
read -p 'Enter source database host: ' SOURCEDBHOST
read -p 'Enter source database name: ' SOURCEDBNAME
read -p 'Enter source database username: ' SOURCEDBUSER
read -s -p 'Enter source database password: ' SOURCEDBPASS
SOURCEPATH="/home/${SOURCEUSER}/public_html";
echo;
[ ! -d "${SOURCEPATH}" ] && {
    echo "Source user path '${SOURCEPATH}' does not exist, exiting.";
    exit 1;
}
echo '###### DESTINATION ACCOUNT DATA ######'
read -p 'Enter destination username: ' DESTUSER
read -p 'Enter destination database host: ' DESTDBHOST
read -p 'Enter destination database name: ' DESTDBNAME
read -p 'Enter destination database username: ' DESTDBUSER
read -s -p 'Enter destination database password: ' DESTDBPASS
DESTPATH="/home/${DESTUSER}/public_html";
echo
[ -d "${DESTPATH}" ] && {
    echo '###### WARNING! ######';
    echo 'This is destructive and will remove any files at path:';
    echo "  ${DESTPATH}";
    echo "Additionally, you will lose any content in database:";
    echo "  ${DESTDBNAME}";
    read -p 'Continue? [y/n]: ' HURTME;
    [ "${HURTME}" != "y" ] && {
        echo 'Aborting on user input.';
        exit 1;
    }
}
echo '###### ALMOST DONE! ######'
read -p 'What is the originating domain name: ' SOURCEDOMAIN
read -p 'What is the destination domain name: ' DESTDOMAIN

echo '@@@@@@ READY TO WORK! ######'
BAKPATH="${DESTPATH}.$(date +%s)";
echo mv "${DESTPATH}" "${BAKPATH}";
echo "Created backup of '${DESTPATH}' at '${BAKPATH}'";
echo cp -av "${SOURCEPATH}" "${DESTPATH}";
echo find ${DESTPATH} -user ${SOURCEUSER} -exec chown ${DESTUSER} {} \;
echo find ${DESTPATH} -group ${SOURCEUSER} -exec chgrp ${DESTUSER} {} \;
echo "Copied '${SOURCEPATH}' to '${DESTPATH}'. Also, changed"
echo "ownership of files from '${SOURCEUSER}' user to '${DESTUSER}' user"

mysqldump -h ${DESTDBHOST} -u ${DESTDBUSER} -p${DESTDBPASS} ${DESTDBNAME} > "${BAKPATH}/${DESTDBNAME}.sql"
echo "Created backup of '${DESTDBNAME}' at '${BAKPATH}/${DESTDBNAME}.sql'"
mysqldump -h ${SOURCEDBHOST} -u ${SOURCEDBUSER} -p${SOURCEDBPASS} ${SOURCEDBNAME} > /home/${DESTDBUSER}/${DESTDBNAME}.sql
sed -i "s#${SOURCEDOMAIN}
