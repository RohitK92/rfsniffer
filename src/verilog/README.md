Here is a description of how the hardware works - 

1. Configuration phase
	- The first "always" block in the driver code is to determine which bands the hardware will program the VCO for and to configure your chirp signal.
	- Remember that this phase has to occur before the "run" phase, since the "run" phase uses the variables set in the configuration phase.
	- To start the configuration phase, you should program the "user registers" before you start the capture from software.
	- Few examples of setting the user registers from softwware are included at the end of this README.
	- Please be sure to follow the register map given below. If you make an error, the hardware will automatically set all the registers to default values.
	- Things may go wrong if the configuration is not done properly. If you think you are getting wrong results, I would recommend you to restart the USRP and check your SW code where you set the user registers. 

2. Run phase
	- The second "always" block in the driver code runs 2 state machines to communicate with the TX aux DAC and RX VCO to create a chirp signal and set different frequencies.
	- I refer to variables initialized in the config phase while sending SPI messages to the DAC and VCO.
	- This phase is triggered when you start a capture from the SW code.


Some theory about aux DAC - 
Voltage produced by DAC = Value written into DAC register/65535 * 3V

For the chirp signal, I use this terminology for software-hardware communication.
"Number of steps" = Steps it takes to reach to 3V.
"Jump" = Fixed size jumps made to reach to 65535 and produce 3V.

My terminology might be confusing, so just keep the following formula in mind while configuring your chirp signal - 
"Jump" = 65536/"Number of steps".
Here, I use 65536 so that chirp goes to 0.

IMPORTANT: I would recommend you to proceed in the following way - 
1. Decide on the number of steps for your chirp signal.
2. Use the formula given above to find out "jump".
3. If "jump" is not an integer, please take ceiling(jump) and use this value.
4. If you forget to use ceiling function, your chirp signal will stay at 3V.


User Register Map - 
Register 1 - Use this register to tell the hardware which of the first 32 bands you want to sweep.
	     This is a bit array. This means that bit 0 maps to band 1, bit 31 maps to band 32.
	     Example - If you want to sweep band 2 and 3, you should set bit 1 and 2 to 1 and all other bits should be 0. That is, I expect you to write a decimal value of 6 into this register. Register 2 should be 0.
Register 2 - Use this register to tell the hardware which of the next 5 bands (band number 33 to 37) you want to sweep.
	     This is a bit array. This means that bit 0 maps to band 33, bit 4 maps to band 37. Higher bits are don't care.
Register 3 - Use this register to mention "Number of steps" for the chirp signal.
Register 4 - Use this register to mention the "Jump" size for the chirp signal.
Register 5 - Use this register to tell the hardware the "clock divider value" for DAC. Based on the clock divider value, the hardware will set the SPI clock for the aux DAC.
Register 6 - Use this register to tell the hardware about the "RF divider" value it should use while configuring the VCO.
	     If you enter 1 - Output frequency will be in the range 2.2 Ghz to 4.4 GHz
	     If you enter 2 - Output frequency will be in the range 1.1 Ghz to 2.2 GHz
	     If you enter 4 - Output frequency will be in the range 550 Mhz to 1.1 GHz



Examples - (Python)
Example 1 - 
self.u.set_user_register(1,15,0) # Sweep bands 1, 2, 3 and 4.                   
self.u.set_user_register(2,0,0) # 
self.u.set_user_register(3,8,0) # Number of steps are 8                          
self.u.set_user_register(4,8192,0) # Jump is 8192.               
self.u.set_user_register(5,4,0) # SPI clock divider for DAC is 4. This means DAC will get a 10 MHz clock.
self.u.set_user_register(6,1,0) # RF divider value is 1. I would recommend you to check the datasheet of ADF4350 (register 4 map) before setting this register.


Example 2 - 
self.u.set_user_register(1,4096,0) # Sweep band 12 only.                   
self.u.set_user_register(2,0,0) # 
self.u.set_user_register(3,16,0) # Number of steps are 16                       
self.u.set_user_register(4,4096,0) # Jump is 4096.               
self.u.set_user_register(5,8,0) # SPI clock divider for DAC is 8. This means DAC will get a 5 MHz clock.
self.u.set_user_register(6,2,0) # RF divider value is 2. I would recommend you to check the datasheet of ADF4350 (register 4 map) before setting this register.


Example 3 - 
self.u.set_user_register(1,0,0) # .                   
self.u.set_user_register(2,3,0) # Sweep bands 33 and 34
self.u.set_user_register(3,10,0) # Number of steps are 10                          
self.u.set_user_register(4,6554,0) # Jump is 6554.               
self.u.set_user_register(5,4,0) # SPI clock divider for DAC is 4. This means DAC will get a 10 MHz clock.
self.u.set_user_register(6,4,0) # RF divider value is 4. I would recommend you to check the datasheet of ADF4350 (register 4 map) before setting this register.
