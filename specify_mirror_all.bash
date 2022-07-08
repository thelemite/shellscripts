#!/usr/bin/env bash

# Creates bziped archive of target database on Specify backend, 
# then scps it over to script execution location, bunzips | mysql load

SPECIFY_SERVER="ritchie.floridamuseum.ufl.edu"
MYSQL=$(which mysql)
MYSQLDUMP=$(which mysqldump)
BZIP=$(which bzip2)

DATE=$(date +"%Y%m%d")

declare -a DBS=("uf_birds" "uf_fishes" "uf_mammals" "uf_invertebratezoology" "uf_herpetology" "uf_grr" "uf_paleobotany" "uf_invertebratepaleontology" "uf_vertebratepaleontology")

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

#begin main loop of dbs
for DB in "${DBS[@]}"
do

local_dbname="$DB"

FILENAME=${DATE}".ritchie."${DB}".mysqldump.bz2"

echo "Taking a dump of "${DB}"..."

REMOTE_DIR="/home/${remote_sshuser}/sql/"
LOCAL_DIR="/home/${USER}/mysqldumps/"

ssh -t ${remote_sshuser}@${SPECIFY_SERVER} "cd ${REMOTE_DIR} && ${MYSQLDUMP} -u ${remote_dbuser} -p'${remote_dbpass}' ${DB} | ${BZIP} > ${FILENAME}"

echo "Ahh...that's better.  Flinging that dump at you... Catch..."

scp ${remote_sshuser}@${SPECIFY_SERVER}:${REMOTE_DIR}${FILENAME} ${LOCAL_DIR}${FILENAME}

echo "Nice catch...now we stick the dump in my ess kyew el."

${MYSQL} -u ${local_dbuser} -p"${local_dbpass}" -e "DROP DATABASE ${local_dbname};" > /dev/null 2>&1
${MYSQL} -u ${local_dbuser} -p"${local_dbpass}" -e "CREATE DATABASE ${local_dbname};" > /dev/null 2>&1
${BZIP} -dc ${LOCAL_DIR}${FILENAME} | ${MYSQL} -u ${local_dbuser} -p"${local_dbpass}" ${local_dbname} > /dev/null 2>&1

echo "Cool, looks like everything came out OK.  Time to wipe..............the archive file out."
ssh ${remote_sshuser}@${SPECIFY_SERVER} "rm ${REMOTE_DIR}${FILENAME}"

done # end main loop

echo "Alright, that's enough playing with dumps...Now, go wash your hands and get back to work."
echo "Sincerely, The Management"
exit 0


