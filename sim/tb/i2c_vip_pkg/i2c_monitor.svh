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

class i2c_monitor extends uvm_monitor;
    `uvm_component_utils(i2c_monitor)
    virtual interface i2c_intf.monitor IF;
    
    uvm_analysis_port#(i2c_item) ap;
    
    function new(string name = "i2c_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        ap = new("monitor_ap", this);
    endfunction : build_phase
    
    virtual task run_phase(uvm_phase phase);
        bit [7:0] addr;
        bit ack;
        bit [7:0] dataq[$];
        enum   {IDLE,
                ADDR,
                ADDRACK,
                DATA,
                ACK,
                PRE_STOP,
                STOP} state;
        bit [3:0] bit_index;
        bit oldscl, oldsda;
        oldscl = 0;
        oldsda = 0;
        state = IDLE;
        bit_index = 0;
        forever @(this.IF.scl,this.IF.sda) begin
            i2c_item tr;
            case (state)
                IDLE: begin
                    if (oldsda && !this.IF.sda) begin
                        state = ADDR;
                        bit_index = 7;
                        //`uvm_info(get_name(), "moving to ADDR", UVM_DEBUG)
                    end
                end
                ADDR: begin
                    if (!oldscl && this.IF.scl) begin
                        addr[bit_index] = this.IF.sda;
                        if (bit_index == 0) begin
                            state = ADDRACK;
                            //`uvm_info(get_name(), "moving to ADDRACK", UVM_DEBUG)
                            bit_index = 7;
                        end else begin
                            bit_index = bit_index - 1;
                        end
                    end
                    if (this.IF.scl && (oldsda != this.IF.sda)) begin
                        `uvm_error(get_name(), "Start or Stop detected during ADDR phase.");
                    end;
                end
                ADDRACK: begin
                    if (!oldscl && this.IF.scl) begin
                        ack = !this.IF.sda;
                        if (ack) begin
                            state = DATA;
                            //`uvm_info(get_name(), "moving to DATA", UVM_DEBUG)
                            dataq.push_back(8'h00);
                        end else begin
                            state = PRE_STOP;
                            //`uvm_info(get_name(), "moving to STOP", UVM_DEBUG)
                        end
                    end
                    if (this.IF.scl && (oldsda != this.IF.sda)) begin
                        `uvm_error(get_name(), "Start or Stop detected during ADDR ACK phase.")
                    end;
                end
                DATA: begin
                    if (!oldscl && this.IF.scl) begin
                        dataq[$][bit_index] = this.IF.sda;
                        if (bit_index == 0) begin
                            state = ACK;
                            //`uvm_info(get_name(), "moving to ACK", UVM_DEBUG)
                            bit_index = 7;
                        end else begin
                            bit_index = bit_index - 1;
                        end
                    end
                    // bit index = 6 because the leading edge of SCL to get it high for the stop will clock a zero bit from SDA.
                    if ((bit_index == 6) && this.IF.scl && !oldsda && this.IF.sda) begin
                        // Write transaction ended by master.
                        bit [7:0] data[];
                        dataq.pop_back();
                        data = {>>{dataq}};
                        tr = new("monitor_trxn");
                        tr.set_address(addr[7:1]);
                        tr.set_tr_type(addr[0]);
                        tr.set_data(data);
                        tr.set_final_ack(ack);
                        ap.write(tr);
                        dataq = {};
                        state = IDLE;
                    end else if (this.IF.scl && (oldsda != this.IF.sda)) begin
                        `uvm_error(get_name(), "Invalid Start or Stop detected during DATA phase.")
                    end;
                end
                ACK: begin
                    if (!oldscl && this.IF.scl) begin
                        ack = !this.IF.sda;
                        if (ack) begin
                            state = DATA;
                            dataq.push_back(8'h00);
                        end else begin
                            state = PRE_STOP;
                        end
                    end
                    if (this.IF.scl && (oldsda != this.IF.sda)) begin
                        `uvm_error(get_name(), "Start or Stop detected during DATA ACK phase.")
                    end;
                end
                PRE_STOP: begin
                    if (!this.IF.scl) begin
                        state = STOP;
                    end
                end
                STOP: begin
                    if (oldscl && !this.IF.scl) begin
                        `uvm_error(get_name(), "databit clocked after NACK.")
                    end
                    if (this.IF.scl && !oldsda && this.IF.sda) begin
                        bit [7:0] data[];
                        data = {>>{dataq}};
                        tr = new("monitor_trxn");
                        tr.set_address(addr[7:1]);
                        tr.set_tr_type(addr[0]);
                        tr.set_data(data);
                        tr.set_final_ack(ack);
                        ap.write(tr);
                        dataq = {};
                        state = IDLE;
                    end
                    if (this.IF.scl && oldsda && !this.IF.sda) begin
                        bit [7:0] data[];
                        data = {>>{dataq}};
                        tr = new("monitor_trxn");
                        tr.set_address(addr[7:1]);
                        tr.set_tr_type(addr[0]);
                        tr.set_data(data);
                        tr.set_final_ack(ack);
                        ap.write(tr);
                        dataq = {};
                        `uvm_info(get_name(), "Repeated Start Detected.", UVM_HIGH);
                        state = ADDR;
                    end;
                end
            endcase
            oldsda = this.IF.sda;
            oldscl = this.IF.scl;
        end
    endtask
    
endclass