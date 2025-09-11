`timescale 1ns / 10ps
module decoder_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("decoder_sim.vcd");
        $dumpvars(0, decoder_test);
    end
    
    // входные сигналы
    reg i = 0;
    reg [2:0] X = 3'b0;
    
    always #10 X = X + 1;

    // выходные сигналы
    wire [7:0] Y;

    // подключаем модуль
    decoder DD1(X, Y);

    // отслеживание сигналов
    initial begin
        $monitor("At time %t, out1=%b", $time, Y);
        #500 $finish;
    end
endmodule // decoder_test