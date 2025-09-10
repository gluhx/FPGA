`timescale 1ns / 10ps
module syncTtrigger_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("syncTtrigger_sim.vcd");
        $dumpvars(0, syncTtrigger_test);
    end
    
    // тактовый сигнал
    reg clk = 0;
    always #5 clk = !clk;

    // входные сигналы
    reg T = 0;
    always #7 T = !T;

    // выходные сигналы
    wire Q, nQ;

    // подключаем модуль
    syncTtrigger T1(clk, T, Q, nQ);

    // отслеживание сигналов
    initial begin
        $monitor("At time %t, out1=%b, out2=%b", $time, Q, nQ);
        #500 $finish;
    end
endmodule // syncTtrigger_test
