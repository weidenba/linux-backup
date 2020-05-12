#! /bin/sh

BACKUPSERVERMAC="00:00:00:00:00:00"
USERNAME="BACKUP_SERVER_LOGIN"
SERVERADDRESS="BACKUP_SERVER_ADDRESS"
BACKUPDRIVE="/dev/sdX"
MOUNTDST="/mnt/backup"
SRC="/home /var"
OPTIONS="--exclude='*.cache*' --exclude='tmp'"
PASSWORD="BACKUP_DRIVE_PASSWORD"

# ------ Do not edit below this line! ------

LOGIN="$USERNAME@$SERVERADDRESS"
DST="$LOGIN:$MOUNTDST"
DECRYPTCOMMAND="echo $PASSWORD | sudo /sbin/cryptsetup luksOpen $BACKUPDRIVE cryptedBackup0"
DECRYPTCOMMAND="'"$DECRYPTCOMMAND"'"
RSYNCCOMMAND="sudo /usr/bin/rsync -azhP -e ssh --progress $OPTIONS --del $SRC $DST"

echo "STARTING BACKUP..."
echo "WAKEUP BACKUP SERVER..."
wakeonlan $BACKUPSERVERMAC
echo "WAIT FOR $SERVERADDRESS TO BOOT..."
sleep 90
echo -e '\E[33m' "DECRYPT BACKUPDISK $MOUNTDST ..."; tput sgr0
eval "ssh $LOGIN $DECRYPTCOMMAND" || exit 1
sleep 5
echo -e '\E[33m' "MOUNT BACKUPDISK $MOUNTDST ..."; tput sgr0
ssh $LOGIN 'sudo /bin/mount /dev/mapper/cryptedBackup0 /mnt/backup' || exit 1
sleep 5
eval $RSYNCCOMMAND
sleep 5
echo -e '\E[33m' "DISK SPACE AFTER BACKUP: "; tput sgr0
ssh $LOGIN 'df -h | grep /mnt/backup'

echo -e '\E[33m' "UMOUNT BACKUPDISK..."; tput sgr0
ssh $LOGIN 'sudo /bin/umount /mnt/backup'
sleep 5
echo -e '\E[33m' "ENCRYPT BACKUPDISK $MOUNTDST ..."; tput sgr0
ssh $LOGIN 'sudo /sbin/cryptsetup luksClose /dev/mapper/cryptedBackup0'
sleep 5
echo "SHUTDOWN BACKUP SERVER"
ssh $LOGIN 'sudo /sbin/shutdown -h now'
echo "BACKUP COMPLETE"

