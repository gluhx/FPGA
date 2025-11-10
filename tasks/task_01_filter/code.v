// Умножитель с задержкой 2 такта
module mult_2clk (
    input clk,
    input reset,
    input [31:0] op1,
    input [31:0] op2,
    output reg [31:0] result
);
    reg [31:0] stage1;

    always @(posedge clk) begin
        if (!reset) begin
            stage1 <= 0;
            result <= 0;
        end else begin
            stage1 <= op1 * op2;
            result <= stage1;
        end
    end
endmodule

// Основной фильтр
module filter (
    input clk,
    input reset,
    input [7:0] x_in,
    output reg [31:0] y_out
);

    wire [31:0] x = {24'b0, x_in};

    // Регистры для хранения предыдущих значений
    reg [31:0] x_d1;  // x[n-1]
    reg [31:0] y_d1;  // y[n-1]

    // Константы
    localparam [31:0] A = 32'd2;
    localparam [31:0] B = 32'd3;

    // Провода для умножителей
    wire [31:0] ay;  // a * y[n-1]
    wire [31:0] bx;  // b * x[n]

    // Умножители
    mult_2clk m_ay (.clk(clk), .reset(reset), .op1(A), .op2(y_d1), .result(ay));
    mult_2clk m_bx (.clk(clk), .reset(reset), .op1(B), .op2(x),     .result(bx));

    // Счётчик для управления начальными условиями
    reg [1:0] state = 2'b00;

    always @(posedge clk) begin
        if (!reset) begin
            x_d1 <= 0;
            y_d1 <= 0;
            y_out <= 0;
            state <= 2'b00;
        end else begin
            // Обновляем регистры
            x_d1 <= x;
            y_d1 <= y_out;

            case (state)
                2'b00: begin  // y0 = 0
                    y_out <= 0;
                    state <= 2'b01;
                end
                2'b01: begin  // y1 = a*y0 + b*x1 = 0 + b*x1
                    y_out <= 0;  // заглушка, потому что y1 будет готов в следующем такте
                    state <= 2'b10;
                end
                2'b10: begin  // y2 = a*y1 + b*x2
                    y_out <= 0;  // заглушка, потому что y1 ещё не готов
                    state <= 2'b11;
                end
                2'b11: begin  // y3 = a*y2 + b*x3, и т.д.
                    y_out <= ay + bx;
                end
            endcase
        end
    end

endmodule
