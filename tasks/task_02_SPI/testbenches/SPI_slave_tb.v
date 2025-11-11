// задаём временную шкалу
`timescale 10 ps/ 1 ps

module SPI_slave_test;

//dump для GTKWAVE
initial begin
    $dumpfile("SPI_slave_simulation.vcd");
    $dunpvars(0, SPI_slave_test);
end

//объявляем и задаём входные сигналы
reg mosi = 1'b1;
reg cs = 1'b1;
reg sck = 
