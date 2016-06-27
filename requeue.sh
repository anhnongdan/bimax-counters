#!/bin/sh
log=/tmp/requeue.log
rd="/usr/bin/redis-cli -s /tmp/redis_counters.sock"
ldir=/data/logs
echo "`date`:$@" >> $log
list(){
	list="$@"
for f in "$list";do
	echo "zadd process_requeue1 `date +%s` $f" |$rd > /dev/null
done
}
range(){
	from=$1
	to=$2
		
}
$@
