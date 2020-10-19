class axi4stream_uvm_slv_agent#(
    SIGNAL_SET = 8'b00010011,
    DEST_WIDTH = 1,
    DATA_WIDTH = 8,
    ID_WIDTH = 1,
    USER_WIDTH = 1,
    USER_BITS_PER_BYTE = 0,
    HAS_ARESETN = 1
) extends uvm_agent;
    `uvm_component_utils(axi4stream_uvm_slv_agent#(
        .SIGNAL_SET(SIGNAL_SET),
        .DEST_WIDTH(DEST_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .USER_WIDTH(USER_WIDTH),
        .USER_BITS_PER_BYTE(USER_BITS_PER_BYTE),
        .HAS_ARESETN(HAS_ARESETN)))

    typedef axi4stream_uvm_transaction#(
        SIGNAL_SET,
        DEST_WIDTH,
        DATA_WIDTH,
        ID_WIDTH,
        USER_WIDTH,
        USER_BITS_PER_BYTE
    ) transaction;
    typedef axi4stream_slv_agent #(
        SIGNAL_SET,
        DEST_WIDTH,
        DATA_WIDTH,
        ID_WIDTH,
        USER_WIDTH,
        USER_BITS_PER_BYTE,
        HAS_ARESETN
    ) axis_slave_agent;

    uvm_sequencer#(transaction) sequencer;
    uvm_analysis_port#(transaction) ap;
    axis_slave_agent inner_agent;

    typedef virtual interface axi4stream_vip_if#(
        SIGNAL_SET,
        DEST_WIDTH,
        DATA_WIDTH,
        ID_WIDTH,
        USER_WIDTH,
        USER_BITS_PER_BYTE,
        HAS_ARESETN
    ) vif_t;
    vif_t vif;

    extern function new(string name = "axi4stream_uvm_slv_agent", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task          run_phase(uvm_phase phase);
    extern virtual task          monitor_adapter();
    extern virtual task          driver_adapter();
endclass

function axi4stream_uvm_slv_agent::new(string name = "axi4stream_uvm_slv_agent", uvm_component parent = null);
    super.new(name, parent);
endfunction : new;

function void axi4stream_uvm_slv_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    inner_agent = new("axi4steam_slv_agent", vif);
    sequencer = new("input_sequencer", this);
    ap = new("monitor_ap", this);
endfunction : build_phase;

task axi4stream_uvm_slv_agent::run_phase(uvm_phase phase);
    super.run_phase(phase);
    inner_agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);
    inner_agent.start_slave();
    fork
        monitor_adapter();
        driver_adapter();
    join
endtask : run_phase;

task axi4stream_uvm_slv_agent::driver_adapter();
    // nothing really to do here for a slave?
endtask : driver_adapter

task axi4stream_uvm_slv_agent::monitor_adapter();
    axi4stream_transaction beat;
    transaction tr;
    bit [(DATA_WIDTH/8)-1:0] keep;
    bit keepd[];
    tr = new("axi4stream_uvm_slv_txn");
    tr.beats.delete();
    tr.length = 0;
    forever begin
        inner_agent.monitor.item_collected_port.get(beat);
        tr.beats.push_back(beat);
        if (beat.get_last()) begin
            beat.get_keep(keepd);
            keep = {>>{keepd}};
            tr.length += $clog2(keep);
            ap.write(tr);
            tr = new("axi4stream_uvm_slv_txn");
        end else begin
            tr.length += DATA_WIDTH/8;
        end
    end
endtask : monitor_adapter;
