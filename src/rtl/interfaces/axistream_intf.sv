interface axistream_intf#(
  parameter DATA_WIDTH=32,
  parameter USER_WIDTH=1,
  parameter KEEP_WIDTH=DATA_WIDTH/8,
  parameter DEST_WIDTH=0,
  parameter ID_WIDTH=0
) (aclk, aresetn);
  input aclk;
  input aresetn;

  logic                    tvalid;
  logic                    tready;
  logic                    tlast;
  logic [USER_WIDTH-1:0]   tuser;
  logic [DEST_WIDTH-1:0]   tdest;
  logic [ID_WIDTH-1:0]     tid;
  logic [DATA_WIDTH-1:0]   tdata;
  logic [KEEP_WIDTH-1:0]   tkeep;

  modport master(
    output tvalid,
    output tlast,
    output tuser,
    output tdest,
    output tid,
    output tdata,
    output tkeep,
    
    input  tready
  );

  modport slave(
    input  tvalid,
    input  tlast,
    input  tuser,
    input  tdest,
    input  tid,
    input  tdata,
    input  tkeep,
    
    output tready
  );

  modport monitor(
    input  tvalid,
    input  tlast,
    input  tuser,
    input  tdest,
    input  tid,
    input  tdata,
    input  tkeep,
    
    input tready
  );
endinterface