// задаём временную шкалу
`timescale 10ps / 1ps

module mult_2t_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("mult_2t_simulation.vcd");
        $dumpvars(0, mult_2t_test);
    end
    
    // объявляем и задаём входные сигналы
    reg clk = 0;
    always #5 clk = !clk;
    
    reg [7:0] x = 0;

    always @(posedge clk) begin
       x <= x + 1;
    end

    reg reset = 1'b1;
    initial begin
        #91 reset <= 1'b0;
    end
    
    reg enable = 1'b1;
    initial begin
        #50 enable <= 1'b0;
        #20 enable <= 1'b1;
    end
    // подключаем и задаём выходные сигналы
    wire [7:0] out;

    // подключаем модуль
    mult_2t MULT(
        .clk(clk), 
        .reset(reset),
        .enable(enable),
        .multipliable_1(x),
        .multipliable_2(x),
        .mult_result(out)
    );

    // отслеживание сигналов
    initial begin
        $monitor("At time %t, reset : %b, en : %b, in : %b, out %b", $time, reset, enable, x, out);
        #200 $finish;
    end

endmodule // mult_2t_test
