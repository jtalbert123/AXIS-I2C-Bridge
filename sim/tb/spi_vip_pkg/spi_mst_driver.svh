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
class spi_mst_driver#(integer WORD_SIZE = 8, integer STATE_LEN = 2) extends uvm_driver#(spi_item);
    `uvm_component_param_utils(spi_mst_driver#(.WORD_SIZE(WORD_SIZE), .STATE_LEN(STATE_LEN)))

    virtual interface spi.master IF;
    virtual interface clock_if clkIF;
    spi_item next_tr;
    
    function new(string name = "spi_mst_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual task get_items(uvm_phase phase);
        spi_item current_tr;
        forever begin
            seq_item_port.get_next_item(current_tr);
            phase.raise_objection(this);
            next_tr = current_tr;
            wait (item_done.triggered);
            seq_item_port.item_done(current_tr);
            phase.drop_objection(this);
        end
    endtask
    
    virtual task run_phase(uvm_phase phase);
        logic [WORD_SIZE-1:0] miso[],   mosi[];
        logic [WORD_SIZE-1:0] misoq[$], mosiq[$];
        logic [$clog2(STATE_LEN)-1:0] state_len;
        enum   {IDLE, START, CLK_LOW, CLK_HIGH, POST} state;
        logic [$clog2(WORD_SIZE)-1:0] bit_index;
        fork
            get_items(phase);
        join_none
        state = IDLE;
        bit_index = 0;
        this.IF.mosi = 0;
        this.IF.ss = 1;
        this.IF.sclk = 1;
        state_len = 0;
        // Every clock cycle
        forever @(this.clkIF.cb) begin
            case (state)
                IDLE: begin
                    this.IF.sclk = 0;
                    this.IF.ss = 1;
                    if (next_tr != null) begin
                        next_tr.get_misodata(miso);
                        next_tr.get_mosidata(mosi);
                        misoq = {>>{miso}};
                        mosiq = {>>{mosi}};
                        this.IF.mosi = mosiq[0][bit_index];
                        if (state_len < STATE_LEN-1) begin
                            state_len = state_len+1;
                        end else begin
                            state_len = 0;
                            state = START;
                        end
                    end else begin
                        state_len = 0;
                    end
                end
                START: begin
                    this.IF.sclk = 0;
                    this.IF.ss = 0;
                    if (state_len < STATE_LEN-1) begin
                        state_len = state_len+1;
                    end else begin
                        state_len = 0;
                        state = CLK_HIGH;
                    end
                end
                CLK_HIGH: begin
                    this.IF.sclk = 1;
                    this.IF.ss = 0;
                    if (state_len < STATE_LEN-1) begin
                        state_len = state_len+1;
                    end else begin
                        state_len = 0;
                        state = CLK_LOW;
                        if (bit_index < WORD_SIZE - 1) begin
                            bit_index = bit_index + 1;
                        end else begin
                            bit_index = 0;
                            mosiq.pop_front();
                            if (mosiq.size() == 0) begin
                                state = POST;
                            end
                        end
                    end
                end
                CLK_LOW: begin
                    this.IF.sclk = 0;
                    if (mosiq.size() > 0) begin
                        this.IF.mosi = mosiq[0][bit_index];
                    end
                    if (state_len < STATE_LEN-1) begin
                        state_len = state_len+1;
                    end else begin
                        state_len = 0;
                        state = CLK_HIGH;
                    end
                end
                POST: begin
                    this.IF.ss = 0;
                    this.IF.sclk = 0;
                    if (state_len < STATE_LEN-1) begin
                        state_len = state_len+1;
                    end else begin
                        state_len = 0;
                        state = IDLE;
                        next_tr = null;
                    end
                end
            endcase
        end
    endtask
    
endclass