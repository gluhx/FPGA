module XOR #(
    parameter WIDTH = 8
)
(
    input [WIDTH - 1:0] in_1,
    input [WIDTH - 1:0] in_2,
    output [WIDTH - 1:0] out
);

assign out = in_1 ^ in_2;

endmodule // XOR
