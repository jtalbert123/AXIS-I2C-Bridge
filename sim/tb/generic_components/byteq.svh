`ifndef BYTEQ_SVH
`define BYTEQ_SVH

typedef bit[7:0]  byteq[$];

class byteq_item extends uvm_sequence_item;
`uvm_object_utils(byteq_item)

    byteq data;

    extern function new(string name = "byteq_item");
    extern virtual function void    do_copy(uvm_object rhs);
    extern virtual function bit     do_compare(uvm_object rhs, uvm_comparer comparer);
    extern virtual function byteq   get_data();
    extern virtual function void    set_data(byteq t);
    extern virtual function string  convert2string();

endclass

function byteq_item::new(string name = "byteq_item");
    super.new(name);
    data.delete();
endfunction

function byteq byteq_item::get_data();
    byteq t;
    t = {data};
    return t;
endfunction

function void byteq_item::set_data(byteq t);
    data = {t};
endfunction

function void byteq_item::do_copy(uvm_object rhs);
    byteq_item other;
    if (!$cast(other, rhs)) begin
        `uvm_fatal(get_name(), $sformatf("cannot cast %s to byteq_item", rhs.get_name()))
    end
    this.set_data(other.get_data());
endfunction

function bit byteq_item::do_compare(uvm_object rhs, uvm_comparer comparer);
    byteq_item other;
    if (other == null || !$cast(other, rhs)) begin
        return 0;
    end
    if (other.data.size() != this.data.size()) begin
        return 0;
    end else begin
        foreach (this.data[i]) begin
            if (other.data[i] != this.data[i]) begin
                return 0;
            end
        end
    end
    return 1;
endfunction

function string byteq_item::convert2string();
    string s = "";
    foreach (data[i]) begin
        if (((i % 16) != 15) || (i == data.size()-1)) begin
            s = {s, $sformatf("%02h ", data[i])};
        end else if (((i % 16) == 15) && (i != data.size()-1)) begin
            s = {s, $sformatf("%02h\n", data[i])};
        end else if (((i % 16) == 15) && (i == data.size()-1)) begin
            s = {s, $sformatf("%02h", data[i])};
        end
    end
    return s;
endfunction

`endif //BYTEQ_SVH