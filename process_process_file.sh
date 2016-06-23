#!/bin/sh
log=/var/log/process_process_file.log
rd="/usr/bin/redis-cli -s /tmp/redis.sock"
proc="/usr/bin/python /mnt/app/bimax-counters/process_1.0"
while true;do
	echo "zrange process_queue 0 7" | $rd | while read f;do 
                if [ -z "$f" ];then sleep 1;continue; fi
		echo "`date +%s` $f" >> $log
		ccu="`wc -l $f | awk '{printf("%.f", $1/10);}'`"
		echo "set CCU $ccu"  | $rd
		echo "zadd process_queue_history `date +%s` $f" | $rd > /dev/null
		echo "zrem process_queue $f" | $rd > /dev/null
		echo $proc $f
	done  | parallel -j8
	sleep 1
done
