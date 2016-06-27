#!/bin/sh
log=/var/log/process_queue_piwik.log
rd="/usr/bin/redis-cli -s /tmp/redis_counters.sock"
proc="/usr/bin/python /mnt/app/bimax-counters/queue_piwik_1.0"

conf=/mnt/app/bimax-counters/bi.conf

tmp=`mktemp`
tmpd=`mktemp -d`	
while true;do
        requeue_cc=`awk -F'=' '/piwik_queue_cc=/ {print $2}' $conf | head -1`
        requeue_ll=`awk -F'=' '/piwik_queue_ll=/ {print $2}' $conf | head -1`
        requeue_state=`awk -F'=' '/piwik_queue_state=/ {print $2}' $conf | head -1`
        if [ "$requeue_state" == "pause" ];then sleep 1;continue;fi

	id=1
	nn=$((requeue_ll + 1))
	echo "zrange process_queue1 -$requeue_cc -1" | $rd | sort -r | while read f;do 
	#echo "zrange process_queue1 0 $nn" | $rd | while read f;do 
                if [ -z "$f" ];then sleep 1;continue; fi
		ll=`wc -l $f | awk -v ll=$requeue_ll  '{printf("%.f", $1/ll);}'`
		cd $tmpd
		split -l $ll $f	
		echo "`date +%s` $f" >> $log
	#	echo "zadd process_queue2 `date +%s` $f" |$rd > /dev/null
		echo "zrem process_queue1 $f" |$rd > /dev/null
		find $tmpd -type f | while read ff;do
			echo $proc $ff $id
		done
                id=$((id + 1)) 
	done  > $tmp 
	cmd="`cat $tmp`"	
	if [ -n "$cmd" ];then
		echo "$cmd" | parallel -j$nn
	fi
	rm -f $tmpd/*
	sleep 1
done
