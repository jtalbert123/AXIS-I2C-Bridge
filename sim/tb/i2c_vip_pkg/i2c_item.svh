`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: James Talbert
// 
// Create Date: 02/22/2020 10:27:13 PM
// Design Name: AXIS I2C Master
// Module Name: i2c_item
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

class i2c_item extends uvm_sequence_item;
    `uvm_object_utils(i2c_item)

    bit [6:0] address;
    bit read_nWrite;
    bit [7:0] data[];
    bit final_ack;
    
    function new(input string name = "i2c_item");
        super.new(name);
    endfunction
    
    virtual function void set_address(input bit [6:0] address);
        this.address = address;
    endfunction
    
    virtual function void set_tr_type(input bit read_nWrite);
        this.read_nWrite = read_nWrite;
    endfunction
    
    virtual function void set_data(input bit [7:0] data[]);
        this.data = new[data.size()](data);
    endfunction
    
    virtual function void set_final_ack(input bit final_ack);
        this.final_ack = final_ack;
    endfunction
    
    virtual function bit[6:0] get_address();
        return this.address;
    endfunction
    
    virtual function bit get_tr_type();
        return this.read_nWrite;
    endfunction
    
    virtual function void get_data(output bit [7:0] data[]);
        data = new[this.data.size()](this.data);
    endfunction
    
    virtual function integer get_data_size();
        return this.data.size();
    endfunction
    
    virtual function bit get_final_ack();
        return this.final_ack;
    endfunction

    virtual function string convert2string();
        string direction;
        string addrack;
        string datastr;
        string result;
        if (this.read_nWrite)
            direction = "Read from";
        else
            direction = "Write to";
        
        if (this.final_ack || (this.data.size() > 0))
            addrack = "[A]";
        else
            addrack = "[N]";
        
        foreach (this.data[i]) begin
            if (this.final_ack || (i < this.data.size()-1)) begin
                $sformat(datastr, "%s %02H[A]", datastr, this.data[i]);
            end else begin
                $sformat(datastr, "%s %02H[N]", datastr, this.data[i]);
            end
        end
        $sformat(result, "%s: %s %02H%s: {%s}", get_name(), direction, address, addrack, datastr);
        return result;
    endfunction : convert2string
  
endclass
