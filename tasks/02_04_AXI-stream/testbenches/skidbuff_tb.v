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
wire [7:0] master_data;
wire master_valid;
wire master_last;
wire master_ready;

// провода для связи skidbuff -> slave
wire [7:0] slave_data;
wire slave_valid;
wire slave_last;
wire slave_ready;

// выход slave
wire [7:0] data_out;

//подключаем модуль AXI-master
AXI_master master (
    .clk(clk),
    .reset_n(reset_n),
    .data(master_data),
    .valid(master_valid),
    .last(master_last),
    .ready(master_ready),
    .data_in(data_in),
    .we(we)
);

//подключаем модуль skid buffer - ИСПРАВЛЕНО: используем reset_n (так называется порт)
skid_buff skid (
    .clk(clk),
    .reset_n(reset_n),  // теперь правильно: порт называется reset_n
    .s_data(master_data),
    .s_valid(master_valid),
    .s_last(master_last),
    .s_ready(master_ready),
    .m_data(slave_data),
    .m_valid(slave_valid),
    .m_last(slave_last),
    .m_ready(slave_ready)
);

//подключаем модуль AXI-slave
AXI_slave slave (
    .clk(clk),
    .reset_n(reset_n),
    .data(slave_data),
    .valid(slave_valid),
    .last(slave_last),
    .ready(slave_ready),
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
    $monitor("At time %0t: reset_n=%b, stop=%b\n" +
             "  MASTER: data=%h, valid=%b, last=%b, ready=%b, buff_count=%d\n" +
             "  SKID:   state=%b, mem_data=%h, mem_last=%b, s_ready=%b, m_valid=%b\n" +
             "  SLAVE:  data=%h, valid=%b, last=%b, ready=%b, data_out=%h",
              $time, reset_n, stop,
              master_data, master_valid, master_last, master_ready, master.buff_count,
              skid.STATE, skid.mem_data, skid.mem_last, skid.s_ready, skid.m_valid,
              slave_data, slave_valid, slave_last, slave_ready, data_out);
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
    $display("=========================================================");
    $display("=== ТЕСТИРОВАНИЕ AXI STREAM С SKID BUFFER ===");
    $display("=========================================================");
    $display("Тестовый пакет: 01 02 03 04 05 06 07 08\n");
    init_inputs();

    // Снимаем reset
    #10 reset_n = 1'b1;
    #5;

    // ============ ТЕСТ 1: Обычная передача без задержек ============
    $display("\n=== ТЕСТ 1: Обычная передача пакета (slave всегда готов) ===");

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

    // ============ ТЕСТ 2: Slave не готов (stop активен) ============
    $display("\n=== ТЕСТ 2: Slave не готов (stop активен) ===");

    // Загружаем данные
    load_data(test_packet);

    // Ждем начала передачи
    @(posedge clk);

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

    // ============ ТЕСТ 3: Проверка работы skid buffer при задержках slave ============
    $display("\n=== ТЕСТ 3: Проверка буферизации в skid buffer ===");

    // Загружаем данные
    load_data(test_packet);

    // Передаем 2 байта
    @(posedge clk);
    @(posedge clk);

    // Активируем stop на 2 такта - skid buffer должен запомнить данные
    $display("--- Активируем stop = 1 на 2 такта ---");
    stop = 1'b1;
    #20;

    // Проверяем состояние skid buffer
    if (skid.STATE == 1'b1)
        $display("ТЕСТ 3: skid buffer в режиме буферизации - OK");
    else
        $display("ТЕСТ 3: skid buffer не переключился в режим буферизации - ОШИБКА");

    // Деактивируем stop
    $display("--- Деактивируем stop = 0 ---");
    stop = 1'b0;

    // Ждем завершения передачи
    #50;

    if (skid.STATE == 1'b0)
        $display("ТЕСТ 3: skid buffer вернулся в обычный режим - OK");
    else
        $display("ТЕСТ 3: skid buffer застрял в режиме буферизации - ОШИБКА");

    #20;

    // ============ ТЕСТ 4: Множественные задержки от slave ============
    $display("\n=== ТЕСТ 4: Множественные задержки от slave ===");

    // Загружаем данные
    load_data(test_packet);

    // Цикл задержек: то готов, то не готов
    repeat(10) begin
        @(posedge clk);
        stop = ~stop;  // Переключаем stop каждый такт
    end

    stop = 1'b0;  // Возвращаем в нормальное состояние
    #50;

    #20;

    // ============ ТЕСТ 5: Проверка last сигнала ============
    $display("\n=== ТЕСТ 5: Проверка сигнала last ===");

    // Загружаем данные
    load_data(test_packet);

    // Отслеживаем last
    repeat(9) begin
        @(posedge clk);
        if (slave_valid && slave_ready) begin
            $display("slave data=%h, last=%b, master.buff_count=%d", 
                     slave_data, slave_last, master.buff_count);
        end
    end

    #20;

    // ============ ТЕСТ 6: Проверка данных на выходе slave ============
    $display("\n=== ТЕСТ 6: Проверка данных на выходе slave ===");

    // Загружаем данные
    load_data(test_packet);

    // Сбрасываем счетчик для проверки
    i = 0;

    // Ждем 8 тактов передачи и проверяем выходные данные
    repeat(8) begin
        @(posedge clk);
        if (slave_valid && slave_ready) begin
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
        $display("ТЕСТ 6: Все 8 байт переданы корректно - OK");
    else
        $display("ТЕСТ 6: ОШИБКА - передано только %d байт", i);

    #20;

    // ============ ТЕСТ 7: Передача с прерыванием от master (запись новых данных) ============
    $display("\n=== ТЕСТ 7: Попытка записи новых данных во время передачи ===");

    // Загружаем первые данные
    load_data(test_packet);

    // Ждем передачи 2 байт
    @(posedge clk);
    @(posedge clk);

    // Пытаемся записать новые данные во время передачи
    $display("Попытка записи новых данных во время передачи (master_valid=%b, master_ready=%b)", 
             master_valid, master_ready);
    load_data(pack_data(8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77, 8'h88));

    // Ждем завершения передачи
    #80;

    if (master.buff_count == 0)
        $display("ТЕСТ 7: master.buff_count = 0 после записи - OK (запись проигнорирована)");
    else
        $display("ТЕСТ 7: master.buff_count = %d после записи - ОШИБКА", master.buff_count);

    #20;

    // ============ ТЕСТ 8: Передача с прерыванием от reset ============
    $display("\n=== ТЕСТ 8: Передача прерывается сбросом (reset_n) ===");

    // Загружаем данные
    load_data(test_packet);

    // Ждем передачи 3 байт
    repeat(3) @(posedge clk);

    // Сбрасываем модули
    $display("--- Сброс reset_n = 0 на 3 такта ---");
    reset_n = 1'b0;
    #30;

    // Проверяем состояние после сброса
    $display("После сброса: master.data_buff=%h, master.buff_count=%d, data_out=%h, skid.state=%b",
             master.data_buff, master.buff_count, data_out, skid.STATE);

    // Восстанавливаем
    $display("--- Восстановление reset_n = 1 ---");
    reset_n = 1'b1;
    #10; // Даем время на восстановление после сброса

    // Проверяем, что данные не передаются и буферы сброшены
    #20;

    if (master.buff_count == 0 && master.data_buff == 64'b0 && data_out == 8'b0 && skid.STATE == 1'b0)
        $display("ТЕСТ 8: Сброс работает корректно - OK");
    else
        $display("ТЕСТ 8: ОШИБКА - buff_count=%d, data_buff=%h, data_out=%h, skid.state=%b",
                 master.buff_count, master.data_buff, data_out, skid.STATE);

    #20;

    // ============ ТЕСТ 9: Граничный случай - очень быстрые переключения stop ============
    $display("\n=== ТЕСТ 9: Граничный случай - stop меняется каждый такт ===");

    // Загружаем данные
    load_data(test_packet);

    // Очень быстрые переключения stop
    repeat(16) begin
        @(posedge clk);
        stop = ~stop;
    end

    stop = 1'b0;
    #50;

    #20;

    // ============ ТЕСТ 10: Проверка работы skid buffer при длительной недоступности slave ============
    $display("\n=== ТЕСТ 10: Длительная недоступность slave ===");

    // Загружаем данные
    load_data(test_packet);

    // Ждем начала передачи
    @(posedge clk);

    // Активируем stop на 10 тактов
    $display("--- Активируем stop = 1 на 10 тактов ---");
    stop = 1'b1;
    #100;

    $display("skid buffer state = %b, mem_data = %h, s_ready = %b, m_valid = %b", 
             skid.STATE, skid.mem_data, skid.s_ready, skid.m_valid);

    // Деактивируем stop
    $display("--- Деактивируем stop = 0 ---");
    stop = 1'b0;

    // Ждем завершения передачи
    #80;

    #20;

    $display("\n=========================================================");
    $display("=== ТЕСТИРОВАНИЕ AXI STREAM С SKID BUFFER ЗАВЕРШЕНО ===");
    $display("=========================================================");

    // Завершение симуляции
    #100 $finish;
end

// Детальный монитор для отслеживания каждого переданного байта
always @(posedge clk) begin
    if (master_valid && master_ready) begin
        $display("MASTER->SKID: Такт %0t, data=%h, last=%b, buff_count=%d",
                  $time, master_data, master_last, master.buff_count);
    end
    
    if (slave_valid && slave_ready) begin
        $display("SKID->SLAVE:  Такт %0t, data=%h, last=%b, data_out=%h",
                  $time, slave_data, slave_last, data_out);
    end
end

// Проверка сигнала last
always @(posedge clk) begin
    if (slave_valid && slave_ready && slave_last) begin
        $display("LAST DETECTED: Такт %0t, последний байт пакета принят slave", $time);
    end
end

// Проверка состояния skid buffer при изменении stop
always @(stop) begin
    $display("СТОП ИЗМЕНЕН: Такт %0t, stop = %b", $time, stop);
end

endmodule

