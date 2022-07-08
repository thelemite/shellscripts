#!/usr/bin/env bash

if [[ $# -ne 4 ]]; then
echo 1>&2 "Usage: $0 <ssh username> <remote hostname> <remote target path> <local mountpoint>"
exit 1
fi

if [[ ! -d "$4" ]]; then
    mkdir $4
fi

sudo sshfs -o allow_other,IdentityFile=/home/solomun/.ssh/id_rsa $1@$2:$3 $4

echo "OK, should be mounted up."

exit 1