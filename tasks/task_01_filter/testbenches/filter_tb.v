// задаём временную шкалу
`timescale 10ps / 1ps

module filter_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("filter_simulation.vcd");
        $dumpvars(0, filter_test);
    end
    
    // объявляем и задаём входные сигналы
    reg clk = 0;
    always #5 clk = !clk;
    
    reg [31:0] x = 0;


    always @(negedge clk) begin
       x <= x + 1;
    end

    reg reset = 1'b1;
    initial begin
        #191 reset <= 1'b0;
    end
    
    
    // подключаем и задаём выходные сигналы
    wire [31:0] out;

    // подключаем модуль
    filter FILT(
        .clk(clk), 
        .reset(reset),
        .x(x),
        .y(out)
    );

    // отслеживание сигналов
    initial begin
        $monitor("At time %t, reset : %b, in : %b, out %b", $time, reset, x, out);
        #300 $finish;
    end

endmodule // mult_2t_test
