
import tb_pkg::*;
import i2c_vip_pkg::*;
import axi4stream_vip_pkg::*;
import uvm_pkg::*;
import axis_i2c_master_pkg::*;

module tb_top(

    );
    
    logic         clk;
    logic         reset;
    axistream_intf#(
        .DATA_WIDTH(8)
    ) input_axis (clk, ~reset);
    axistream_intf#(
        .DATA_WIDTH(8)
    ) output_axis (clk, ~reset);
    axilite_intf#(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32)
    ) axilite_if (clk, ~reset);

    // Without this, the spi VIP code fails to compile
    // because vivado doesn't think we need the intf compiled
    spi_intf spi_iface();
    dummy u_dummy();
    assign spi_iface.sclk = clk;

    i2c_intf i2c_if();
    i2c_bus i2c_bus_impl(
        .bus(i2c_if)
    );
	wire SDA, SCL;
	assign SDA = i2c_if.sda;
	assign SCL = i2c_if.scl;

/*  initial begin // init i2c slave
        $deposit(i2c_if.sda_o_slv, 1'b1);
        $deposit(i2c_if.scl_o_slv, 1'b1);
    end */

    initial begin
        reset = 1;
        #170ns;
        reset = 0;
    end;

    initial forever begin
        clk = 0;
        #5ns;
        clk = 1;
        #5ns;
    end;

    axis_master_0 axis_master(
        .aclk         (input_axis.aclk    ),      // input wire aclk
        .aresetn      (input_axis.aresetn ),      // input wire aresetn
        .m_axis_tvalid(input_axis.tvalid  ),      // output wire [0 : 0] m_axis_tvalid
        .m_axis_tready(input_axis.tready  ),      // input wire [0 : 0] m_axis_tready
        .m_axis_tdata (input_axis.tdata   ),      // output wire [7 : 0] m_axis_tdata
        .m_axis_tlast (input_axis.tlast   )       // output wire [0 : 0] m_axis_tlast
    );

    axis_slave_0 axis_slave(
        .aclk         (output_axis.aclk    ),     // input wire aclk
        .aresetn      (output_axis.aresetn ),     // input wire aresetn
        .s_axis_tvalid(output_axis.tvalid  ),     // output wire [0 : 0] m_axis_tvalid
        .s_axis_tready(output_axis.tready  ),     // input wire [0 : 0] m_axis_tready
        .s_axis_tdata (output_axis.tdata   ),     // output wire [7 : 0] m_axis_tdata
        .s_axis_tlast (output_axis.tlast   )      // output wire [0 : 0] m_axis_tlast
    );

    AXIS_I2C_Master_0 axis_i2c_master (
        .clk           (clk),                     // input wire clk
        .aresetn       (~reset),                  // input wire aresetn

        .SDA               (SDA),                 // inout wire SDA
        .SCL               (SCL),                 // inout wire SCL
        .s_axis_req_tdata  (input_axis.tdata),    // input wire [7 : 0] s_axis_req_tdata
        .s_axis_req_tvalid (input_axis.tvalid),   // input wire s_axis_req_tvalid
        .s_axis_req_tlast  (input_axis.tlast),    // input wire s_axis_req_tlast
        .s_axis_req_tready (input_axis.tready),   // output wire s_axis_req_tready

        .m_axis_resp_tdata (output_axis.tdata),   // output wire [7 : 0] m_axis_resp_tdata
        .m_axis_resp_tvalid(output_axis.tvalid),  // output wire m_axis_resp_tvalid
        .m_axis_resp_tlast (output_axis.tlast),   // output wire m_axis_resp_tlast
        .m_axis_resp_tready(output_axis.tready),  // input wire m_axis_resp_tready

        .S_AXI_AWADDR  (axilite_if.awaddr[6:0]),  // input wire [6 : 0] S_AXI_AWADDR
        .S_AXI_AWPROT  (axilite_if.awprot),       // input wire [2 : 0] S_AXI_AWPROT
        .S_AXI_AWVALID (axilite_if.awvalid),      // input wire S_AXI_AWVALID
        .S_AXI_AWREADY (axilite_if.awready),      // output wire S_AXI_AWREADY
        .S_AXI_WDATA   (axilite_if.wdata),        // input wire [31 : 0] S_AXI_WDATA
        .S_AXI_WSTRB   (axilite_if.wstrb),        // input wire [3 : 0] S_AXI_WSTRB
        .S_AXI_WVALID  (axilite_if.wvalid),       // input wire S_AXI_WVALID
        .S_AXI_WREADY  (axilite_if.wready),       // output wire S_AXI_WREADY
        .S_AXI_BRESP   (axilite_if.bresp),        // output wire [1 : 0] S_AXI_BRESP
        .S_AXI_BVALID  (axilite_if.bvalid),       // output wire S_AXI_BVALID
        .S_AXI_BREADY  (axilite_if.bready),       // input wire S_AXI_BREADY
        .S_AXI_ARADDR  (axilite_if.araddr[6:0]),  // input wire [6 : 0] S_AXI_ARADDR
        .S_AXI_ARPROT  (axilite_if.arprot),       // input wire [2 : 0] S_AXI_ARPROT
        .S_AXI_ARVALID (axilite_if.arvalid),      // input wire S_AXI_ARVALID
        .S_AXI_ARREADY (axilite_if.arready),      // output wire S_AXI_ARREADY
        .S_AXI_RDATA   (axilite_if.rdata),        // output wire [31 : 0] S_AXI_RDATA
        .S_AXI_RRESP   (axilite_if.rresp),        // output wire [1 : 0] S_AXI_RRESP
        .S_AXI_RVALID  (axilite_if.rvalid),       // output wire S_AXI_RVALID
        .S_AXI_RREADY  (axilite_if.rready),       // input wire S_AXI_RREADY
        .SDA_o_o       (i2c_if.sda_o_mst),        // output wire SDA_o_o
        .SDA_o_t       (       ),                 // output wire SDA_o_t
        .SCL_o_o       (i2c_if.scl_o_mst),        // output wire SCL_o_o
        .SCL_o_t       (       ),                 // output wire SCL_o_t
        .state_o       (),                        // output wire [4 : 0] state_o
        .bit_state_o   ()                         // output wire [1 : 0] bit_state_o
    );

    axi4_master_0 axi4_master (
        .aclk        ( clk),                      // input wire aclk
        .aresetn     (~reset),                    // input wire aresetn

        .m_axi_awaddr ( axilite_if.awaddr  ),     // output wire [31 : 0] m_axi_awaddr
        .m_axi_awprot ( axilite_if.awprot  ),     // output wire [2 : 0] m_axi_awprot
        .m_axi_awvalid( axilite_if.awvalid ),     // output wire m_axi_awvalid
        .m_axi_awready( axilite_if.awready ),     // input wire m_axi_awready
        .m_axi_wdata  ( axilite_if.wdata   ),     // output wire [31 : 0] m_axi_wdata
        .m_axi_wstrb  ( axilite_if.wstrb   ),     // output wire [3 : 0] m_axi_wstrb
        .m_axi_wvalid ( axilite_if.wvalid  ),     // output wire m_axi_wvalid
        .m_axi_wready ( axilite_if.wready  ),     // input wire m_axi_wready
        .m_axi_bresp  ( axilite_if.bresp   ),     // input wire [1 : 0] m_axi_bresp
        .m_axi_bvalid ( axilite_if.bvalid  ),     // input wire m_axi_bvalid
        .m_axi_bready ( axilite_if.bready  ),     // output wire m_axi_bready
        .m_axi_araddr ( axilite_if.araddr  ),     // output wire [31 : 0] m_axi_araddr
        .m_axi_arprot ( axilite_if.arprot  ),     // output wire [2 : 0] m_axi_arprot
        .m_axi_arvalid( axilite_if.arvalid ),     // output wire m_axi_arvalid
        .m_axi_arready( axilite_if.arready ),     // input wire m_axi_arready
        .m_axi_rdata  ( axilite_if.rdata   ),     // input wire [31 : 0] m_axi_rdata
        .m_axi_rresp  ( axilite_if.rresp   ),     // input wire [1 : 0] m_axi_rresp
        .m_axi_rvalid ( axilite_if.rvalid  ),     // input wire m_axi_rvalid
        .m_axi_rready ( axilite_if.rready  )      // output wire m_axi_rready
    );

    logic start, stop;

    always @(posedge i2c_if.sda or negedge i2c_if.scl) begin
        stop = 0;
        if (i2c_if.scl) begin
            stop = 1;
        end else begin
            stop = 0;
        end
    end

    always @(negedge i2c_if.sda or negedge i2c_if.scl) begin
        start = 0;
        if (i2c_if.scl) begin
            start = 1;
        end else begin
            start = 0;
        end
    end

    initial begin
        uvm_config_db#(axis_master_if)::set(null, "*", "axis_mst_vif", axis_master.inst.IF);
        uvm_config_db#(axis_slave_if)::set(null, "*", "axis_slv_vif", axis_slave.inst.IF);
        uvm_config_db#(virtual interface i2c_intf)::set(null, "*", "i2c_vif", i2c_if);

        run_test("basic_test");
    end
endmodule
