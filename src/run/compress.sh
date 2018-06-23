#!/bin/bash

SCRIPT_PATH=`realpath $0`
SCRIPT_DIR=`dirname $SCRIPT_PATH`

DATA_DIR=/data

export PYTHONPATH="$PYTHONPATH:/usr/local/lib/python2.7/dist-packages"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"

killall -9 airspy_rx 2>/dev/null >/dev/null
killall -9 uhd_rx_cfile 2>/dev/null >/dev/null
killall python2 2>/dev/null >/dev/null
killall compress 2>/dev/null >/dev/null

rm -f /tmp/capture.iq
mkfifo /tmp/capture.iq
rm -f /tmp/compress_fft.iq
mkfifo /tmp/compress_fft.iq
find $DATA_DIR -name "compress-*.iqz" | xargs -n1 rm  2>/dev/null >/dev/null

if [ "$#" -ne 5 ];
then
  echo "Usage: $0 BIN_COUNT THRESHOLD ITERATIONS CENTER_FREQ(HZ) SAMPLE_RATE" >&2
  exit 1
fi

if uhd_find_devices 2>/dev/null >/dev/null;
then
  $SCRIPT_DIR/../capture/uhdrx.sh $5 $4 2>/dev/null >/dev/null &
elif airspy_info | grep Found > /dev/null;
then
  $SCRIPT_DIR/../capture/airspyrx.sh $5 `expr $4 / 1000000` 2>/dev/null >/dev/null &
else
  echo "Error: No IQ capture device found"
  exit 1
fi

$SCRIPT_DIR/../compress/compress_fft.py --N=$1 2>/dev/null >/dev/null &

cd $DATA_DIR
$SCRIPT_DIR/../compress/compress $1 $2 $3 `expr $4 / 1000` `expr $5 / 1000` 79 80 81 239 271 272 273 279 280 281 `seq -s ' ' 239 260`  `seq -s ' ' 200 240` `seq -s ' ' 254 257` `seq -s ' ' 242 244` 250 296 332 333 `seq -s ' ' 287 289`
