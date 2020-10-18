interface i2c_intf();
    logic sda;
    logic scl;
    
    logic sda_o_mst, scl_o_mst;
    logic sda_o_slv, scl_o_slv;
    
    modport monitor(input sda, scl);
    modport master( input sda, scl,
                    output sda_o_mst, scl_o_mst);
    modport slave(input sda, scl,
                output sda_o_slv, scl_o_slv);
endinterface

module i2c_bus(
    i2c_intf bus
);
    assign bus.sda = bus.sda_o_mst && bus.sda_o_slv;
    assign bus.scl = bus.scl_o_mst && bus.scl_o_slv;
endmodule