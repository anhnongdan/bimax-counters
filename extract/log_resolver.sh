#!/bin/bash

# Notice: this log_resolver is a local name translator 
# for extractor. As file path on master and slave NFS 
# will be the same, this resolver has the role to 
# return a file path in backup dir in case of when
# the-file-on master dir cannot be accesses.
# This means when the master comes back up. This will  
# return to master path as soon as the file is available.

MYDIR="$(dirname "$(realpath "$0")")"
conf=$MYDIR/bi_extract.conf
master=`awk -F'=' '/master_log=/ {print $2}' $conf | head -1`
backup=`awk -F'=' '/backup_log=/ {print $2}' $conf | head -1`

fn=$1

timeout 3s ls $fn >> /dev/null 2>&1

# if the file exist, return immediately
# file names on queue_extract must always
# match with master path
if [ $? -eq 0 ];then
	#file ok
	echo $fn
else
	if [[ $fn = $master* ]];then
		#echo "valid file name"
		path=`echo $fn | awk -F"$master" '{print $2}'`
		echo "${backup}$path"
	else
		#invalid file name
		echo $fn
	fi 
fi
