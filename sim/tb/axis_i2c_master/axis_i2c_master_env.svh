import axis_master_0_pkg::*;
import axis_slave_0_pkg::*;

class axis_i2c_master_env extends uvm_env;
    `uvm_component_utils(axis_i2c_master_env)

    typedef axi4stream_uvm_transaction#(
        .SIGNAL_SET(axis_master_0_VIP_SIGNAL_SET),
        .DEST_WIDTH(axis_master_0_VIP_DEST_WIDTH),
        .DATA_WIDTH(axis_master_0_VIP_DATA_WIDTH),
        .ID_WIDTH(axis_master_0_VIP_ID_WIDTH),
        .USER_WIDTH(axis_master_0_VIP_USER_WIDTH),
        .USER_BITS_PER_BYTE(axis_master_0_VIP_USER_BITS_PER_BYTE)
    ) stream_packet_in;
    typedef axi4stream_uvm_transaction#(
        .SIGNAL_SET(axis_slave_0_VIP_SIGNAL_SET),
        .DEST_WIDTH(axis_slave_0_VIP_DEST_WIDTH),
        .DATA_WIDTH(axis_slave_0_VIP_DATA_WIDTH),
        .ID_WIDTH(axis_slave_0_VIP_ID_WIDTH),
        .USER_WIDTH(axis_slave_0_VIP_USER_WIDTH),
        .USER_BITS_PER_BYTE(axis_slave_0_VIP_USER_BITS_PER_BYTE)
    ) stream_packet_out;

    typedef axi4stream_uvm_mst_agent#(
        .SIGNAL_SET(axis_master_0_VIP_SIGNAL_SET),
        .DEST_WIDTH(axis_master_0_VIP_DEST_WIDTH),
        .DATA_WIDTH(axis_master_0_VIP_DATA_WIDTH),
        .ID_WIDTH(axis_master_0_VIP_ID_WIDTH),
        .USER_WIDTH(axis_master_0_VIP_USER_WIDTH),
        .USER_BITS_PER_BYTE(axis_master_0_VIP_USER_BITS_PER_BYTE),
        .HAS_ARESETN(axis_master_0_VIP_HAS_ARESETN)
    ) axis_uvm_master;
    typedef axi4stream_uvm_slv_agent#(
        .SIGNAL_SET(axis_slave_0_VIP_SIGNAL_SET),
        .DEST_WIDTH(axis_slave_0_VIP_DEST_WIDTH),
        .DATA_WIDTH(axis_slave_0_VIP_DATA_WIDTH),
        .ID_WIDTH(axis_slave_0_VIP_ID_WIDTH),
        .USER_WIDTH(axis_slave_0_VIP_USER_WIDTH),
        .USER_BITS_PER_BYTE(axis_slave_0_VIP_USER_BITS_PER_BYTE),
        .HAS_ARESETN(axis_slave_0_VIP_HAS_ARESETN)
    ) axis_uvm_slave;

    i2c_agent i2c_agent_h;
    axis_uvm_master axis_mst_agent_h;
	axis_uvm_slave  axis_slv_agent_h;

    typedef generic_listener#(stream_packet_in)  axis_in_listener;
    typedef generic_listener#(stream_packet_out) axis_out_listener;
    axis_in_listener  axis_output_listener;
    axis_out_listener axis_input_listener;

    extern         function      new(string name = "axis_i2c_master_env", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual task          run_phase(uvm_phase phase);
endclass

function axis_i2c_master_env::new(string name = "axis_i2c_master_env", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

function void axis_i2c_master_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    i2c_agent_h = i2c_agent::type_id::create("i2c_agent", this);
    i2c_agent_h.cfg.driver_type = SLAVE;
    if (!uvm_config_db#(virtual interface i2c_intf)::get(null, "*", "i2c_vif", i2c_agent_h.cfg.vif)) begin
        `uvm_fatal(get_name(), "Could not get i2c vif from db")
    end
    
    axis_mst_agent_h = axis_uvm_master::type_id::create("axis_mst_agent", this);
    if (!uvm_config_db#(axis_master_if)::get(null, "*", "axis_mst_vif", axis_mst_agent_h.vif)) begin
        `uvm_fatal(get_name(), "Could not get axis master vif from db")
    end
    
    axis_slv_agent_h = axis_uvm_slave::type_id::create("axis_slv_agent", this);
    if (!uvm_config_db#(axis_slave_if)::get(null, "*", "axis_slv_vif", axis_slv_agent_h.vif)) begin
        `uvm_fatal(get_name(), "Could not get axis slave vif from db")
    end

    // axis_input_listener  =  axis_in_listener::type_id()::create("axis_input_listener", this);
    // axis_output_listener = axis_out_listener::type_id()::create("axis_output_listener", this);

    axis_input_listener  =  new("axis_input_listener", this);
    axis_output_listener = new("axis_output_listener", this);

endfunction : build_phase

function void axis_i2c_master_env::connect_phase(uvm_phase phase);
    axis_mst_agent_h.ap.connect(axis_input_listener.analysis_export);
    axis_slv_agent_h.ap.connect(axis_output_listener.analysis_export);
endfunction : connect_phase

task axis_i2c_master_env::run_phase(uvm_phase phase);
    super.run_phase(phase);
endtask : run_phase