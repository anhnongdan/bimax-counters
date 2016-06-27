#!/bin/sh
import=/mnt/app/bimax-counters
pw=/usr/share/nginx/html/piwik
ilogs=$import/import_logs.py
tk=0eee725762ddb2e65d1701726418ab73
opt=""
if [ $1 -eq 1  ];then
	opt="--add-sites-new-hosts"
fi
#url="172.20.4.64"
url="localhost"
exec python $ilogs \
 --token-auth=$tk \
 --config=$pw/config/config.ini.php \
 --url=http://$url/ $opt \
 --recorders=32 --recorder-max-payload-size=200 --enable-http-errors --enable-http-redirects --enable-static --enable-bots \
 --log-format-name=nginx_json - 
 #--debug  --log-format-name=nginx_json - 
