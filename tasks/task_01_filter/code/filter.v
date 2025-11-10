//подключаем необходимые файлы
`include "sequence.v"

module filter(
    input clk,
    input reset,
    input enable,
    input [7:0] x,
    output [7:0] y
);

//объявляем и задаём служебные регистры
reg [7:0] x_n = 8'b0;
reg [7:0] x_n_1 = 8'b0;

//подключаем модуль для вычисления последовательности
sequence SEQ(
    .clk(clk),
    .reset(reset),
    .enable_start(enable),
    .x_n(x_n),
    .x_n_1(x_n_1),
    .y(y)
);

always @(posedge clk or negedge reset) begin 
    //проверяем reset
    if (!reset) begin 
        x_n <= 8'b0;
        x_n_1 <= 8'b0;
    end else begin 
        //первый такт
        x_n <= x;

        //второй такт
        x_n_1 <= x_n;
    end
end

endmodule // filter
