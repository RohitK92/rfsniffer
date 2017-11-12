#!/bin/bash

export PYTHONPATH="$PYTHONPATH:/usr/local/lib/python2.7/dist-packages"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"

killall decompress

rm -f decompress_fft.iq
mkfifo decompress_fft.iq
rm -f decompress.iq
mkfifo decompress.iq

../decompress/decompress &
../decompress/decompress_fft.py &
../convert/amdemod.py
