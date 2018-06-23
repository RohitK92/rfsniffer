#!/bin/bash

DATA_DIR=/data

export PYTHONPATH="$PYTHONPATH:/usr/local/lib/python2.7/dist-packages"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"

killall decompress 2>/dev/null >/dev/null

rm -f /tmp/decompress_fft.iq 2>/dev/null >/dev/null
mkfifo /tmp/decompress_fft.iq 2>/dev/null >/dev/null
rm -f /tmp/decompress.iq 2>/dev/null >/dev/null
mkfifo /tmp/decompress.iq 2>/dev/null >/dev/null

VDL2_FREQS_KHZ=( 136650 136975 )

inotifywait -m -e moved_to $DATA_DIR 2>/dev/null | while read line

do
  linearr=($line)
  file=${linearr[2]}

  for freq_khz in "${VDL2_FREQS_KHZ[@]}"
  do
    if [[ $file == *"$freq_khz"* ]]; then
      ../decompress/decompress $DATA_DIR/$file >/dev/null 2>/dev/null &
      ../decompress/decompress_fft.py >/dev/null 2>/dev/null &
      ../convert/vdl2.py >/dev/null 2>/dev/null

      ~/Projects/dumpvdl2/dumpvdl2 --iq-file /tmp/vdl2.iq --sample-format S16_LE --oversample 2 `expr $freq_khz \* 1000`
      break
    fi
  done
done
