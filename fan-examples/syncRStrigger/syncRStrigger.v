module syncRStrigger(clk, R, S, Q, nQ);
	// объявляем входы
	input R, S, clk;

	// объявляем выходы и их окружение
	output Q, nQ;
	reg Q, nQ;

	always @(posedge clk) begin
		if (S == 1 && R == 0) begin
			Q <= 1;
			nQ <= 0;
		end
                if (S == 0 && R == 1) begin
                        Q <= 0;
                        nQ <= 1;
                end
                if (S == 1 && R == 1) begin
                        Q <= 1'bx;
                        nQ <= 1'bx;
                end
	end
endmodule //
