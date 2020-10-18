`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: James Talbert <jtalbert123@gmail.com> 
// 
// Create Date: 02/13/2020 02:59:03 PM
// Design Name: AXIS I2C Master
// Module Name: QuantaGenerator
// Project Name: 
// Target Devices: 
// Tool Versions: Developed with Vivado 2019.2
// Description: Generates a periodic 1-cycle pulse when enabled. 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Down counting, i_period is sampled only when the counter reaches 0 (when a tick is outputted).
// 
//////////////////////////////////////////////////////////////////////////////////


module QuantaGenerator(
    input i_clk,
    input i_aresetn,
    input i_reset,
    output o_en,
    input [31:0] i_period
    );
    
    reg[31:0] count_val;
    
    always @(negedge i_aresetn, posedge i_clk)
    begin
		if (i_aresetn == 0) begin
			count_val <= 0;
		end else if (i_clk == 1) begin
			if (i_reset || count_val == 0) begin
				count_val <= i_period;
			end else begin
				count_val <= count_val - 1;
			end
		end
    end
    
    assign o_en = count_val == 0;
endmodule
