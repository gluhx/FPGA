// задаём временную шкалу
`timescale 10 ps/ 1 ps

module FIFO_test;

//dump для GTKWAVE
initial begin
    $dumpfile("FIFO_simulation.vcd");
    $dumpvars(0, FIFO_test);
end

// Параметры
localparam DATA_WIDTH = 8;
localparam BUFFER_LENGTH = 8;  // 8 элементов в буфере
localparam DEPTH_FIFO = 4;
localparam ADDR_WIDTH = 2;

// Генерация тактовых сигналов (разные частоты для wr_clk и rd_clk)
reg wr_clk = 1'b0;
reg rd_clk = 1'b0;

// wr_clk с периодом 10 (100 MHz)
always #5 wr_clk = ~wr_clk;

// rd_clk с периодом 20 (50 MHz) - медленнее, чтобы видеть заполнение FIFO
always #10 rd_clk = ~rd_clk;

// Сброс и управляющие сигналы
reg a_reset_n = 1'b0;
reg [(BUFFER_LENGTH * DATA_WIDTH) - 1:0] data_in = 0;
reg we = 1'b0;
reg stop = 1'b0;

// Соединительные провода
wire [DATA_WIDTH-1:0] din;
wire wr_en;
wire full;
wire [DATA_WIDTH-1:0] dout;
wire rd_en;
wire empty;

// Выход read_agent
wire [DATA_WIDTH-1:0] data_out;

// Debug провода для просмотра содержимого FIFO
wire [DATA_WIDTH-1:0] debug_mem_0, debug_mem_1, debug_mem_2, debug_mem_3;

// Функция для формирования 64-битного значения из 8 байт
function [63:0] pack_data;
    input [7:0] b0, b1, b2, b3, b4, b5, b6, b7;
    begin
        pack_data = {b7, b6, b5, b4, b3, b2, b1, b0};
    end
endfunction

// Константа с тестовыми данными 0102030405060708
localparam [63:0] TEST_PACKET = pack_data(8'h01, 8'h02, 8'h03, 8'h04,
                                          8'h05, 8'h06, 8'h07, 8'h08);

// Счетчик отправленных пакетов
integer packet_counter = 0;

// Подключаем FIFO
FIFO #(
    .DEPTH_FIFO(DEPTH_FIFO),
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) fifo_inst (
    .wr_clk(wr_clk),
    .rd_clk(rd_clk),
    .a_reset_n(a_reset_n),
    .din(din),
    .wr_en(wr_en),
    .full(full),
    .dout(dout),
    .empty(empty),
    .rd_en(rd_en)
);

// Подключаем write_agent
write_agent #(
    .DATA_WIDTH(DATA_WIDTH),
    .BUFFER_LENGTH(BUFFER_LENGTH)
) write_agent_inst (
    .clk(wr_clk),
    .a_reset_n(a_reset_n),
    .full(full),
    .wr_en(wr_en),
    .din(din),
    .data_in(data_in),
    .we(we)
);

// Подключаем read_agent
read_agent #(
    .DATA_WIDTH(DATA_WIDTH)
) read_agent_inst (
    .clk(rd_clk),
    .a_reset_n(a_reset_n),
    .empty(empty),
    .rd_en(rd_en),
    .dout(dout),
    .data_out(data_out),
    .stop(stop)
);

// Подключаем debug провода к памяти FIFO
assign debug_mem_0 = fifo_inst.mem_data[0];
assign debug_mem_1 = fifo_inst.mem_data[1];
assign debug_mem_2 = fifo_inst.mem_data[2];
assign debug_mem_3 = fifo_inst.mem_data[3];

// Тестовая последовательность
initial begin
    $display("=========================================================");
    $display("=== ТЕСТИРОВАНИЕ FIFO С WRITE_AGENT И READ_AGENT ===");
    $display("=========================================================");
    $display("Параметры: DATA_WIDTH=%0d, BUFFER_LENGTH=%0d, DEPTH_FIFO=%0d",
              DATA_WIDTH, BUFFER_LENGTH, DEPTH_FIFO);
    $display("Тестовые данные: 01 02 03 04 05 06 07 08");
    $display("Частота wr_clk: 100 MHz, частота rd_clk: 50 MHz\n");

    // Сброс
    a_reset_n = 1'b0;
    we = 1'b0;
    stop = 1'b0;
    data_in = 0;
    packet_counter = 0;
    #40;

    a_reset_n = 1'b1;
    #20;

    // ПОСЫЛКА 1: Полностью без stop
    $display("\n=== ПОСЫЛКА 1: Без остановок чтения ===");
    $display("Время: %0t - Отправка пакета %0d", $time, packet_counter+1);

    data_in = TEST_PACKET;
    we = 1'b1;
    #20;
    we = 1'b0;
    packet_counter = packet_counter + 1;

    #200;  // Ждем завершения передачи
    $display("Время: %0t - Пакет %0d передан", $time, packet_counter);

    // Задержка 5 тактов wr_clk (50 времени) между посылками
    #50;


    #100 $finish;
end

// ИСПРАВЛЕННАЯ ЧАСТЬ - правильные имена сигналов
// Мониторинг сигналов write_agent и FIFO (на wr_clk)
always @(posedge wr_clk) begin
    if (we)
        $display("Время %0t (wr_clk): ЗАПИСЬ в буфер: data_in=%h (пакет %0d)",
                  $time, data_in, packet_counter);

    if (wr_en && !full)
        $display("Время %0t (wr_clk): ЗАПИСЬ в FIFO: din=%h, wr_ptr=%0d (пакет %0d)",
                  $time, din, fifo_inst.write_ptr_bin[ADDR_WIDTH-1:0], packet_counter);

    if (full)
        $display("Время %0t (wr_clk): FIFO ПОЛНОЕ (full=1) (пакет %0d)", $time, packet_counter);
end

// Мониторинг сигналов read_agent и FIFO (на rd_clk)
always @(posedge rd_clk) begin
    if (rd_en && !empty)
        $display("Время %0t (rd_clk): ЧТЕНИЕ из FIFO: dout=%h, rd_ptr=%0d, data_out=%h (пакет %0d)",
                  $time, dout, fifo_inst.read_ptr_bin[ADDR_WIDTH-1:0], data_out, packet_counter);

    if (empty && !stop)
        $display("Время %0t (rd_clk): FIFO ПУСТОЕ (empty=1) (пакет %0d)", $time, packet_counter);

    if (stop)
        $display("Время %0t (rd_clk): ЧТЕНИЕ ОСТАНОВЛЕНО (stop=1) (пакет %0d)", $time, packet_counter);
end

// Мониторинг изменения full
always @(fifo_inst.full) begin
    if (fifo_inst.full)
        $display("Время %0t: ### FIFO СТАЛО ПОЛНЫМ ### (пакет %0d)", $time, packet_counter);
end

// Мониторинг изменения empty
always @(fifo_inst.empty) begin
    if (fifo_inst.empty)
        $display("Время %0t: ### FIFO СТАЛО ПУСТЫМ ### (пакет %0d)", $time, packet_counter);
end

// Периодический вывод состояния FIFO (каждые 50 единиц времени)
always #50 begin
    $display("Время %0t: СОСТОЯНИЕ FIFO - full=%b, empty=%b, wr_ptr=%0d, rd_ptr=%0d, mem[0]=%h, mem[1]=%h, mem[2]=%h, mem[3]=%h (пакет %0d)",
              $time, fifo_inst.full, fifo_inst.empty,
              fifo_inst.write_ptr_bin[ADDR_WIDTH-1:0], fifo_inst.read_ptr_bin[ADDR_WIDTH-1:0],
              debug_mem_0, debug_mem_1, debug_mem_2, debug_mem_3, packet_counter);
end

// Мониторинг начала новой посылки
always @(posedge we) begin
    $display("==========================================");
    $display("Время %0t: НАЧАЛО ПОСЫЛКИ %0d", $time, packet_counter+1);
    $display("==========================================");
end

// Мониторинг окончания посылки (когда FIFO становится пустым после чтения)
reg last_empty_state = 1'b1;
always @(posedge rd_clk) begin
    if (last_empty_state == 1'b0 && empty == 1'b1 && packet_counter > 0) begin
        $display("==========================================");
        $display("Время %0t: ПОСЫЛКА %0d ЗАВЕРШЕНА", $time, packet_counter);
        $display("==========================================");
    end
    last_empty_state <= empty;
end

endmodule
