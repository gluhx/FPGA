// задаём временную шкалу
`timescale 10 ps/ 1 ps

module SPI_master_test;

//dump для GTKWAVE
initial begin
    $dumpfile("SPI_master_simulation.vcd");
    $dumpvars(0, SPI_master_test);
end

//объявляем и задаём входные сигналы
reg clk = 1'b0;
always #5 clk <= ~clk;

reg reset = 1'b1;

reg [7:0] data = 8'b10101010;

reg en = 1'b0;

initial begin
    #19 en = 1'b1;
    #10 en = 1'b0;
    #310 en = 1'b1;
    #10 en = 1'b0;
end

// объявляем выходные сигналы
wire sck, cs, mosi;

//подключаем модуль
SPI_master SPI_MASTER(
    .clk(clk),
    .reset(reset),
    .en_transit(en),
    .data(data),
    .sck(sck),
    .mosi(mosi),
    .cs(cs)
);

//включаем мониторнг сигналов
initial  begin
    $monitor("At time %t, en - %b, cs - %b, sck - %b, mosi - %b", $time, en, cs,sck,mosi);
    #400 $finish;
end

endmodule // SPI_master_test
