module write_agent #(
    parameter DATA_WIDTH = 8,        // Ширина выходных данных (в битах)
    parameter BUFFER_LENGTH = 8       // Количество элементов в буфере
) (
    input wire clk,
    input wire a_reset_n,              // Active low reset

    // FIFO interface
    input wire full,                    // FIFO full flag
    output reg wr_en,                    // Write enable to FIFO
    output reg [DATA_WIDTH-1:0] din,     // Data output to FIFO (в байтах)

    // Input data interface
    input wire [(BUFFER_LENGTH * DATA_WIDTH) - 1:0] data_in,    // Входные данные для буфера
    input wire we                             // Write enable for buffer
);

// Буфер для хранения данных
reg [(DATA_WIDTH * BUFFER_LENGTH) - 1:0] data_buff;

// Указатель на текущий байт для чтения из буфера
reg [3:0] rd_ptr;  // 3 бита для значений 0-7 (для BUFFER_LENGTH=8)

// Флаг, что буфер загружен и готов к отправке
reg buffer_loaded;

// Загрузка буфера
always @(posedge clk or negedge a_reset_n) begin
    if (!a_reset_n) begin
        data_buff <= 0;
        rd_ptr <= 0;
        buffer_loaded <= 1'b0;
    end else if (we) begin
        data_buff <= data_in;
        rd_ptr <= 0;
        buffer_loaded <= 1'b1;
    end
end

// Логика wr_en
always @(posedge clk or negedge a_reset_n) begin
    if (~a_reset_n)
        wr_en <= 1'b0;
    else
        wr_en <= buffer_loaded && !full && ~we;  // Используйте неблокирующее присваивание
end

// Логика данных - ИСПРАВЛЕНО
always @(posedge clk or negedge a_reset_n) begin
    if (!a_reset_n) begin
        din <= 0;
    end else begin
        if (buffer_loaded && !full && ~we) begin
        // Используем оператор +: для переменной индексации
        din <= data_buff[rd_ptr * DATA_WIDTH +: DATA_WIDTH];
        
        // Увеличиваем указатель
        if (rd_ptr < (BUFFER_LENGTH - 1))
            rd_ptr <= rd_ptr + 1;
        else begin
            rd_ptr <= 0;
            buffer_loaded <= 1'b0;
        end
    end
        if (full && wr_en)
            rd_ptr = rd_ptr - 1;
    end
end

endmodule
