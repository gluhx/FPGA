//подключаем необходимые модули
`include "mult_2t.v"

module sequence(
    input clk,
    input reset,
    input enable_start,
    input [7:0] x_n,
    input [7:0] x_n_1,
    output [7:0] y
);

// объявляем и задаём постоянные
parameter [7:0] a = 8'b10;
parameter [7:0] b = 8'b11;
parameter [7:0] aa = a * a;
parameter [7:0] ab = a * b;

//объявляем и задаём служебные сигналы
wire [2:0][7:0] mult_result;

//подключаем модуль для расчёта a**2 * y_n-2
mult_2t MULT_AAY(
    .clk(clk),
    .reset(reset),
    .enable(enable_start),
    .multipliable_1(aa),
    .multipliable_2(y),
    .mult_result(mult_result[0])
);

//подключаем модуль для расчётв a * b * x_n-1 
mult_2t MULT_ABX(
    .clk(clk),
    .reset(reset),
    .enable(enable_start),
    .multipliable_1(ab),
    .multipliable_2(x_n_1),
    .mult_result(mult_result[1])
);

//подключаем модуль для расчёта b * x_n 
mult_2t MULT_BX(
    .clk(clk),
    .reset(reset),
    .enable(enable_start),
    .multipliable_1(b),
    .multipliable_2(x_n),
    .mult_result(mult_result[2])
);

assign y = mult_result[0] + mult_result[1] + mult_result[2];

endmodule // sequence
