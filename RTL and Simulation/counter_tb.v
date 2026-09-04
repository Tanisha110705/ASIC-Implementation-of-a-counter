module counter_test;
  reg clk, rst;
  wire [7:0] count;

  initial begin
    clk = 0;
    rst = 0;     // Initial state
    #10;
    rst = 1;     // Reset active: 0 -> 1
    #150;
    rst = 0;     // Release reset: 1 -> 0
    #20;
    rst = 1;     // Re-assert reset: 0 -> 1
    #2600;       // 260 clock cycles: allows count[7:0] to toggle all 8 bits
    $finish;
  end

  counter counter1(clk, rst, count);

  always #5 clk = ~clk;
endmodule
