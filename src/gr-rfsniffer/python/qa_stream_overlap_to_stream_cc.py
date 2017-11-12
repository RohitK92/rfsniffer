#!/usr/bin/env python
# -*- coding: utf-8 -*-
# 
# Copyright 2017 <+YOU OR YOUR COMPANY+>.
# 
# This is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
# 
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this software; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street,
# Boston, MA 02110-1301, USA.
# 

from gnuradio import gr, gr_unittest
from gnuradio import blocks
import rfsniffer_swig as rfsniffer
from sys import stderr

class qa_stream_overlap_to_stream_cc (gr_unittest.TestCase):

    def setUp (self):
        self.tb = gr.top_block ()

    def tearDown (self):
        self.tb = None

    def test_001_t (self):
        src_data = (
            (1+1j), (2+2j), (3+3j), (2+2j), (2.5+2.5j), (3+3j),
            (2+2j), (2.5+2.5j), (3+3j), (3.5+3.5j), (4+4j), (4.5+4.5j),
            (3.5+3.5j), (4+4j), (4.5+4.5j), (10+10j), (11+11j), (12+12j),
        )
        expected_data = (
            (1+1j), (2+2j), (3+3j), (4+4j), (5+5j), (6+6j), (7+7j), (8+8j), (9+9j)
        )
        src = blocks.vector_source_c(src_data)
        v_to_so = rfsniffer.stream_overlap_to_stream_cc(6, 3)
        dst = blocks.vector_sink_c()
        self.tb.connect(src, v_to_so)
        self.tb.connect(v_to_so, dst)
        self.tb.run()
        self.assertComplexTuplesAlmostEqual(expected_data, dst.data(), 9)

if __name__ == '__main__':
    gr_unittest.run(qa_stream_overlap_to_stream_cc, "qa_stream_overlap_to_stream_cc.xml")
