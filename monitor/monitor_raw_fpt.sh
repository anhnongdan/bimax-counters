#!/bin/sh
sysctl fs.inotify.max_user_watches=65565
MYDIR="$(dirname "$(realpath "$0")")"
conf=$MYDIR/bi_monitor_raw.conf
queue_host=`awk -F'=' '/monitor_queue_host=/ {print $2}' $conf | head -1`
rd="/usr/bin/redis-cli $queue_host"

/usr/bin/inotifywait -r -m /data/logs_fpt --format "%w%f" -e create | while read f;do
	if [ -z "$f" ];then continue; fi
        if [ ! -f "$f" ];then continue; fi

 	echo "$f" | grep ":" > /dev/null
        if [ $? -eq 0 ]; then continue;fi

 	echo "$f" | grep "%" > /dev/null
        if [ $? -eq 0 ]; then continue;fi
	
 	echo "$f" | grep "+" > /dev/null
        if [ $? -eq 0 ]; then continue;fi

 	echo "$f" | grep ";" > /dev/null
        if [ $? -eq 0 ]; then continue;fi

 	echo "$f" | grep -F '\' > /dev/null
        if [ $? -eq 0 ]; then continue;fi

 	if [ "$f" = "-" ];then continue;fi

        log=`awk -F'=' '/monitor_queue_log=/ {print $2}' $conf | head -1`
        requeue_list=`awk -F'=' '/monitor_queue_list=/ {print $2}' $conf | head -1`
        requeue_state=`awk -F'=' '/monitor_queue_state=/ {print $2}' $conf | head -1`
        while [ "$requeue_state" == "pause" ];do 
		sleep 1
        	log=`awk -F'=' '/monitor_queue_log=/ {print $2}' $conf | head -1`
        	requeue_list=`awk -F'=' '/monitor_queue_list=/ {print $2}' $conf | head -1`
	        requeue_state=`awk -F'=' '/monitor_queue_state=/ {print $2}' $conf | head -1`
	done





	if [ -z "$last" ];then
		last="$f"
	else
		echo "`date`:$last" >> $log
		for qq in $requeue_list;do
			echo "rpush $qq $last" | $rd
		done
		last="$f"
	fi
done
