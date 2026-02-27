// задаём временную шкалу
`timescale 10 ps/ 1 ps

module axi_master_test;

//dump для GTKWAVE
initial begin
    $dumpfile("AXI_master_simulation.vcd");
    $dumpvars(0, axi_master_test);
end

//объявляем и задаём входные сигналы
reg clk = 1'b0;
always #5 clk <= ~clk;

reg reset_n = 1'b0;
reg [63:0] data_in = 64'b0;  // 64-битная входная шина
reg we = 1'b0;                // сигнал записи в буфер
reg ready = 1'b0;             // готовность приемника

// объявляем выходные сигналы
wire [7:0] data;              // выходные данные
wire valid;                   // валидность данных
wire last;                    // признак последнего байта

//подключаем модуль AXI-master
AXI_master DUT (
    .clk(clk),
    .reset_n(reset_n),
    .data(data),
    .valid(valid),
    .last(last),
    .ready(ready),
    .data_in(data_in),
    .we(we)
);

// Функция для инициализации входных данных
task init_inputs;
    begin
        reset_n = 1'b0;
        we = 1'b0;
        ready = 1'b0;
        data_in = 64'b0;
    end
endtask

// Функция для загрузки данных в буфер
task load_data;
    input [63:0] data_value;  // 64-битное значение
    begin
        @(posedge clk);
        data_in <= data_value;
        we <= 1'b1;
        @(posedge clk);
        we <= 1'b0;
        $display("Загружены данные: %h", data_value);
    end
endtask

// Функция для формирования 64-битного значения из 8 байт (порядок как в вашем коде)
// data_buff[7:0] - первый передаваемый байт (data[7:0])
// data_buff[63:56] - последний передаваемый байт
function [63:0] pack_data;
    input [7:0] b0, b1, b2, b3, b4, b5, b6, b7; // b0 - первый передаваемый байт
    begin
        pack_data = {b7, b6, b5, b4, b3, b2, b1, b0}; // b7 в старшие разряды
    end
endfunction

// Монитор для отслеживания всех сигналов
initial begin
    $monitor("At time %0t: clk=%b, reset_n=%b, data=%h, valid=%b, last=%b, ready=%b, buff_count=%d, data_buff=%h",
              $time, clk, reset_n, data, valid, last, ready, DUT.buff_count, DUT.data_buff);
end

// Генерация тестовых сигналов
initial begin
    // Инициализация
    $display("=== НАЧАЛО ТЕСТИРОВАНИЯ AXI MASTER ===");
    init_inputs();

    // Снимаем reset
    #10 reset_n = 1'b1;
    #5 ready = 1'b1;
    #5;

    // ============ ТЕСТ 1: Передача 8 байт с ready = 1 всегда ============
    $display("\n=== ТЕСТ 1: Передача 8 байт (12 34 56 78 9A BC DE F0) с ready = 1 ===");
    $display("Порядок передачи: 12 -> 34 -> 56 -> 78 -> 9A -> BC -> DE -> F0");

    // Загружаем данные: первый байт 0x12, последний 0xF0
    // В data_buff: [63:56]=F0, [55:48]=DE, [47:40]=BC, [39:32]=9A, [31:24]=78, [23:16]=56, [15:8]=34, [7:0]=12
    load_data(pack_data(8'h01, 8'h02, 8'h03, 8'h04, 
                        8'h05, 8'h06, 8'h07, 8'h08));


    // Ждем завершения передачи (8 тактов)
    #90;

    // Проверяем, что буфер опустел
    if (DUT.buff_count == 0)
        $display("ТЕСТ 1 ПРОЙДЕН: Все данные переданы");
    else
        $display("ТЕСТ 1 НЕ ПРОЙДЕН: buff_count = %d", DUT.buff_count);

    #20;

    // ============ ТЕСТ 2: Передача с прерываниями ready ============
    $display("\n=== ТЕСТ 2: Передача 8 байт (11 22 33 44 55 66 77 88) с прерываниями ready ===");

    // Загружаем данные: первый байт 0x11, последний 0x88
    load_data(pack_data(8'h11, 8'h22, 8'h33, 8'h44,
                        8'h55, 8'h66, 8'h77, 8'h88));

    // Начинаем передачу с ready = 1
    ready = 1'b1;

    // Ждем передачи 3 байт
    repeat(3) @(posedge clk);

    // Опускаем ready на 5 тактов
    $display("--- Опускаем ready в 0 на 5 тактов ---");
    ready = 1'b0;
    #50; // 5 тактов

    // Снова поднимаем ready
    $display("--- Восстанавливаем ready = 1 ---");
    ready = 1'b1;

    // Ждем завершения передачи (осталось 5 байт)
    #60;

    // Проверяем передачу последнего байта
    if (DUT.buff_count == 0)
        $display("ТЕСТ 2 ПРОЙДЕН: Все данные переданы после прерывания");
    else
        $display("ТЕСТ 2 НЕ ПРОЙДЕН: buff_count = %d", DUT.buff_count);

    #20;

    // ============ ТЕСТ 3: Проверка last ============
    $display("\n=== ТЕСТ 3: Проверка сигнала last ===");

    // Загружаем данные: 4 байта A1 B2 C3 D4, остальные 0
    load_data(pack_data(8'hA1, 8'hB2, 8'hC3, 8'hD4, 8'h00, 8'h00, 8'h00, 8'h00));

    // Начинаем передачу с ready = 1
    ready = 1'b1;

    // Отслеживаем last в течение 8 тактов
    repeat(8) begin
        @(posedge clk);
        $display("data=%h, last=%b, buff_count=%d", data, last, DUT.buff_count);
    end

    #20;

    // ============ ТЕСТ 4: Попытка записи во время передачи ============
    $display("\n=== ТЕСТ 4: Попытка записи во время передачи (we должен игнорироваться при valid=1) ===");

    // Загружаем первые данные
    load_data(pack_data(8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77, 8'h88));

    // Начинаем передачу
    ready = 1'b1;

    // Ждем передачи 2 байт
    @(posedge clk);
    @(posedge clk);

    // Пытаемся записать новые данные (должно игнорироваться, т.к. valid=1)
    $display("Попытка записи новых данных во время передачи (valid=%b)", valid);
    load_data(pack_data(8'hFF, 8'hEE, 8'hDD, 8'hCC, 8'hBB, 8'hAA, 8'h99, 8'h88));

    // Ждем завершения передачи
    #60;

    if (DUT.buff_count == 0)
        $display("ТЕСТ 4 ПРОЙДЕН: Запись во время передачи проигнорирована");
    else
        $display("ТЕСТ 4 НЕ ПРОЙДЕН: buff_count = %d", DUT.buff_count);

    #20;

    // ============ ТЕСТ 5: Сброс во время передачи ============
    $display("\n=== ТЕСТ 5: Сброс во время передачи ===");

    // Загружаем данные
    load_data(pack_data(8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77, 8'h88));

    // Начинаем передачу
    ready = 1'b1;

    // Ждем передачи нескольких байт
    #30;

    // Сбрасываем модуль
    $display("--- Сброс reset_n = 0 ---");
    reset_n = 1'b0;
    #20;

    // Проверяем состояние после сброса
    $display("После сброса: data=%h, last=%b, buff_count=%d", data, last, DUT.buff_count);

    // Восстанавливаем
    $display("--- Восстановление reset_n = 1 ---");
    reset_n = 1'b1;

    // Проверяем, что данные не передаются
    #20;

    if (DUT.buff_count == 0 && DUT.data_buff == 64'b0 && last == 1'b0)
        $display("ТЕСТ 5 ПРОЙДЕН: Сброс работает корректно");
    else
        $display("ТЕСТ 5 НЕ ПРОЙДЕН: buff_count = %d, data_buff = %h, last = %b",
                 DUT.buff_count, DUT.data_buff, last);

    #20;

    $display("\n=== ТЕСТИРОВАНИЕ ЗАВЕРШЕНО ===");

    // Завершение симуляции
    #100 $finish;
end

// Дополнительный монитор для отслеживания каждого переданного байта
always @(posedge clk) begin
    if (valid && ready) begin
        $display("ПЕРЕДАЧА: Такт %0t, data=%h, last=%b, buff_count=%d", 
                  $time, data, last, DUT.buff_count);
    end
end

endmodule
