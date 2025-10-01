module mult(
    input clk,
    input reset,
    input [31:0] multipliable_1,
    input [31:0] multipliable_2,
    output reg [31:0] composition = 31'b0
);

reg [1:0][31:0] multipliables = 64'b0;

    always @(posedge clk) begin
        //checking reset
        if(!(reset)) begin 
            composition <= 31'b0;
            multipliables <= 64'b0;
        end
        else begin
            //first step of multiplication
            multipliables[0] <= multipliable_1;
            multipliables[1] <= multipliable_2;

            //second step of multiplication
            composition <= multipliables[0] * multipliables[1];
        end
    end
endmodule // mult

module addition(
    input [31:0] terms_1, 
    input [31:0] terms_2,
    output [31:0] additional_result
);

    assign additional_result = terms_1 + terms_2;

endmodule //addition

module filter(
    input clk,
    input reset,
    input [7:0] x,
    output [31:0] y
);

    //declare the coefficient
    reg [31:0] a = 2;
    reg [31:0] b = 3;

    //declare service signals

    //declare signal for multiplication bloks
    wire [1:0][31:0] mult_ay_input;
    wire [31:0] mult_ay_output;
    wire [1:0][31:0] mult_bx_input;
    wire [31:0] mult_bx_output;

    //link the multiplication signals
    assign mult_ay_input[0] = a;
    assign mult_ay_input[1] = y;

    assign mult_bx_input[0] = b;
    assign mult_bx_input[1] = x;

    //declare multiplication blocks
    mult MULT_AY(clk, reset, mult_ay_input[0], mult_ay_input[1], mult_ay_output);
    mult MULT_BX(clk, reset, mult_bx_input[0], mult_bx_input[1], mult_bx_output);

    //declare the additional block
    addition ADD(mult_ay_output, mult_bx_output, y);
endmodule // filter
