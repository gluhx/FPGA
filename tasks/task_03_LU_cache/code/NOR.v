module NOR #(
    parameter WIDTH = 8
)(
    input [WIDTH - 1:0] in,
    output out 
);

assign out = ~(|in) ? 1 : 0;

endmodule // NOR
