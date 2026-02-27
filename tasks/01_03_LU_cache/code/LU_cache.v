`include "memory_cell.v"

module LU_cache #(
    parameter CELL_SIZE = 8,
    parameter CELL_COUNT = 8,
    parameter CELL_ADDR_SIZE = 3
)
(
    input clk,
    input reset,
    input [CELL_SIZE - 1:0] data_in,
    input new_data,
    output [CELL_COUNT - 1:0][CELL_SIZE - 1:0] data_out
);

//объявляем служебные сигналы
wire [CELL_ADDR_SIZE - 1:0] addr; //шина адреса
wire [CELL_COUNT - 1:0][CELL_ADDR_SIZE-1:0] addr_array;
wire eq;
wire [CELL_COUNT - 1:0] eq_array;
wire priority_wen;

//подключаем модули
genvar i;
generate 
    for (i = 0; i < CELL_COUNT; i = i + 1) begin : memory_cel_modules
        if (i == 0) begin
            memory_cell #(
                .CELL_SIZE(CELL_SIZE),
                .ADDR_SIZE(CELL_ADDR_SIZE),
                .CELL_ADDR(i)
            ) CELL (
                .clk(clk),
                .reset(reset),
                .wen(new_data),
                .priority_wen(priority_wen),
                .input_data(data_in),
                .check_data(data_in),
                .input_addr(addr),
                .eq(eq_array[i]),
                .output_addr(addr_array[i]),
                .output_data(data_out[i])
            );
        end else begin
            memory_cell #(
                .CELL_SIZE(CELL_SIZE),
                .ADDR_SIZE(CELL_ADDR_SIZE),
                .CELL_ADDR(i)
            ) CELL (
                .clk(clk),
                .reset(reset),
                .wen(new_data),
                .priority_wen(priority_wen),
                .input_data(data_out[i-1]),
                .check_data(data_in),
                .input_addr(addr),
                .eq(eq_array[i]),
                .output_addr(addr_array[i]),
                .output_data(data_out[i])
            );
        end
    end
endgenerate

//связываем нужные сигналы
assign priority_wen = (!eq & new_data) ? 1 : 0;

assign eq = |eq_array;

// Создаем блок ИЛИ для каждого бита
genvar bit_idx;
generate
    for (bit_idx = 0; bit_idx < CELL_ADDR_SIZE; bit_idx = bit_idx + 1) begin : or_bit
        // Создаем провод для всех входов ИЛИ для этого бита
        wire [CELL_COUNT-1:0] or_inputs;
        
        // Собираем значения бита от всех ячеек
        for (i = 0; i < CELL_COUNT; i = i + 1) begin : collect_bits
            assign or_inputs[i] = addr_array[i][bit_idx];
        end
        
        // Реализуем ИЛИ через побитовое ИЛИ (|)
        assign addr[bit_idx] = |or_inputs;
    end
endgenerate
endmodule // LU_cache
