#!/bin/bash
MYDIR="$(dirname "$(realpath "$0")")"

printf "\n" >> /etc/check_mk/logwatch.cfg
cat $MYDIR/logwatch.cfg >> /etc/check_mk/logwatch.cfg
printf "\n" >> /etc/check_mk/logwatch.cfg
