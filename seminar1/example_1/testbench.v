module counter_testbench;
    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,counter_testbench);
    end
    reg clk = 0;
    always #5 clk = !clk;

    reg in = 0;
    initial begin
        #5 in = !in;
        forever begin
            #7 in = !in;
            #12 in = !in;
        end
    end

    wire out0, out1, out2;

    counter c1 (clk, in, out0, out1, out2);
    initial begin
        $monitor("At time %t, out0 = %b, out1 = %b, out2 = %b, state = %d",
                 $time, out0, out1, out2, c1.state);
        #300 $finish;
    end
endmodule // counter_testbench
