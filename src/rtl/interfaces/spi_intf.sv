interface spi_intf();
    logic mosi, miso, sclk, ss;
    
    modport monitor(input mosi, miso, sclk, ss);
    modport master(output mosi, sclk, ss,
                    input miso);
    modport slave(output miso,
                   input mosi, sclk, ss);
endinterface

module dummy();
endmodule