#!/bin/bash

# Maintainer:   jeffskinnerbox@yahoo.com / www.jeffskinnerbox.me
# Version:      1.5.0


#set -x

# arguments to be used with rsync
ARGS="-aev --delete --numeric-ids --relative --delete-excluded"
EXCL_DESKTOP="--exclude-from=/home/backup_user/rsync-exclude-desktop --exclude=mnt/backup"
EXCL_RPI="--exclude-from=/home/backup_user/rsync-exclude-RPi"
EXCL_WINDOWS="--exclude-from=/home/backup_user/rsync-exclude-windows"
REMOTE_WRAPPER="--rsync-path=/home/backup_user/bin/rsync-wrapper.sh"
SSH_ARGS="--rsh=\"/usr/bin/ssh -o CheckHostIP=no -i /home/backup_user/.ssh/id_rsa\""

# Location of the Log file
LOG="/home/backup_user/backup.log"

DIR=`date +%Y_%b_%d_%H_%M`

while true; do
    read -p "What would you like to backup? ('desktop', 'RedRPi', 'BlackRPi', or 'SaraPC')  " answer
    case $answer in
        'desktop' )
            ARGUMENTS="$ARGS $EXCL_DESKTOP"
            SOURCE="/."
            DESTINATION="/mnt/backup/full-backup/desktop/$DIR"
            break;;
        'RedRPi' )
            ARGUMENTS="$ARGS $EXCL_RPI $REMOTE_WRAPPER $SSH_ARGS"
            SOURCE="backup_user@RedRPi:/"
            DESTINATION="/mnt/backup/full-backup/RedRPi/$DIR"
            break;;
        'BlackRPi' )
            ARGUMENTS="$ARGS $EXCL_RPI $REMOTE_WRAPPER $SSH_ARGS"
            SOURCE="backup_user@BlackRPi:/"
            DESTINATION="/mnt/backup/full-backup/BlackRPi/$DIR"
            break;;
        'SaraPC' )
            ARGUMENTS="$ARGS $EXCL_WINDOWS --fake-super $SSH_ARGS"
            SOURCE="Sara@SaraPC:/"
            DESTINATION="/mnt/backup/full-backup/SaraPC/$DIR"
            break;;
        [Qq]* )
            echo "Exiting script."
            exit;;
        * )
            echo "Please answer 'desktop', 'RedRPi', 'BlackRPi', 'SaraPC' or 'q' to quit";;
    esac
done

# Capture scripts start time
STARTTIME=`date +%s`

# Place in the log file information concerning the execution of this script
echo -e "\n\n####" $answer "full-backup script started on `date` ####" >> $LOG
echo -n "options passed to rsync: " >> $LOG
echo "$ARGUMENTS $SOURCE $DESTINATION" >> $LOG

# Now execute the script, also capture scripts end time, calculate run time,
# and send status notification to Pushover app
( STARTTIME=`date +%s` ; eval /usr/bin/rsync "$ARGUMENTS $SOURCE $DESTINATION" >> $LOG 2>&1 ;\
EXITSTATUS=$? ;\
echo "rsync terminated with exit status $EXITSTATUS." >> $LOG ;\
echo "####" $answer "full-backup script completed at `date` ####" >> $LOG ;\
ENDTIME=`date +%s` ;\
INTERVAL=$((ENDTIME - STARTTIME)) ;\
RUNTIME="$(($INTERVAL / 60)) min. $(($INTERVAL % 60)) sec." ;\
/home/jeff/bin/apprise -t "Full Backup Status" -m "Filesystem backup took $RUNTIME and completed on `date` with exit status $EXITSTATUS." ) &

echo "Full Backup Underway From '$SOURCE' To '$DESTINATION'"


#-------------------------------------
#
#/usr/bin/rsync -aev --delete --numeric-ids --relative --delete-excluded --exclude-from=/home/backup_user/rsync-exclude-desktop --exclude=mnt/backup /. /mnt/backup/full-backup/desktop/
#
#/usr/bin/rsync -aev --delete --numeric-ids --relative --delete-excluded --exclude-from=/home/backup_user/rsync-exclude-RPi --rsync-path=/home/backup_user/bin/rsync-wrapper.sh --rsh="/usr/bin/ssh -i /home/backup_user/.ssh/id_rsa" backup_user@RedRPi:/ /mnt/backup/full-backup/RedRPi/
#
#/usr/bin/rsync -aev --delete --numeric-ids --relative --delete-excluded --exclude-from=/home/backup_user/rsync-exclude-RPi --rsync-path=/home/backup_user/bin/rsync-wrapper.sh --rsh="/usr/bin/ssh -i /home/backup_user/.ssh/id_rsa" backup_user@BlackRPi:/ /mnt/backup/full-backup/BlackRPi/
#
#/usr/bin/rsync -aev --delete --numeric-ids --relative --delete-excluded --exclude-from=/home/backup_user/rsync-exclude-windows --fake-super --rsh="/usr/bin/ssh -i /home/backup_user/.ssh/id_rsa" Sara@SaraPC:/ /mnt/backup/full-backup/SaraPC/
