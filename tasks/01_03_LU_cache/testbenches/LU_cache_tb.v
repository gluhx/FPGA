// задаём временную шкалу
`timescale 10 ps/ 1 ps

module LU_cache_test;

//dump для GTKWAVE
initial begin
    $dumpfile("LU_cache_simulation.vcd");
    $dumpvars(0, LU_cache_test);
end

//объявляем и задаём входные сигналы
reg clk = 1'b0;
always #5 clk <= ~clk;


reg reset = 1'b1;
reg new_data = 1'b0;

reg [7:0] x = 275;
initial begin
    #5 x = 9;
    new_data = 1'b1;
    #1 new_data = 1'b0;
    #9 x = 1;
    new_data = 1'b1;
    #1 new_data = 1'b0;
    #9 x = 2;
    new_data = 1'b1;
    #1 new_data = 1'b0;
    #9 x = 4;
    new_data = 1'b1;
    #1 new_data = 1'b0;
    #9 x = 5;
    new_data = 1'b1;
    #1 new_data = 1'b0;
    #9 x = 6;
    new_data = 1'b1;
    #1 new_data = 1'b0;
    #9 x = 7;
    new_data = 1'b1;
    #1 new_data = 1'b0;
    #9 x = 8;
    new_data = 1'b1;
    #1 new_data = 1'b0;
    #9 x = 1;
    new_data = 1'b1;
    #1 new_data = 1'b0;
    #9 x = 5;
    new_data = 1'b1;
    #1 new_data = 1'b0;
    #19 x = 9;
    new_data = 1'b1;
    #1 new_data = 1'b0;
    #9 x = 3;
    new_data = 1'b1;
    #1 new_data = 1'b0;
    #9 x = 7;
    new_data = 1'b1;
    #1 new_data = 1'b0;
end

// объявляем выходные сигналы
wire [7:0][7:0] output_data;

//подключаем модуль
LU_cache #(
    .CELL_SIZE(8),
    .CELL_COUNT(8),
    .CELL_ADDR_SIZE(3)
) CACHE (
    .clk(clk),
    .reset(reset),
    .data_in(x),
    .new_data(new_data),
    .data_out(output_data)
);

//включаем мониторнг сигналов
initial  begin
    #5000 $finish;
end

endmodule // memory_cell_test
