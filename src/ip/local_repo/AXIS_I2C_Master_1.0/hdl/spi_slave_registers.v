`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2020 08:36:10 PM
// Design Name: 
// Module Name: spi_slave_registers
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module spi_slave_registers(
    input spi_ss,
    input spi_mosi,
    output reg spi_miso,
    output spi_miso_tri,
    input spi_clk,
    input clk,
    input aresetn,
		
	output reg [31:0] period_1,
	output reg [31:0] period_2,
	output reg [31:0] period_3,
	output reg [31:0] period_4,
	output reg [31:0] period_start_1,
	output reg [31:0] period_start_2,
	output reg [31:0] period_start_3,
	output reg [31:0] period_stop_1,
	output reg [31:0] period_stop_2,
	output reg [31:0] period_stop_3,
	
	input wire [4:0] fsm_state,
	input wire [1:0] fsm_bit_state
    );
    localparam integer WORD_SIZE = 8;
    localparam integer NUM_IN_REGS = 4*10;
    localparam integer NUM_OUT_REGS = 1;
    localparam integer NUM_REGS = NUM_IN_REGS + NUM_OUT_REGS;
    
    assign spi_miso_tri = spi_ss;
    
    reg [WORD_SIZE-1:0] inregs [NUM_IN_REGS-1:0];
    reg [WORD_SIZE-1:0] regs [NUM_REGS-1:0];
    reg [WORD_SIZE-1:0] rxword;
    reg [$clog2(NUM_REGS)-1:0] address;
    // Up-counter (LSB first)
    reg [$clog2(WORD_SIZE)-1:0] bit_counter;
    reg [$clog2(NUM_REGS+1)-1:0] rx_counter;
    
    reg old_sclk;
    reg old_ss;
    reg rxword_done;
    
    integer i;
    always @(*) begin
        for (i = 0; i < NUM_IN_REGS; i = i + 1) begin
            regs[i] <= inregs[i];
        end
    end
//    genvar j;
//    generate for (j = 0; j < NUM_IN_REGS; j = j + 1) begin
//        assign regs[i] = inregs[i];
//    end
//    endgenerate
    
    //integer i;
    always @(negedge aresetn, posedge clk) begin
        if (aresetn == 0) begin
            old_sclk <= 0;
            rx_counter <= 0;
            bit_counter <= 0;
            rxword_done <= 0;
            for (i = 0; i < NUM_IN_REGS; i = i+1) begin
                inregs[i] <= 0;
            end
        end else if (clk == 1) begin
            if (spi_ss) begin
                old_sclk <= 0;
                bit_counter <= 0;
                rx_counter <= 0;
            end else begin
                // Sample on rising edge
                if (!old_sclk && spi_clk) begin
                    rxword[bit_counter] <= spi_mosi;
                    if (bit_counter < WORD_SIZE-1) begin
                        bit_counter <= bit_counter + 1;
                    end else begin
                        rxword_done <= 1;
                        bit_counter <= 0;
                    end
                end else begin
                    if ((old_sclk && !spi_clk) || (old_ss && !spi_ss)) begin
                        spi_miso <= regs[address][bit_counter];
                    end
                end
                old_sclk <= spi_clk;
                old_ss <= spi_ss;
            end
            if (rxword_done) begin
                rxword_done <= 0;
                if (rx_counter == 0) begin
                    address <= rxword;
                end else begin
                    if (address < NUM_IN_REGS) begin
                        inregs[address] <= rxword;
                    end
                    address <= address + 1;
                end
                rx_counter <= rx_counter + 1;
            end
        end
    end
    
    always @(*) begin
        period_1 <= {regs[3],regs[2],regs[1],regs[0]};
		period_2 <= {regs[7],regs[6],regs[5],regs[4]};
		period_3 <= {regs[11],regs[10],regs[9],regs[8]};
		period_4 <= {regs[15],regs[14],regs[13],regs[12]};
		
        period_start_1 <= {regs[19],regs[18],regs[17],regs[16]};
		period_start_2 <= {regs[23],regs[22],regs[21],regs[20]};
		period_start_3 <= {regs[27],regs[26],regs[25],regs[24]};
		
        period_stop_1 <= {regs[31],regs[20],regs[29],regs[28]};
		period_stop_2 <= {regs[35],regs[34],regs[33],regs[32]};
		period_stop_3 <= {regs[39],regs[38],regs[37],regs[36]};
		
		regs[NUM_IN_REGS][4:0] <= fsm_state;
		regs[NUM_IN_REGS][6:5] <= fsm_bit_state;
		regs[NUM_IN_REGS][7] <= 0;
    end
    
endmodule
