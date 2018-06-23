module chirp_spi_driver
     (
	input clock,
	input reset,
	input set_stb_user,
	input [7:0] set_addr_user,
	input [31:0] set_data_user,
	input trigger,
        output [1:0] sen,
        output sclk,
        output mosi,
	output [7:0] debug
     );

localparam START_CHIRP = 0;
localparam GENERATE_CHIRP = 1;
localparam WAIT_READY_DAC = 2;
localparam SET_FREQUENCY = 3;
localparam WAIT_READY_VCO = 4;
localparam WAIT_FOR_VCO_LOCK = 5;

reg device;
reg start_tr;
reg first_match;
reg [2:0] state; 
reg [4:0] rf_divider;
reg [5:0] band;
reg [5:0] do_band;
reg [5:0] first_band_match;
reg [5:0] num_bits;
reg [7:0] prefix; 
reg [15:0] data;
reg [15:0] jump; 
reg [23:0] start_data; 
reg [31:0] freq_bit_array;
reg [31:0] freq_bit_array2;
reg [31:0] counter;
reg [31:0] num_sawtooth_steps;
reg [31:0] load_data;
reg [31:0] sclk_divider;
reg [31:0] sclk_divider_dac;
reg [31:0] wait_counter;
reg [31:0] reg4_contents;
reg [31:0] reg0_contents [36:0];
wire ready;


always @ (*) begin
	if (freq_bit_array[0] == 1 && do_band == 0) begin
		band = 1; 
	end else if (freq_bit_array[1] == 1 && do_band <= 1) begin
		band = 2; 
	end else if (freq_bit_array[2] == 1 && do_band <= 2) begin
		band = 3; 
	end else if (freq_bit_array[3] == 1 && do_band <= 3) begin
		band = 4; 
	end else if (freq_bit_array[4] == 1 && do_band <= 4) begin
		band = 5; 
	end else if (freq_bit_array[5] == 1 && do_band <= 5) begin
		band = 6;
	end else if (freq_bit_array[6] == 1 && do_band <= 6) begin
		band = 7;
	end else if (freq_bit_array[7] == 1 && do_band <= 7) begin
		band = 8;
	end else if (freq_bit_array[8] == 1 && do_band <= 8) begin
		band = 9;
	end else if (freq_bit_array[9] == 1 && do_band <= 9) begin
		band = 10;
	end else if (freq_bit_array[10] == 1 && do_band <= 10) begin
		band = 11;
	end else if (freq_bit_array[11] == 1 && do_band <= 11) begin
		band = 12;
	end else if (freq_bit_array[12] == 1 && do_band <= 12) begin
		band = 13; 
	end else if (freq_bit_array[13] == 1 && do_band <= 13) begin
		band = 14; 
	end else if (freq_bit_array[14] == 1 && do_band <= 14) begin
		band = 15; 
	end else if (freq_bit_array[15] == 1 && do_band <= 15) begin
		band = 16; 
	end else if (freq_bit_array[16] == 1 && do_band <= 16) begin
		band = 17;
	end else if (freq_bit_array[17] == 1 && do_band <= 17) begin
		band = 18;
	end else if (freq_bit_array[18] == 1 && do_band <= 18) begin
		band = 19;
	end else if (freq_bit_array[19] == 1 && do_band <= 19) begin
		band = 20;
	end else if (freq_bit_array[20] == 1 && do_band <= 20) begin
		band = 21;
	end else if (freq_bit_array[21] == 1 && do_band <= 21) begin
		band = 22;
	end else if (freq_bit_array[22] == 1 && do_band <= 22) begin
		band = 23;
	end else if (freq_bit_array[23] == 1 && do_band <= 23) begin
		band = 24;
	end else if (freq_bit_array[24] == 1 && do_band <= 24) begin
		band = 25; 
	end else if (freq_bit_array[25] == 1 && do_band <= 25) begin
		band = 26; 
	end else if (freq_bit_array[26] == 1 && do_band <= 26) begin
		band = 27; 
	end else if (freq_bit_array[27] == 1 && do_band <= 27) begin
		band = 28; 
	end else if (freq_bit_array[28] == 1 && do_band <= 28) begin
		band = 29;
	end else if (freq_bit_array[29] == 1 && do_band <= 29) begin
		band = 30;
	end else if (freq_bit_array[30] == 1 && do_band <= 30) begin
		band = 31;
	end else if (freq_bit_array[31] == 1 && do_band <= 31) begin
		band = 32;
	end else if (freq_bit_array2[0] == 1 && do_band <= 32) begin
		band = 33;
	end else if (freq_bit_array2[1] == 1 && do_band <= 33) begin
		band = 34;
	end else if (freq_bit_array2[2] == 1 && do_band <= 34) begin
		band = 35;
	end else if (freq_bit_array2[3] == 1 && do_band <= 35) begin
		band = 36;
	end else if (freq_bit_array2[4] == 1 && do_band <= 36) begin
		band = 37;
	end else begin
		band = first_band_match + 1;
	end

	if (rf_divider == 1)
		reg4_contents <= 32'h000FA23C;
	else if (rf_divider == 2)
		reg4_contents <= 32'h001FA23C;
	else if (rf_divider == 4)
		reg4_contents <= 32'h002FA23C;
	else if (rf_divider == 8)
		reg4_contents <= 32'h003FA23C;
	else if (rf_divider == 16)
		reg4_contents <= 32'h004FA23C;
	else 
		reg4_contents <= 32'h000FA23C; // If the user enters a wrong value, set default to 2.2-4.4GHz band.

