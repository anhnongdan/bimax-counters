#!/bin/sh
log=/var/log/process_queue_piwik_real.log
conf=/mnt/app/bimax-counters/bi.conf
queue_host=`awk -F'=' '/piwik_queue_real_host=/ {print $2}' $conf | head -1`
rd="/usr/bin/redis-cli $queue_host"
proc="/usr/bin/python /mnt/app/bimax-counters/queue_piwik_1.0"
qinfo=/usr/lib/check_mk_agent/update.info


tmp=`mktemp`
tmpd=`mktemp -d`	
while true;do
        requeue_cc=`awk -F'=' '/piwik_queue_real_cc=/ {print $2}' $conf | head -1`
        requeue_ll=`awk -F'=' '/piwik_queue_real_ll=/ {print $2}' $conf | head -1`
        requeue_state=`awk -F'=' '/piwik_queue_real_state=/ {print $2}' $conf | head -1`
        if [ "$requeue_state" == "pause" ];then sleep 1;continue;fi


        qlimit=`awk -F'=' '/piwik_queue_real_qlimit=/ {print $2}' $conf | head -1`
        nq="`awk -F'|' '/queue_stat/ {sub(/^.*=/,"",$1);print $1}' $qinfo`"
        while [ $nq -gt $qlimit ];do
                echo "`date`: reach limit $qlimit wait for release queue:$nq" >> $log
                sleep 10
                nq="`awk -F'|' '/queue_stat/ {sub(/^.*=/,"",$1);print $1}' $qinfo`"
        done



	id=1
	nn=$((requeue_ll + 1))
	fn="/data/logs/`date +'%Y/%m/%d' --date='1 minute ago'`/track-`date +'%Y-%m-%d-%H-%M' --date='1 minute ago'`"
	echo "zrange process_queue1 -$requeue_cc -1" | $rd | sort -r | while read f;do 
	   	if [[ "$f" < "$fn" ]];then
                        echo "`date`:ignore $f" >> $log
			echo "zadd process_queue2 `date +%s` $f" |$rd > /dev/null
                else
                        echo "`date`:process $f" >> $log
                        echo $f
                fi
		echo "zrem process_queue1 $f" |$rd > /dev/null
	done | while read f;do
                if [ -z "$f" ];then sleep 1;continue; fi
                if [ ! -f "$f" ];then sleep 1;continue; fi
		ll=`wc -l $f | awk -v ll=$requeue_ll  '{printf("%.f", $1/ll);}'`
		cd $tmpd
		split -l $ll $f	
		find $tmpd -type f | while read ff;do
			echo $proc $ff $id
		done
                id=$((id + 1)) 
	done  > $tmp 
	cmd="`cat $tmp`"	
	if [ -n "$cmd" ];then
		echo "$cmd" | parallel -j32
	fi
	rm -f $tmpd/*
	sleep 1
done
