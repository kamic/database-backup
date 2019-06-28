# database-backup
 Wrapper script for database backup

## Disclaimer
 This software is not production ready and only for personal use for somebody who understands the script and accepts the involved risks.
 There is no safety/sanity check or whatsoever!

## Requirements
 * optional requires [telegram-notify](http://www.bernaerts-nicolas.fr/linux/75-debian/351-debian-send-telegram-notification)

## Installation
 1. Clone repo
 2. Rename `database-dump.conf.example` to `database-dump.conf`
 3. Make changes according to your liking/needs
 4. Rename `database-backup.conf.example` to `database-backup.conf`
 5. Make changes according to your liking/needs
 6. use install.sh for installation under /usr/local/sbin/ or

    1. place `database-dump.conf` as `/etc/database-dump.conf`
    2. place `database-backup.conf` as `/etc/database-backup.conf`
    3. rename `database-dump.sh` to `database-dump` and make it executeable

        `$ chmod +x /path/to/database-dump`
    4. rename `database-backup.sh` to `database-backup` and make it executeable

        `$ chmod +x /path/to/database-backup`
    5. move executeables to desired path
 7. have fun

## Usage for database-dump as standalone script
```
database-dump [Options]

Options:
  -h        show help.
  -a        backup all databases into one file.
  -s        backup one database into one file.
              use like -s <database-name>
  -u        database user.
              use like -u <username>
  -p        database password.
              use like -p <password>
  -f        path in which dump should be written.
              use like -f </path/to/file>"
```
