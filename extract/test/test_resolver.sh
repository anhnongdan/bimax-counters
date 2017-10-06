#!/bin/bash

MYDIR="$(dirname "$(realpath "$0")")"
resolver=$MYDIR/log_resolver.sh

#exist on backup
#should return as-is with premise: "backup and slave are alway in-sync"
name1=/data/nfs_test/abc/test1

#request resolve backup path
#this case is not supposed to happen in the system
name2=/data/cdn/abc/test1

#doesn't exist on master
name3=/data/nfs_test/abc/test2


file1=`$resolver $name1`
file2=`$resolver $name2`
file3=`$resolver $name3`

echo "name1: $name1 -> $file1"
cat $file1

echo "name2: $name2 -> $file2"
cat $file2

echo "name3: $name3 -> $file3"
cat $file3
