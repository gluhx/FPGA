// задаём временную шкалу
`timescale 10ps / 1ps

module XOR_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("XOR_simulation.vcd");
        $dumpvars(0, XOR_test);
    end
    
    // объявляем и задаём входные сигналы
    parameter CELL_SIZE = 8;

    reg [CELL_SIZE - 1:0] x1 = 8'b0;
    reg [CELL_SIZE - 1:0] x2 = 8'b1010101;

    initial begin
        #20 x2 = 8'b10101010;
    end 

    // подключаем и задаём выходные сигналы
    wire [CELL_SIZE - 1:0] out;

    // подключаем модуль
    XOR #(
        .WIDTH(CELL_SIZE)
    ) DD1 (
        .in_1(x1),
        .in_2(x2),
        .out(out)
    );

    // отслеживание сигналов
    initial begin
        $monitor("At time %t, , in : %b, %b, out %b", $time, x1, x2, out);
        #40 $finish;
    end

endmodule // XOR_test
