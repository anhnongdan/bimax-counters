#!/bin/sh
log=/var/log/process_queue_piwik.log
rd="/usr/bin/redis-cli -s /tmp/redis.sock"
proc="/usr/bin/python /mnt/app/bimax-counters/queue_piwik_1.0"
while true;do
	id=1
	echo "zrange process_queue1 0 7" | $rd | while read f;do 
                if [ -z "$f" ];then sleep 1;continue; fi
		echo "`date +%s` $f" >> $log
	#	echo "zadd process_queue2 `date +%s` $f" |$rd > /dev/null
		echo "zrem process_queue1 $f" |$rd > /dev/null
		echo $proc $f $id
                id=$((id + 1)) 
	done  | parallel -j8
	sleep 1
done
