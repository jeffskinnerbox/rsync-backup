#!/bin/bash

# Maintainer:   jeffskinnerbox@yahoo.com / www.jeffskinnerbox.me
# Version:      1.5.0

# This utility does a push notification to the service Pushover - https://pushover.net/

#set -x

# include your secrets
source /home/jeff/src/linux-tools/network-backup/secret.env

# Parse command line options
USAGE="Usage: `basename $0` [-h] -t title -m message"
while getopts ht:m: OPT; do
    case "$OPT" in
        h)
            echo $USAGE
            exit 0
            ;;
        t)
            TITLE=$OPTARG
            ;;
        m)
            MESSAGE=$OPTARG
            ;;
        \?)
            # getopts issues an error message
            echo $USAGE >&2
            exit 1
            ;;
    esac
done

# Send message to Pushover to create notification
curl --silent \
    -F "token=$APPTOKEN" \
    -F "user=$USERKEY" \
    -F "message=$MESSAGE" \
    -F "device=desktop" \
    -F "title=$TITLE" \
    -F "sound=spacealarm" \
    https://api.pushover.net/1/messages.json | grep '"status":1' > /dev/null

# Check the exit code to identify an error
if [ $? -eq 0 ];
    then
        exit 0
    else
        echo "apprise failed"
        exit 1
fi
