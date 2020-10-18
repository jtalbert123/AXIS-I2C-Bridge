

`ifndef BASIC_TEST_SVH
`define BASIC_TEST_SVH

class basic_test extends uvm_test;
    `uvm_component_utils(basic_test)

    axis_i2c_master_env env;

    extern         function      new(string name = "basic_test", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual task          run_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);

endclass

function      basic_test::new(string name = "basic_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

function void basic_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_name(), "build_phase", UVM_LOW)
    env = axis_i2c_master_env::type_id::create("axis_i2c_env", this);
endfunction : build_phase

function void basic_test::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_name(), "connect_phase", UVM_LOW)
    
endfunction : connect_phase

task basic_test::run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_name(), "run_phase", UVM_LOW)
    phase.raise_objection(this);
    #20us;
    phase.drop_objection(this);
endtask : run_phase

function void basic_test::report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_name(), "report_phase", UVM_LOW)
    
endfunction : report_phase

    
`endif //BASIC_TEST_SVH