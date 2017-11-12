/* -*- c++ -*- */

#define RFSNIFFER_API

%include "gnuradio.i"			// the common stuff

//load generated python docstrings
%include "rfsniffer_swig_doc.i"

%{
#include "rfsniffer/stream_to_vector_overlap.h"
#include "rfsniffer/stream_overlap_to_stream_cc.h"
%}


%include "rfsniffer/stream_to_vector_overlap.h"
GR_SWIG_BLOCK_MAGIC2(rfsniffer, stream_to_vector_overlap);

%include "rfsniffer/stream_overlap_to_stream_cc.h"
GR_SWIG_BLOCK_MAGIC2(rfsniffer, stream_overlap_to_stream_cc);
