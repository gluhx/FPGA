module SPI_slave(
    input cs,
    input sck,
    input mosi,
    output reg [7:0] cmd,
    output reg [1:0][7:0] addr,
    output reg [3:0][7:0] data,
    output reg rf // флаг наличия результата
);

// объявляем и задаём служебные регистры
reg [6:0][7:0] memory = 64'b0;
reg [2:0] counter_byte = 3'b0;
reg [2:0] counter_bit = 3'b0;

always @(posedge sck) begin 
    // проверяем CS 
    if (!cs) begin
        // записываем значение
        memory [counter_byte][counter_bit] <= mosi;

        // увеличиваем счётчики
        if ((counter_byte == 3'b110) && (counter_bit == 3'b110)) begin
            counter_byte <= 3'b0;
            counter_bit <= 3'b0;
            rf <= 1'b1;
        end else if (counter_bit <= 3'b111) begin
            counter_byte <= counter_byte +1;
            counter_bit <= 3'b0;
        end else counter_bit <= counter_bit + 1;
    end
end

//при установке флага выдаём на выход память
always @(posedge rf) begin
    cmd <= memory[0];
    addr <= memory[2:1];
    data <= memory [6:3];
    rf <= 1'b0;
end

endmodule // SPI_Slave
