[200~module JK_trigger_tb;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("JK_trigger_sim.vcd");
        $dumpvars(0, JK_trigger_tb);
    end
    
    // тактовый сигнал
    reg clk = 0;
    always #5 clk = !clk;

    // входные сигналы
    reg J = 0;
    always #7 J = !J;
    reg K = 0;
    always #6 K = !K;

    // выходные сигналы
    wire Q, nQ;

    // подключаем модуль
    JK_trigger T1(J, K, clk, Q, nQ);

    // отслеживание сигналов
    initial begin
        $monitor("At time %t, out1=%b, out2=%b", $time, Q, nQ);
        #500 $finish;
    end
endmodule // JK_trigger_tb
