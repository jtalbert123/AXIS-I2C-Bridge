`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: James Talbert
// 
// Create Date: 02/22/2020 10:27:13 PM
// Design Name: AXIS I2C Master
// Module Name: i2c_monitor
// Project Name: 
// Target Devices: 
// Tool Versions: built with Vivado 2019.2 and SystemVerilog
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

class i2c_slv_driver extends uvm_driver#(i2c_item);
    `uvm_component_utils(i2c_slv_driver)

    virtual interface i2c_intf.slave IF;
    i2c_item next_tr;
    event item_done;
    
    function new(input string name = "i2c_slv_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual task get_items(uvm_phase phase);
        i2c_item current_tr;
        forever begin
            seq_item_port.get_next_item(current_tr);
            `uvm_info(get_name(), "got response item", UVM_MEDIUM)
            phase.raise_objection(this);
            next_tr = current_tr;
            wait (item_done.triggered);
            seq_item_port.item_done(current_tr);
            phase.drop_objection(this);
        end
    endtask
    
    virtual task run_phase(uvm_phase phase);
        bit [7:0] addr;
        bit [7:0] data[];
        bit [7:0] dataq[$];
        enum   {IDLE,
                ADDR,
                POST_ADDR,
                ADDRACK,
                DATA,
                ACK,
                PRE_STOP,
                STOP} state;
        bit [3:0] bit_index;
        bit oldscl, oldsda;
        fork
            get_items(phase);
        join_none
        oldscl = 0;
        oldsda = 0;
        state = IDLE;
        bit_index = 0;
        this.IF.scl_o_slv = 1;
        this.IF.scl_o_slv = 1;
        forever @(this.IF.scl,this.IF.sda) begin
            case (state)
                IDLE: begin
                    this.IF.sda_o_slv = 1;
                    if (oldsda && !this.IF.sda) begin
                        state = ADDR;
                        bit_index = 7;
                        `uvm_info(get_name(), "moving to ADDR", UVM_MEDIUM)
                    end
                end
                ADDR: begin
                    if (this.next_tr == null) begin
                        state = IDLE;
                    end else if (!oldscl && this.IF.scl) begin
                        this.next_tr.get_data(data);
                        dataq = {>> {data}};
                        addr[bit_index] = this.IF.sda;
                        if (bit_index == 0) begin
                            if (addr == {this.next_tr.get_address(), this.next_tr.get_tr_type()} && (this.next_tr.get_final_ack() || dataq.size() > 0)) begin 
                                state = POST_ADDR;
                                `uvm_info(get_name(), "ACKing matching address/type combo", UVM_MEDIUM)
                            end else begin
                                state = IDLE;
                                `uvm_info(get_name(), "Not ACKing unmatching address/type combo", UVM_MEDIUM)
                            end
                            bit_index = 7;
                        end else begin
                            bit_index = bit_index - 1;
                        end
                    end
                end
                POST_ADDR: begin
                    if (oldscl && !this.IF.scl) begin
                        state = ADDRACK;
                        this.IF.sda_o_slv = 0;
                    end
                end
                ADDRACK: begin
                    this.IF.sda_o_slv = 0;
                    if (oldscl && !this.IF.scl) begin
                        state = DATA;
                        if (this.next_tr.get_type()) begin
                            bit_index = 7;
                            this.IF.sda_o_slv = dataq[0][bit_index];
                        end else begin
                            this.IF.sda_o_slv = 1;
                        end
                    end
                end
                DATA: begin
                    if (this.next_tr.get_type()) begin
                        if (oldscl && !this.IF.scl) begin
                            if (bit_index == 0) begin
                                dataq.pop_front();
                                this.IF.sda_o_slv = 1;
                                state = ACK;
                                `uvm_info(get_name(), "moving to ACK", UVM_MEDIUM)
                                bit_index = 7;
                            end else begin
                                bit_index = bit_index - 1;
                                this.IF.sda_o_slv = dataq[0][bit_index];
                            end
                        end
                    end else begin
                        if (oldscl && !this.IF.scl) begin
                            if (bit_index == 0) begin
                                dataq.pop_front();
                                this.IF.sda_o_slv = 1;
                                state = ACK;
                                if ((this.next_tr.get_type() == 0) && (this.next_tr.get_final_ack() || dataq.size() > 0)) begin
                                    this.IF.sda_o_slv = 0;
                                end else begin
                                    this.IF.sda_o_slv = 1;
                                end
                                `uvm_info(get_name(), "moving to ACK", UVM_MEDIUM)
                                bit_index = 7;
                            end else begin
                                bit_index = bit_index - 1;
                                this.IF.sda_o_slv = 1;
                            end
                        end
                    end
                    // bit index = 6 because the leading edge of SCL to get it high for the stop will clock a zero bit from SDA.
                    if ((bit_index == 6) && this.IF.scl && !oldsda && this.IF.sda) begin
                        // Write transaction ended by master.
                        state = IDLE;
                    end
                end
                ACK: begin
                    if ((this.next_tr.get_type() == 0) && (this.next_tr.get_final_ack() || dataq.size() > 0)) begin
                        this.IF.sda_o_slv = 0;
                    end else begin
                        this.IF.sda_o_slv = 1;
                    end
                    if (oldscl && !this.IF.scl) begin
                        if (dataq.size() > 0) begin
                            if (this.next_tr.get_type()) begin
                                this.IF.sda_o_slv = dataq[0][bit_index];
                            end else begin
                                this.IF.sda_o_slv = 1;
                            end
                            state = DATA;
                        end else begin
                            this.IF.sda_o_slv = 1;
                            state = STOP;
                        end
                    end
                end
                STOP: begin
                    if (oldscl && !this.IF.scl) begin
                        `uvm_error(get_name(), "databit clocked after NACK.")
                    end
                    if (this.IF.scl && !oldsda && this.IF.sda) begin
                        state = IDLE;
                        next_tr = null;
                        ->item_done;
                    end
                    if (this.IF.scl && oldsda && !this.IF.sda) begin
                        state = ADDR;
                        next_tr = null;
                        ->item_done;
                    end;
                end
            endcase
            oldsda = this.IF.sda;
            oldscl = this.IF.scl;
        end
    endtask
    
endclass