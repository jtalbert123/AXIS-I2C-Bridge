`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: James Talbert
// 
// Create Date: 02/22/2020 10:27:13 PM
// Design Name: AXIS I2C Master
// Module Name: i2c_transaction
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

class spi_item#(integer WORD_SIZE = 8) extends uvm_sequence_item;
    `uvm_object_param_utils(spi_item#(.WORD_SIZE(WORD_SIZE)))
    logic [WORD_SIZE-1:0] miso[];
    logic [WORD_SIZE-1:0] mosi[];
    
    function new(input string name = "spi_item");
        super.new(name);
    endfunction
    
    virtual function void set_misodata(input logic [7:0] misodata[]);
        this.miso = new[misodata.size()](misodata);
    endfunction
    
    virtual function void set_mosidata(input logic [7:0] mosidata[]);
        this.mosi = new[mosidata.size()](mosidata);
    endfunction
    
    virtual function void get_misodata(output logic [7:0] misodata[]);
        misodata = new[this.miso.size()](this.miso);
    endfunction
    
    virtual function void get_mosidata(output logic [7:0] mosidata[]);
        mosidata = new[this.mosi.size()](this.mosi);
    endfunction
    
    virtual function integer get_misodata_size();
        return this.miso.size();
    endfunction
    
    virtual function integer get_mosidata_size();
        return this.mosi.size();
    endfunction

    virtual function string convert2string();
        string datastr, result;
        foreach (this.mosi[i]) begin
            $sformat(datastr, "%s {%02H,%02H} ", datastr, this.miso[i], this.mosi[i]);
        end
        $sformat(result, "%s: {miso,mosi}: %s", get_name(), datastr);
        return result;
    endfunction : convert2string
  
endclass
