#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: Am
# Generated: Wed Jan 31 14:31:47 2018
##################################################

from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import filter
from gnuradio import gr
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from optparse import OptionParser


class am(gr.top_block):

    def __init__(self, freq=0):
        gr.top_block.__init__(self, "Am")

        ##################################################
        # Parameters
        ##################################################
        self.freq = freq

        ##################################################
        # Variables
        ##################################################
        self.center_freq = center_freq = 133e6

        ##################################################
        # Blocks
        ##################################################
        self.freq_xlating_fir_filter_xxx_0_0_0_0_0_0_0_0 = filter.freq_xlating_fir_filter_ccf(800, (firdes.low_pass(1,10e6,10e6/(2*800), 1000)), (freq*1e3)-center_freq, 10e6)
        self.dc_blocker_xx_0_0_0_0_0_0_0_0 = filter.dc_blocker_ff(32, True)
        self.blocks_wavfile_sink_0_0_0_0_0_0_0_0 = blocks.wavfile_sink("/tmp/"+str(freq)+".wav", 1, int(12.5e3), 16)
        self.blocks_file_source_0 = blocks.file_source(gr.sizeof_gr_complex*1, "/tmp/decompress.iq", False)
        self.blocks_complex_to_mag_0_0_0_0_0_0_0_0 = blocks.complex_to_mag(1)

        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_complex_to_mag_0_0_0_0_0_0_0_0, 0), (self.dc_blocker_xx_0_0_0_0_0_0_0_0, 0))    
        self.connect((self.blocks_file_source_0, 0), (self.freq_xlating_fir_filter_xxx_0_0_0_0_0_0_0_0, 0))    
        self.connect((self.dc_blocker_xx_0_0_0_0_0_0_0_0, 0), (self.blocks_wavfile_sink_0_0_0_0_0_0_0_0, 0))    
        self.connect((self.freq_xlating_fir_filter_xxx_0_0_0_0_0_0_0_0, 0), (self.blocks_complex_to_mag_0_0_0_0_0_0_0_0, 0))    

    def get_freq(self):
        return self.freq

    def set_freq(self, freq):
        self.freq = freq
        self.freq_xlating_fir_filter_xxx_0_0_0_0_0_0_0_0.set_center_freq((self.freq*1e3)-self.center_freq)
        self.blocks_wavfile_sink_0_0_0_0_0_0_0_0.open("/tmp/"+str(self.freq)+".wav")

    def get_center_freq(self):
        return self.center_freq

    def set_center_freq(self, center_freq):
        self.center_freq = center_freq
        self.freq_xlating_fir_filter_xxx_0_0_0_0_0_0_0_0.set_center_freq((self.freq*1e3)-self.center_freq)


def argument_parser():
    parser = OptionParser(option_class=eng_option, usage="%prog: [options]")
    parser.add_option(
        "", "--freq", dest="freq", type="intx", default=0,
        help="Set freq [default=%default]")
    return parser


def main(top_block_cls=am, options=None):
    if options is None:
        options, _ = argument_parser().parse_args()

    tb = top_block_cls(freq=options.freq)
    tb.start()
    tb.wait()


if __name__ == '__main__':
    main()
