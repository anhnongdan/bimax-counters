#!/bin/sh
conf=/mnt/app/bimax-counters/splitter/bi_splitter.conf
proc="/mnt/app/bimax-counters/splitter/queue_piwik_splitter.py"

tmp=`mktemp`
tmpd=`mktemp -d`	
while true;do
	delay=`awk -F'=' '/splitter_delay=/ {print $2}' $conf | head -1`
	log=`awk -F'=' '/splitter_log=/ {print $2}' $conf | head -1`
	queue_host=`awk -F'=' '/splitter_queue_host=/ {print $2}' $conf | head -1`
	rd="/usr/bin/redis-cli $queue_host"
        queue_name=`awk -F'=' '/splitter_queue_name=/ {print $2}' $conf | head -1`
        queue_dup=`awk -F'=' '/splitter_queue_dup=/ {print $2}' $conf | head -1`
        queue_next=`awk -F'=' '/splitter_queue_next=/ {print $2}' $conf | head -1`
        requeue_cc=`awk -F'=' '/splitter_cc=/ {print $2}' $conf | head -1`
        requeue_ll=`awk -F'=' '/splitter_ll=/ {print $2}' $conf | head -1`
        requeue_state=`awk -F'=' '/splitter_state=/ {print $2}' $conf | head -1`
        if [ "$requeue_state" == "pause" ];then sleep 1;continue;fi

	if [ -n "$queue_dup" ];then
		for queue_each in $queue_dup;do
			echo "rpush $queue_each $f" |$rd > /dev/null
		done
	fi

	id=1
	nn=$((requeue_ll + 1))
#	dd1=`date +'%Y/%m/%d' --date="$delay minute ago"`	
	dd2=`date +'%Y-%m-%d-%H-%M' --date="$delay minute ago"`
#	fn="/data/logs/$dd1/track-$dd2"
	#echo "lrange $queue_name -$requeue_cc -1" | $rd | sort -r | while read fff;do 
	f="`echo "rpop $queue_name" | $rd`"
#| while read f;do 
		#echo "`date`: raw $f" >> $log
                if [ -z "$f" ];then sleep 1;continue; fi
                if [ ! -f "$f" ];then sleep 1;continue; fi
		dd="`echo $f | awk -F'/' '{sub(/track-/,"",$7);sub(/-.\.log$/,"",$7);print $7}'`"
                #echo "`date`: compare $dd vs $dd2" >> $log
	   	if [ "$dd" \< "$dd2" ];then
                        echo "`date`:ignore $f" >> $log
			echo "rpush $queue_next $f" |$rd > /dev/null
			#echo "zrem $queue_name $f" |$rd > /dev/null
			continue
                #else
                #        echo $f
                fi
                echo "`date`:process $f" >> $log
		#echo "zrem $queue_name $f" |$rd > /dev/null
	#done  |  while read f;do
        #        if [ -z "$f" ];then sleep 1;continue; fi
        #        if [ ! -f "$f" ];then sleep 1;continue; fi
		ll=`wc -l $f | awk -v ll=$requeue_ll  '{printf("%.f", $1/ll);}'`
		cd $tmpd
		split -l $ll $f	
		> $tmp
		find $tmpd -type f | while read ff;do
			echo $proc $ff $id >> $tmp
                	id=$((id + 1)) 
		done
	#done  > $tmp 
	cmd="`cat $tmp`"	
	if [ -n "$cmd" ];then
		echo "$cmd" | parallel -j32
	fi
	rm -f $tmpd/*
	sleep 1
done
