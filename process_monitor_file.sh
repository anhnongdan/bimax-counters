#!/bin/sh
conf=/mnt/app/bimax-counters/bi.conf
queue_host=`awk -F'=' '/monitor_queue_host=/ {print $2}' $conf | head -1`
rd="/usr/bin/redis-cli $queue_host"

/usr/bin/inotifywait -r -m /data/logs --format "%w%f" -e create | while read f;do
        requeue_list=`awk -F'=' '/monitor_queue_list=/ {print $2}' $conf | head -1`
        requeue_state=`awk -F'=' '/monitor_queue_state=/ {print $2}' $conf | head -1`
        while [ "$requeue_state" == "pause" ];do 
		sleep 1
        	requeue_list=`awk -F'=' '/monitor_queue_list=/ {print $2}' $conf | head -1`
	        requeue_state=`awk -F'=' '/monitor_queue_state=/ {print $2}' $conf | head -1`
	done


	if [ -z "$last" ];then
		last="$f"
	else
		for qq in $requeue_list;do
			echo "zadd $qq `date +%s` $last" | $rd
			#echo "zadd process_queue `date +%s` $last" | $rd
		done
		last="$f"
	fi
done
