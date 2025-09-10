module syncTtrigger(clk, T, Q, nQ);
	//объявляем входы
	input clk, T;

	//объявляем выходы
	output Q, nQ;
	reg Q, nQ;
	reg tmp_Q = 1;

	always @(posedge clk) begin
		if (T) tmp_Q = !tmp_Q;
		Q <= tmp_Q;
		nQ <= !tmp_Q;
	end
endmodule // syncTtrigger
