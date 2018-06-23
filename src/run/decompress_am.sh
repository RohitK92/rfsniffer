#!/bin/bash

DATA_DIR=/data

export PYTHONPATH="$PYTHONPATH:/usr/local/lib/python2.7/dist-packages"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"

killall decompress 2>/dev/null >/dev/null

rm -f /tmp/decompress_fft.iq
mkfifo /tmp/decompress_fft.iq
rm -f /tmp/decompress.iq
mkfifo /tmp/decompress.iq

# Generate silencce as initial wav
sox -n -r 12500 -c 1 /tmp/am-total.wav trim 0.0 1.0

for file in $(ls -1v $DATA_DIR/*$1*)
do
  ../decompress/decompress $file &
  ../decompress/decompress_fft.py &
  ../convert/am.py --freq=$1

  mv /tmp/am-total.wav /tmp/am-total.wav-old
  sox /tmp/am-total.wav-old /tmp/$1.wav /tmp/am-total.wav
done

mv /tmp/am-total.wav $1.wav
