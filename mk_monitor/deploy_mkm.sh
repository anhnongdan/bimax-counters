#!/bin/bash
MYDIR="$(dirname "$(realpath "$0")")"

cp $MYDIR/haproxy* /usr/lib/check_mk_agent/plugins/
cat $MYDIR/logwatch.cfg >> /etc/check_mk/logwatch.cfg
