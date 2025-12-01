`include "XOR.v"
`include "NOR.v"

module memory_cell #(
    parameter CELL_SIZE = 8,
    parameter CELL_ADDR = 0,
    parameter ADDR_SIZE = 3
)(
    input clk,
    input reset,
    input wen,
    input priority_wen,
    input [CELL_SIZE - 1:0] input_data,
    input [CELL_SIZE - 1:0] check_data,
    input [ADDR_SIZE - 1:0] input_addr,
    output eq,
    output [ADDR_SIZE - 1:0] output_addr,
    output reg [CELL_SIZE - 1:0] output_data = 0
);

//объявляем и сохраняем адрес ячейки
reg [ADDR_SIZE - 1:0] cell_addr = CELL_ADDR;

//объявляем и задаём вспомагательные сигналы
wire [CELL_SIZE - 1:0] temp_data;

XOR #(
    .WIDTH(CELL_SIZE)
) DD1 (
    .in_1(check_data),
    .in_2(output_data),
    .out(temp_data)
);

NOR #(
    .WIDTH(CELL_SIZE)
) DD2 (
    .in(temp_data),
    .out(eq)
);

//передача адреса
assign output_addr = eq ? cell_addr : 0;

always @(posedge clk or negedge reset) begin 
    //проверяем reset
    if (!(reset)) output_data <= 0;
    else if (((wen) && (cell_addr <= input_addr)) || priority_wen) output_data <= input_data; 
end

endmodule // memory_cell
