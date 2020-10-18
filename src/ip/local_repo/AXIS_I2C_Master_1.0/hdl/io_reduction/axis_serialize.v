`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: James Talbert
// 
// Create Date: 02/24/2020 04:11:53 PM
// Design Name: 
// Module Name: axis_serialize
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Converts an 8-bit stream to a 1-bit stream
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axis_serialize#(
    integer S_AXIS_TDATA_WIDTH = 8
) (
    input [S_AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
    input s_axis_tvalid,
    input s_axis_tlast,
    output s_axis_tready,
    
    output m_axis_tdata,
    output m_axis_tvalid,
    output m_axis_tlast,
    input m_axis_tready,
    
    input clk,
    input aresetn
    );
    
    reg [$clog2(S_AXIS_TDATA_WIDTH)-1:0] bit_counter;
    reg [S_AXIS_TDATA_WIDTH-1:0] stored_data;
    reg stored_data_valid;
    reg stored_data_last;
    
    assign s_axis_tready = ~stored_data_valid;
    assign m_axis_tvalid = stored_data_valid;
    assign m_axis_tdata = stored_data[bit_counter];
    assign m_axis_tlast = stored_data_last && (bit_counter == 0);
    
    always @(posedge clk, negedge aresetn) begin
        if (aresetn == 0) begin
            bit_counter <= 0;
            stored_data_valid <= 0;
            stored_data_last <= 0;
            bit_counter <= S_AXIS_TDATA_WIDTH-1;
        end else if (clk == 1) begin
            // Input data ready, nothing stored.
            if (s_axis_tvalid && !stored_data_valid) begin
                stored_data_valid <= 1;
                stored_data  <= s_axis_tdata;
                stored_data_last <= s_axis_tlast;
            end
            // Transmitting data, and data is received.
            if (m_axis_tvalid && m_axis_tready) begin
                if (bit_counter == 0) begin
                    bit_counter <= S_AXIS_TDATA_WIDTH-1;
                    stored_data_valid <= 0;
                end else begin
                    bit_counter <= bit_counter - 1;
                end
            end
        end
    end
endmodule
