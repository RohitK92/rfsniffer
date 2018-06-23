#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: Decompress Fft
# Generated: Wed Jan 17 13:10:22 2018
##################################################

from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import fft
from gnuradio import gr
from gnuradio.eng_option import eng_option
from gnuradio.fft import window
from gnuradio.filter import firdes
from optparse import OptionParser
import rfsniffer


class decompress_fft(gr.top_block):

    def __init__(self):
        gr.top_block.__init__(self, "Decompress Fft")

        ##################################################
        # Variables
        ##################################################
        self.sample_rate = sample_rate = 10e6
        self.fft_bins = fft_bins = 400

        ##################################################
        # Blocks
        ##################################################
        self.rfsniffer_stream_overlap_to_stream_cc_0 = rfsniffer.stream_overlap_to_stream_cc(fft_bins, 200)
        self.fft_vxx_0 = fft.fft_vcc(fft_bins, False, (window.rectangular(fft_bins)), True, 1)
        self.blocks_vector_to_stream_0 = blocks.vector_to_stream(gr.sizeof_gr_complex*1, fft_bins)
        self.blocks_stream_to_vector_0 = blocks.stream_to_vector(gr.sizeof_gr_complex*1, fft_bins)
        self.blocks_file_source_0 = blocks.file_source(gr.sizeof_gr_complex*1, "/tmp/decompress_fft.iq", False)
        self.blocks_file_sink_0 = blocks.file_sink(gr.sizeof_gr_complex*1, "/tmp/decompress.iq", False)
        self.blocks_file_sink_0.set_unbuffered(False)

        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_file_source_0, 0), (self.blocks_stream_to_vector_0, 0))    
        self.connect((self.blocks_stream_to_vector_0, 0), (self.fft_vxx_0, 0))    
        self.connect((self.blocks_vector_to_stream_0, 0), (self.rfsniffer_stream_overlap_to_stream_cc_0, 0))    
        self.connect((self.fft_vxx_0, 0), (self.blocks_vector_to_stream_0, 0))    
        self.connect((self.rfsniffer_stream_overlap_to_stream_cc_0, 0), (self.blocks_file_sink_0, 0))    

    def get_sample_rate(self):
        return self.sample_rate

    def set_sample_rate(self, sample_rate):
        self.sample_rate = sample_rate

    def get_fft_bins(self):
        return self.fft_bins

    def set_fft_bins(self, fft_bins):
        self.fft_bins = fft_bins


def main(top_block_cls=decompress_fft, options=None):

    tb = top_block_cls()
    tb.start()
    tb.wait()


if __name__ == '__main__':
    main()
