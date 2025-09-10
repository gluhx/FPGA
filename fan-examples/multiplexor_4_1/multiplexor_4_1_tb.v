`timescale 1ns / 10ps
module multiplexor_4_1_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("multiplexor_4_1_sim.vcd");
        $dumpvars(0, multiplexor_4_1_test);
    end
    
    // входные сигналы
    reg [1:0] X = 2'b00;
    always #5 X = X + 1;
    reg [3:0] D = 4'b1010;
    always #17 D = D ^ 4'b1111;

    // выходные сигналы
    wire F;

    // подключаем модуль
    multiplexor_4_1 MUX1(D, X, F);

    // отслеживание сигналов
    initial begin
        $monitor("At time %t, out1=%b", $time, F);
        #500 $finish;
    end
endmodule // multiplexor_4_1_test
