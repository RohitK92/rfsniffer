#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: Acars
# Generated: Wed Jan 17 20:45:42 2018
##################################################

from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import filter
from gnuradio import gr
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from optparse import OptionParser


class acars(gr.top_block):

    def __init__(self):
        gr.top_block.__init__(self, "Acars")

        ##################################################
        # Variables
        ##################################################
        self.center_freq = center_freq = 133e6

        ##################################################
        # Blocks
        ##################################################
        self.freq_xlating_fir_filter_xxx_0_1_0 = filter.freq_xlating_fir_filter_ccc(800, (firdes.low_pass(1,10e6,10e6/(2*800), 10e3)), 131.725e6-center_freq, 10e6)
        self.freq_xlating_fir_filter_xxx_0_1 = filter.freq_xlating_fir_filter_ccc(800, (firdes.low_pass(1,10e6,10e6/(2*800), 10e3)), 136.850e6-center_freq, 10e6)
        self.freq_xlating_fir_filter_xxx_0_0_2 = filter.freq_xlating_fir_filter_ccc(800, (firdes.low_pass(1,10e6,10e6/(2*800), 10e3)), 136.700e6-center_freq, 10e6)
        self.freq_xlating_fir_filter_xxx_0_0_1_0 = filter.freq_xlating_fir_filter_ccc(800, (firdes.low_pass(1,10e6,10e6/(2*800), 10e3)), 136.800e6-center_freq, 10e6)
        self.freq_xlating_fir_filter_xxx_0_0_0_0_1_1 = filter.freq_xlating_fir_filter_ccc(800, (firdes.low_pass(1,10e6,10e6/(2*800), 10e3)), 130.425e6-center_freq, 10e6)
        self.freq_xlating_fir_filter_xxx_0_0_0_0_1 = filter.freq_xlating_fir_filter_ccc(800, (firdes.low_pass(1,10e6,10e6/(2*800), 10e3)), 130.450e6-center_freq, 10e6)
        self.freq_xlating_fir_filter_xxx_0_0_0_0_0_0_1_1 = filter.freq_xlating_fir_filter_ccc(800, (firdes.low_pass(1,10e6,10e6/(2*800), 10e3)), 131.125e6-center_freq, 10e6)
        self.freq_xlating_fir_filter_xxx_0_0_0_0_0_0_0_0 = filter.freq_xlating_fir_filter_ccc(800, (firdes.low_pass(1,10e6,10e6/(2*800), 10e3)), 129.125e6-center_freq, 10e6)
        self.freq_xlating_fir_filter_xxx_0_0_0_0 = filter.freq_xlating_fir_filter_ccc(800, (firdes.low_pass(1,10e6,10e6/(2*800), 10e3)), 130.250e6-center_freq, 10e6)
        self.freq_xlating_fir_filter_xxx_0_0 = filter.freq_xlating_fir_filter_ccc(800, (firdes.low_pass(1,10e6,10e6/(2*800), 10e3)), 136.750e6-center_freq, 10e6)
        self.freq_xlating_fir_filter_xxx_0 = filter.freq_xlating_fir_filter_ccc(800, (firdes.low_pass(1,10e6,10e6/(2*800),10e3)), 131.550e6-center_freq, 10e6)
        self.dc_blocker_xx_0_1_0 = filter.dc_blocker_ff(32, True)
        self.dc_blocker_xx_0_1 = filter.dc_blocker_ff(32, True)
        self.dc_blocker_xx_0_0_2 = filter.dc_blocker_ff(32, True)
        self.dc_blocker_xx_0_0_1_0 = filter.dc_blocker_ff(32, True)
        self.dc_blocker_xx_0_0_0_0_1_1 = filter.dc_blocker_ff(32, True)
        self.dc_blocker_xx_0_0_0_0_1 = filter.dc_blocker_ff(32, True)
        self.dc_blocker_xx_0_0_0_0_0_0_1_1 = filter.dc_blocker_ff(32, True)
        self.dc_blocker_xx_0_0_0_0_0_0_0_0 = filter.dc_blocker_ff(32, True)
        self.dc_blocker_xx_0_0_0_0 = filter.dc_blocker_ff(32, True)
        self.dc_blocker_xx_0_0 = filter.dc_blocker_ff(32, True)
        self.dc_blocker_xx_0 = filter.dc_blocker_ff(32, True)
        self.blocks_wavfile_sink_0 = blocks.wavfile_sink("/tmp/acars.wav", 11, 12500, 16)
        self.blocks_file_source_0 = blocks.file_source(gr.sizeof_gr_complex*1, "/tmp/decompress.iq", False)
        self.blocks_complex_to_mag_0_1_0 = blocks.complex_to_mag(1)
        self.blocks_complex_to_mag_0_1 = blocks.complex_to_mag(1)
        self.blocks_complex_to_mag_0_0_2 = blocks.complex_to_mag(1)
        self.blocks_complex_to_mag_0_0_1_0 = blocks.complex_to_mag(1)
        self.blocks_complex_to_mag_0_0_0_0_1_1 = blocks.complex_to_mag(1)
        self.blocks_complex_to_mag_0_0_0_0_1 = blocks.complex_to_mag(1)
        self.blocks_complex_to_mag_0_0_0_0_0_0_1_1 = blocks.complex_to_mag(1)
        self.blocks_complex_to_mag_0_0_0_0_0_0_0_0 = blocks.complex_to_mag(1)
        self.blocks_complex_to_mag_0_0_0_0 = blocks.complex_to_mag(1)
        self.blocks_complex_to_mag_0_0 = blocks.complex_to_mag(1)
        self.blocks_complex_to_mag_0 = blocks.complex_to_mag(1)

        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_complex_to_mag_0, 0), (self.dc_blocker_xx_0, 0))    
        self.connect((self.blocks_complex_to_mag_0_0, 0), (self.dc_blocker_xx_0_0, 0))    
        self.connect((self.blocks_complex_to_mag_0_0_0_0, 0), (self.dc_blocker_xx_0_0_0_0, 0))    
        self.connect((self.blocks_complex_to_mag_0_0_0_0_0_0_0_0, 0), (self.dc_blocker_xx_0_0_0_0_0_0_0_0, 0))    
        self.connect((self.blocks_complex_to_mag_0_0_0_0_0_0_1_1, 0), (self.dc_blocker_xx_0_0_0_0_0_0_1_1, 0))    
        self.connect((self.blocks_complex_to_mag_0_0_0_0_1, 0), (self.dc_blocker_xx_0_0_0_0_1, 0))    
        self.connect((self.blocks_complex_to_mag_0_0_0_0_1_1, 0), (self.dc_blocker_xx_0_0_0_0_1_1, 0))    
        self.connect((self.blocks_complex_to_mag_0_0_1_0, 0), (self.dc_blocker_xx_0_0_1_0, 0))    
        self.connect((self.blocks_complex_to_mag_0_0_2, 0), (self.dc_blocker_xx_0_0_2, 0))    
        self.connect((self.blocks_complex_to_mag_0_1, 0), (self.dc_blocker_xx_0_1, 0))    
        self.connect((self.blocks_complex_to_mag_0_1_0, 0), (self.dc_blocker_xx_0_1_0, 0))    
        self.connect((self.blocks_file_source_0, 0), (self.freq_xlating_fir_filter_xxx_0, 0))    
        self.connect((self.blocks_file_source_0, 0), (self.freq_xlating_fir_filter_xxx_0_0, 0))    
        self.connect((self.blocks_file_source_0, 0), (self.freq_xlating_fir_filter_xxx_0_0_0_0, 0))    
        self.connect((self.blocks_file_source_0, 0), (self.freq_xlating_fir_filter_xxx_0_0_0_0_0_0_0_0, 0))    
        self.connect((self.blocks_file_source_0, 0), (self.freq_xlating_fir_filter_xxx_0_0_0_0_0_0_1_1, 0))    
        self.connect((self.blocks_file_source_0, 0), (self.freq_xlating_fir_filter_xxx_0_0_0_0_1, 0))    
        self.connect((self.blocks_file_source_0, 0), (self.freq_xlating_fir_filter_xxx_0_0_0_0_1_1, 0))    
        self.connect((self.blocks_file_source_0, 0), (self.freq_xlating_fir_filter_xxx_0_0_1_0, 0))    
        self.connect((self.blocks_file_source_0, 0), (self.freq_xlating_fir_filter_xxx_0_0_2, 0))    
        self.connect((self.blocks_file_source_0, 0), (self.freq_xlating_fir_filter_xxx_0_1, 0))    
        self.connect((self.blocks_file_source_0, 0), (self.freq_xlating_fir_filter_xxx_0_1_0, 0))    
        self.connect((self.dc_blocker_xx_0, 0), (self.blocks_wavfile_sink_0, 0))    
        self.connect((self.dc_blocker_xx_0_0, 0), (self.blocks_wavfile_sink_0, 7))    
        self.connect((self.dc_blocker_xx_0_0_0_0, 0), (self.blocks_wavfile_sink_0, 2))    
        self.connect((self.dc_blocker_xx_0_0_0_0_0_0_0_0, 0), (self.blocks_wavfile_sink_0, 1))    
        self.connect((self.dc_blocker_xx_0_0_0_0_0_0_1_1, 0), (self.blocks_wavfile_sink_0, 5))    
        self.connect((self.dc_blocker_xx_0_0_0_0_1, 0), (self.blocks_wavfile_sink_0, 4))    
        self.connect((self.dc_blocker_xx_0_0_0_0_1_1, 0), (self.blocks_wavfile_sink_0, 3))    
        self.connect((self.dc_blocker_xx_0_0_1_0, 0), (self.blocks_wavfile_sink_0, 8))    
        self.connect((self.dc_blocker_xx_0_0_2, 0), (self.blocks_wavfile_sink_0, 6))    
        self.connect((self.dc_blocker_xx_0_1, 0), (self.blocks_wavfile_sink_0, 9))    
        self.connect((self.dc_blocker_xx_0_1_0, 0), (self.blocks_wavfile_sink_0, 10))    
        self.connect((self.freq_xlating_fir_filter_xxx_0, 0), (self.blocks_complex_to_mag_0, 0))    
        self.connect((self.freq_xlating_fir_filter_xxx_0_0, 0), (self.blocks_complex_to_mag_0_0, 0))    
        self.connect((self.freq_xlating_fir_filter_xxx_0_0_0_0, 0), (self.blocks_complex_to_mag_0_0_0_0, 0))    
        self.connect((self.freq_xlating_fir_filter_xxx_0_0_0_0_0_0_0_0, 0), (self.blocks_complex_to_mag_0_0_0_0_0_0_0_0, 0))    
        self.connect((self.freq_xlating_fir_filter_xxx_0_0_0_0_0_0_1_1, 0), (self.blocks_complex_to_mag_0_0_0_0_0_0_1_1, 0))    
        self.connect((self.freq_xlating_fir_filter_xxx_0_0_0_0_1, 0), (self.blocks_complex_to_mag_0_0_0_0_1, 0))    
        self.connect((self.freq_xlating_fir_filter_xxx_0_0_0_0_1_1, 0), (self.blocks_complex_to_mag_0_0_0_0_1_1, 0))    
        self.connect((self.freq_xlating_fir_filter_xxx_0_0_1_0, 0), (self.blocks_complex_to_mag_0_0_1_0, 0))    
        self.connect((self.freq_xlating_fir_filter_xxx_0_0_2, 0), (self.blocks_complex_to_mag_0_0_2, 0))    
        self.connect((self.freq_xlating_fir_filter_xxx_0_1, 0), (self.blocks_complex_to_mag_0_1, 0))    
        self.connect((self.freq_xlating_fir_filter_xxx_0_1_0, 0), (self.blocks_complex_to_mag_0_1_0, 0))    

    def get_center_freq(self):
        return self.center_freq

    def set_center_freq(self, center_freq):
        self.center_freq = center_freq
        self.freq_xlating_fir_filter_xxx_0.set_center_freq(131.550e6-self.center_freq)
        self.freq_xlating_fir_filter_xxx_0_0.set_center_freq(136.750e6-self.center_freq)
        self.freq_xlating_fir_filter_xxx_0_0_0_0.set_center_freq(130.250e6-self.center_freq)
        self.freq_xlating_fir_filter_xxx_0_0_0_0_0_0_0_0.set_center_freq(129.125e6-self.center_freq)
        self.freq_xlating_fir_filter_xxx_0_0_0_0_0_0_1_1.set_center_freq(131.125e6-self.center_freq)
        self.freq_xlating_fir_filter_xxx_0_0_0_0_1.set_center_freq(130.450e6-self.center_freq)
        self.freq_xlating_fir_filter_xxx_0_0_0_0_1_1.set_center_freq(130.425e6-self.center_freq)
        self.freq_xlating_fir_filter_xxx_0_0_1_0.set_center_freq(136.800e6-self.center_freq)
        self.freq_xlating_fir_filter_xxx_0_0_2.set_center_freq(136.700e6-self.center_freq)
        self.freq_xlating_fir_filter_xxx_0_1.set_center_freq(136.850e6-self.center_freq)
        self.freq_xlating_fir_filter_xxx_0_1_0.set_center_freq(131.725e6-self.center_freq)


def main(top_block_cls=acars, options=None):

    tb = top_block_cls()
    tb.start()
    tb.wait()


if __name__ == '__main__':
    main()
