module multiplication(clk, a, b, c, F);
    //входные сигналы
    input clk;
    input [7:0] a, b, c;

    //выходные сигналы
    output [15:0] F;
    reg [15:0] F;
    
    //служебные сигналы
    reg [15:0] F_1, F_2;
    reg [7:0] c_2, c_1;

    always @(posedge clk) begin
        F_2 <= a * b;
        c_2 <= c;
        F_1 <= F_2;
        c_1 <= c_2;
        F <= F_1 + c_1;
    end
endmodule // multiplication

module multiplication_c(clk, a, b, c, out);
    //входные сигнал
    input clk;
    input [7:0] a, b, c;

    //выход
    output [16:0] out;
    reg [16:0] out;

    //служебные сигналы
    wire [15:0] F;

    multiplication DD1(clk, a, b, c, F);
    
    always @(posedge clk) begin
        out <= F;
    end
endmodule // multiplication_c
