!/bin/bash
backup_dir="/backup"
cp -r /etc/ $backup_dir
cp -r /home/ $backup_dir
backup_file="backup_$(date +%Y%m%d%H%M%S).tar.gz"
tar -czvf $backup_dir/$backup_file.tar.gz $backup_dir/etc/*
tar -cvzf $backup_dir/$backup_file $backup_dir/home/*
rm -rf $backup_dir/etc/
rm -rf $backup_dir/home
