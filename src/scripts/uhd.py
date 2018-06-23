import time
from gnuradio import uhd
from gnuradio import gr 
from gnuradio import blocks
from gnuradio.eng_option import eng_option
import sys
from optparse import OptionParser

try:
    from uhd_app import UHDApp
except ImportError:
    from gnuradio.uhd.uhd_app import UHDApp

class uhd_fft(gr.top_block, UHDApp):
	def __init__(self, options, filename):
		gr.top_block.__init__(self, "Multi Chirp")
		self.u = uhd.usrp_source(device_addr="addr=192.168.10.2",
			    		io_type=uhd.io_type.COMPLEX_FLOAT32,
			    		num_channels=1)
		
		self.s = uhd.usrp_sink(device_addr="addr=192.168.11.2",
			    		io_type=uhd.io_type.COMPLEX_FLOAT32,
			    		num_channels=1)
	
		self.delay = 0.0001
		self.fixed_delay = 0.001
		self.fk = open('starttime.log', 'w')

		# Initialization code for controlling the DAC output 
		self.chan = 0
		self.unit = uhd.dboard_iface.UNIT_TX
		self.dac = uhd.dboard_iface.AUX_DAC_A
		self.iface = self.u.get_dboard_iface(self.chan)


		# Set up the transmitter. Filename hardcoded for now. 
        	self.s.set_samp_rate(options.samp)
        	self.s.set_gain(options.tgain, 0)
        	self.s.set_antenna("TX/RX", 0)
		#self.s.set_center_freq(2412e6, 0)
	
		# Connect the blocks. Source from a file.	
		if len(filename) >= 1:
			self.fs = blocks.file_source(gr.sizeof_gr_complex*1, filename[0], True) 
			self.connect((self.fs, 0), (self.s, 0))
		
		# Set up the receiver 
        	self.u.set_samp_rate(options.samp)
        	self.u.set_gain(options.rgain, 0)
        	self.u.set_antenna("RX2", 0)
		#self.u.set_center_freq(2425e6, 0)

		# Connect the blocks. Write to a file.
		if len(filename) == 2:
			self.f = blocks.file_meta_sink(gr.sizeof_gr_complex*1, filename[1], options.samp, 1, blocks.GR_FILE_FLOAT, True, 1000000, "", True)
        		self.f.set_unbuffered(False)
			self.connect((self.u, 0), (self.f, 0))

	def change_band(self, fr, ft):
		current_t = self.u.get_time_now().get_real_secs()
		
		#self.s.set_command_time(uhd.time_spec(current_t + self.fixed_delay))
	        self.s.set_center_freq(ft, 0)
		#self.s.clear_command_time()
		
		#self.u.set_command_time(uhd.time_spec(current_t + self.fixed_delay))
		self.u.set_center_freq(fr, 0)
		#self.u.clear_command_time()
		

		time.sleep(5*self.fixed_delay)


	def gen_chirp(self):
		max_dac_steps = 16
		current_t = self.u.get_time_now().get_real_secs()
		
		t = current_t + self.fixed_delay + self.delay
		self.fk.write('chirp:' + str(t) + '\n')
		self.fk.write('chirp:' + str(t + self.delay*max_dac_steps) + '\n')

		for i in range (0, max_dac_steps):
			self.u.set_command_time(uhd.time_spec(current_t + self.fixed_delay + self.delay*i))
			self.iface.write_aux_dac(self.unit, self.dac, i*0.2)				
			self.u.clear_command_time()
	
		self.u.set_command_time(uhd.time_spec(current_t + self.fixed_delay + self.delay*max_dac_steps))
		self.iface.write_aux_dac(self.unit, self.dac, 0)				
		self.u.clear_command_time()
		
		time.sleep(self.fixed_delay)

def get_options():
	usage="%prog: [options] input_filename output_filename"
	parser = OptionParser(option_class=eng_option, usage=usage)
	
	parser.add_option("-s", "--rrate", type="float", dest="samp",
			default=20e6, 
               		help="Set the receiver sample rate")
	
	parser.add_option("-t", "--tgain", type="float", dest="tgain",
			default=1, 
          		help="Set the transmitter gain")

	parser.add_option("-r", "--rgain", type="float", dest="rgain",
			default=1, 
                	help="Set the receiver gain")
		
	parser.add_option("-m", "--mode", type="float", dest="mode",
			default=1, 
                 	help="Set the mode: Calibration/Testing")
		
	(options, filename) = parser.parse_args()
	return (options, filename)
		

def main():
	index = 0
	band_starts = [2156e6, 2207e6, 2251e6, 2295e6, 2347e6, 2391e6, 2439e6, 2491e6, 2542e6, 2590e6, 2642e6, 2702e6, 2758e6, 2814e6, 2882e6]
	
	(options, filename) = get_options()
	tb = uhd_fft(options, filename)
	tb.start()
	
	# Use center of the band frequencies for the calibration mode. Use other frequencies for the testing mode.
	# Default mode is calibration mode.
	if(options.mode):
		tx_freq_list = [2156e6, 2207e6, 2251e6, 2295e6, 2347e6, 2391e6, 2439e6, 2491e6, 2542e6, 2590e6, 2642e6, 2702e6, 2758e6, 2814e6, 2882e6]
		#freq_list = [2168e6, 2225e6, 2269e6, 2316e6, 2363e6, 2408e6, 2459e6, 2508e6, 2553e6, 2602e6, 2653e6, 2710e6, 2768e6, 2800e6, 2900e6]
		#freq_list = [2178e6, 2245e6, 2289e6, 2336e6, 2383e6, 2428e6, 2479e6, 2528e6, 2573e6, 2622e6, 2673e6, 2730e6, 2788e6, 2820e6, 2920e6]
		rx_freq_list = [2178e6, 2245e6, 2289e6, 2336e6, 2383e6, 2428e6, 2479e6, 2528e6, 2573e6, 2622e6, 2673e6, 2730e6, 2788e6, 2820e6, 2920e6]
	else:
		freq_list = [2198e6, 2245e6, 2289e6, 2336e6, 2383e6, 2428e6, 2479e6, 2528e6, 2573e6, 2622e6, 2673e6, 2730e6, 2788e6, 2820e6, 2920e6]
		

	#for x in range (0,100):
	for fr in rx_freq_list:
			#tb.change_band(f)
		tb.fk.write(str(band_starts[index]) + '\n')
		tb.change_band(fr, tx_freq_list[index])
		tb.gen_chirp()
		index = index + 1
	
	time.sleep(0.01)
	tb.fk.close()
	tb.stop()

# Call the main function.
main()

'''

GPIO Code
self.iface.set_gpio_ddr(uhd.dboard_iface.UNIT_TX, 0xFFFF, 0x0001)
self.iface.set_gpio_out(uhd.dboard_iface.UNIT_TX, 0xFFFF, 0x0001)
read_gpio = self.iface.read_gpio(uhd.dboard_iface.UNIT_TX)
print(read_gpio)
self.iface.set_gpio_ddr(uhd.dboard_iface.UNIT_TX, 0xFFFF, 0x0001)
self.iface.set_gpio_out(uhd.dboard_iface.UNIT_TX, 0xFFFE, 0x0001)
read_gpio = self.iface.read_gpio(uhd.dboard_iface.UNIT_TX)
print(read_gpio)
'''
