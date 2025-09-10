`timescale 1ns / 10ps
module syncRStrigger_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("syncRStrigger_sim.vcd");
        $dumpvars(0, syncRStrigger_test);
    end
    
    // тактовый сигнал
    reg clk = 0;
    always #5 clk = !clk;

    // входные сигналы
    reg R = 0;
    always #7 R = !R;
    reg S = 0;
    always #6 S = !S;

    // выходные сигналы
    wire Q, nQ;

    // подключаем модуль
    syncRStrigger T1(R, S, clk, Q, nQ);

    // отслеживание сигналов
    initial begin
        $monitor("At time %t, out1=%b, out2=%b", $time, Q, nQ);
        #500 $finish;
    end
endmodule // syncRStrigger_test
