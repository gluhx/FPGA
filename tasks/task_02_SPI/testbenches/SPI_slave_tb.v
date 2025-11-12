//подключаем модуль master
`include "SPI_master.v"

// задаём временную шкалу
`timescale 10 ps/ 1 ps

module SPI_slave_test;

//dump для GTKWAVE
initial begin
    $dumpfile("SPI_slave_simulation.vcd");
    $dumpvars(0, SPI_slave_test);
end

//объявляем и задаём входные сигналы
reg clk = 1'b0;
always #5 clk <= ~clk;

reg reset = 1'b1;

reg [7:0] data = 8'b10101010;
initial begin 
    #1200 data = 8'b10000001;
end

reg en = 1'b0;
initial begin
    #19 en = 1'b1;
    #1150 en = 1'b0;
    #150 en = 1'b1;
    #30 en = 1'b0;
    #500 en = 1'b1;
end

// объявляем связывающие сигналы
wire sck, cs, mosi;

// объявляем выходные сигналы
wire [7:0] cmd;
wire [1:0][7:0] addr;
wire [3:0][7:0] data_out;
wire rf;

//подключаем модуль master
SPI_master SPI_MASTER(
    .clk(clk),
    .reset(reset),
    .en_transit(en),
    .data(data),
    .sck(sck),
    .mosi(mosi),
    .cs(cs)
);

//подключаем модул slave 
SPI_slave SPI_Slave(
    .cs(cs),
    .sck(sck),
    .mosi(mosi),
    .cmd(cmd),
    .addr(addr),
    .data(data_out)
);

//включаем мониторнг сигналов
initial  begin
    $monitor("At time %t, cs - %b, sck - %b, mosi - %b, outputs - %b, %b, %b, %b", $time, en, cs, sck, mosi, cmd, addr, data_out, rf);
    #5000 $finish;
end

endmodule // SPI_master_test
