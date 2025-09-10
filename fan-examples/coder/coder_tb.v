`timescale 1ns / 10ps
module coder_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("coder_sim.vcd");
        $dumpvars(0, coder_test);
    end
    
    // входные сигналы
    reg i = 0;
    reg [7:0] X = 8'b0;
    initial begin
        forever begin
            #10;
            if (X == 0) X = 8'b00000001;
            else X = X << 1;
        end
    end

    // выходные сигналы
    wire [2:0] Y;

    // подключаем модуль
    coder DD1(X, Y);

    // отслеживание сигналов
    initial begin
        $monitor("At time %t, out1=%b", $time, Y);
        #500 $finish;
    end
endmodule // coder_test