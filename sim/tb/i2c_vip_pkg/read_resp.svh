
`ifndef READ_RESP_SVH
`define READ_RESP_SVH

class read_resp extends uvm_sequence#(i2c_item);
    `uvm_object_utils(read_resp)

    bit [6:0] address;
    int length;
    rand bit [7:0] data[$];
    
    constraint C_read_length {
        data.size() == length;
    }

    extern function new(string name = "read_resp");
    extern virtual task body();

endclass

function read_resp::new(string name = "read_resp");
    super.new(name);
endfunction : new

task read_resp::body();
    i2c_item req = new("read_resp");
    wait_for_grant();
    req.set_address(address);
    req.set_tr_type(1'b1);
    req.set_data(data);
    send_request(req, 0);
    wait_for_item_done();
endtask : body

`endif //READ_RESP_SVH