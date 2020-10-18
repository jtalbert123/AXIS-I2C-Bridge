`timescale 1ns / 1ps
//`define CADENCE

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2020 04:11:53 PM
// Design Name: 
// Module Name: chip_top
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


module chip_top#(
    parameter integer SERIALIZE_INTERFACES = 1,
    
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 7
) (
    inout SDA,
    inout SCL,
    input [(1-SERIALIZE_INTERFACES)*7:0] s_axis_req_tdata,
    input s_axis_req_tvalid,
    input s_axis_req_tlast,
    output s_axis_req_tready,
    output [(1-SERIALIZE_INTERFACES)*7:0] m_axis_resp_tdata,
    output m_axis_resp_tvalid,
    output m_axis_resp_tlast,
    input m_axis_resp_tready,
    input spi_mosi,
    inout spi_miso,
    input spi_clk,
    input spi_ss,
    input clk,
    input aresetn
`ifndef CADENCE
    ,
    // Write address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
        // privilege and security level of the transaction, and whether
        // the transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_AWPROT,
    // Write address valid. This signal indicates that the master signaling
        // valid write address and control information.
    input wire  S_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
        // to accept an address and associated control signals.
    output wire  S_AXI_AWREADY,
    // Write data (issued by master, acceped by Slave) 
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
        // valid data. There is one write strobe bit for each eight
        // bits of the write data bus.    
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
        // data and strobes are available.
    input wire  S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
        // can accept the write data.
    output wire  S_AXI_WREADY,
    // Write response. This signal indicates the status
        // of the write transaction.
    output wire [1 : 0] S_AXI_BRESP,
    // Write response valid. This signal indicates that the channel
        // is signaling a valid write response.
    output wire  S_AXI_BVALID,
    // Response ready. This signal indicates that the master
        // can accept a write response.
    input wire  S_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
        // and security level of the transaction, and whether the
        // transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel
        // is signaling valid read address and control information.
    input wire  S_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
        // ready to accept an address and associated control signals.
    output wire  S_AXI_ARREADY,
    // Read data (issued by slave)
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    // Read response. This signal indicates the status of the
        // read transfer.
    output wire [1 : 0] S_AXI_RRESP,
    // Read valid. This signal indicates that the channel is
        // signaling the required read data.
    output wire  S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
        // accept the read data and response information.
    input wire  S_AXI_RREADY,
    
    
    output wire SDA_o_o, SDA_o_t,
    output wire SCL_o_o, SCL_o_t,
    output wire [4:0] state_o,
    output wire [1:0] bit_state_o
`endif
    );
    
    
    wire [7:0] s_axis_req_tdata_internal;
    wire s_axis_req_tvalid_internal;
    wire s_axis_req_tlast_internal;
    wire s_axis_req_tready_internal;
    
    wire [7:0] m_axis_resp_tdata_internal;
    wire m_axis_resp_tvalid_internal;
    wire m_axis_resp_tlast_internal;
    wire m_axis_resp_tready_internal;
    
    wire SDA_o, SDA_t, SDA_i;
    wire SCL_o, SCL_t, SCL_i;
    wire miso_o, miso_t;
		
    wire [31:0] period_1;
    wire [31:0] period_2;
    wire [31:0] period_3;
    wire [31:0] period_4;
    wire [31:0] period_start_1;
    wire [31:0] period_start_2;
    wire [31:0] period_start_3;
    wire [31:0] period_stop_1;
    wire [31:0] period_stop_2;
    wire [31:0] period_stop_3;
    
    wire [4:0] fsm_state;
    wire [1:0] fsm_bit_state;
    
`ifndef CADENCE
    assign state_o = fsm_state;
    assign bit_state_o = fsm_bit_state;
    assign SDA_o_o = SDA_o;
    assign SDA_o_t = SDA_t;
    assign SCL_o_o = SCL_o;
    assign SCL_o_t = SCL_t;
`endif
    
    function get_tri_state;
    input o, t;
    begin
        if (t) begin
            get_tri_state = 1'bZ;
        end else begin
            get_tri_state = o;
        end
    end endfunction
    
