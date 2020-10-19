

class axi4stream_uvm_transaction#(
    parameter SIGNAL_SET = 8'b00010011,
    parameter DEST_WIDTH = 1,
    parameter DATA_WIDTH = 8,
    parameter ID_WIDTH = 1,
    parameter USER_WIDTH = 1,
    parameter USER_BITS_PER_BYTE = 0
) extends uvm_sequence_item;
    `uvm_object_param_utils(axi4stream_uvm_transaction#(
        .SIGNAL_SET(SIGNAL_SET),
        .DEST_WIDTH(DEST_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .USER_WIDTH(USER_WIDTH),
        .USER_BITS_PER_BYTE(USER_BITS_PER_BYTE)
    ))
    
    axi4stream_transaction beats[$];
    int length;
    extern         function        new(string name = "axi4stream_uvm_transaction");
    extern virtual function void   build(bit[7:0] bytes[]);
    extern virtual function axi4stream_transaction new_beat(bit [DATA_WIDTH-1:0] data);
    extern virtual function string convert2string();
endclass

function axi4stream_uvm_transaction::new(string name = "axi4stream_uvm_transaction");
    super.new(name);
endfunction : new

function axi4stream_transaction axi4stream_uvm_transaction::new_beat(bit [DATA_WIDTH-1:0] data);
    xil_axi4stream_data_byte current;
    axi4stream_transaction item = new(get_name(),
      SIGNAL_SET,
      DATA_WIDTH,
      USER_WIDTH,
      USER_BITS_PER_BYTE,
      ID_WIDTH,
      DEST_WIDTH);
    bit [7:0] beatdata[] = {<<8{data}};
    `uvm_info(get_name(), $sformatf("creating beat with data %p", beatdata), UVM_MEDIUM)
    item.set_data(beatdata);
    item.set_delay(0);
    return item;
endfunction : new_beat

function void axi4stream_uvm_transaction::build(bit[7:0] bytes[]);
    axi4stream_transaction item = new(get_name(),
      SIGNAL_SET,
      DATA_WIDTH,
      USER_WIDTH,
      USER_BITS_PER_BYTE,
      ID_WIDTH,
      DEST_WIDTH);
    bit [DATA_WIDTH-1:0] data[] = {>>DATA_WIDTH{bytes}};
    bit [DATA_WIDTH-1:0] beatdata;
    bit keep[];
    `uvm_info(get_name(), $sformatf("creating stream packet with data %p", data), UVM_MEDIUM)
    beats.delete();
    foreach (data[i]) begin
        axi4stream_transaction beat;
        beatdata = data[i];
        beat = new_beat(beatdata);
        if (i == ($size(data, 1)-1)) begin
            beat.set_last(1);
            keep = new[(DATA_WIDTH/8)];
            for (int k = 0; k < (DATA_WIDTH/8); k++) begin
                keep[k] = k < (i%(DATA_WIDTH/8)) ? 1'b1 : 1'b0;
            end
            // beat.set_keep(keep);
        end else begin
            beat.set_last(0);
            keep = new[(DATA_WIDTH/8)];
            for (int k = 0; k < (DATA_WIDTH/8); k++) begin
                keep[k] = 1'b1;
            end
            // beat.set_keep(keep);
        end
        beats.push_back(beat);
    end
    length = $size(bytes);
endfunction : build

function string axi4stream_uvm_transaction::convert2string();
    string s = "AXI-S Packet:\n";
    logic [7:0] data[DATA_WIDTH/8];
    bit [7:0] dataq[$];
    foreach (beats[i]) begin
        beats[i].get_data(data);
        foreach (data[i]) begin
            dataq.push_back(data[i]);
        end
    end
    foreach (dataq[i]) begin
        if (((i % 16) != 15) || (i == beats.size()-1)) begin
            s = {s, $sformatf("%0h ", dataq[i])};
        end else if (((i % 16) == 15) && (i != beats.size()-1)) begin
            s = {s, $sformatf("%0h\n", dataq[i])};
        end else if (((i % 16) == 15) && (i == beats.size()-1)) begin
            s = {s, $sformatf("%0h", dataq[i])};
        end
    end
    return s;
endfunction