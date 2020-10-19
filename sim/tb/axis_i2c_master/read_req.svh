
`ifndef READ_REQ_SVH
`define READ_REQ_SVH

class read_req#(type T = axi4stream_uvm_transaction#()) extends uvm_sequence#(T);
    `uvm_object_param_utils(read_req#(.T(T)))

    rand bit [6:0] address;
    rand int rd_len;

    constraint C_read_length {
        rd_len dist {
            0 := 1,
            1 := 1,
            [2:255] :/ 1
        };
    }

    extern function new(string name = "read_req");
    extern virtual task body();

endclass

function read_req::new(string name = "read_req");
    super.new(name);
endfunction : new

task read_req::body();
    bit[7:0] request[2];
    T req = new("read_req");
    wait_for_grant();
    request[0] = {address, 1'b1};
    request[1] = rd_len;
    req.build(request);
    `uvm_info(get_name(), $sformatf("Sending stream packet: %0h, %0h", request[0], request[1]), UVM_MEDIUM)
    `uvm_info(get_name(), $sformatf("Sending stream transaction: %s", req.convert2string()), UVM_MEDIUM) 
    send_request(req, 0);
    wait_for_item_done();
endtask : body

`endif //READ_REQ_SVH