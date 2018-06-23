#!/bin/bash

DATA_DIR=/data

export PYTHONPATH="$PYTHONPATH:/usr/local/lib/python2.7/dist-packages"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"

#killall decompress python2 acarsdec 2>/dev/null

rm -f /tmp/decompress_fft.iq
mkfifo /tmp/decompress_fft.iq
rm -f /tmp/decompress.iq
mkfifo /tmp/decompress.iq

ACARS_FREQS_KHZ=( 131550 129125 130250 130425 130450 131125 136700 136750 136800 136850 131725 )

inotifywait -m -e moved_to $DATA_DIR 2>/dev/null | while read line

do
  linearr=($line)
  file=${linearr[2]}

  for freq_khz in "${ACARS_FREQS_KHZ[@]}"
  do
    # ACARS freq in compressed file
    if [[ $file == *"$freq_khz"* ]]; then
      ../decompress/decompress $DATA_DIR/$file >/dev/null 2>/dev/null &
      ../decompress/decompress_fft.py >/dev/null 2>/dev/null &
      ../convert/acars.py >/dev/null 2>/dev/null

      ~/Projects/acarsdec/acarsdec -f /tmp/acars.wav
      break
    fi
  done

done
