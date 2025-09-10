`timescale 1ns / 10ps
module Dtrigger_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("Dtrigger_sim.vcd");
        $dumpvars(0, Dtrigger_test);
    end
    
    // тактовый сигнал
    reg clk = 0;
    always #5 clk = !clk;

    // входные сигналы
    reg D = 0;
    always #7 D = !D;

    // выходные сигналы
    wire Q, nQ;

    // подключаем модуль
    Dtrigger T1(clk, D, Q, nQ);

    // отслеживание сигналов
    initial begin
        $monitor("At time %t, out1=%b, out2=%b", $time, Q, nQ);
        #500 $finish;
    end
endmodule // Dtrigger_test
