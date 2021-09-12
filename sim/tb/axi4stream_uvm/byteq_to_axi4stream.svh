`ifndef BYTEQ_TO_AXI4STREAM_SVH
`define BYTEQ_TO_AXI4STREAM_SVH

class byteq_to_axi4stream#(type T) extends uvm_sequence#(T);
    `uvm_object_param_utils(byteq_to_axi4stream#(.T(T)));

    uvm_sequencer#(byteq_item) input_sequencer;

    extern function new(string name = "byteq_to_axi4stream");
    extern virtual task body();

endclass

    function byteq_to_axi4stream::new(string name = "byteq_to_axi4stream");
        super.new(name);
    endfunction

    task byteq_to_axi4stream::body();
        T streamItem;
        byteq_item inputItem;
        
        forever begin
            input_sequencer.get_next_item(inputItem);
            streamItem = new(inputItem.get_name());
            streamItem.build(inputItem.get_data());
            
            wait_for_grant();
            send_request(streamItem, 0);
            wait_for_item_done();
            input_sequencer.item_done(inputItem);
        end
    endtask

`endif //BYTEQ_TO_AXI4STREAM_SVH