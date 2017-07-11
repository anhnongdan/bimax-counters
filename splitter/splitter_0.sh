#!/bin/sh
conf=/mnt/app/bimax-counters/splitter/bi_splitter_0.conf
proc="/mnt/app/bimax-counters/splitter/queue_piwik_splitter.py"

tmp=`mktemp`
tmpd=`mktemp -d`	
while true;do
	delay=`awk -F'=' '/splitter_delay=/ {print $2}' $conf | head -1`
	log=`awk -F'=' '/splitter_log=/ {print $2}' $conf | head -1`
	queue_host=`awk -F'=' '/splitter_queue_host=/ {print $2}' $conf | head -1`
	rd="/usr/bin/redis-cli $queue_host"
        queue_name=`awk -F'=' '/splitter_queue_name=/ {print $2}' $conf | head -1`
        requeue_cc=`awk -F'=' '/splitter_cc=/ {print $2}' $conf | head -1`
        requeue_ll=`awk -F'=' '/splitter_ll=/ {print $2}' $conf | head -1`
        requeue_state=`awk -F'=' '/splitter_state=/ {print $2}' $conf | head -1`
        if [ "$requeue_state" == "pause" ];then sleep 1;continue;fi


	id=1
	nn=$((requeue_ll + 1))
	f="`echo "rpop $queue_name" | $rd`"
                echo "`date`:process $f" >> $log
		ll=`wc -l $f | awk -v ll=$requeue_ll  '{printf("%.f", $1/ll);}'`
		cd $tmpd
		split -l $ll $f	
		> $tmp
		find $tmpd -type f | while read ff;do
			echo $proc $ff $id >> $tmp
                	id=$((id + 1)) 
		done
	cmd="`cat $tmp`"	
	if [ -n "$cmd" ];then
		echo "$cmd" | parallel -j32
	fi
	rm -f $tmpd/*
	sleep 1
done
