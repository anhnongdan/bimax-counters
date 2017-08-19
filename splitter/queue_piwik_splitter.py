#!/usr/bin/python
import sys, re, os, time, io, subprocess, logging, json, uuid

logging.basicConfig(filename='/tmp/queue_piwik.log',level=logging.DEBUG)

from nginx_log_parser import NginxLogParser
from dateutil.parser import parse

import _strptime
from datetime import datetime, timedelta
from pytz import timezone, utc
from pytz.tzinfo import StaticTzInfo
from shlex import split

#[Thangnt] Spliter has the role to split the log on /data/logs into separated domains
#it doesn't change anything in the log, just parse the time to create files.
#Log processing (i.e hls, dash token generalizing, filter, etc.) is now the role 
#of extractor - see extract/queue_piwik_2.1 

class OffsetTime(StaticTzInfo):
    def __init__(self, offset):
        """A dumb timezone based on offset such as +0530, -0600, etc.
        """
        hours = int(offset[:3])
        minutes = int(offset[0] + offset[3:])
        self._utcoffset = timedelta(hours=hours, minutes=minutes)

def load_datetime(value, format):
    if format.endswith('%z'):
        format = format[:-2]
        offset = value[-5:]
        value = value[:-5]
        return OffsetTime(offset).localize(datetime.strptime(value, format))

    return datetime.strptime(value, format)

def dump_datetime(value, format):
    return value.strftime(format)

parser = NginxLogParser('$request_time $remote_addr $sent_http_x_cache [$time_local] ' + \
			'"$request" $http_host $status $body_bytes_sent ' + \
			'"$http_referer" "$http_user_agent" "$http_range"')
logdir="/data/cdn"
fds = dict() 
if __name__ == "__main__":
    ff = sys.argv[1]
    with open(ff, "r") as f:
        for line in f:
            try:
		    if not line or line is None:
			continue
		    msgp = parser.parse_line(line)
		    if not msgp or msgp is None:
			continue
                    host = msgp['http_host'].strip()
                    
		    #[Thangnt] Splitter must follow the time on log to write to 
		    #the designated files. This make the whole system is very vulnerable
		    #to the input time inaccuracy.
		    #It's ok to let Splitter use local host time rather than rely on the
		    #input log. Now both syslog-ng and Splitter use local time to process
		    #log, if an Edge Server send out old log, it just goes through Log 
		    #Controller and goes to PW DB.
		    # https://github.com/anhnongdan/bimax-counters/issues/2
		    
		    #cur1 = load_datetime(msgp['time_local'], '%d/%b/%Y:%H:%M:%S %z')
		    #cur = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
		    #print cur	    
		    #print 1
			
		    #dir1 = dump_datetime(cur, '%Y/%m/%d')
                    #dir2 = dump_datetime(cur, '%Y_%m_%d_%H_%M')
		    dir1 = datetime.now().strftime("%Y/%m/%d")
		    dir2 = datetime.now().strftime("%Y_%m_%d_%H_%M")
		    #print dir1
		    #print dir2
		
                    mydir = "%s/%s/%s" % (logdir, host, dir1)
                    if not os.path.exists(mydir):
                         os.makedirs(mydir, 0755)
                    fd_name = "%s/%s_%s" % (mydir, host, dir2)
                    if fd_name not in fds:
                        fd = open(fd_name, 'a')
                        fds[fd_name] = fd
                    else:
                        fd = fds[fd_name]
 
                    fd.write(line)
                    fd.flush()
            except Exception, err:
                pass
