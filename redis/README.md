1.  mkdir /data/redis
chmod -R 755 /data/redis/

2. Copy config files

3. copy ini file to supervisor

4. reload supervisor

5. use htop and ps -ef to verify if redis server on both host are running ok

6. 


Ref:
https://discuss.pivotal.io/hc/en-us/articles/205309278-How-to-setup-Redis-Master-and-Salve-replication
https://discuss.pivotal.io/hc/en-us/articles/205309388-How-to-setup-HAProxy-and-Redis-Sentinel-for-automatic-failover-between-Redis-Master-and-Slave-servers


Check slave:
[root@VNPT-HCM-ANALYTIC-04 ~]# redis-cli info replication
# Replication
role:slave
master_host:172.20.4.63
master_port:6379
master_link_status:up
master_last_io_seconds_ago:0
master_sync_in_progress:0
slave_repl_offset:166583
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
  
Check master:
[root@VNPT-HCM-BIMAX-01 redis]# redis-cli -p 6379 info replication
# Replication
role:master
connected_slaves:1
slave0:ip=172.20.4.52,port=6379,state=online,offset=371784,lag=1
master_repl_offset:371798
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:371797

