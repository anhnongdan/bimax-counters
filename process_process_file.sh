#!/bin/sh
log=/var/log/process_process_file.log
rd="/usr/bin/redis-cli -s /tmp/redis_counters.sock"
proc="/usr/bin/python /mnt/app/bimax-counters/process_1.0"
conf=/mnt/app/bimax-counters/bi.conf
tmp=`mktemp`
tmpd=`mktemp -d`
while true;do
   	requeue_cc=`awk -F'=' '/process_queue_cc=/ {print $2}' $conf | head -1`
        requeue_ll=`awk -F'=' '/process_queue_ll=/ {print $2}' $conf | head -1`

	fn="/data/logs/`date +'%Y/%m/%d' --date='1 minute ago'`/track-`date +'%Y-%m-%d-%H-%M' --date='1 minute ago'`"
        requeue_state=`awk -F'=' '/process_queue_state=/ {print $2}' $conf | head -1`
        if [ "$requeue_state" == "pause" ];then sleep 1;continue;fi
	
	nn=$((requeue_ll + 1))
	#echo "zrange process_queue 0 $nn" | $rd | while read f;do 
	fn="/data/logs/`date +'%Y/%m/%d' --date='1 minute ago'`/track-`date +'%Y-%m-%d-%H-%M' --date='1 minute ago'`"
	echo "zrange process_queue -$requeue_cc -1" | $rd | sort -r | while read f;do
                if [[ "$f" < "$fn" ]];then 
			echo "`date`:ignore $f" >> $log
		else
			echo "`date`:process $f" >> $log
			echo $f
		fi
	done | while read f;do 
                if [ -z "$f" ];then sleep 1;continue; fi
                if [ ! -f "$f" ];then sleep 1;continue; fi
		ccu="`wc -l $f | awk '{printf("%.f",$1/10);}'`"
		echo "set CCU $ccu" | $rd > /dev/null
	#	echo "zadd process_queue1 `date +%s` $f" |$rd > /dev/null
 		ll=`wc -l $f | awk -v ll=$requeue_ll  '{printf("%.f", $1/ll);}'`
                cd $tmpd
                split -l $ll $f
		find $tmpd -type f | while read ff;do
                        echo $proc $ff
                done
		echo "zrem process_queue $f" |$rd > /dev/null
	done  > $tmp

	cmd="`cat $tmp`"
        if [ -n "$cmd" ];then
                echo "$cmd" | parallel -j32
        fi
	rm -f $tmpd/*
	sleep 1
done
