`timescale 1ns / 10ps
module multiplication_c_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("multiplication_c_sim.vcd");
        $dumpvars(0, multiplication_c_test);
    end
    
    // входные сигналы
    reg clk = 0;
    always #5 clk = !clk;
    
    reg [7:0] a, b, c;
    initial begin
        a = 0;
        b = 0;
        c = 0;
    end
    always #5 a = a + 1;
    always #5 b = b + 1;
    always #5 c = c + 1;
    // выходные сигналы
    wire [16:0] out;

    // подключаем модуль
    multiplication_c DD1(clk, a, b, c, out);

    // отслеживание сигналов
    initial begin
        $monitor("At time %t", $time);
        #500 $finish;
    end
endmodule // multiplication_c_test