`ifdef CADENCE
    assign SDA = get_tri_state(SDA_o, SDA_t);
    assign SCL = get_tri_state(SCL_o, SCL_t);
    assign spi_miso = get_tri_state(miso_o, miso_t);
    assign SCL_i = SCL;
    assign SDA_i = SDA;
`else
    IOBUF #(
        .DRIVE(12), // Specify the output drive strength
        .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
        .IOSTANDARD("DEFAULT"), // Specify the I/O standard
        .SLEW("SLOW") // Specify the output slew rate
    ) IOBUF_sda (
        .O(SDA_i),     // Buffer output
        .IO(SDA),   // Buffer inout port (connect directly to top-level port)
        .I(SDA_o),     // Buffer input
        .T(SDA_t)      // 3-state enable input, high=input, low=output
    );
    IOBUF #(
        .DRIVE(12), // Specify the output drive strength
        .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
        .IOSTANDARD("DEFAULT"), // Specify the I/O standard
        .SLEW("SLOW") // Specify the output slew rate
    ) IOBUF_scl (
        .O(SCL_i),     // Buffer output
        .IO(SCL),   // Buffer inout port (connect directly to top-level port)
        .I(SCL_o),     // Buffer input
        .T(SCL_t)      // 3-state enable input, high=input, low=output
    );
    OBUFT OBUFT_miso (
        .O(spi_miso),   // Buffer inout port (connect directly to top-level port)
        .I(miso_o),     // Buffer input
        .T(miso_t)      // 3-state enable input, high=input, low=output
    );

