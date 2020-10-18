`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2020 01:53:27 PM
// Design Name: 
// Module Name: tb_REQ
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

`timescale 1ns / 1ps

import axi4stream_vip_pkg::*;
import m_axis_vip_pkg::*;
import s_axis_vip_pkg::*;
import i2c_vip_pkg::*;

module tb_REQ();
    reg clk, resetn;
    // Ports of Axi Slave Bus Interface S_AXIS_REQ
	wire  req_tready;
	wire [7:0] req_tdata;
	wire  req_tlast;
	wire  req_tvalid;
	wire [7:0] resp_tdata;
	wire resp_tlast, resp_tready, resp_tvalid;
	wire SDA_o, SDA_t;
	wire SCL_o, SCL_t;
	wire SDA, SCL;
	
	reg slv_SDA_o, slv_SCL_o;
	
	i2c i2cbus();
	// Manages the AND function and pullup
	i2c_bus bus_manager (.bus(i2cbus));
	
	assign SDA = i2cbus.sda;
	assign SCL = i2cbus.scl;
	
    m_axis_vip req_stim (
        .aclk(clk),                 // input wire aclk
        .aresetn(resetn),           // input wire aresetn
        .m_axis_tvalid(req_tvalid),  // output wire [0 : 0] m_axis_tvalid
        .m_axis_tready(req_tready),  // input wire [0 : 0] m_axis_tready
        .m_axis_tdata(req_tdata),    // output wire [7 : 0] m_axis_tdata
        .m_axis_tlast(req_tlast)     // output wire [0 : 0] m_axis_tlast
    );
    
    s_axis_vip resp_monitor (
        .aclk(clk),                 // input wire aclk
        .aresetn(resetn),           // input wire aresetn
        .s_axis_tvalid(resp_tvalid),  // output wire [0 : 0] m_axis_tvalid
        .s_axis_tready(resp_tready),  // input wire [0 : 0] m_axis_tready
        .s_axis_tdata(resp_tdata),    // output wire [7 : 0] m_axis_tdata
        .s_axis_tlast(resp_tlast)     // output wire [0 : 0] m_axis_tlast
    );
    
    AXIS_I2C_Master_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Parameters of Axi Slave Bus Interface S_AXIS_REQ
		.C_S_AXIS_REQ_TDATA_WIDTH(8),

		// Parameters of Axi Master Bus Interface M_AXIS_RESP
		.C_M_AXIS_RESP_TDATA_WIDTH(8)
	) DUT
	(
		.clk(clk),
		.aresetn(resetn),
		
		// Ports of Axi Slave Bus Interface S_AXIS_REQ
		.s_axis_req_tready(req_tready),
		.s_axis_req_tdata(req_tdata),
		.s_axis_req_tlast(req_tlast),
		.s_axis_req_tvalid(req_tvalid),

		// Ports of Axi Master Bus Interface M_AXIS_RESP
		.m_axis_resp_tvalid(resp_tvalid),
		.m_axis_resp_tdata(resp_tdata),
		.m_axis_resp_tlast(resp_tlast),
		.m_axis_resp_tready(resp_tready),
		
		// I2C port
		.SDA_o(i2cbus.sda_o_mst), .SDA_t(),
		.SDA_i(i2cbus.sda),
		.SCL_o(i2cbus.scl_o_mst), .SCL_t(),
		.SCL_i(i2cbus.scl)
	);
	
	m_axis_vip_mst_t mst_agent;
	s_axis_vip_slv_t slv_agent;
	i2c_monitor i2cmon;
	i2c_slv_driver i2cslave;
    // Ready signal created by slave VIP when TREADY is High
    axi4stream_ready_gen ready_gen;
	
	initial begin
	   clk = 0;
	   resetn = 0;
	   #20ns resetn = 1;
	end
	always
	   #5ns clk = ~clk;
	
	axi4stream_transaction req_queue[$];
	time ack_queue[$];
	axi4stream_monitor_transaction expected_resp_queue[$];
	i2c_transaction i2cslave_queue[$];
    
    function void do_req;
	    input xil_axi4stream_data_byte data[];
	    automatic time delay = 1ns;
	    automatic xil_axi4stream_data_byte current;
        axi4stream_transaction beat;
	    //automatic integer i;
        foreach (data[i]) begin
            current = data[i][7:0];
            beat = mst_agent.driver.create_transaction("data beat " + i);
            beat.set_data('{current});
            beat.set_last(i == ($size(data, 1)-1));
            beat.set_delay(0);
            req_queue.push_back(beat);
        end
	endfunction;
    
    function void expect_response;
	    input xil_axi4stream_data_byte data[];
	    automatic time delay = 1ns;
	    automatic xil_axi4stream_data_byte current;
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
            expected_resp_queue.push_back(beat);
        end
	endfunction;
    
    function void do_i2c;
        input i2c_transaction tr;
        xil_axi4stream_data_byte data[];
        xil_axi4stream_data_byte dataq[$];
        automatic logic [7:0] addrbyte = 0;
        automatic logic [6:0] addr = 0;
        
        // get data from transaction
        tr.get_data(data);
        // build REQ AXIS byte queue.
        addrbyte = {tr.get_address(), tr.get_type()};
        dataq.push_back(addrbyte);
        if (tr.get_type()) begin
            dataq.push_back(data.size());
        end else begin
            foreach (data[i]) begin
                dataq.push_back(data[i]);
            end
        end
        // Colapse back to dynamic array
        data = new[dataq.size()](dataq);
	    
	    i2cslave_queue.push_back(tr);
	    do_req(data);
	    
	    if (tr.get_type()) begin
	       tr.get_data(data);
	       dataq = {>>{data}};
	       // add address ACK?
	       if (tr.get_data_size() > 0 || tr.get_final_ack()) begin
	           dataq.push_front(8'd0);
	       end else begin
               dataq.push_front(8'd1);
	       end
	       data = new[dataq.size()](dataq);
	       expect_response(data);
	    end else begin
	       dataq = '{};
	       if (tr.get_data_size() > 0 || tr.get_final_ack()) begin
	           dataq.push_front(8'd0);
	       end else begin
               dataq.push_front(8'd1);
	       end
	       dataq.push_back(tr.get_data_size());
	       data = new[dataq.size()](dataq);
	       expect_response(data);
	    end
	    dataq = '{};
    endfunction;
	
	initial begin
	   i2c_transaction tr;
	   forever begin
	       wait(i2cslave_queue.size() > 0);
	       tr = i2cslave_queue.pop_front();
	       i2cslave.set_transaction(tr);
	   end
	end
	
	initial begin
	   axi4stream_transaction beat;
	   while (1) begin
	       wait (req_queue.size() > 0);
	       beat = req_queue.pop_front();
	       
	       mst_agent.driver.send(beat);
	       wait (!req_tvalid);
	   end
	end
    
    initial begin
        axi4stream_monitor_transaction resp_tr;
        axi4stream_monitor_transaction expected_resp;
        xil_axi4stream_data_byte act_data[1], exp_data[1];
        //xil_axi4stream_data_byte act_data[4], exp_data[1];
        #1;
        forever begin
            slv_agent.monitor.item_collected_port.get(resp_tr);
            if (expected_resp_queue.size() == 0) begin
                $error("Test failed: Unexpected resp beat.");
            end else begin
                expected_resp = expected_resp_queue.pop_front();
                expected_resp.get_data(exp_data);
                resp_tr.get_data(act_data);
                if (exp_data[0] != act_data[0]) begin
                    $error("Test failed: Incorrect Resp data.");
                end
                if (expected_resp.get_last() != resp_tr.get_last()) begin
                    $error("Test failed: Incorrect tlast.");
                end
            end
            
        end
    end
    
    initial begin
        #1
        forever begin
            i2c_transaction tr;
            i2cmon.get_transaction(tr);
            $display(tr.convert2string());
        end
    end
	
	initial begin
	   slv_SDA_o <= 1;
	   slv_SCL_o <= 1;
	   
	   mst_agent = new ("master vip agent (req IF).", req_stim.inst.IF);
	   req_stim.inst.IF.set_xilinx_reset_check_to_warn();
	   mst_agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);
	   
	   mst_agent.start_master();
	   
	   slv_agent = new ("slave vip agent (resp IF).", resp_monitor.inst.IF);
	   resp_monitor.inst.IF.set_xilinx_reset_check_to_warn();
	   slv_agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);
	   
	   slv_agent.start_slave();
	   
	   i2cmon = new(.IF(i2cbus.monitor));
	   
	   i2cslave = new(.IF(i2cbus.slave));
	   
	   fork
	       i2cmon.run_phase();
	       i2cslave.run_phase();
	   join_none
	   
	   #50ns
	   begin
           i2c_transaction tr;
           tr = new(.address(7'h1), .read_nWrite(0), .data('{8'hAA}), .final_ack(0));
           do_i2c(.tr(tr));
           tr = new(.address(7'h2), .read_nWrite(0), .data('{8'hAA, 8'hBB}), .final_ack(1));
           do_i2c(.tr(tr));
           tr = new(.address(7'h3), .read_nWrite(1), .data('{8'h01, 8'h02, 8'h03}), .final_ack(1));
           do_i2c(.tr(tr));
	   end
	   
	   $display($time);
	end
	
	// Test process
	/*
	i2c_transaction a;
	logic [7:0] i2c_data[];
	initial begin
	   a = new(.data('{8'hAA}));
	   a.get_data(i2c_data);
	   //$display(a.convert2string());
	end
	*/
endmodule
