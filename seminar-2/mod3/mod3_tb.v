`timescale 10ps / 1ps
module mod3_test;
    // дамп файла для GtkWave
    initial begin
        $dumpfile("mod3_sim.vcd");
        $dumpvars(0, mod3_test);
    end
    
    // входные сигналы
    reg clk = 0;
    always #5 clk = !clk;
    
    reg [7:0] a = 33;
    reg [7:0] b = 29;
    reg start, finish, in;
    reg [4:0] i = 0;

    always @(posedge clk) begin
        i <= i + 1;
        case (i)
            0: begin
                start <= 1;
                in <= a[7];
            end
            1: begin 
                in <= a[6];
                start <= 0;
            end
            2: in <= a[5];
            3: in <= a[4];
            4: in <= a[3];
            5: in <= a[2];
            6: in <= a[1];
            7: begin 
                in <= a[0];
                finish <= 1;
            end
            8: begin 
                finish <= 0;
                in <= 0;
            end
            15: begin
                start <= 1;
                in <= b[7];
            end
            16: begin 
                in <= b[6];
                start <= 0;
            end
            17: in <= b[5];
            18: in <= b[4];
            19: in <= b[3];
            20: in <= b[2];
            21: in <= b[1];
            22: begin 
                in <= b[0];
                finish <= 1;
            end
            23: begin 
                finish <= 0;
                in <= 0;
            end
            24: i <= 0;

            25: i <= 0;
        endcase
    end
    
    wire out;
    wire is_out;
    // подключаем модуль
    mod3 DD1(clk, in, start, finish, out, is_out);

    // отслеживание сигналов
    initial begin
        $monitor("At time %t", $time);
        #500 $finish;
    end
endmodule // mod3_test
