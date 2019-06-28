#!/usr/bin/env bash

######################################################################
# Wrapper script for database backup
#
# Author:   Michael Kaindleinsberger
# Mail:     m.Kaindleinsberger@gmail.com
# Date:     20.06.2019
# Copyright 2017
# License: MIT
#######################################################################

#set -x

set -euo pipefail
IFS=$'\n\t'

readonly PROGRAM_NAME=$(basename $0)
readonly PROGRAM_VERSION="0.6"
readonly PROGRAM_DATE="20.06.2019"

source /etc/database-dump.conf
MYSQL="${MYSQL:-/usr/bin/mysql}"
TELEGRAM="${TELEGRAM:-false}"

info()    { logger "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [INFO]    $@" ; echo "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [INFO]    $@" ; [ "$TELEGRAM" = true ] && telegram-notify --silent --html --text "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [INFO]    $@" ; }
warning() { logger "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [WARNING] $@" ; echo "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [WARNING] $@" ; [ "$TELEGRAM" = true ] && telegram-notify --silent --html --text "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [WARNING] $@" ; }
error()   { logger "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [ERROR]   $@" ; echo "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [ERROR]   $@" ; [ "$TELEGRAM" = true ] && telegram-notify --silent --html --text "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [ERROR]   $@" ; }
fatal()   { logger "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [FATAL]   $@" ; echo "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [FATAL]   $@" ; [ "$TELEGRAM" = true ] && telegram-notify --silent --html --text "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [FATAL]   $@" ; exit 1 ; }

[ -z "$DB_HOST" ] && fatal "DB_HOST not set. Please check config file."
[ -z "$DB_USERNAME" ] && fatal "DB_USERNAME not set. Please check config file."
[ -z "$DB_PASSWORD" ] && fatal "DB_PASSWORD not set. Please check config file."

create_dumps() {

  info "starting to dump all databases to seperate files ..."

  for db in $($MYSQL --host=$DB_HOST --user=$DB_USERNAME --password=$DB_PASSWORD --batch --skip-column-names -e "SHOW DATABASES;" | grep -v 'mysql\|information_schema');
  do
    if [[ ("$db" != "performance_schema") && ("$db" != "information_schema") ]]; then
      database-dump -s "$db" -u "$DB_USERNAME" -p "$DB_PASSWORD" -f /tmp
      info "dumped $db."
    else
      info "skipped $db"
    fi
  done

  info "done."
}

move_dumps() {
  cd /tmp
  local files="*.sql"

  info "moving all dumps to mounted backup-path ..."

  for f in $files;
  do
    mv $f $BACKUP_PATH/$f
    info "moved $f."
  done

  info "done."
}

rotate_dumps() {
  cd /$BACKUP_PATH

  bkup_files="$(find -maxdepth 1 -mtime +31 -type f | wc -l)"

  info "deleting all dumps older than 31 days ..."

  if ($bkup_files > 14); then
    info "found dumps to delete ..."
    result="$(find -maxdepth 1 -mtime +31 -type f -delete)"
    info "delete returned: $result"
  else
    info "no dumps found to delete"
  fi

  info "done."
}

main() {
  info "started!"

  create_dumps
  move_dumps
  rotate_dumps

  info "finished"

  exit 0
}

main
