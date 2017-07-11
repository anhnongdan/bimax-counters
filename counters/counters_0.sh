#!/bin/sh
#log=/var/log/process_process_file.log
#log=/dev/null
conf=/mnt/app/bimax-counters/counters/bi_counters_0.conf

queue_host=`awk -F'=' '/process_queue_host=/ {print $2}' $conf | head -1`
rd="/usr/bin/redis-cli $queue_host"

proc="/usr/bin/python /mnt/app/bimax-counters/counters/process_1.4"
tmp=`mktemp`
tmpd=`mktemp -d`
while true;do
   	log=`awk -F'=' '/process_queue_log=/ {print $2}' $conf | head -1`
   	requeue_cc=`awk -F'=' '/process_queue_cc=/ {print $2}' $conf | head -1`
        requeue_ll=`awk -F'=' '/process_queue_ll=/ {print $2}' $conf | head -1`
        queue_name=`awk -F'=' '/process_queue_name=/ {print $2}' $conf | head -1`
#        queue_next=`awk -F'=' '/process_queue_next=/ {print $2}' $conf | head -1`

	#fn="/data/logs/`date +'%Y/%m/%d' --date='1 minute ago'`/track-`date +'%Y-%m-%d-%H-%M' --date='1 minute ago'`"
        requeue_state=`awk -F'=' '/process_queue_state=/ {print $2}' $conf | head -1`
        if [ "$requeue_state" == "pause" ];then sleep 1;continue;fi
	
#	nn=$((requeue_ll + 1))
#	dd2=`date +'%Y-%m-%d-%H-%M' --date="$delay minute ago"`
	#echo "zrange process_queue 0 $nn" | $rd | while read f;do 
	#fn="/data/logs/`date +'%Y/%m/%d' --date='1 minute ago'`/track-`date +'%Y-%m-%d-%H-%M' --date='1 minute ago'`"
	f="`echo "rpop $queue_name" | $rd`"
                if [ -z "$f" ];then sleep 1;continue; fi
                if [ ! -f "$f" ];then sleep 1;continue; fi

 	#	dd="`echo $f | awk -F'/' '{sub(/track-/,"",$7);sub(/-.\.log$/,"",$7);print $7}'`"

         #       if [ "$dd" \< "$dd1" ];then 
	#		echo "`date`:ignore $f" >> $log
	#		echo "rpush $queue_next $f" |$rd > /dev/null
	#		continue
	#	fi
		echo "`date`:process $f" >> $log
		ccu="`wc -l $f | awk '{printf("%.f",$1/10);}'`"
		echo "set CCU $ccu" | $rd > /dev/null
	#	echo "zadd process_queue1 `date +%s` $f" |$rd > /dev/null
 		ll=`wc -l "$f" | awk -v ll=$requeue_ll  '{printf("%.f", $1/ll);}'`
                cd $tmpd
                split -l $ll "$f"
		> $tmp
		find $tmpd -type f | while read ff;do
                        echo $proc $ff >> $tmp
                done

	cmd="`cat $tmp`"
        if [ -n "$cmd" ];then
                echo "$cmd" | parallel -j32
        fi
	rm -f $tmpd/*
	sleep 1
done
