interface axilite_intf#(
  parameter DATA_WIDTH=32,
  parameter ADDR_WIDTH=32,
  parameter WSTRB_WIDTH=DATA_WIDTH/8
) (aclk, aresetn);
  input aclk;
  input aresetn;

  logic [ADDR_WIDTH-1:0]   awaddr;
  logic [2:0]              awprot;
  logic                    awvalid;
  logic                    awready;

  logic [ADDR_WIDTH-1:0]   araddr;
  logic [2:0]              arprot;
  logic                    arvalid;
  logic                    arready;

  logic [DATA_WIDTH-1:0]   wdata;
  logic [WSTRB_WIDTH-1:0]  wstrb;
  logic                    wvalid;
  logic                    wready;

  logic [DATA_WIDTH-1:0]   rdata;
  logic [1:0]              rresp;
  logic                    rvalid;
  logic                    rready;

  logic [1:0]              bresp;
  logic                    bvalid;
  logic                    bready;

  modport master(
    output awaddr,
    output awprot,
    output awvalid,
    input  awready,

    output araddr,
    output arprot,
    output arvalid,
    input  arready,

    output wdata,
    output wstrb,
    output wvalid,
    input  wready,

    input  rdata,
    input  rresp,
    input  rvalid,
    output rready,

    input  bresp,
    input  bvalid,
    output bready
  );

  modport slave(
    input awaddr,
    input awprot,
    input awvalid,
    output  awready,

    input araddr,
    input arprot,
    input arvalid,
    output  arready,

    input wdata,
    input wstrb,
    input wvalid,
    output  wready,

    output  rdata,
    output  rresp,
    output  rvalid,
    input rready,

    output  bresp,
    output  bvalid,
    input bready
  );

  modport monitor(
    input awaddr,
    input awprot,
    input awvalid,
    input awready,

    input araddr,
    input arprot,
    input arvalid,
    input arready,

    input wdata,
    input wstrb,
    input wvalid,
    input wready,

    input rdata,
    input rresp,
    input rvalid,
    input rready,

    input bresp,
    input bvalid,
    input bready
  );
endinterface