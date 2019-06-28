#!/usr/bin/env bash

#run as root or with sudo

mv ./database-dump.conf /etc/database-dump.conf
mv ./database-backup.conf /etc/database-backup.conf

mv ./database-dump.sh /usr/local/sbin/database-dump
chmod +x /usr/local/sbin/database-dump

mv ./database-backup.sh /usr/local/sbin/database-backup
chmod +x /usr/local/sbin/database-backup
