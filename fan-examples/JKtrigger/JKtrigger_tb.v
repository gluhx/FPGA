`timescale 1ns / 10ps
module JKtrigger_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("JKtrigger_sim.vcd");
        $dumpvars(0, JKtrigger_test);
    end
    
    // тактовый сигнал
    reg clk = 0;
    always #5 clk = !clk;

    // входные сигналы
    reg J = 0;
    always #7 J = !J;
    reg K = 0;
    always #6 K = !K;

    // выходные сигналы
    wire Q, nQ;

    // подключаем модуль
    JKtrigger T1(J, K, clk, Q, nQ);

    // отслеживание сигналов
    initial begin
        $monitor("At time %t, out1=%b, out2=%b", $time, Q, nQ);
        #500 $finish;
    end
endmodule // JKtrigger_test
