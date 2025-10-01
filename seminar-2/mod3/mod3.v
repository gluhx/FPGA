module mod3 (
    input clk,
    input in,
    input start,
    input finish,
    output reg out,
    output reg has_result
);

reg is_transition_going = 1'b0;
reg [1:0] inter_value = 2'b0;
reg is_current_bit_odd = 1'b0;
reg has_result_delay = 1'b0;

always @ (posedge clk) begin
    if(has_result_delay) begin
        out <= (inter_value == 2'b00) ? 1 : 0;
    end else out <= 0;
    has_result <= has_result_delay;
    if(start) begin
        is_transition_going <= 1'b1;
        inter_value <= 2'b0;
        is_current_bit_odd <= 1'b0;
        has_result_delay <= 1'b0;
        has_result <= 1'b0;
        out <= 1'b0;
    end else if (finish) begin
        is_transition_going <= 1'b0;
        has_result_delay <= 1'b1;
    end

    if(is_transition_going) begin
        if(is_current_bit_odd) begin
            if (inter_value == 2'b10 && in) inter_value <= 2'b00;
            else begin
                inter_value <= inter_value + (
                    (in) ? 2'b01 : 2'b00
                 );
             end
        end else begin
             if (inter_value == 2'b00 && in) inter_value <= 2'b10;
             else begin
                 inter_value <= inter_value - (
                     (in) ? 2'b01 : 2'b00
                 );
             end
         end
         is_current_bit_odd <= ~is_current_bit_odd;
        end
    end
    endmodule // mod3

