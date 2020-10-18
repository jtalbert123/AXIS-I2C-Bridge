`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2020 05:05:37 PM
// Design Name: 
// Module Name: tb_spi_regs
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import spi_vip_pkg::*;

module tb_spi_regs(

    );
    
    spi spibus();
    clock_if clkif();
    
    reg clk;
    reg aresetn;
    assign clkif.clk = clk;
    
    spi_mst_driver master;
    spi_monitor monitor;
    
    spi_transaction pendingq[$], respq[$];
    
    //default clocking cb @clk.cb;
    //endclocking
    
    spi_slave_registers dut (
        .spi_ss(spibus.ss),
        .spi_clk(spibus.sclk),
        .spi_miso(spibus.miso),
        .spi_mosi(spibus.mosi),
        //.clk(clk.clk),
        .clk(clk),
        .aresetn(aresetn),
        
        .fsm_state(5'b00100),
        .fsm_bit_state(2'b10)
    );
    
    initial begin
        clk <= 0;
        aresetn <= 0;
        spibus.miso <= 0;
        #50ns;
        aresetn <= 1;
    end
    
    //always #5ns clk.clk <= ~clk.clk;
    always #5ns clk <= ~clk;
    
    initial begin
        spi_transaction tr;
        while (1) begin
            wait (pendingq.size() > 0);
            tr = pendingq.pop_front();
            master.set_transaction(tr);
        end
    end
    
        spi_transaction expected_tr;
        spi_transaction actual_tr;
    initial begin
        logic [7:0] expected_data[], actual_data[];
        wait (monitor != null);
        while (1) begin
            monitor.get_transaction(actual_tr);
            wait (respq.size() > 0);
            expected_tr = respq.pop_front();
            $display(actual_tr.convert2string());
            $display(expected_tr.convert2string());
            expected_tr.get_misodata(expected_data);
            actual_tr.get_misodata(actual_data);
            if (expected_data != actual_data) begin
                $error("bad SPI slave response");
            end
        end
    end
    
    task do_transaction;
        input spi_transaction tr;
        pendingq.push_back(tr);
        respq.push_back(tr);
    endtask
    
    initial begin
        master  = new(.IF(spibus), .clkIF(clkif));
        monitor = new(.IF(spibus));
        
        fork
            master.run_phase();
            monitor.run_phase();
        join_none
    end
    
    initial begin
        spi_transaction tr;
        #100ns;
        tr = new(.mosidata('{8'd00, 8'hFF, 8'h00}), .misodata('{8'd0, 8'h00, 8'h00}));
        do_transaction(tr);
        
        tr = new(.mosidata('{8'd00, 8'h00, 8'hFF}), .misodata('{8'h0F, 8'hFF, 8'h00}));
        do_transaction(tr);
        
        tr = new(.mosidata('{8'd00, 8'h00, 8'hFF}), .misodata('{8'h0F, 8'h00, 8'hFF}));
        do_transaction(tr);
    end
    
endmodule
