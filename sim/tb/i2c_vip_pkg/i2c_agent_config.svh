class i2c_agent_config extends uvm_object;
    `uvm_object_utils(i2c_agent_config)

    driver_type_t driver_type;
    virtual interface i2c_intf vif;

    extern         function        new(string name = "i2c_agent_config");
    extern virtual function string convert2string();
endclass

function i2c_agent_config::new(string name = "i2c_agent_config");
    super.new(name);
endfunction : new

function string i2c_agent_config::convert2string();
    string s = "";

    if (driver_type == MASTER) begin
        s = {s, "I2C Master"};
    end else begin
        s = {s, "I2C Slave"};
    end

    return s;
endfunction : convert2string