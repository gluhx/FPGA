// задаём временную шкалу
`timescale 10 ps/ 1 ps

module AXI_stream_test;

//dump для GTKWAVE
initial begin
    $dumpfile("AXI_stream_simulation.vcd");
    $dumpvars(0, AXI_stream_test);
end

//объявляем и задаём входные сигналы
reg clk = 1'b0;
always #5 clk <= ~clk;

reg reset_n = 1'b0;
reg [63:0] data_in = 64'b0;  // 64-битная входная шина
reg we = 1'b0;                // сигнал записи в буфер master
reg stop = 1'b0;              // сигнал остановки slave

// объявляем провода для связи между модулями
wire [7:0] data;              // данные от master к slave
wire valid;                   // валидность данных от master
wire last;                    // признак последнего байта от master
wire ready;                   // готовность slave

// выход slave
wire [7:0] data_out;          // данные на выходе slave

//подключаем модуль AXI-master
AXI_master master (
    .clk(clk),
    .reset_n(reset_n),
    .data(data),
    .valid(valid),
    .last(last),
    .ready(ready),
    .data_in(data_in),
    .we(we)
);

//подключаем модуль AXI-slave
AXI_slave slave (
    .clk(clk),
    .reset_n(reset_n),
    .data(data),
    .valid(valid),
    .last(last),
    .ready(ready),
    .data_out(data_out),
    .stop(stop)
);

// Функция для инициализации входных данных
task init_inputs;
    begin
        reset_n = 1'b0;
        we = 1'b0;
        stop = 1'b0;
        data_in = 64'b0;
    end
endtask

// Функция для загрузки данных в буфер master
task load_data;
    input [63:0] data_value;  // 64-битное значение
    begin
        @(posedge clk);
        data_in <= data_value;
        we <= 1'b1;
        @(posedge clk);
        we <= 1'b0;
        $display("Загружены данные в master: %h", data_value);
    end
endtask

// Функция для формирования 64-битного значения из 8 байт
// Порядок: первый передаваемый байт - младший байт (data[7:0])
function [63:0] pack_data;
    input [7:0] b0, b1, b2, b3, b4, b5, b6, b7; // b0 - первый передаваемый байт
    begin
        pack_data = {b7, b6, b5, b4, b3, b2, b1, b0};
    end
endfunction

// Монитор для отслеживания всех сигналов
initial begin
    $monitor("At time %0t: clk=%b, reset_n=%b, data=%h, valid=%b, last=%b, ready=%b, data_out=%h, stop=%b, master_buff_count=%d, master_data_buff=%h",
              $time, clk, reset_n, data, valid, last, ready, data_out, stop, master.buff_count, master.data_buff);
end

// Проверка переданных данных на выходе slave
integer i;
reg [7:0] expected_data [0:7];
reg [63:0] test_packet;

initial begin
    // Формируем тестовый пакет 0102030405060708
    // Первый байт: 01, последний: 08
    test_packet = pack_data(8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07, 8'h08);
    
    // Ожидаемые данные по порядку
    expected_data[0] = 8'h01;
    expected_data[1] = 8'h02;
    expected_data[2] = 8'h03;
    expected_data[3] = 8'h04;
    expected_data[4] = 8'h05;
    expected_data[5] = 8'h06;
    expected_data[6] = 8'h07;
    expected_data[7] = 8'h08;
    
    // Инициализация
    $display("=== НАЧАЛО ТЕСТИРОВАНИЯ AXI STREAM ===");
    $display("Тестовый пакет: 01 02 03 04 05 06 07 08\n");
    init_inputs();

    // Снимаем reset
    #10 reset_n = 1'b1;
    #5;

    // ============ ТЕСТ 1: Обычная передача ============
    $display("=== ТЕСТ 1: Обычная передача пакета 0102030405060708 ===");
    $display("Порядок передачи: 01 -> 02 -> 03 -> 04 -> 05 -> 06 -> 07 -> 08");

    // Загружаем данные в master
    load_data(test_packet);

    // Ждем завершения передачи (8 тактов + запас)
    #100;

    // Проверяем, что буфер master опустел
    if (master.buff_count == 0)
        $display("ТЕСТ 1: master.buff_count = 0 - OK");
    else
        $display("ТЕСТ 1: master.buff_count = %d - ОШИБКА", master.buff_count);

    #20;

    // ============ ТЕСТ 2: Передача прерывается сигналом stop ============
    $display("\n=== ТЕСТ 2: Передача с прерыванием от slave (stop) ===");

    // Загружаем данные
    load_data(test_packet);

    // Ждем передачи 3 байт
    repeat(3) @(posedge clk);

    // Активируем stop на 5 тактов
    $display("--- Активируем stop = 1 на 5 тактов ---");
    stop = 1'b1;
    #50; // 5 тактов

    // Деактивируем stop
    $display("--- Деактивируем stop = 0 ---");
    stop = 1'b0;

    // Ждем завершения передачи
    #60;

    if (master.buff_count == 0)
        $display("ТЕСТ 2: master.buff_count = 0 после stop - OK");
    else
        $display("ТЕСТ 2: master.buff_count = %d после stop - ОШИБКА", master.buff_count);

    #20;

    // ============ ТЕСТ 3: Передача прерывается записью новых данных в master ============
    $display("\n=== ТЕСТ 3: Передача прерывается записью новых данных в master ===");

    // Загружаем первые данные
    load_data(test_packet);

    // Ждем передачи 2 байт
    @(posedge clk);
    @(posedge clk);

    // Пытаемся записать новые данные во время передачи
    $display("Попытка записи новых данных во время передачи (valid=%b, ready=%b)", valid, ready);
    load_data(pack_data(8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07, 8'h08));

    // Ждем завершения передачи
    #80;

    if (master.buff_count == 0)
        $display("ТЕСТ 3: master.buff_count = 0 после записи - OK (запись проигнорирована)");
    else
        $display("ТЕСТ 3: master.buff_count = %d после записи - ОШИБКА", master.buff_count);

    #20;

    // ============ ТЕСТ 4: Передача прерывается сбросом ============
    $display("\n=== ТЕСТ 4: Передача прерывается сбросом (reset_n) ===");

    // Загружаем данные
    load_data(test_packet);

    // Ждем передачи 3 байт
    repeat(3) @(posedge clk);

    // Сбрасываем модули
    $display("--- Сброс reset_n = 0 на 3 такта ---");
    reset_n = 1'b0;
    #30;

    // Проверяем состояние после сброса
    $display("После сброса: master.data_buff=%h, master.buff_count=%d, data_out=%h", 
             master.data_buff, master.buff_count, data_out);

    // Восстанавливаем
    $display("--- Восстановление reset_n = 1 ---");
    reset_n = 1'b1;

    // Проверяем, что данные не передаются и буферы сброшены
    #20;

    if (master.buff_count == 0 && master.data_buff == 64'b0 && data_out == 8'b0)
        $display("ТЕСТ 4: Сброс работает корректно - OK");
    else
        $display("ТЕСТ 4: ОШИБКА - buff_count=%d, data_buff=%h, data_out=%h", 
                 master.buff_count, master.data_buff, data_out);

    #20;

    // ============ ТЕСТ 5: Проверка данных на выходе slave ============
    $display("\n=== ТЕСТ 5: Проверка данных на выходе slave ===");

    // Загружаем данные
    load_data(test_packet);

    // Сбрасываем счетчик для проверки
    i = 0;

    // Ждем 8 тактов передачи и проверяем выходные данные
    repeat(8) begin
        @(posedge clk);
        if (valid && ready) begin
            if (data_out === expected_data[i]) begin
                $display("Байт %d: ожидалось %h, получено %h - OK", 
                         i+1, expected_data[i], data_out);
            end else begin
                $display("Байт %d: ОШИБКА - ожидалось %h, получено %h", 
                         i+1, expected_data[i], data_out);
            end
            i = i + 1;
        end
    end

    if (i == 8)
        $display("ТЕСТ 5: Все 8 байт переданы корректно - OK");
    else
        $display("ТЕСТ 5: ОШИБКА - передано только %d байт", i);

    #20;

    // ============ Дополнительная проверка сигнала last ============
    $display("\n=== Дополнительная проверка: Сигнал last ===");

    // Загружаем данные
    load_data(test_packet);

    // Отслеживаем last
    repeat(9) begin
        @(posedge clk);
        if (valid && ready) begin
            $display("data=%h, last=%b, master.buff_count=%d", data, last, master.buff_count);
        end
    end

    #20;

    $display("\n=== ТЕСТИРОВАНИЕ AXI STREAM ЗАВЕРШЕНО ===");

    // Завершение симуляции
    #100 $finish;
end

// Монитор для отслеживания каждого переданного байта
always @(posedge clk) begin
    if (valid && ready) begin
        $display("ПЕРЕДАЧА: Такт %0t, data=%h, data_out=%h, last=%b, master.buff_count=%d",
                  $time, data, data_out, last, master.buff_count);
    end
end

// Проверка сигнала last
always @(posedge clk) begin
    if (valid && ready && last) begin
        $display("LAST DETECTED: Такт %0t, это последний байт пакета", $time);
    end
end

endmodule
