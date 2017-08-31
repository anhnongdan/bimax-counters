#!/bin/sh
sysctl fs.inotify.max_user_watches=65565
conf=/mnt/app/bimax-counters/monitor/bi_filter.conf
queue_host=`awk -F'=' '/filter_queue_host=/ {print $2}' $conf | head -1`
rd="/usr/bin/redis-cli $queue_host"

/usr/bin/inotifywait -r -m /data/cdn --format "%w%f" -e create | while read f;do
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


        log=`awk -F'=' '/filter_queue_log=/ {print $2}' $conf | head -1`
        requeue_list=`awk -F'=' '/filter_queue_list=/ {print $2}' $conf | head -1`
        requeue_state=`awk -F'=' '/filter_queue_state=/ {print $2}' $conf | head -1`
        while [ "$requeue_state" == "pause" ];do 
		sleep 1
        	log=`awk -F'=' '/filter_queue_log=/ {print $2}' $conf | head -1`
        	requeue_list=`awk -F'=' '/filter_queue_list=/ {print $2}' $conf | head -1`
	        requeue_state=`awk -F'=' '/filter_queue_state=/ {print $2}' $conf | head -1`
	done

	domain=`echo "$f" | awk -F '/' '{print $4}'`
        last=`echo "rpop $domain" | $rd`

        if [ -z "$last" ];then
                echo "rpush $domain $f" | $rd
        else
		echo "`date`:$last" >> $log
		for qq in $requeue_list;do
			echo "rpush $qq $last" | $rd
		done
		#last="$f"
                echo "rpush $domain $f" | $rd
        fi

done
