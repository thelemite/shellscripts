#!/usr/bin/env bash

if [[ $# -ne 3 ]]; then
echo 1>&2 "Usage: $0 <ssh username> <remote hostname> <local mountpoint>"
exit 1
fi

if [[ ! -d "$3" ]]; then
    mkdir $3
fi

sudo sshfs -o allow_other,IdentityFile=/home/solomun/.ssh/id_rsa $1@$2:/ $3

echo "OK, should be mounted up."

exit 1