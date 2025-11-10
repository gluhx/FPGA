// Умножитель с задержкой 2 такта
module mult_2t (
    input clk,
    input reset,
    input enable,
    input [7:0] multipliable_1,
    input [7:0] multipliable_2,
    output reg [7:0] mult_result = 8'b0
);
    reg [31:0] mult_delay = 8'b0;

    always @(posedge clk or negedge reset) begin
        // проверяем reset
        if (!reset) begin
            mult_delay <= 0;
            mult_result <= 0;
        end else begin
            // проверяем сигнал разрешения
            if (enable) begin
                // первый такт
                mult_delay <= multipliable_1 * multipliable_2;
            end                
            
            // второй такт
            mult_result <= mult_delay;
        end
    end
endmodule // mult_2t