end



always @ (posedge clock) begin
	if (set_stb_user == 1) begin
		if (set_addr_user == 1)
			freq_bit_array <= set_data_user;
		else if (set_addr_user == 2)
			freq_bit_array2 <= set_data_user;
		else if (set_addr_user == 3)
			num_sawtooth_steps <= set_data_user;
		else if(set_addr_user == 4)
			jump <= set_data_user;
		else if (set_addr_user == 5)
			sclk_divider_dac <= set_data_user;
		else if (set_addr_user == 6)
			rf_divider <= set_data_user;
		else begin // This is a bad way of initialization but set the default values here for now.
			num_sawtooth_steps <= 16;
			jump <= 4096;
			sclk_divider_dac <= 4;
			freq_bit_array <= 1;
			freq_bit_array2 <= 0;
			rf_divider <= 1;
		end 
	end
end

always @ (posedge clock) begin
	if (!trigger) begin
		start_tr <= 0;
		start_data <= 24'b000110000000000000000000; // The start sequence that we know works! 
		prefix <= 8'b00011000;
		state <= START_CHIRP;
		do_band <= 0;
		first_match <= 0;
		
		// Initialize reg0_contents memory.
		reg0_contents[0] <= 32'h002c47a8;
		reg0_contents[1] <= 32'h002d3330;
		reg0_contents[2] <= 32'h002e3330;
		reg0_contents[3] <= 32'h002f0000;
		reg0_contents[4] <= 32'h00300000;
		reg0_contents[5] <= 32'h00310000;
		reg0_contents[6] <= 32'h00320000;
		reg0_contents[7] <= 32'h00330000;
		reg0_contents[8] <= 32'h00340000;
		reg0_contents[9] <= 32'h00350000;
		reg0_contents[10] <= 32'h00363330;
		reg0_contents[11] <= 32'h00376660;
		reg0_contents[12] <= 32'h00390000;
		reg0_contents[13] <= 32'h0039ccc8;
		reg0_contents[14] <= 32'h003b0000;
		reg0_contents[15] <= 32'h003bccc8;
		reg0_contents[16] <= 32'h003c9998;
		reg0_contents[17] <= 32'h003dccc8;
		reg0_contents[18] <= 32'h003eccc8;
		reg0_contents[19] <= 32'h003fccc8;
		reg0_contents[20] <= 32'h00410000;
		reg0_contents[21] <= 32'h00423330;
		reg0_contents[22] <= 32'h00436660;
		reg0_contents[23] <= 32'h00449998;
		reg0_contents[24] <= 32'h0045ccc8;
		reg0_contents[25] <= 32'h00476660;
		reg0_contents[26] <= 32'h00489998;
		reg0_contents[27] <= 32'h004a0000;
		reg0_contents[28] <= 32'h004b3330;
		reg0_contents[29] <= 32'h004c3330;
		reg0_contents[30] <= 32'h004d6660;
		reg0_contents[31] <= 32'h004e9998;
		reg0_contents[32] <= 32'h004fccc8;
		reg0_contents[33] <= 32'h00510000;
		reg0_contents[34] <= 32'h00526660;
		reg0_contents[35] <= 32'h0053ccc8;
		reg0_contents[36] <= 32'h00550000;
	end
	else begin
	
	case(state)
	START_CHIRP: begin
		start_tr <= 1;
		counter <= 1;
		num_bits <= 32;
		device <= 1;
		sclk_divider <= 4; 
		load_data <= 32'h65008a4a;
		state <= WAIT_READY_VCO;
	end
	
	GENERATE_CHIRP: begin
		if (counter == num_sawtooth_steps + 1) begin // Beware..... We are setting chirp to 0.
			// Set frequency SPI is about to start. Configure everything.
			load_data <= 32'h65008a4a; // This is Register 2 for some reason. 
			device <= 1;
			num_bits <= 32;
			counter <= 1;
			state <= WAIT_READY_VCO;
			sclk_divider <= 4; 
		end else begin
			counter <= counter + 1;
			data <= data + jump;
			load_data <= {prefix, data, 8'h00};
			state <= WAIT_READY_DAC;
		end
		start_tr <= 1; // Danger! Please put me in the right block.
	end
	
	WAIT_READY_DAC: begin
		if (ready == 1)
			state <= GENERATE_CHIRP;
		else
			state <= WAIT_READY_DAC;
		start_tr <= 0;
	end

	SET_FREQUENCY: begin
		if (counter == 7) begin
			// Generate chirp SPI is about to start. Configure eveyrthing.
			wait_counter <= 0;
			state <= WAIT_FOR_VCO_LOCK;
		end else if (counter == 1) begin
			load_data <= 32'h00400005; // Register 5 
			counter <= counter + 1;
			state <= WAIT_READY_VCO;
			start_tr <= 1;
		end else if (counter == 2) begin
			counter <= counter + 1;
			state <= WAIT_READY_VCO;
		 	load_data <= reg4_contents; // Register 4 
			start_tr <= 1;
		end else if (counter == 3) begin
			counter <= counter + 1;
			state <= WAIT_READY_VCO;
		 	load_data <= 32'h0001001B; // Register 3
			start_tr <= 1;
		end else if (counter == 4) begin
			counter <= counter + 1;
			state <= WAIT_READY_VCO;
		 	load_data <= 32'h65008A42; // Register 2
			start_tr <= 1;
		end else if (counter == 5) begin
			counter <= counter + 1;
			state <= WAIT_READY_VCO;
		 	load_data <= 32'h00007FF9; // Register 1
			start_tr <= 1;
		end else begin
			counter <= counter + 1;
			state <= WAIT_READY_VCO;
			do_band <= band;
			
			if (first_match == 0) begin
				first_band_match <= band - 1;
				first_match <= 1;
			end
			
			load_data <= reg0_contents[band-1]; // Register 0
			start_tr <= 1; // danger. Please put me in the right block.
		end

	end

	WAIT_READY_VCO: begin
		if (ready == 1)
			state <= SET_FREQUENCY;
		else
			state <= WAIT_READY_VCO;
		start_tr <= 0;
	end

	WAIT_FOR_VCO_LOCK: begin
		if(wait_counter == 12000) begin
			wait_counter <= 0;
			counter <= 1;
			num_bits <= 24;
			device <= 0;
			sclk_divider <= sclk_divider_dac; 
			data <= start_data + jump; 
			load_data <= {start_data, 8'h00};
			state <= WAIT_READY_DAC;
			start_tr <= 1;
		end else begin
			wait_counter <= wait_counter + 1;
			state <= WAIT_FOR_VCO_LOCK;
		end
	end
	endcase
	end
end

chirp_spi_core chirp 
    (
        .clock(clock), 
	.reset(trigger),
	.device(device),
        .start_tr(start_tr),
	.num_bits(num_bits),
	.sclk_divider(sclk_divider), 
	.set_data(load_data),
        .ready(ready),
        .sen(sen),
        .sclk(sclk),
        .mosi(mosi)
    );

// Connect your debug signals here.
    assign debug = {
       rf_divider 
    };
endmodule
