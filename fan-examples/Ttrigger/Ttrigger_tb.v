`timescale 1ns / 10ps
module Ttrigger_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("Ttrigger_sim.vcd");
        $dumpvars(0, Ttrigger_test);
    end
    
    // входные сигналы
    reg T = 0;
    always #5 T = !T;

    // выходные сигналы
    wire Q, nQ;

    // подключаем модуль
    Ttrigger T1(T, Q, nQ);

    // отслеживание сигналов
    initial begin
        $monitor("At time %t, out1=%b, out2=%b", $time, Q, nQ);
        #500 $finish;
    end
endmodule // Ttrigger_test
