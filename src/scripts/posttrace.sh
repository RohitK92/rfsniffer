#!/bin/bash
: '
#SAMPLE_RATE_SPS=$1
GAIN=$1
FILE=$2
META_EXTENSION=".hdr"
METAFILE=$FILE$META_EXTENSION
ANTENNA="RX2"
'

s=`gr_read_file_metadata trace.dat.hdr | grep -i 'seconds' | grep -oP "[^Seconds: ].*"`

while read value 
do
	if grep --quiet -i chirp <<< "$value" ; then
		v=$(echo "$value" | grep -oP "[^chirp start:].*")
		#s=`name | grep -oP "[^Seconds:].*"`
		echo "(($v - $s) * 20000000)" | bc -l
	else
		echo $value
	fi
done < starttime.log
