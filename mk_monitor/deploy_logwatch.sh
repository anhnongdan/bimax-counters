#!/bin/bash
MYDIR="$(dirname "$(realpath "$0")")"

cat $MYDIR/logwatch.cfg >> /etc/check_mk/logwatch.cfg
