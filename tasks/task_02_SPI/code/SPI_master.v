module SPI_master(
    input clk, 
    input reset,
    input en_transit,
    input [7:0] data,
    output reg sck = 1'b1,
    output reg mosi = 1'b1,
    output reg cs = 1'b1
);

// объявляем и задаём слкжебные регистры
reg [7:0] memory = 8'b0;
reg flag_transit =1'b0;
reg [2:0] counter_bit = 3'b111;

always @(posedge clk or negedge reset) begin
    //проверяем reset
    if (!reset) begin
        memory <= 8'b0;
        flag_transit <=1'b0;
        counter_bit <= 3'b111;
        sck <= 1'b1;
        mosi <= 1'b1;
        cs <= 1'b1;
    end else begin
        // если пришёл сигнал разрешения передачи - устанавливаем флаг
        if ((en_transit) && (!flag_transit)) begin 
            flag_transit <= 1'b1;
            cs <= 1'b0;
            sck <= 1'b0;
            mosi <= 1'b0;
            memory <= data;
        end else begin
            // если установлен флаг, начинаем тактировать sck
            if (flag_transit) begin
                sck <= ~sck;
                // начинаем передачу
                if (!sck) begin
                    mosi <= memory[counter_bit];

                    //проверяем счётчик бита
                    if (counter_bit == 3'b0) begin
                        flag_transit <= 1'b0;
                        counter_bit <= 3'b111;
                    end else counter_bit <= counter_bit - 1;
                end
            end else begin
                sck <= 1'b1;
                mosi <=1'b1;
                cs <= 1'b1;
            end
        end
    end
end

endmodule // SPI_master
