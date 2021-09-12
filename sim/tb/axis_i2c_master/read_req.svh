
`ifndef READ_REQ_SVH
`define READ_REQ_SVH

class read_req extends uvm_sequence#(byteq_item);
    `uvm_object_utils(read_req)

    rand bit [6:0] address;
    rand int rd_len;

    constraint C_read_length {
        rd_len dist {
            0 := 0,
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
    byteq request_data;
    byteq_item request = new("axis_i2c_req_req");
    request_data.delete();
    request_data[0] = {address, 1'b1};
    request_data[1] = rd_len;
    request.set_data(request_data);
    // `uvm_info(get_name(), $sformatf("Sending stream packet: %0h, %0h", request[0], request[1]), UVM_MEDIUM)
    // `uvm_info(get_name(), $sformatf("Sending stream transaction: %s", req.convert2string()), UVM_MEDIUM) 
    
    wait_for_grant();
    send_request(request, 0);
    wait_for_item_done();
endtask : body

`endif //READ_REQ_SVH