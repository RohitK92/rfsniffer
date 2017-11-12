#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: Compress Fft
# Generated: Tue Oct  3 08:30:12 2017
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


class compress_fft(gr.top_block):

    def __init__(self, N=400):
        gr.top_block.__init__(self, "Compress Fft")

        ##################################################
        # Parameters
        ##################################################
        self.N = N

        ##################################################
        # Blocks
        ##################################################
        self.rfsniffer_stream_to_vector_overlap_0 = rfsniffer.stream_to_vector_overlap(gr.sizeof_gr_complex, N, N/2)
        self.fft_vxx_0 = fft.fft_vcc(N, True, (window.hanning(N)), True, 1)
        self.blocks_vector_to_stream_0 = blocks.vector_to_stream(gr.sizeof_gr_complex*1, N)
        self.blocks_file_source_0 = blocks.file_source(gr.sizeof_gr_complex*1, "capture.iq", False)
        self.blocks_file_sink_0 = blocks.file_sink(gr.sizeof_gr_complex*1, "compress_fft.iq", False)
        self.blocks_file_sink_0.set_unbuffered(False)

        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_file_source_0, 0), (self.rfsniffer_stream_to_vector_overlap_0, 0))    
        self.connect((self.blocks_vector_to_stream_0, 0), (self.blocks_file_sink_0, 0))    
        self.connect((self.fft_vxx_0, 0), (self.blocks_vector_to_stream_0, 0))    
        self.connect((self.rfsniffer_stream_to_vector_overlap_0, 0), (self.fft_vxx_0, 0))    

    def get_N(self):
        return self.N

    def set_N(self, N):
        self.N = N


def argument_parser():
    parser = OptionParser(option_class=eng_option, usage="%prog: [options]")
    parser.add_option(
        "", "--N", dest="N", type="intx", default=400,
        help="Set N [default=%default]")
    return parser


def main(top_block_cls=compress_fft, options=None):
    if options is None:
        options, _ = argument_parser().parse_args()

    tb = top_block_cls(N=options.N)
    tb.start()
    tb.wait()


if __name__ == '__main__':
    main()
