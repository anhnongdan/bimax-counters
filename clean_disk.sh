#!/bin/sh
lock=/tmp/clean_disk.lock
filelist=/tmp/fileslist.txt
if [ -f "$lock" ];then exit 0;fi
touch $lock
for dir in /data/cdn /data/logs /data/logs_fpt;do
        find $dir -type f -mmin +300 -exec rm -rf {} \;
done
rm -f $lock
exit 0

#######
rm -rf /data/cdn/*/`date +%Y/%m/%d -d '1 day ago'`
rm -rf /data/logs/`date +%Y/%m/%d -d '1 day ago'`
rm -rf /data/logs_fpt/`date +%Y/%m/%d -d '1 day ago'`
exit 0


########
if [ -f $lock ];then
        locklast=`stat $lock -c "%Y"`
        now=`date +%s`
        dlay=`echo $now - $locklast | bc`
        if [ $dlay -gt 120 ];then
                rm -f $lock
        fi

fi
if [ -f $lock ];then  exit 0;fi
touch $lock


find  /data/cdn -mindepth 4 -type d -mtime +1 | awk '!/thvl/' | while read dd;do echo $dd;rm -rf $dd;done
find  /data/cdn -mindepth 5 -type f -mmin +1 | awk '!/thvl/' | while read dd;do echo $dd;rm -rf $dd;done
find  /data/cdn -mindepth 4 -type d -mtime +1 -iname '*thvl*' | while read dd;do echo $dd;rm -rf $dd;done
#find  /data/cdn -mindepth 4 -type d -mtime +1| awk '!/thvl/' | while read dd;do echo $dd;rm -rf $dd;done
rm -f $lock
