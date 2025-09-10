module RStrigger(R, S, Q, nQ);
	// объявляем входы
	input R, S;

	// объявляем выходы и их окружение
	output Q, nQ;
	reg tmp_Q = 1;

	assign Q = ((S == 1) & (R == 0)) ? 1 : (((S == 0) & (R == 1)) ? 0 : (((S == 0) & (R == 0)) ? tmp_Q : 1'bx));
	assign nQ = !Q;

	always @(posedge Q, negedge Q)
		tmp_Q <= Q;
endmodule // RStrigger
