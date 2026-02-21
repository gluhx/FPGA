// задаём временную шкалу
`timescale 10 ps/ 1 ps

module skid_buff_test;

//dump для GTKWAVE
initial begin
    $dumpfile("skidbuff_simulation.vcd");
    $dumpvars(0, skid_buff_test);
end

//объявляем и задаём входные сигналы
reg clk = 1'b0;
always #5 clk <= ~clk;

reg reset = 1'b0;
reg [7:0] m_data = 8'b0;
reg m_valid = 1'b0;
reg m_last = 1'b0;
reg s_ready = 1'b0;

// объявляем выходные сигналы
wire [7:0] s_data;
wire s_valid;
wire s_last;
wire m_ready;

//подключаем модуль
skid_buff DUT (
    .clk(clk),
    .reset(reset),
    .m_data(m_data),
    .m_valid(m_valid),
    .m_last(m_last),
    .m_ready(m_ready),
    .s_data(s_data),
    .s_valid(s_valid),
    .s_last(s_last),
    .s_ready(s_ready)
);

// Монитор для отслеживания всех сигналов
initial begin
    $monitor("At time %0t: clk=%b, reset=%b, m_data=%h, m_valid=%b, m_last=%b, m_ready=%b, s_data=%h, s_valid=%b, s_last=%b, s_ready=%b, STATE=%b, mem_data=%h, mem_last=%b", 
              $time, clk, reset, m_data, m_valid, m_last, m_ready, s_data, s_valid, s_last, s_ready, DUT.STATE, DUT.mem_data, DUT.mem_last);
end

// Генерация тестовых сигналов
initial begin
    // Инициализация
    $display("=== НАЧАЛО ТЕСТИРОВАНИЯ ===");
    #10 reset = 1'b1;
    #10 s_ready = 1'b0; // Slave готов к приему
    
    // ============ ПАКЕТ 1: Полное прохождение без прерываний ============
    $display("\n=== ПАКЕТ 1: Нормальная передача, s_ready всегда = 1 ===");
    
    // Байт 1.1
    #10 m_data = 8'h11; m_valid = 1'b1; m_last = 1'b0; s_ready = 1'b1;
    #10;
    
    // Байт 1.2
    m_data = 8'h22; m_valid = 1'b1; m_last = 1'b0; s_ready = 1'b0;
    #10 s_ready = 1'b1;
    #10;
    // Байт 1.3
    m_data = 8'h33; m_valid = 1'b1; m_last = 1'b0;
    #10;
    
    // Байт 1.4 (последний)
    m_data = 8'h44; m_valid = 1'b1; m_last = 1'b1;
    #10;
    
    // Завершаем передачу
    m_valid = 1'b0; m_last = 1'b0;
    #20;
    
    // ============ ПАКЕТ 2: Прерывание на 2 такта (s_ready = 0) ============
    $display("\n=== ПАКЕТ 2: Передача с прерыванием на 2 такта (s_ready = 0) ===");
    
    // Байт 2.1 - нормальная передача
    #10 m_data = 8'hAA; m_valid = 1'b1; m_last = 1'b0;
    #10;
    
    // Байт 2.2 - нормальная передача
    m_data = 8'hBB; m_valid = 1'b1; m_last = 1'b0;
    #10;
    
    // Байт 2.3 - здесь будет прерывание (s_ready = 0 на 2 такта)
    m_data = 8'hCC; m_valid = 1'b1; m_last = 1'b0;
    
    // Отключаем s_ready на 2 такта
    $display("--- Прерывание передачи: s_ready = 0 на 2 такта ---");
    s_ready = 1'b0;
    #10; // 1-й такт прерывания
    #10; // 2-й такт прерывания
    
    // Восстанавливаем s_ready
    s_ready = 1'b1;
    $display("--- Восстановление передачи: s_ready = 1 ---");
    #10; // Передача должна продолжиться из буфера
    
    // Байт 2.4 (последний)
    m_data = 8'hDD; m_valid = 1'b1; m_last = 1'b1;
    #10;
    
    // Завершаем передачу
    m_valid = 1'b0; m_last = 1'b0;
    #20;
    
    // ============ Дополнительная проверка: Сброс во время передачи ============
    $display("\n=== Дополнительная проверка: Сброс во время передачи ===");
    
    s_ready = 1'b0; // Создаем условие для буферизации
    #10 m_data = 8'hEE; m_valid = 1'b1; m_last = 1'b0;
    #10; // Переход в режим буферизации
    
    // Сброс во время буферизации
    $display("--- Сброс во время режима буферизации ---");
    #5 reset = 1'b1;
    #5 reset = 1'b0;
    s_ready = 1'b1;
    #20;
    
    $display("\n=== ТЕСТИРОВАНИЕ ЗАВЕРШЕНО ===");
    
    // Завершение симуляции
    #100 $finish;
end


endmodule
