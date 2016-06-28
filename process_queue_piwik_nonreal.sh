#!/bin/sh
log=/var/log/process_queue_piwik_nreal.log
qinfo=/usr/lib/check_mk_agent/update.info
conf=/mnt/app/bimax-counters/bi.conf

queue_host=`awk -F'=' '/piwik_queue_nreal_host=/ {print $2}' $conf | head -1`
rd="/usr/bin/redis-cli $queue_host"


proc="/usr/bin/python /mnt/app/bimax-counters/queue_piwik_1.0"

tmp=`mktemp`
tmpd=`mktemp -d`	
while true;do
        requeue_cc=`awk -F'=' '/piwik_queue_nreal_cc=/ {print $2}' $conf | head -1`
        requeue_ll=`awk -F'=' '/piwik_queue_nreal_ll=/ {print $2}' $conf | head -1`
        requeue_state=`awk -F'=' '/piwik_queue_nreal_state=/ {print $2}' $conf | head -1`
        if [ "$requeue_state" == "pause" ];then sleep 1;continue;fi

	qlimit=`awk -F'=' '/piwik_queue_nreal_qlimit=/ {print $2}' $conf | head -1`
	nq="`awk -F'|' '/queue_stat/ {sub(/^.*=/,"",$1);print $1}' $qinfo`"
	while [ $nq -gt $qlimit ];do
		echo "`date`: reach limit $qlimit wait for release queue:$nq" >> $log
		sleep 10
		nq="`awk -F'|' '/queue_stat/ {sub(/^.*=/,"",$1);print $1}' $qinfo`"
	done
	id=1
	nn=$((requeue_ll + 1))
	echo "zrange process_queue2 -$requeue_cc -1" | $rd | sort -r | while read f;do 
	#echo "zrange process_queue1 0 $nn" | $rd | while read f;do 
                if [ -z "$f" ];then sleep 1;continue; fi
                if [ ! -f "$f" ];then sleep 1;continue; fi
		ll=`wc -l $f | awk -v ll=$requeue_ll  '{printf("%.f", $1/ll);}'`
		cd $tmpd
		split -l $ll $f	
		echo "`date`:process $f" >> $log
		echo "zrem process_queue2 $f" |$rd > /dev/null
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
