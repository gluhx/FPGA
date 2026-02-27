//подключаем необходимые файлы
`include "sequence.v"

module filter(
    input clk,
    input reset,
    input [31:0] x,
    output [31:0] y
);

//объявляем и задаём служебные регистры
reg [31:0] x_n = 32'b0;
reg [31:0] x_n_1 = 32'b0;
reg counter = 1'b0;

//объявлям и задаём служебные сигналы
wire [31:0] add_y, even_y;
wire add, even;

//подключаем модуль для вычисления чётной последовательности
sequence SEQ_ADD(
    .clk(clk),
    .reset(reset),
    .enable_start(add),
    .x_n(x_n),
    .x_n_1(x_n_1),
    .y(add_y)
);

//подключаем модуль для вычисления нечётной последовательности
sequence SEQ_EVEN(
    .clk(clk),
    .reset(reset),
    .enable_start(even),
    .x_n(x_n),
    .x_n_1(x_n_1),
    .y(even_y)
);

// подключаем сигналы друг к другу
assign add = counter ? 1'b1 : 1'b0;
assign even = counter ? 1'b0 : 1'b1;

assign y = counter ? add_y : even_y;

always @(posedge clk or negedge reset) begin 
    //проверяем reset
    if (!reset) begin 
        x_n <= 32'b0;
        x_n_1 <= 32'b0;
    end else begin 
        //первый такт
        x_n <= x;

        //второй такт
        x_n_1 <= x_n;

        //делаем счётчик
        counter <= ~counter;
    end
end

endmodule // filter
