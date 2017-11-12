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

#ifndef INCLUDED_RFSNIFFER_STREAM_OVERLAP_TO_STREAM_CC_IMPL_H
#define INCLUDED_RFSNIFFER_STREAM_OVERLAP_TO_STREAM_CC_IMPL_H

#include <rfsniffer/stream_overlap_to_stream_cc.h>

namespace gr {
  namespace rfsniffer {

    class stream_overlap_to_stream_cc_impl : public stream_overlap_to_stream_cc
    {
     private:
       int d_overlap;

     public:
      stream_overlap_to_stream_cc_impl(size_t nitems_per_block, unsigned overlap);
      ~stream_overlap_to_stream_cc_impl();

      void forecast (int noutput_items, gr_vector_int &ninput_items_required);

      int general_work(int noutput_items,
           gr_vector_int &ninput_items,
           gr_vector_const_void_star &input_items,
           gr_vector_void_star &output_items);
    };

  } // namespace rfsniffer
} // namespace gr

#endif /* INCLUDED_RFSNIFFER_STREAM_OVERLAP_TO_STREAM_CC_IMPL_H */

