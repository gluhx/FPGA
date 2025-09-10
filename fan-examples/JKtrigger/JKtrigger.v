module JKtrigger(J, K, clk, Q, nQ);
    // объявляем входы
    input J, K, clk;

    // объявляем выходы и их окружение
    output Q, nQ;
    reg Q, nQ;
    reg tmp_Q = 1;

    always @(posedge clk) begin
        if (J == 1 && K == 0) tmp_Q = 1;
        if (J == 0 && K == 1) tmp_Q = 0;
        if (J == 1 && K == 1) tmp_Q = !tmp_Q;
        
        Q <= tmp_Q;
        nQ <= !tmp_Q;
    end
endmodule // JKtrigger
