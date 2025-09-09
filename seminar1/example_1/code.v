module counter(clk, x_in, out0, out1, out2);
    input clk, x_in;
    output out0, out1, out2;
    reg out0, out1, out2;
    reg [1:0] state=0;

    always @(posedge clk) begin
        out0 <= x_in & (state == 0);
        out1 <= x_in & (state == 1);
        out2 <= x_in & (state == 2);

        if (x_in) 
            if (state == 2)
                state <= 0;
            else
                state = state +1;
    end

endmodule // counter
