// задаём временную шкалу
`timescale 10ps / 1ps

module sequence_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("sequence_simulation.vcd");
        $dumpvars(0, sequence_test);
    end
    
    // объявляем и задаём входные сигналы
    reg clk = 0;
    always #5 clk = !clk;
    
    reg [7:0] x = 1;
    wire [7:0] x_n_1;

    assign x_n_1 = x - 1;

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
    sequence SEQ(
        .clk(clk), 
        .reset(reset),
        .enable_start(enable),
        .x_n(x),
        .x_n_1(x_n_1),
        .y(out)
    );

    // отслеживание сигналов
    initial begin
        $monitor("At time %t, reset : %b, en : %b, in : %b, %b, out %b", $time, reset, enable, x, x_n_1, out);
        #200 $finish;
    end

endmodule // mult_2t_test
