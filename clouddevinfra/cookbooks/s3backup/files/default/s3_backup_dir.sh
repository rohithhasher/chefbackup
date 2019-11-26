#!/bin/bash

NO_ARGS=0
if [ $# -eq "$NO_ARGS" ] # should check for no arguments
then
	echo "Usage: `basename $0` <backup-name> <folder> <frequency>"
	echo "You must specify backup name and the backup folder"
	exit 1
fi

configName=$1
folder=$2
frequency=$3

tstamp=`date +%Y-%m-%d-%H%M%S`
fname=$configName-$tstamp
#tar -czf /mnt/$fname.tar.gz $folder
#echo s3cmd put /mnt/$fname.tar.gz s3://clouddevinfra/backups/$frequency/$configName/$fname.tar.gz 
#s3cmd put /mnt/$fname.tar.gz s3://clouddevinfra/backups/$frequency/$configName/$fname.tar.gz 
#rm /mnt/$fname.tar.gz
tar -cvpz  /mnt/$fname.tar.gz $folder/ | split -d -b 3900m -  /mnt/$fname.tar.gz.
echo s3cmd put /mnt/$fname.tar.gz s3://clouddevinfra/backups/$frequency/$configName/$fname.tar.gz
s3cmd put /mnt/$fname.tar.gz* s3://clouddevinfra/backups/$frequency/$configName
rm /mnt/$fname.tar.gz*
echo "$(hostname) Backup for $tstamp" | mail -s "$(hostname) Backup for :$tstamp" support@hashedin.com
