`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2020 04:15:43 PM
// Design Name: 
// Module Name: tb_AXIS_serdes
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

import axi4stream_vip_pkg::*;
import m_axis_vip_pkg::*;
import s_axis_vip_pkg::*;

module tb_AXIS_serdes(

    );
    reg clk;
    reg aresetn;
    
    reg m_axis_tlast, m_axis_tready, m_axis_tvalid;
    reg [7:0] m_axis_tdata;
    
    reg s_axis_tlast, s_axis_tready, s_axis_tvalid;
    reg [7:0] s_axis_tdata;
    
    reg axis_tlast, axis_tready, axis_tvalid;
    reg [0:0] axis_tdata;
	
	m_axis_vip_mst_t mst_agent;
	s_axis_vip_slv_t slv_agent;
	axi4stream_transaction m_axis_queue[$];
	axi4stream_monitor_transaction s_axis_queue[$];
	
    m_axis_vip stim (
        .aclk(clk),                 // input wire aclk
        .aresetn(aresetn),           // input wire aresetn
        .m_axis_tvalid(m_axis_tvalid),  // output wire [0 : 0] m_axis_tvalid
        .m_axis_tready(m_axis_tready),  // input wire [0 : 0] m_axis_tready
        .m_axis_tdata(m_axis_tdata),    // output wire [7 : 0] m_axis_tdata
        .m_axis_tlast(m_axis_tlast)     // output wire [0 : 0] m_axis_tlast
    );
    
    axis_serialize#(
        .S_AXIS_TDATA_WIDTH(8)
    ) ser (
        .s_axis_tdata(m_axis_tdata),
        .s_axis_tvalid(m_axis_tvalid),
        .s_axis_tlast(m_axis_tlast),
        .s_axis_tready(m_axis_tready),
        
        .m_axis_tdata(axis_tdata),
        .m_axis_tvalid(axis_tvalid),
        .m_axis_tlast(axis_tlast),
        .m_axis_tready(axis_tready),
        
        .clk(clk),
        .aresetn(aresetn)
    );
    
    axis_deserialize#(
        .M_AXIS_TDATA_WIDTH(8)
    ) des (
        .s_axis_tdata(axis_tdata),
        .s_axis_tvalid(axis_tvalid),
        .s_axis_tlast(axis_tlast),
        .s_axis_tready(axis_tready),
        
        .m_axis_tdata(s_axis_tdata),
        .m_axis_tvalid(s_axis_tvalid),
        .m_axis_tlast(s_axis_tlast),
        .m_axis_tready(s_axis_tready),
        
        .clk(clk),
        .aresetn(aresetn)
    );
    
    s_axis_vip monitor (
        .aclk(clk),                 // input wire aclk
        .aresetn(aresetn),           // input wire aresetn
        .s_axis_tvalid(s_axis_tvalid),  // output wire [0 : 0] m_axis_tvalid
        .s_axis_tready(s_axis_tready),  // input wire [0 : 0] m_axis_tready
        .s_axis_tdata(s_axis_tdata),    // output wire [7 : 0] m_axis_tdata
        .s_axis_tlast(s_axis_tlast)     // output wire [0 : 0] m_axis_tlast
    );
    
    default clocking cb @(posedge clk);
    endclocking
    
    initial begin
        aresetn <= 0;
        clk <= 0;
        ##8 aresetn <= 1;
    end
    
    always #5ns clk <= ~clk;
    
    function void send_data;
	    input xil_axi4stream_data_byte data[];
	    xil_axi4stream_data_byte current;
        axi4stream_transaction beat;
	    //automatic integer i;
        foreach (data[i]) begin
            current = data[i][7:0];
            beat = mst_agent.driver.create_transaction("data beat " + i);
            beat.set_data('{current});
            beat.set_last(i == ($size(data, 1)-1));
            beat.set_delay(0);
            m_axis_queue.push_back(beat);
        end
	endfunction;
    
    function void expect_response;
	    input xil_axi4stream_data_byte data[];
	    xil_axi4stream_data_byte current;
        axi4stream_monitor_transaction beat;
        //automatic integer i;
        foreach (data[i]) begin
            current = data[i][7:0];
            beat = new("Expected response beat " + i,
                s_axis_vip_VIP_SIGNAL_SET,
                s_axis_vip_VIP_DATA_WIDTH,
                s_axis_vip_VIP_USER_WIDTH,
                s_axis_vip_VIP_USER_BITS_PER_BYTE,
                s_axis_vip_VIP_ID_WIDTH,
                s_axis_vip_VIP_DEST_WIDTH);
            beat.set_data('{current});
            beat.set_last(i == ($size(data, 1)-1));
            beat.set_delay(0);
            s_axis_queue.push_back(beat);
        end
	endfunction;
	
    function testcase;
	    input xil_axi4stream_data_byte data[];
	    send_data(data);
	    expect_response(data);
    endfunction
	
	initial begin
	   axi4stream_transaction beat;
	   while (1) begin
	       wait (m_axis_queue.size() > 0);
	       beat = m_axis_queue.pop_front();
	       
	       mst_agent.driver.send(beat);
	       wait (!m_axis_tvalid);
	   end
	end
    
    initial begin
        axi4stream_monitor_transaction s_axis_tr;
        axi4stream_monitor_transaction expected_resp;
        xil_axi4stream_data_byte act_data[1], exp_data[1];
        //xil_axi4stream_data_byte act_data[4], exp_data[1];
        #1;
        forever begin
            slv_agent.monitor.item_collected_port.get(s_axis_tr);
            if (s_axis_queue.size() == 0) begin
                $error("Test failed: Unexpected resp beat.");
            end else begin
                expected_resp = s_axis_queue.pop_front();
                expected_resp.get_data(exp_data);
                s_axis_tr.get_data(act_data);
                if (exp_data[0] != act_data[0]) begin
                    $error("Test failed: Incorrect Resp data.");
                end
                if (expected_resp.get_last() != s_axis_tr.get_last()) begin
                    $error("Test failed: Incorrect tlast.");
                end
            end
            
        end
    end
    
    initial begin
        mst_agent = new ("master vip agent (req IF).", stim.inst.IF);
	    stim.inst.IF.set_xilinx_reset_check_to_warn();
        mst_agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);
        mst_agent.start_master();
       
        slv_agent = new ("slave vip agent (resp IF).", monitor.inst.IF);
        monitor.inst.IF.set_xilinx_reset_check_to_warn();
        slv_agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);
	    slv_agent.start_slave();
	    
	    testcase('{8'hAA});
	    testcase('{8'h11, 8'h22});
	    testcase('{8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77});
	    testcase('{8'h0F, 8'h1E, 8'h2C, 8'h3B, 8'h4A, 8'h59, 8'h68});
    end
endmodule
