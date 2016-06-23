#!/bin/sh
rd="/usr/bin/redis-cli -s /tmp/redis.sock"
/usr/bin/inotifywait -r -m /data/logs --format "%w%f" -e create | while read f;do
	if [ -z "$last" ];then
		last="$f"
	else
		echo "zadd process_queue `date +%s` $last" | $rd
		last="$f"
	fi
done
