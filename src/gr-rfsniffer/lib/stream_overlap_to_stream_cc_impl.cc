/* -*- c++ -*- */
/* 
 * Copyright 2017 <+YOU OR YOUR COMPANY+>.
 * 
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gnuradio/io_signature.h>
#include "stream_overlap_to_stream_cc_impl.h"

namespace gr {
  namespace rfsniffer {

    stream_overlap_to_stream_cc::sptr
    stream_overlap_to_stream_cc::make(size_t nitems_per_block, unsigned overlap)
    {
      return gnuradio::get_initial_sptr
        (new stream_overlap_to_stream_cc_impl(nitems_per_block, overlap));
    }

    stream_overlap_to_stream_cc_impl::stream_overlap_to_stream_cc_impl(size_t nitems_per_block, unsigned overlap)
      : gr::block("stream_overlap_to_stream_cc",
              gr::io_signature::make(1, 1, sizeof(gr_complex)),
              gr::io_signature::make(1, 1, sizeof(gr_complex))),
      d_overlap(overlap)
    {
      if (overlap + 1 >= nitems_per_block) {
        throw std::invalid_argument("rfsniffer_vector_to_stream_overlap_cc: overlap must be smaller than the number of items per block.");
      }
      set_history(overlap + 1);
      set_min_noutput_items(nitems_per_block - overlap);
      set_max_noutput_items(nitems_per_block - overlap);
    }

    stream_overlap_to_stream_cc_impl::~stream_overlap_to_stream_cc_impl()
    {
    }

    void
    stream_overlap_to_stream_cc_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
      ninput_items_required[0] = noutput_items + d_overlap;
    }

    int
    stream_overlap_to_stream_cc_impl::general_work (int noutput_items,
                       gr_vector_int &ninput_items,
                       gr_vector_const_void_star &input_items,
                       gr_vector_void_star &output_items)
    {
      //fprintf(stderr, "Work: noutput_items: %d ninput_items: %d\n", noutput_items, ninput_items[0]);
      const gr_complex* in = (const gr_complex *)input_items[0];
      gr_complex* out = (gr_complex *)output_items[0];

      //fprintf(stderr, "Data: \n");

      // 1. Copy over the input that is part of the overlap
      memcpy(out, in, (sizeof(gr_complex) * d_overlap));

      // 2. Copy over the input that is not part of the overlap 
      memcpy(out + d_overlap, in + d_overlap, (sizeof(gr_complex) * (noutput_items - d_overlap)));

      // 3. Add the overlapped input
      for (int i = 0; i < d_overlap; i++)
        out[i] += in[i + d_overlap];

        //fprintf(stderr, " IN1:(%f,%fi) IN2:(%f,%fi) OUT:(%f,%fi)\n",
        //  real(in[i]), imag(in[i]),
        //  real(in[i + d_overlap]), imag(in[i + d_overlap]),
        //  real(out[i]), imag(out[i]));
      //fprintf(stderr, "\n");

      // Tell runtime system how many input items we consumed on
      // each input stream.
      consume_each(noutput_items + d_overlap);

      // Tell runtime system how many output items we produced.
      return noutput_items;
    }

  } /* namespace rfsniffer */
} /* namespace gr */

