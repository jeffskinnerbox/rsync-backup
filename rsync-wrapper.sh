#!/bin/bash

# Maintainer:   jeffskinnerbox@yahoo.com / www.jeffskinnerbox.me
# Version:      1.5.0


#set -x

# This script is a wrapper around rsync, so that rsync can run as root,
# and at the same time, eliminate any security risks.

# Location of the Log file
LOG="/home/backup_user/backup.log"

# Place in the log file information concerning the execution of this script
echo "rsync wrapper script executed on `date`" >> $LOG
echo "options passed to rsync: " $@ >> $LOG
echo "---------------------------------------------" >> $LOG

# Now execute the script
/usr/bin/sudo /usr/bin/rsync "$@"
