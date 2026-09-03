module counter_test;
  reg clk, rst;
  wire [7:0] count;

  initial begin
    clk = 0;
    rst = 0;     // Initial state (0)
    #10;
    rst = 1;     // Transition 1: 0 -> 1
    #150;
    rst = 0;     // Transition 2: 1 -> 0 (completes toggle coverage)
    #20;
    rst = 1;     // Release reset to resume counting
    #20;
    $finish;
  end

  counter counter1(clk, rst, count);

  always #5 clk = ~clk;
endmodule
