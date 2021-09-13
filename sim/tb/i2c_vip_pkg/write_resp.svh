
`ifndef WRITE_RESP_SVH
`define WRITE_RESP_SVH

class write_resp extends uvm_sequence#(i2c_item);
    `uvm_object_utils(write_resp)

    bit [6:0] address;
    int length;

    extern function new(string name = "write_resp_seq");
    extern virtual task body();

endclass

function write_resp::new(string name = "write_resp_seq");
    super.new(name);
endfunction : new

task write_resp::body();
    byteq data;
    i2c_item resp = new("write_resp");
    wait_for_grant();
    resp.set_address(address);
    data.delete();
    repeat (length) begin
        data.push_back(8'hFF);
    end
    resp.set_final_ack(1'b1);
    resp.set_data(data);
    resp.set_tr_type(1'b0);
    send_request(resp, 0);
    wait_for_item_done();
endtask : body

`endif //WRITE_RESP_SVH