#for m in {0..40};do
#        ls /data/logs/2017/02/13/track-2017-02-13-13-`printf "%0.2d" $m`-* |while read f;do
#for m in {12..23};do ls /data/logs/2017/02/13/track-2017-02-13-`printf "%0.2d" $m`-* |while read f;do
#for m in {0..10};do ls /data/logs/2017/02/12/track-2017-02-12-12-`printf "%0.2d" $m`-* |while read f;do
#for m in {0..11};do ls /data/logs/2017/03/18/track-2017-03-18-`printf "%0.2d" $m`-* |while read f;do
#for m in {0..33};do ls /data/logs/2017/03/18/track-2017-03-18-12-`printf "%0.2d" $m`-* |while read f;do
#for m in {31..34};do ls /data/logs/2017/03/18/track-2017-03-18-13-`printf "%0.2d" $m`-* |while read f;do
for m in {6..59};do ls /data/logs/2017/03/19/track-2017-03-19-07-`printf "%0.2d" $m`-* |while read f;do
                echo "rpush queue_counters_0 $f"
        done
done

