#!/bin/sh
log=/usr/lib/check_mk_agent/update.info
lock=/var/run/updateinfo.lock
touch $lock
> ${log}.1
find /usr/lib/check_mk_agent/local.internal -type f | while read f;do
	echo "sh $f >> ${log}.1"
done  | parallel -j32 
mv -f ${log}.1 $log
rm -f $lock
