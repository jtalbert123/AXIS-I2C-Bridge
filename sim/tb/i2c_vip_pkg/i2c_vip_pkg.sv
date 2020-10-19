

package i2c_vip_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;

typedef enum {MASTER, SLAVE} driver_type_t;

`include "i2c_item.svh"
`include "i2c_monitor.svh"
`include "i2c_slv_driver.svh"
`include "i2c_agent_config.svh"
`include "i2c_agent.svh"
`include "read_resp.svh"

endpackage