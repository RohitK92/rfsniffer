#!/bin/bash

DIR=`dirname $0`

export PYTHONPATH="$PYTHONPATH:/usr/local/lib/python2.7/dist-packages"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"

killall -9 airspy_rx
killall -9 uhd_rx_cfile
killall python2
killall compress

rm -f capture.iq
mkfifo capture.iq
rm -f compress_fft.iq
mkfifo compress_fft.iq
rm -f compress.iq

if [ "$#" -ne 5 ];
then
  echo "Usage: $0 BIN_COUNT THRESHOLD ITERATIONS CENTER_FREQ(HZ) SAMPLE_RATE" >&2
  exit 1
fi

if uhd_find_devices > /dev/null 2> /dev/null;
then
  $DIR/../capture/uhdrx.sh $5 $4 &
  $DIR/../compress/compress_fft.py --N=$1 &
  $DIR/../compress/compress $1 $2 $3 `expr $4 / 1000` `expr $5 / 1000`
elif airspy_info | grep Found > /dev/null;
then
  $DIR/../capture/airspyrx.sh $5 `expr $4 / 1000000` &
  $DIR/../compress/compress_fft.py --N=$1 &
  $DIR/../compress/compress $1 $2 $3 `expr $4 / 1000` `expr $5 / 1000`
else
  echo "Error: No IQ capture device found"
  exit 1
fi
