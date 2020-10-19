class spi_monitor#(integer WORD_SIZE = 8) extends uvm_monitor;
    `uvm_component_param_utils(spi_monitor#(.WORD_SIZE(WORD_SIZE)))

    virtual interface spi_intf.monitor IF;

    uvm_analysis_port#(spi_item) ap;
    
    function new(string name = "spi_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        ap = new("monitor_ap", this);
    endfunction : build_phase
    
    virtual task run_phase(uvm_phase phase);
        logic [WORD_SIZE-1:0] misoq[$], misodata[];
        logic [WORD_SIZE-1:0] mosiq[$], mosidata[];
        logic [WORD_SIZE-1:0] misoword, mosiword;
        enum   {IDLE, ACTIVE} state;
        logic [$clog2(WORD_SIZE)-1:0] bit_index;
        logic old_sclk;
        old_sclk = 0;
        state = IDLE;
        bit_index = 0;
        forever @(this.IF.sclk,this.IF.ss) begin
            case (state)
                IDLE: begin
                    if (!this.IF.ss) begin
                        state = ACTIVE;
                        bit_index = 0;
                        misoq = '{};
                        mosiq = '{};
                        misoword = 0;
                        mosiword = 0;
                        `uvm_info(get_name(), "moving to ADDR", UVM_DEBUG);
                    end
                end
                ACTIVE: begin
                    if (this.IF.ss) begin
                        // end of frame
                        spi_item tr;
                        state = IDLE;
                        if (bit_index > 0) begin
                            misoq.push_back(misoword);
                            mosiq.push_back(mosiword);
                        end
                        misodata = {>>{misoq}};
                        mosidata = {>>{mosiq}};
                        tr = new(get_name());
                        tr.set_misodata(misodata);
                        tr.set_mosidata(mosidata);
                        ap.write(tr);
                    end else if (!old_sclk && this.IF.sclk) begin
                        misoword[bit_index] = this.IF.miso;
                        mosiword[bit_index] = this.IF.mosi;
                        if (bit_index == WORD_SIZE - 1) begin
                            bit_index = 0;
                            misoq.push_back(misoword);
                            mosiq.push_back(mosiword);
                            misoword = 0;
                            mosiword = 0;
                        end else begin
                            bit_index = bit_index + 1;
                        end
                    end
                end
            endcase
            old_sclk = this.IF.sclk;
        end
    endtask
    
endclass