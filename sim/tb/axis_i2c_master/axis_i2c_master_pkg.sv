package axis_i2c_master_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;
import i2c_vip_pkg::*;
import spi_vip_pkg::*;
import spi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import axis_master_0_pkg::*;
import axis_slave_0_pkg::*;
import axi4stream_uvm_pkg::*;
import generic_components_pkg::*;

typedef virtual interface axi4stream_vip_if#(
    axis_master_0_VIP_SIGNAL_SET,
    axis_master_0_VIP_DEST_WIDTH,
    axis_master_0_VIP_DATA_WIDTH,
    axis_master_0_VIP_ID_WIDTH,
    axis_master_0_VIP_USER_WIDTH,
    axis_master_0_VIP_USER_BITS_PER_BYTE,
    axis_master_0_VIP_HAS_ARESETN
) axis_master_if;
typedef virtual interface axi4stream_vip_if#(
    axis_slave_0_VIP_SIGNAL_SET,
    axis_slave_0_VIP_DEST_WIDTH,
    axis_slave_0_VIP_DATA_WIDTH,
    axis_slave_0_VIP_ID_WIDTH,
    axis_slave_0_VIP_USER_WIDTH,
    axis_slave_0_VIP_USER_BITS_PER_BYTE,
    axis_slave_0_VIP_HAS_ARESETN
) axis_slave_if;

`include "axis_i2c_master_env.svh"
`include "read_req.svh"

endpackage