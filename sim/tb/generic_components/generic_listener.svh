class generic_listener#(type T = int) extends uvm_subscriber#(.T(T));
    `uvm_component_param_utils(generic_listener#(.T(T)))
    
    function new(string name = "generic_listener", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void write(T t);
        `uvm_info(get_name(), {"Listener item:\n", t.convert2string()}, UVM_MEDIUM)
    endfunction : write
endclass