

`ifndef BASIC_TEST_SVH
`define BASIC_TEST_SVH

class basic_test extends uvm_test;
    `uvm_component_utils(basic_test)

    axis_i2c_master_env env;
    typedef axi4stream_uvm_transaction#(
        .SIGNAL_SET(axis_master_0_VIP_SIGNAL_SET),
        .DEST_WIDTH(axis_master_0_VIP_DEST_WIDTH),
        .DATA_WIDTH(axis_master_0_VIP_DATA_WIDTH),
        .ID_WIDTH(axis_master_0_VIP_ID_WIDTH),
        .USER_WIDTH(axis_master_0_VIP_USER_WIDTH),
        .USER_BITS_PER_BYTE(axis_master_0_VIP_USER_BITS_PER_BYTE)
    ) master_txn;
    typedef read_req#(master_txn) test_seq_t;
    typedef read_resp resp_seq_t;

    test_seq_t test_seq;
    resp_seq_t resp_seq;

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
    test_seq = test_seq_t::type_id::create("axis_i2c_read_req");
    resp_seq = resp_seq_t::type_id::create("axis_i2c_read_resp");
endfunction : build_phase

function void basic_test::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_name(), "connect_phase", UVM_LOW)
    
endfunction : connect_phase

task basic_test::run_phase(uvm_phase phase);
    master_txn tr;
    super.run_phase(phase);
    `uvm_info(get_name(), "run_phase", UVM_LOW)
    phase.raise_objection(this);
    test_seq.randomize();
    resp_seq.length = test_seq.rd_len;
    resp_seq.address = test_seq.address;
    resp_seq.randomize();
    fork
        test_seq.start(env.axis_mst_agent_h.sequencer);
        resp_seq.start(env.i2c_agent_h.sequencer);
    join
    #200us;
    phase.drop_objection(this);
endtask : run_phase

function void basic_test::report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_name(), "report_phase", UVM_LOW)
    
endfunction : report_phase

    
`endif //BASIC_TEST_SVH