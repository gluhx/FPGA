`timescale 1ns / 10ps
module mod3_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("mod3_sim.vcd");
        $dumpvars(0, mod3_test);
    end
    
    // входные сигналы
    reg clk = 0;
    always #5 clk = !clk;
    reg clk1;
    always @(posedge clk) begin
        clk1 = 1;
        #4 clk1 = 0;
    end
    
    reg [7:0] a = 231;
    reg start, finish, in;
    reg [4:0] i = 0;

    always @(posedge clk1) begin
        i <= i + 1;
        case (i)
            0: start <= 1;
            1: begin
                start <= 0;
                in <= a[7];
            end
            2: in <= a[6];
            3: in <= a[5];
            4: in <= a[4];
            5: in <= a[3];
            6: in <= a[2];
            7: in <= a[1];
            8: in <= a[0];
            9: begin 
                finish <= 1;
                in <=0;
            end
            10: finish <= 0;
            11: i <= 0;
        endcase
    end
    
    wire out;
    // подключаем модуль
    mod3 DD1(clk, in, start, finish, out);

    // отслеживание сигналов
    initial begin
        $monitor("At time %t", $time);
        #500 $finish;
    end
endmodule // mod3_test
