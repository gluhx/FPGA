module read_agent #(
    parameter DATA_WIDTH = 8        // Ширина входных данных (в битах)
) (
    input wire clk,
    input wire a_reset_n,              // Active low reset
    
    // FIFO interface
    input wire empty,                    // FIFO empty flag
    output reg rd_en,                     // Read enable to FIFO
    input wire [DATA_WIDTH-1:0] dout,     // Data input from FIFO
    
    // Output data interface
    output reg [DATA_WIDTH-1:0] data_out, // Выходные данные
    
    // Control signal
    input wire stop                        // Сигнал остановки чтения
);

    // Флаг наличия рукопожатия
    wire handshake;
    assign handshake = rd_en & !empty;
    
    // Логика для rd_en (аналогично ready в AXI_slave)
    always @(posedge clk or negedge a_reset_n) begin
        if (!a_reset_n) begin
            rd_en <= 1'b0;
        end else begin
            // Готовы читать, если не остановлено (аналогично ~stop & reset_n)
            rd_en <= !stop & !empty;
        end
    end
    
    // Захват данных при рукопожатии (аналогично data_out в AXI_slave)
    always @(posedge clk or negedge a_reset_n) begin
        if (!a_reset_n) begin
            data_out <= {DATA_WIDTH{1'b0}};
        end else begin
            if (handshake) begin
                data_out <= dout;
            end else begin
                data_out <= {DATA_WIDTH{1'b0}};
            end
        end
    end

endmodule
