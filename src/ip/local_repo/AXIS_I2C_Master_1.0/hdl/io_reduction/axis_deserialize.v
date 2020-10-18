`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: James Talbert
// 
// Create Date: 02/24/2020 04:11:53 PM
// Design Name: 
// Module Name: axis_deserialize
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Converts a 1-bit stream to an 8-bit stream
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axis_deserialize#(
    integer M_AXIS_TDATA_WIDTH = 8
) (
    input s_axis_tdata,
    input s_axis_tvalid,
    input s_axis_tlast,
    output s_axis_tready,
    
    output [M_AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
    output m_axis_tvalid,
    output m_axis_tlast,
    input m_axis_tready,
    
    input clk,
    input aresetn
    );
    
    reg [$clog2(M_AXIS_TDATA_WIDTH)-1:0] bit_counter;
    reg [M_AXIS_TDATA_WIDTH-1:0] stored_data;
    reg stored_data_valid;
    reg stored_data_last;
    
    assign s_axis_tready = ~stored_data_valid;
    assign m_axis_tvalid = stored_data_valid;
    assign m_axis_tdata = stored_data;
    assign m_axis_tlast = stored_data_last;
    
    always @(posedge clk, negedge aresetn) begin
        if (aresetn == 0) begin
            bit_counter <= 0;
            stored_data_valid <= 0;
            stored_data_last <= 0;
            bit_counter <= M_AXIS_TDATA_WIDTH-1;
        end else if (clk == 1) begin
            // output data ready, output data read.
            if (m_axis_tvalid && m_axis_tready) begin
                stored_data_valid <= 0;
                stored_data_last <= 0;
            end
            // receiving data, and data is being transmitted.
            if (s_axis_tvalid && s_axis_tready) begin
                stored_data[bit_counter] <= s_axis_tdata;
                stored_data_last <= stored_data_last | s_axis_tlast;
                if (bit_counter == 0) begin
                    bit_counter <= M_AXIS_TDATA_WIDTH-1;
                    stored_data_valid <= 1;
                end else begin
                    bit_counter <= bit_counter - 1;
                end
            end
        end
    end
endmodule
