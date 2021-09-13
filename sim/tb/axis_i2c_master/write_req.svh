
`ifndef WRITE_REQ_SVH
`define WRITE_REQ_SVH

class write_req extends uvm_sequence#(byteq_item);
    `uvm_object_utils(write_req)

    rand bit [6:0] address;
    rand bit [7:0] data[$];
    rand int wr_len;

    constraint C_write_length {
        wr_len dist {
            0 := 0,
            1 := 1,
            [2:255] :/ 1
        };
        data.size() == wr_len;
    }

    extern function new(string name = "write_req");
    extern virtual task body();

endclass

function write_req::new(string name = "write_req");
    super.new(name);
endfunction : new

task write_req::body();
    byteq request_data;
    byteq_item request = new("axis_i2c_write_req");
    request_data.delete();
    request_data[0] = {address, 1'b0};
    foreach (data[i]) begin
        request_data[i + 1] = data[i];
    end
    request.set_data(request_data);
    // `uvm_info(get_name(), $sformatf("Sending stream packet: %0h, %0h", request[0], request[1]), UVM_MEDIUM)
    // `uvm_info(get_name(), $sformatf("Sending stream transaction: %s", req.convert2string()), UVM_MEDIUM) 
    
    wait_for_grant();
    send_request(request, 0);
    wait_for_item_done();
endtask : body

`endif //WRITE_REQ_SVH