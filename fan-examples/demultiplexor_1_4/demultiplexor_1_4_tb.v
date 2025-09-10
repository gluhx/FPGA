`timescale 1ns / 10ps
module demultiplexor_1_4_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("demultiplexor_1_4_sim.vcd");
        $dumpvars(0, demultiplexor_1_4_test);
    end
    
    // входные сигналы
    reg [1:0] X = 2'b00;
    always #15 X = X + 1;
    reg D = 1;
    always #2 D = !D;

    // выходные сигналы
    wire [3:0] F;

    // подключаем модуль
    demultiplexor_1_4 DMX1(D, X, F);

    // отслеживание сигналов
    initial begin
        $monitor("At time %t, out1=%b", $time, F);
        #500 $finish;
    end
endmodule // demultiplexor_1_4_test
