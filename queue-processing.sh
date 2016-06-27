#!/bin/sh
log=/tmp/archive.log
console=/usr/share/nginx/html/piwik/console
queue(){
        $console queuedtracking:$@
}
while true;do
	queue process
	sleep 1
done
exit 0
