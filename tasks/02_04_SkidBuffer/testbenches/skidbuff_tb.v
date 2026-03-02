// задаём временную шкалу
`timescale 10 ps/ 1 ps

module skidbuff_test;

//dump для GTKWAVE
initial begin
    $dumpfile("skidbuff_simulation.vcd");
    $dumpvars(0, skidbuff_test);
end

//объявляем и задаём входные сигналы
reg clk = 1'b0;
always #5 clk <= ~clk;

reg reset_n = 1'b0;
reg [63:0] data_in = 64'b0;  // 64-битная входная шина
reg we = 1'b0;                // сигнал записи в буфер master
reg stop = 1'b0;              // сигнал остановки slave

// провода для связи master -> skidbuff
wire [7:0] s_data;
wire s_valid;
wire s_last;
wire s_ready;

// провода для связи skidbuff -> slave
wire [7:0] m_data;
wire m_valid;
wire m_last;
wire m_ready;

// выход slave
wire [7:0] data_out;

//подключаем модуль AXI-master
AXI_master master (
    .clk(clk),
    .reset_n(reset_n),
    .data(s_data),
    .valid(s_valid),
    .last(s_last),
    .ready(s_ready),
    .data_in(data_in),
    .we(we)
);

//подключаем модуль skid buffer
skid_buff skid (
    .clk(clk),
    .reset_n(reset_n),
    .s_data(s_data),
    .s_valid(s_valid),
    .s_last(s_last),
    .s_ready(s_ready),
    .m_data(m_data),
    .m_valid(m_valid),
    .m_last(m_last),
    .m_ready(m_ready)
);

//подключаем модуль AXI-slave
AXI_slave slave (
    .clk(clk),
    .reset_n(reset_n),
    .data(m_data),
    .valid(m_valid),
    .last(m_last),
    .ready(m_ready),
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

// Проверка переданных данных на выходе slave
integer i;
reg [7:0] expected_data [0:7];
reg [63:0] test_packet;

// Тестовые сценарии
integer test_num;

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
    $display("=========================================================");
    $display("=== ТЕСТИРОВАНИЕ AXI STREAM С SKID BUFFER ===");
    $display("=========================================================");
    $display("Тестовый пакет: 01 02 03 04 05 06 07 08\n");
    init_inputs();

    // Снимаем reset
    #10 reset_n = 1'b1;
    #5;

    // ============ ТЕСТ 1: Посылка полностью без прерываний ============
    test_num = 1;
    $display("\n=== ТЕСТ %0d: Посылка полностью без прерываний ===", test_num);

    // Загружаем данные в master
    load_data(test_packet);

    // Ждем завершения передачи
    #100;

    // Проверяем, что буфер master опустел
    if (master.buff_count == 0)
        $display("ТЕСТ %0d: master.buff_count = 0 - OK", test_num);
    else
        $display("ТЕСТ %0d: master.buff_count = %d - ОШИБКА", test_num, master.buff_count);

    #20;

    // ============ ТЕСТ 2: Посылка прерывается перед 4 байтом ============
    test_num = 2;
    $display("\n=== ТЕСТ %0d: Посылка прерывается перед 4 байтом ===", test_num);

    // Загружаем данные
    load_data(test_packet);

    // Передаем 3 байта
    repeat(3) @(posedge clk);

    // Прерываем перед четвертым байтом
    $display("--- Активируем stop = 1 перед четвертым байтом ---");
    stop = 1'b1;
    #20; // 2 такта

    // Деактивируем stop
    $display("--- Деактивируем stop = 0 ---");
    stop = 1'b0;

    // Ждем завершения передачи
    #80;

    if (master.buff_count == 0)
        $display("ТЕСТ %0d: master.buff_count = 0 после прерывания - OK", test_num);
    else
        $display("ТЕСТ %0d: master.buff_count = %d после прерывания - ОШИБКА", test_num, master.buff_count);

    #20;

    // ============ ТЕСТ 3: Посылка прерывается перед 5 байтом ============
    test_num = 3;
    $display("\n=== ТЕСТ %0d: Посылка прерывается перед 5 байтом ===", test_num);

    // Загружаем данные
    load_data(test_packet);

    // Передаем 4 байта
    repeat(4) @(posedge clk);

    // Прерываем перед пятым байтом
    $display("--- Активируем stop = 1 перед пятым байтом ---");
    stop = 1'b1;
    #20; // 2 такта

    // Деактивируем stop
    $display("--- Деактивируем stop = 0 ---");
    stop = 1'b0;

    // Ждем завершения передачи
    #60;

    if (master.buff_count == 0)
        $display("ТЕСТ %0d: master.buff_count = 0 после прерывания - OK", test_num);
    else
        $display("ТЕСТ %0d: master.buff_count = %d после прерывания - ОШИБКА", test_num, master.buff_count);

    #20;

    // ============ ТЕСТ 4: Посылка прерывается перед 6 байтом ============
    test_num = 4;
    $display("\n=== ТЕСТ %0d: Посылка прерывается перед 6 байтом ===", test_num);

    // Загружаем данные
    load_data(test_packet);

    // Передаем 5 байт
    repeat(5) @(posedge clk);

    // Прерываем перед шестым байтом
    $display("--- Активируем stop = 1 перед шестым байтом ---");
    stop = 1'b1;
    #20; // 2 такта

    // Деактивируем stop
    $display("--- Деактивируем stop = 0 ---");
    stop = 1'b0;

    // Ждем завершения передачи
    #60;

    if (master.buff_count == 0)
        $display("ТЕСТ %0d: master.buff_count = 0 после прерывания - OK", test_num);
    else
        $display("ТЕСТ %0d: master.buff_count = %d после прерывания - ОШИБКА", test_num, master.buff_count);

    #20;

    // ============ ТЕСТ 5: Посылка прерывается перед 7 байтом ============
    test_num = 5;
    $display("\n=== ТЕСТ %0d: Посылка прерывается перед 7 байтом ===", test_num);

    // Загружаем данные
    load_data(test_packet);

    // Передаем 6 байт
    repeat(6) @(posedge clk);

    // Прерываем перед седьмым байтом
    $display("--- Активируем stop = 1 перед седьмым байтом ---");
    stop = 1'b1;
    #20; // 2 такта

    // Деактивируем stop
    $display("--- Деактивируем stop = 0 ---");
    stop = 1'b0;

    // Ждем завершения передачи
    #60;

    if (master.buff_count == 0)
        $display("ТЕСТ %0d: master.buff_count = 0 после прерывания - OK", test_num);
    else
        $display("ТЕСТ %0d: master.buff_count = %d после прерывания - ОШИБКА", test_num, master.buff_count);

    #20;

    // ============ ТЕСТ 6: Посылка прерывается перед 8 байтом ============
    test_num = 6;
    $display("\n=== ТЕСТ %0d: Посылка прерывается перед 8 байтом ===", test_num);

    // Загружаем данные
    load_data(test_packet);

    // Передаем 7 байт
    repeat(7) @(posedge clk);

    // Прерываем перед восьмым байтом
    $display("--- Активируем stop = 1 перед восьмым байтом ---");
    stop = 1'b1;
    #20; // 2 такта

    // Деактивируем stop
    $display("--- Деактивируем stop = 0 ---");
    stop = 1'b0;

    // Ждем завершения передачи
    #60;

    if (master.buff_count == 0)
        $display("ТЕСТ %0d: master.buff_count = 0 после прерывания - OK", test_num);
    else
        $display("ТЕСТ %0d: master.buff_count = %d после прерывания - ОШИБКА", test_num, master.buff_count);

    #20;

    // ============ ТЕСТ 7: Два прерывания после 2-го байта ============
    test_num = 7;
    $display("\n=== ТЕСТ %0d: Два прерывания после 2-го байта ===", test_num);

    // Загружаем данные
    load_data(test_packet);

    // Передаем 2 байта без прерываний
    repeat(2) @(posedge clk);
    $display("--- Передано 2 байта ---");

    // Первое прерывание
    $display("--- Активируем stop = 1 (первое прерывание) ---");
    stop = 1'b1;
    @(posedge clk);
    
    $display("--- Деактивируем stop = 0 ---");
    stop = 1'b0;
    @(posedge clk);

    // Второе прерывание
    $display("--- Активируем stop = 1 (второе прерывание) ---");
    stop = 1'b1;
    @(posedge clk);
    
    $display("--- Деактивируем stop = 0 ---");
    stop = 1'b0;
    @(posedge clk);

    // Ждем завершения передачи
    $display("--- Продолжаем прием до конца ---");
    #60;

    if (master.buff_count == 0)
        $display("ТЕСТ %0d: master.buff_count = 0 после прерываний - OK", test_num);
    else
        $display("ТЕСТ %0d: master.buff_count = %d после прерываний - ОШИБКА", test_num, master.buff_count);

    #20;

    // ============ Проверка целостности данных после теста 7 ============
    $display("\n=== Проверка целостности данных после теста 7 ===");

    // Загружаем данные еще раз для проверки
    load_data(test_packet);

    i = 0;
    while (i < 8) begin
        @(posedge clk);
        if (m_valid && m_ready) begin
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
        $display("Проверка данных: Все 8 байт переданы корректно - OK");
    else
        $display("Проверка данных: ОШИБКА - передано только %d байт", i);

    #20;

    $display("\n=========================================================");
    $display("=== ТЕСТИРОВАНИЕ AXI STREAM С SKID BUFFER ЗАВЕРШЕНО ===");
    $display("=========================================================");

    // Завершение симуляции
    #100 $finish;
end

// Детальный монитор для отслеживания каждого переданного байта
always @(posedge clk) begin
    if (s_valid && s_ready) begin
        $display("MASTER->SKID: Такт %0t, data=%h, last=%b, buff_count=%d",
                  $time, s_data, s_last, master.buff_count);
    end

    if (m_valid && m_ready) begin
        $display("SKID->SLAVE:  Такт %0t, data=%h, last=%b, data_out=%h",
                  $time, m_data, m_last, data_out);
    end
end

// Проверка сигнала last
always @(posedge clk) begin
    if (m_valid && m_ready && m_last) begin
        $display("LAST DETECTED: Такт %0t, последний байт пакета принят slave", $time);
    end
end

// Проверка состояния skid buffer при изменении stop
always @(stop) begin
    $display("СТОП ИЗМЕНЕН: Такт %0t, stop = %b", $time, stop);
end

endmodule
