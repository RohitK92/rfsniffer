#!/bin/bash

SAMPLE_RATE_SPS=$1
FREQ_HZ=$2
ANTENNA="TX/RX"
GAIN=2

uhd_rx_cfile -A $ANTENNA -r $SAMPLE_RATE_SPS -f $FREQ_HZ -g $GAIN /tmp/capture.iq
