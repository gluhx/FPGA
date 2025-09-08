module test;

  /* Создание сброса, который пульсирует один раз. */
  reg reset = 0;
  initial begin
     $dumpfile("test.vcd");
     $dumpvars(0,test);
     # 17 reset = 1;
     # 11 reset = 0;
     # 29 reset = 1;
     # 11 reset = 0;
     # 100 $stop;
  end

  /* Создание регулярной пульсации клоков. */
  reg clk = 0;
  always #5 clk = !clk;

  wire [7:0] value;
  counter c1 (value, clk, reset);

  initial
     $monitor("At time %t, value = %h (%0d)",
              $time, value, value);
endmodule // test
