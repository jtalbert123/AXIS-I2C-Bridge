

`ifndef BASIC_TEST_SVH
`define BASIC_TEST_SVH

class basic_test extends uvm_test;
    `uvm_component_utils(basic_test)

    axis_i2c_master_env env;
    typedef read_req read_req;
    typedef read_resp read_resp;

    read_req read_seq;
    read_resp rresp_seq;

    write_req write_seq;
    write_resp wresp_seq;

    extern         function      new(string name = "basic_test", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual task          run_phase(uvm_phase phase);
    extern virtual task          do_read();
    extern virtual task          do_write();
    extern virtual function void report_phase(uvm_phase phase);

endclass

function      basic_test::new(string name = "basic_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

function void basic_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_name(), "build_phase", UVM_LOW)
    env = axis_i2c_master_env::type_id::create("axis_i2c_env", this);
    read_seq = read_req::type_id::create("axis_i2c_read_req");
    rresp_seq = read_resp::type_id::create("axis_i2c_read_resp");
    write_seq = write_req::type_id::create("axis_i2c_write_req");
    wresp_seq = write_resp::type_id::create("axis_i2c_write_resp");
endfunction : build_phase

function void basic_test::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_name(), "connect_phase", UVM_LOW)
    uvm_top.print_topology();
endfunction : connect_phase

task basic_test::do_read();
    `uvm_info(get_name(), "Sending 1 read", UVM_MEDIUM)
    read_seq.randomize();
    rresp_seq.length = read_seq.rd_len;
    rresp_seq.address = read_seq.address;
    rresp_seq.randomize();
    fork
        read_seq.start(env.input_sequencer);
        rresp_seq.start(env.i2c_agent_h.sequencer);
    join
endtask : do_read

task basic_test::do_write();
    `uvm_info(get_name(), "Sending 1 write", UVM_MEDIUM)
    write_seq.randomize();
    `uvm_info("stim-debug", $sformatf("About to send write to %02h, length %0d", {write_seq.address, 1'b0}, write_seq.wr_len), UVM_MEDIUM)
    wresp_seq.length = write_seq.wr_len;
    wresp_seq.address = write_seq.address;
    wresp_seq.randomize();
    fork
        write_seq.start(env.input_sequencer);
        wresp_seq.start(env.i2c_agent_h.sequencer);
    join
endtask : do_write

task basic_test::run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_name(), "run_phase", UVM_LOW)
    phase.raise_objection(this);
    fork
        begin
            // repeat (10)
            //     do_read();
            // repeat (10)
            //     do_write();
            repeat (100) begin
                if ($urandom % 2) begin
                    do_write();
                end else begin
                    do_read();
                end
            end 
        end
        begin
            #1s; //timeout
            `uvm_info(get_name(), "TIMEOUT", UVM_NONE)
        end
    join_any
    #200us;
    `uvm_info(get_name(), "Droppping objection", UVM_MEDIUM)    
    phase.drop_objection(this);
endtask : run_phase

function void basic_test::report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_name(), "report_phase", UVM_LOW)
    
endfunction : report_phase

    
`endif //BASIC_TEST_SVH