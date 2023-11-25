#!/bin/bash
backup_files="/home /etc"
dest="/opt/backup"
day=$(date +%A-%F)
hostname=$(hostname -s)
archive_file="$hostname-$day.tgz"
tar czf $dest/$archive_file $backup_files
echo "Backup is done"
date +%A-$F-%T
ls -lh $dest
