#!/usr/bin/env bash

######################################################################
# Wrapper script for mysqldump
#
# Author:   Michael Kaindleinsberger
# Mail:     m.Kaindleinsberger@gmail.com
# Date:     20.06.2019
# Copyright 2019
# License: MIT
#######################################################################

#set -x

#set -euo pipefail
IFS=$'\n\t'

readonly PROGRAM_NAME=$(basename $0)
readonly PROGRAM_VERSION="0.4"
readonly PROGRAM_DATE="20.06.2019"

source /etc/database-dump.conf
MYSQL="${MYSQL:-/usr/bin/mysql}"
MYSQLDUMP="${MYSQLDUMP:-/usr/bin/mysqldump}"
DUMP_POSTFIX="${DUMP_POSTFIX:-$(date +"%Y%m%d_%H%M%S")}"
TELEGRAM="${TELEGRAM:-false}"

info()    { logger "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [INFO]    $@" ; echo "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [INFO]    $@" ; [ "$TELEGRAM" = true ] && telegram-notify --silent --html --text "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [INFO]    $@" ; }
warning() { logger "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [WARNING] $@" ; echo "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [WARNING] $@" ; [ "$TELEGRAM" = true ] && telegram-notify --silent --html --text "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [WARNING] $@" ; }
error()   { logger "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [ERROR]   $@" ; echo "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [ERROR]   $@" ; [ "$TELEGRAM" = true ] && telegram-notify --silent --html --text "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [ERROR]   $@" ; }
fatal()   { logger "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [FATAL]   $@" ; echo "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [FATAL]   $@" ; [ "$TELEGRAM" = true ] && telegram-notify --silent --html --text "$(date +'%d.%m.%Y %H:%M:%S') - $PROGRAM_NAME - [FATAL]   $@" ; exit 1 ; }

usage() {
  echo "$PROGRAM_NAME v$PROGRAM_VERSION from $PROGRAM_DATE"
  echo
  echo "Usage: $PROGRAM_NAME [Options]"
  echo
  echo "Options:"
  echo "  -h        show help."
  echo "  -a        backup all databases into one file."
  echo "  -s        backup one database into one file."
  echo "              use like -s <database-name>"
  echo "  -u        database user."
  echo "              use like -u <username>"
  echo "  -p        database password."
  echo "              use like -p <password>"
  echo "  -f        path in which dump should be written."
  echo "              use like -f </path/to/file>"
}

mysqldump_all() {
  local db_username="$1"
  local db_password="$2"
  local filename="$3"

  $MYSQLDUMP \
  --host="database" \
  --user="$db_username" --password="$db_password" \
  --all-databases \
  --opt \
  --events --routines --triggers \
  --flush-privileges \
  --single-transaction \
  > "$filename"
}

mysqldump_database() {
  local db_username="$1"
  local db_password="$2"
  local filename="$3"
  local db_name="$4"

  $MYSQLDUMP \
  --host="database" \
  --user="$db_username" --password="$db_password" \
  --databases "$db_name"\
  --opt \
  --events --routines --triggers \
  --flush-privileges \
  --single-transaction \
  > "$filename"
}

main () {
  local full_path="none"

  if [[ "$user" == "none" ]]; then
    fatal "Argument -u is missing!"
  fi

  if [[ "$password" == "none" ]]; then
    fatal "Argument -p is missing!"
  fi

  if [[ "$path" == "none" ]]; then
    fatal "Argument -f is missing!"
  fi

  if [[ ("$database" != "none") && ("$flag_a" -gt 0) ]]; then
    fatal "You can't use options a & s together!"
  fi

  if [[ "$flag_a" -gt 0 ]]; then
    full_path="$path"/mysqldump-"$DUMP_POSTFIX.sql"

    info "starting full dump of all mysql-databases."
    mysqldump_all "$user" "$password" "$full_path"
    info "done."
    exit 0
  else
    full_path="$path"/"$database"-"$DUMP_POSTFIX.sql"

    info "starting full dump of database "+"$database"
    mysqldump_database "$user" "$password" "$full_path" "$database"
    info "done"
    exit 0
  fi
}




declare flag_a=0
declare database="none"
declare user="none"
declare password="none"
declare path="none"

while getopts "has:u:p:f:" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    a)
      flag_a=1
      info "set to dump all databases."
      ;;
    s)
      database="$OPTARG"
      info "set to dump database $database."
      ;;
    u)
      user="$OPTARG"
      info "set to use user $user."
      ;;
    p)
      password="$OPTARG"
      info "set to use password $password."
      ;;
    f)
      path="$OPTARG"
      info "set to use path $path for dumps."
      ;;
    :)
      fatal "Option -$OPTARG requires an argument."
      ;;
    \?)
      fatal "Invalid option: -$OPTARG."
      ;;
  esac
done

main
