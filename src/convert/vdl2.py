#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: Vdl2
# Generated: Wed Jan 17 12:58:24 2018
##################################################

from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import filter
from gnuradio import gr
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from optparse import OptionParser


class vdl2(gr.top_block):

    def __init__(self):
        gr.top_block.__init__(self, "Vdl2")

        ##################################################
        # Variables
        ##################################################
        self.center_freq = center_freq = 133e6

        ##################################################
        # Blocks
        ##################################################
        self.rational_resampler_xxx_0 = filter.rational_resampler_ccc(
                interpolation=105,
                decimation=100,
                taps=None,
                fractional_bw=None,
        )
        self.freq_xlating_fir_filter_xxx_0_1 = filter.freq_xlating_fir_filter_ccc(50, (firdes.complex_band_pass(1,10e6,-50e3,50e3, 5000)), 136.975e6-center_freq, 10e6)
        self.blocks_multiply_const_vxx_0 = blocks.multiply_const_vcc((32767, ))
        self.blocks_file_source_0 = blocks.file_source(gr.sizeof_gr_complex*1, "/tmp/decompress.iq", False)
        self.blocks_file_sink_0 = blocks.file_sink(gr.sizeof_short*1, "/tmp/vdl2.iq", False)
        self.blocks_file_sink_0.set_unbuffered(False)
        self.blocks_complex_to_interleaved_short_0 = blocks.complex_to_interleaved_short(False)

        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_complex_to_interleaved_short_0, 0), (self.blocks_file_sink_0, 0))    
        self.connect((self.blocks_file_source_0, 0), (self.freq_xlating_fir_filter_xxx_0_1, 0))    
        self.connect((self.blocks_multiply_const_vxx_0, 0), (self.blocks_complex_to_interleaved_short_0, 0))    
        self.connect((self.freq_xlating_fir_filter_xxx_0_1, 0), (self.rational_resampler_xxx_0, 0))    
        self.connect((self.rational_resampler_xxx_0, 0), (self.blocks_multiply_const_vxx_0, 0))    

    def get_center_freq(self):
        return self.center_freq

    def set_center_freq(self, center_freq):
        self.center_freq = center_freq
        self.freq_xlating_fir_filter_xxx_0_1.set_center_freq(136.975e6-self.center_freq)


def main(top_block_cls=vdl2, options=None):

    tb = top_block_cls()
    tb.start()
    tb.wait()


if __name__ == '__main__':
    main()
