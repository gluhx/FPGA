module decoder(X, Y);
    //объявляем входы
    input [2:0] X;

    //объявляем выходы
    output [7:0] Y;

    assign Y = 8'b00000001 << X;


endmodule // decoder