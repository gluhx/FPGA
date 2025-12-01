// задаём временную шкалу
`timescale 10ps / 1ps

module NOR_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("NOR_simulation.vcd");
        $dumpvars(0, NOR_test);
    end
    
    // объявляем и задаём входные сигналы
    parameter CELL_SIZE = 3;

    reg [CELL_SIZE - 1:0] x = 3'b0;

    always begin
        #2 x = x + 1;
    end 

    // подключаем и задаём выходные сигналы
    wire out;

    // подключаем модуль
    NOR #(
        .WIDTH(CELL_SIZE)
    ) DD1 (
        .in(x),
        .out(out)
    );

    // отслеживание сигналов
    initial begin
        $monitor("At time %t, , in : %b, out %b", $time, x, out);
        #40 $finish;
    end

endmodule // XOR_test
