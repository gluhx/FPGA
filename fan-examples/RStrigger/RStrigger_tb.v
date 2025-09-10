`timescale 1ns / 10ps
module RStrigger_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("RStrigger_sim.vcd");
        $dumpvars(0, RStrigger_test);
    end

    // входные сигналы
    reg R = 0;
    always #7 R = !R;
    reg S = 0;
    always #4 S = !S;

    // выходные сигналы
    wire Q, nQ;

    // подключаем модуль
    RStrigger T1(R, S, Q, nQ);

    // отслеживание сигналов
    initial begin
        $monitor("At time %t, out1=%b, out2=%b", $time, Q, nQ);
        #200 $finish;
    end
endmodule // RStrigger_test
