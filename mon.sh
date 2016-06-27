./tool.sh db_c;
echo -n "Load:";cat /proc/loadavg
echo -n "Queue:";cat /tmp/queue_stat.log
echo -n "redis queue:";echo info | redis-cli -h 172.20.4.67 |grep connected_client;
echo -n "redis counters:";echo info | redis-cli -s /tmp/redis_counters.sock  |grep connected_client;
echo -n "php-fpm:";ps -ef |awk "/php-fpm: pool/" |grep -v awk |wc -l;
echo -n "import_logs:";ps -ef |awk "/import_logs/" |grep -v awk |wc -l;
echo '------------------------------------'
echo "queue_process"
tail -3 /var/log/process_process_file.log
echo '------------------------------------'
echo "queue_piwik real:"
tail -3 /var/log/process_queue_piwik_real.log
echo '------------------------------------'
echo "queue_piwik nreal:"
tail -3 /var/log/process_queue_piwik_nreal.log
echo '------------------------------------'
echo "requeue_piwik nreal:"
tail -3 /var/log/process_requeue_piwik.log
echo '------------------------------------'
echo "process:";
ps aux | awk /process_1.0/ | grep -v awk | grep -v watch #|wc -l;
echo '------------------------------------'
echo "queue_piwik:"
ps aux | awk /queue_piwik/ | grep -v awk | grep -v watch #|wc -l;
