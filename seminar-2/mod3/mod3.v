module mod3(
    input clk,
    input in,
    input start,
    input finish,
    output reg out = 0
);

    // Внутренние регистры
    reg [1:0] mod = 2'b00;  // 2-битный регистр для хранения остатка от деления на 3
    reg active = 0;         // Флаг активности обработки
    
    always @(posedge clk) begin
        if (start) begin
            // Начало передачи - сброс состояния
            mod <= 2'b00;
            active <= 1'b1;
            out <= 1'b0;
        end
        else if (finish && active) begin
            // Конец передачи - проверка результата
            active <= 1'b0;
            out <= (mod == 2'b00) ? 1'b1 : 1'b0;
        end
        else if (active) begin
            // Обработка очередного бита
            case (mod)
                2'b00: mod <= (in == 1'b1) ? 2'b01 : 2'b00;
                2'b01: mod <= (in == 1'b1) ? 2'b11 : 2'b10;
                2'b10: mod <= (in == 1'b1) ? 2'b00 : 2'b01;
                2'b11: mod <= (in == 1'b1) ? 2'b10 : 2'b11;
            endcase
        end
    end

endmodule
