module chirp_spi_core
    (
        input clock, input reset,
        input start_tr,
	input device,
	input [5:0] num_bits,
	input [31:0] sclk_divider, 
	input [31:0] set_data,
        output ready,
        output [1:0] sen,
        output sclk,
        output mosi
    );

    localparam WAIT_TRIG = 0;
    localparam PRE_IDLE = 1;
    localparam CLK_REG = 2;
    localparam CLK_INV = 3;
    localparam POST_IDLE = 4;
    localparam IDLE_SEN = 5;
    localparam READY_LOW = 6;

    reg [2:0] state = WAIT_TRIG;

    reg ready_reg = 0;
    assign ready = ready_reg;
    
    reg sclk_reg = 0;
    assign sclk = sclk_reg;

    wire sen_is_idle = (state == WAIT_TRIG) || (state == READY_LOW);
    assign sen[0] = (!sen_is_idle && device == 0) ? 0 : 1;
    assign sen[1] = (!sen_is_idle && device == 1) ? 0 : 1;
	
    reg [31:0] dataout_reg;
    wire [31:0] dataout_next = {dataout_reg[30:0], 1'b0};
    assign mosi = dataout_reg[31];

    reg [15:0] sclk_counter;
    wire sclk_counter_done = (sclk_counter == sclk_divider);
    wire [15:0] sclk_counter_next = (sclk_counter_done)? 0 : sclk_counter + 1;
	
	
    reg [6:0] bit_counter;
    wire [6:0] bit_counter_next = bit_counter + 1;
    wire bit_counter_done = (bit_counter_next == num_bits);
    
    always @(posedge clock) begin
	if (!reset) begin
	    state <= WAIT_TRIG;
            ready_reg <= 0;
	    sclk_reg <= 0;
	    dataout_reg[31] <= 0;
        end
        else begin
            case (state)
            WAIT_TRIG: begin
                if (start_tr) begin
                    state <= PRE_IDLE;
                    ready_reg <= 0;
                    dataout_reg <= set_data;
                    sclk_counter <= 0;
                    bit_counter <= 0;
                    sclk_reg <= 0;
		end
            end

            PRE_IDLE: begin	
                if (sclk_counter_done) begin
                  state <= CLK_REG;
                  sclk_reg <= 0;
		end
                sclk_counter <= sclk_counter_next;
            end

            CLK_REG: begin
                if (sclk_counter_done) begin
                    if (device == 0 && bit_counter != 0) dataout_reg <= dataout_next;
                    state <= CLK_INV;
                    sclk_reg <= ~sclk_reg;
                end
                sclk_counter <= sclk_counter_next;
            end

            CLK_INV: begin
                if (sclk_counter_done) begin
                    if (device == 1) dataout_reg <= dataout_next;
                    state <= (bit_counter_done)? POST_IDLE : CLK_REG;
                    bit_counter <= bit_counter_next;
                    sclk_reg <= ~sclk_reg;
                end
                sclk_counter <= sclk_counter_next;
            end

            POST_IDLE: begin
                if (sclk_counter_done) begin
                    state <= IDLE_SEN;
                    sclk_reg <= 0;
		end
                sclk_counter <= sclk_counter_next;
            end

            IDLE_SEN: begin
                ready_reg <= 1;
                state <= READY_LOW;
                sclk_reg <= 0;
            end
			
            READY_LOW: begin
                ready_reg <= 0;
                state <= WAIT_TRIG;
            end

            default: state <= WAIT_TRIG;
            endcase
	end
        end
endmodule
