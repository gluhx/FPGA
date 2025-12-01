// задаём временную шкалу
`timescale 10 ps/ 1 ps

module memory_cell_test;

//dump для GTKWAVE
initial begin
    $dumpfile("memory_cell_simulation.vcd");
    $dumpvars(0, memory_cell_test);
end

//объявляем и задаём входные сигналы
reg clk = 1'b0;
always #5 clk <= ~clk;

reg wen = 1'b0;

reg reset = 1'b1;

reg [7:0] input_data = 8'b1111;
reg [7:0] check_data = 8'b0;
reg [7:0] addr_before = 8'b0;

always @(posedge clk) begin
    wen <= ~wen;
    input_data <= input_data - 1;
    check_data <= check_data + 1;
    addr_before <= addr_before + 1;
end


// объявляем выходные сигналы
wire eq;
wire [7:0] output_data, addr;

//подключаем модуль
memory_cell #(
    .CELL_SIZE(8),
    .CELL_ADDR(4),
    .ADDR_SIZE(8)
) CELL (
    .clk(clk),
    .reset(reset),
    .wen(wen),
    .priority_wen(wen),
    .input_data(input_data),
    .check_data(check_data),
    .input_addr(addr_before),
    .eq(eq),
    .output_addr(addr),
    .output_data(output_data)
);

//включаем мониторнг сигналов
initial  begin
    #5000 $finish;
end

endmodule // memory_cell_test
