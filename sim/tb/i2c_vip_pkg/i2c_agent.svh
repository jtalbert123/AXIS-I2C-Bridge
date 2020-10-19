class i2c_agent extends uvm_agent;
    `uvm_component_utils(i2c_agent)

    i2c_monitor monitor;
    i2c_slv_driver slv_driver;
    i2c_agent_config cfg;

    uvm_sequencer#(i2c_item) sequencer;
    uvm_analysis_port#(i2c_item) ap;

    extern         function      new(string name = "i2c_agent", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
endclass

function i2c_agent::new(string name = "i2c_agent", uvm_component parent = null);
    super.new(name, parent);
    cfg = new();
endfunction : new

function void i2c_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = i2c_monitor::type_id::create("monitor", this);
    monitor.IF = cfg.vif.monitor;
    if (get_is_active() && cfg.driver_type == SLAVE) begin
        slv_driver = i2c_slv_driver::type_id::create("slave_driver", this);
        slv_driver.IF = cfg.vif.slave;
    end else if (get_is_active() && cfg.driver_type == MASTER) begin
        `uvm_fatal(get_name(), "MASTER mode not yet implemented.")
    end
    sequencer = new("input_sequencer", this);
endfunction : build_phase

function void i2c_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ap = monitor.ap;
    if (get_is_active() && cfg.driver_type == SLAVE) begin
        slv_driver.seq_item_port.connect(sequencer.seq_item_export);
    end else if (get_is_active() && cfg.driver_type == MASTER) begin
        `uvm_fatal(get_name(), "MASTER mode not yet implemented (how did we even get here).")
    end
endfunction : connect_phase