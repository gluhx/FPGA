//подключаем необходимые модули
`include "mult_2t.v"

module sequence(
    input clk,
    input reset,
    input enable_start,
    input [31:0] x_n,
    input [31:0] x_n_1,
    output reg [31:0] y = 32'b0
);

// объявляем и задаём постоянные
parameter [31:0] a = 32'b10;
parameter [31:0] b = 32'b11;
parameter [31:0] aa = a * a;
parameter [31:0] ab = a * b;

//объявляем и задаём служебные сигналы
wire [2:0][31:0] mult_result;
wire [31:0] temp_y;

//подключаем модуль для расчёта a**2 * y_n-2
mult_2t MULT_AAY(
    .clk(clk),
    .reset(reset),
    .enable(enable_start),
    .multipliable_1(aa),
    .multipliable_2(temp_y),
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

assign temp_y = mult_result[0] + mult_result[1] + mult_result[2];

always @(posedge clk or negedge reset) begin 
    //проверяем reset
    if (!reset) y <= 32'b0;
    else y <= temp_y;
end

endmodule // sequence