`endif

    AXIS_I2C_Master_v1_0 core (
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line
		.clk(clk),
		.aresetn(aresetn),

        // Ports of Axi Slave Bus Interface S_AXIS_REQ
		.s_axis_req_tready(s_axis_req_tready_internal),
		.s_axis_req_tdata(s_axis_req_tdata_internal),
		.s_axis_req_tlast(s_axis_req_tlast_internal),
		.s_axis_req_tvalid(s_axis_req_tvalid_internal),

		// Ports of Axi Master Bus Interface M_AXIS_RESP
		.m_axis_resp_tvalid(m_axis_resp_tvalid_internal),
		.m_axis_resp_tdata(m_axis_resp_tdata_internal),
		.m_axis_resp_tlast(m_axis_resp_tlast_internal),
		.m_axis_resp_tready(m_axis_resp_tready_internal),
		
		// I2C port
		.SDA_o(SDA_o),
		.SDA_t(SDA_t),
		.SDA_i(SDA_i),
		.SCL_o(SCL_o),
		.SCL_t(SCL_t),
		.SCL_i(SCL_i),
		
		.period_1(period_1),
		.period_2(period_2),
		.period_3(period_3),
		.period_4(period_4),
		
		.period_start_1(period_start_1),
		.period_start_2(period_start_2),
		.period_start_3(period_start_3),
		
		.period_stop_1(period_stop_1),
		.period_stop_2(period_stop_2),
		.period_stop_3(period_stop_3),
		
		.state_o(fsm_state),
		.bit_state_o(fsm_bit_state)
	);
	
	generate if (SERIALIZE_INTERFACES == 1) begin
	    // serialize streams
	    axis_serialize#(
            .S_AXIS_TDATA_WIDTH(8)
        ) ser (
            .s_axis_tdata(m_axis_resp_tdata_internal),
            .s_axis_tvalid(m_axis_resp_tvalid_internal),
            .s_axis_tlast(m_axis_resp_tlast_internal),
            .s_axis_tready(m_axis_resp_tready_internal),
            
            .m_axis_tdata(m_axis_resp_tdata),
            .m_axis_tvalid(m_axis_resp_tvalid),
            .m_axis_tlast(m_axis_resp_tlast),
            .m_axis_tready(m_axis_resp_tready),
            
            .clk(clk),
            .aresetn(aresetn)
        );
        
        axis_deserialize#(
            .M_AXIS_TDATA_WIDTH(8)
        ) des (
            .s_axis_tdata(s_axis_req_tdata),
            .s_axis_tvalid(s_axis_req_tvalid),
            .s_axis_tlast(s_axis_req_tlast),
            .s_axis_tready(s_axis_req_tready),
            
            .m_axis_tdata(s_axis_req_tdata_internal),
            .m_axis_tvalid(s_axis_req_tvalid_internal),
            .m_axis_tlast(s_axis_req_tlast_internal),
            .m_axis_tready(s_axis_req_tready_internal),
            
            .clk(clk),
            .aresetn(aresetn)
        );
	end else begin
        // Directly connect core to ports
	    assign m_axis_resp_tdata =  m_axis_resp_tdata_internal;
        assign m_axis_resp_tvalid = m_axis_resp_tvalid_internal;
        assign m_axis_resp_tlast = m_axis_resp_tlast_internal;
        assign m_axis_resp_tready_internal = m_axis_resp_tready;
        
        assign s_axis_req_tdata_internal = s_axis_req_tdata;
        assign s_axis_req_tvalid_internal = s_axis_req_tvalid;
        assign s_axis_req_tlast_internal = s_axis_req_tlast;
        assign s_axis_req_tready = s_axis_req_tready_internal;
	end
	endgenerate
	
    generate if (SERIALIZE_INTERFACES == 1) begin
	    // SPI Interface
	    spi_slave_registers regs (
            .spi_ss(spi_ss),
            .spi_mosi(spi_mosi),
            .spi_miso(miso_o),
            .spi_miso_tri(miso_t),
            .spi_clk(spi_clk),
            .clk(clk),
            .aresetn(aresetn),
		
            .period_1(period_1),
            .period_2(period_2),
            .period_3(period_3),
            .period_4(period_4),
           
            .period_start_1(period_start_1),
            .period_start_2(period_start_2),
            .period_start_3(period_start_3),
           
            .period_stop_1(period_stop_1),
            .period_stop_2(period_stop_2),
            .period_stop_3(period_stop_3),
           
            .fsm_state(fsm_state),
            .fsm_bit_state(fsm_bit_state)
        );
	end else begin
        // AXI Interface
        AXIS_I2C_Master_v1_0_S_AXI regs (
            // Input Ports - Single Bit
            .S_AXI_ACLK    (clk),     
            .S_AXI_ARESETN (aresetn),  
            .S_AXI_ARVALID (S_AXI_ARVALID),  
            .S_AXI_AWVALID (S_AXI_AWVALID),  
            .S_AXI_BREADY  (S_AXI_BREADY),   
            .S_AXI_RREADY  (S_AXI_RREADY),   
            .S_AXI_WVALID  (S_AXI_WVALID),   
            // Input Ports - Busses
            .S_AXI_ARADDR  (S_AXI_ARADDR),
            .S_AXI_ARPROT  (S_AXI_ARPROT),
            .S_AXI_AWADDR  (S_AXI_AWADDR),
            .S_AXI_AWPROT  (S_AXI_AWPROT),
            .S_AXI_WDATA   (S_AXI_WDATA),
            .S_AXI_WSTRB   (S_AXI_WSTRB),
            // Output Ports - Single Bit
            .S_AXI_ARREADY (S_AXI_ARREADY),  
            .S_AXI_AWREADY (S_AXI_AWREADY),  
            .S_AXI_BVALID  (S_AXI_BVALID),   
            .S_AXI_RVALID  (S_AXI_RVALID),   
            .S_AXI_WREADY  (S_AXI_WREADY),   
            // Output Ports - Busses
            .S_AXI_BRESP   (S_AXI_BRESP),
            .S_AXI_RDATA   (S_AXI_RDATA),
            .S_AXI_RRESP   (S_AXI_RRESP),
		
            .period_1(period_1),
            .period_2(period_2),
            .period_3(period_3),
            .period_4(period_4),
           
            .period_start_1(period_start_1),
            .period_start_2(period_start_2),
            .period_start_3(period_start_3),
           
            .period_stop_1(period_stop_1),
            .period_stop_2(period_stop_2),
            .period_stop_3(period_stop_3),
           
            .fsm_state(fsm_state),
            .fsm_bit_state(fsm_bit_state)
        );
	end
	endgenerate
endmodule
