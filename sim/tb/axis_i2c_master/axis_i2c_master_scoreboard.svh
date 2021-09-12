`ifndef axis_i2c_master_scoreboard
`define axis_i2c_master_scoreboard

`uvm_analysis_imp_decl(_axis_req)
`uvm_analysis_imp_decl(_axis_resp)
`uvm_analysis_imp_decl(_i2c)

class axis_i2c_master_scoreboard#(
    parameter SIGNAL_SET = 8'b00010011,
    parameter DEST_WIDTH = 1,
    parameter DATA_WIDTH = 8,
    parameter ID_WIDTH = 1,
    parameter USER_WIDTH = 1,
    parameter USER_BITS_PER_BYTE = 0
) extends uvm_scoreboard;
    `uvm_component_param_utils(axis_i2c_master_scoreboard#(
        .SIGNAL_SET(SIGNAL_SET),
        .DEST_WIDTH(DEST_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .USER_WIDTH(USER_WIDTH),
        .USER_BITS_PER_BYTE(USER_BITS_PER_BYTE)
    ))

typedef axi4stream_uvm_transaction#(
    .SIGNAL_SET(SIGNAL_SET),
    .DEST_WIDTH(DEST_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .ID_WIDTH(ID_WIDTH),
    .USER_WIDTH(USER_WIDTH),
    .USER_BITS_PER_BYTE(USER_BITS_PER_BYTE)
) stream_packet_in;
typedef axi4stream_uvm_transaction#(
    .SIGNAL_SET(SIGNAL_SET),
    .DEST_WIDTH(DEST_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .ID_WIDTH(ID_WIDTH),
    .USER_WIDTH(USER_WIDTH),
    .USER_BITS_PER_BYTE(USER_BITS_PER_BYTE)
) stream_packet_out;

typedef axis_i2c_master_scoreboard#(
    .SIGNAL_SET(SIGNAL_SET),
    .DEST_WIDTH(DEST_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .ID_WIDTH(ID_WIDTH),
    .USER_WIDTH(USER_WIDTH),
    .USER_BITS_PER_BYTE(USER_BITS_PER_BYTE)
) this_t;

stream_packet_in req_q[$];
stream_packet_in i2c_q[$];

stream_packet_in req_resp_q[$];
stream_packet_in i2c_resp_q[$];
stream_packet_in resp_q[$];

uvm_analysis_imp_axis_req#(stream_packet_in, this_t) req_export;
uvm_analysis_imp_axis_resp#(stream_packet_out, this_t) resp_export;
uvm_analysis_imp_i2c#(i2c_item, this_t) i2c_export;

extern function new(string name = "axis_i2c_master_scoreboard", uvm_component parent = null);
extern virtual function void build_phase(uvm_phase phase);  

extern virtual function void check_request();
extern virtual function void check_response();

extern virtual function void write_axis_req(stream_packet_in t);
extern virtual function void write_axis_resp(stream_packet_in t);
extern virtual function void write_i2c(i2c_item  t);

endclass

