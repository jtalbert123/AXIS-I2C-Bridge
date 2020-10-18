

interface clock_if();
    reg clk;
    clocking cb @(posedge clk);
    endclocking
endinterface