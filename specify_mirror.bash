#!/usr/bin/env bash

# Creates bziped archive of target database on Specify backend, 
# then scps it over to script execution location, bunzips | mysql load

if [[ $# -ne 1 ]]; then
echo 1>&2 "Usage: $0 <remote databasename>"
exit 1
fi

SPECIFY_SERVER="ritchie.floridamuseum.ufl.edu"
MYSQL=$(which mysql)
MYSQLDUMP=$(which mysqldump)
BZIP=$(which bzip2)

DATE=$(date +"%Y%m%d")

DB=$1
FILENAME=${DATE}".ritchie."${DB}".mysqldump.bz2"

echo "Enter remote ssh username:"
read remote_sshuser

echo "Enter remote db username:"
read remote_dbuser

echo "Enter remote db password:"
read -s remote_dbpass

echo "Enter local db username:"
read local_dbuser

echo "Enter local db password:"
read -s local_dbpass

echo "Enter a local db name to pump the dump into (*Enter blank for same as source):"
read local_dbname

if [[ -z "$local_dbname" ]]; then 
local_dbname=${DB} 
fi

echo "Taking a dump..."

REMOTE_DIR="/home/${remote_sshuser}/sql/"
LOCAL_DIR="/home/${USER}/mysqldumps/"

ssh -t ${remote_sshuser}@${SPECIFY_SERVER} "cd ${REMOTE_DIR} && ${MYSQLDUMP} -u ${remote_dbuser} -p'${remote_dbpass}' ${DB} | ${BZIP} > ${FILENAME}"

echo "Ahh...that's better.  Flinging that dump at you... Catch..."

scp ${remote_sshuser}@${SPECIFY_SERVER}:${REMOTE_DIR}${FILENAME} ${LOCAL_DIR}${FILENAME}

echo "Nice catch...now we stick the dump in my ess kyew el."

${MYSQL} -u ${local_dbuser} -p"${local_dbpass}" -e "DROP DATABASE ${local_dbname};" > /dev/null 2>&1
${MYSQL} -u ${local_dbuser} -p"${local_dbpass}" -e "CREATE DATABASE ${local_dbname};" > /dev/null 2>&1
${BZIP} -dc ${LOCAL_DIR}${FILENAME} | ${MYSQL} -u ${local_dbuser} -p"${local_dbpass}" ${local_dbname} > /dev/null 2>&1

echo "Alright, that's enough playing with dumps...Now, go wash your hands and get back to work."
echo "Sincerely, The Management"

exit 0


