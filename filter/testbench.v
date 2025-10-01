`timescale 10ps / 1ps
module filter_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("filter_sim.vcd");
        $dumpvars(0, filter_test);
    end
    
    // входные сигналы
    reg clk = 0;
    always #5 clk = !clk;
    
    reg [7:0] x = 0;

    always @(posedge clk) begin
       x <= x + 1;
    end
    reg reset = 1'b1;
    initial begin
        #130 reset <= 1'b0;
        #93 reset <= 1'b1;
    end

    wire [31:0] out;
    // подключаем модуль
    filter DD1(clk, reset, x, out);

    // отслеживание сигналов
    initial begin
        $monitor("At time %t", $time);
        #1000 $finish;
    end
endmodule // filter_test