function axis_i2c_master_scoreboard::new(string name = "axis_i2c_master_scoreboard", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

function void axis_i2c_master_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    req_export = new("req_export", this);
    resp_export = new("resp_export", this);
    i2c_export = new("i2c_export", this);
endfunction : build_phase

function void axis_i2c_master_scoreboard::write_axis_req(stream_packet_in t);
    req_q.push_back(t);
    `uvm_info("ap-debug", $sformatf("scoreboard got req item, there are %0d in the queue", req_q.size()), UVM_MEDIUM)
    `uvm_info("ap-debug", t.convert2string(), UVM_MEDIUM)
    check_request();
endfunction : write_axis_req

function void axis_i2c_master_scoreboard::write_i2c(i2c_item t);
    i2c_q.push_back(t);
    `uvm_info("ap-debug", $sformatf("scoreboard got i2c item, there are %0d in the queue", i2c_q.size()), UVM_MEDIUM)
    `uvm_info("ap-debug", t.convert2string(), UVM_MEDIUM)
    check_request();
endfunction : write_i2c

function void axis_i2c_master_scoreboard::write_axis_resp(stream_packet_in t);
    resp_q.push_back(t);
    `uvm_info("ap-debug", $sformatf("scoreboard got resp item, there are %0d in the queue", resp_q.size()), UVM_MEDIUM)
    `uvm_info("ap-debug", t.convert2string(), UVM_MEDIUM)
    check_response();
endfunction : write_axis_resp

function void axis_i2c_master_scoreboard::check_request();
    while (req_q.size() >= 1 && i2c_q.size() >= 1) begin
        stream_packet_in req;
        bit[7:0] req_bytes[$];
        i2c_item i2c;
        bit[7:0] i2c_data[];
        int expected_data_size;

        req = req_q.pop_front();
        i2c = i2c_q.pop_front();
        req.get_bytes(req_bytes);
        i2c.get_data(i2c_data);

        if (req_bytes[0][0] == 1'b1) begin
            expected_data_size = req_bytes[1];
        end else begin
            expected_data_size = req_bytes.size()-1;
        end

        if (req_bytes[0][7:1] != i2c.get_address()) begin
            `uvm_error(get_name(), $sformatf("Request resulted in I2C transaction with incorrect address. Got $0h, expected %0h", i2c.get_address(), req_bytes[0][7:1]))
        end else if (req_bytes[0][0] != i2c.get_tr_type()) begin
            `uvm_error(get_name(), $sformatf("Request resulted in I2C transaction with incorrect type. Got $0b, expected %0b", i2c.get_tr_type(), req_bytes[0][0]))
        end else if (expected_data_size < i2c.get_data_size()) begin
            `uvm_error(get_name(), $sformatf("Request resulted in I2C transaction with bad length. Got %0d, expected <= %0d", i2c.get_data_size(), req_bytes[1]))
        end else if ((expected_data_size > i2c.get_data_size()) &&
                     (i2c.get_tr_type() == 1'b1)) begin
            `uvm_error(get_name(), $sformatf("Read request terminated early by master, got  %0d, expected %0d", i2c.get_data_size(), req_bytes[1]))
        end else if ((expected_data_size > i2c.get_data_size()) &&
                     (i2c.get_tr_type() == 1'b0) &&
                     (i2c.get_final_ack() == 1'b1)) begin
            `uvm_error(get_name(), $sformatf("Write request terminated early by master, got  %0d, expected %0d", i2c.get_data_size(), req_bytes[1]))
        end else if ((i2c.get_tr_type() == 1'b0)) begin
            req_bytes.pop_front();
            foreach (req_bytes[i]) begin
                if (req_bytes[i] != i2c_data[i]) begin
                    `uvm_error(get_name(), $sformatf("Master wrote wrong data, got  %02h, expected %02h", i2c_data[i], req_bytes[i]))
                    // break;
                end
            end
        end
        i2c_resp_q.push_back(i2c);
        req_resp_q.push_back(req);
        `uvm_info("ap-debug", $sformatf("scoreboard saved i2c item, there are %0d in the queue", i2c_resp_q.size()), UVM_MEDIUM)
        `uvm_info("ap-debug", i2c.convert2string(), UVM_MEDIUM)
        `uvm_info("ap-debug", $sformatf("scoreboard saved req item, there are %0d in the queue", req_resp_q.size()), UVM_MEDIUM)
        `uvm_info("ap-debug", req.convert2string(), UVM_MEDIUM)
        check_response();
    end
endfunction : check_request

function void axis_i2c_master_scoreboard::check_response();
    while (resp_q.size() >= 1 && i2c_resp_q.size() >= 1 && i2c_resp_q.size() >= 1) begin
        i2c_item i2c;
        bit[7:0] i2c_data[];

        stream_packet_out resp;
        bit[7:0] resp_bytes[$];
        stream_packet_out req;
        bit[7:0] req_bytes[$];

        bit slave_terminated_early;

        req = req_resp_q.pop_front();
        i2c = i2c_resp_q.pop_front();
        resp = resp_q.pop_front();
        
        resp.get_bytes(resp_bytes);
        req.get_bytes(req_bytes);
        i2c.get_data(i2c_data);

        slave_terminated_early = (req_bytes[1] > i2c.get_data_size()) &&
                                 (i2c.get_tr_type() == 1'b0) &&
                                 (i2c.get_final_ack() == 1'b0);
        
        if (i2c.get_tr_type() == 0) begin
            if ((slave_terminated_early == 1'b1) && (resp_bytes[0] == 8'd0)) begin
                `uvm_error(get_name(), "Master failed to report write error to user logic.")
            end else if ((slave_terminated_early == 1'b1) && (resp_bytes[1] != i2c.get_data_size())) begin
                `uvm_error(get_name(), $sformatf("Master reported incorrect write size, got %0d, expected %0d.", resp_bytes[1], i2c.get_data_size()))
            end
        end else if ((i2c.get_tr_type() == 1'b1)) begin
            foreach (i2c_data[i]) begin
                if (i2c_data[i] != resp_bytes[i+1]) begin
                    `uvm_error(get_name(), $sformatf("Master reported wrong read data at axis byte %0d, got  %02h, expected %02h", i, i2c_data[i], resp_bytes[i+1]))
                    // break;
                end
            end
            if (resp_bytes.size() - 1 != i2c_data.size()) begin
                `uvm_error(get_name(), $sformatf("Master reported wrong number of bytes read, got  %02h, expected %02h", i2c_data.size(), resp_bytes.size() - 1))
            end
        end
    end
endfunction : check_response

`endif //axis_i2c_master_scoreboard