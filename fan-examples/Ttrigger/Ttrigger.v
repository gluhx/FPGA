module Ttrigger(T, Q, nQ);
	//объявляем входы
	input T;

	//объявляем выходы
	output Q, nQ;
	reg Q, nQ;
	reg tmp_Q = 1;

	always @(posedge T) begin
		tmp_Q = !tmp_Q;
		Q <= tmp_Q;
		nQ <= !tmp_Q;
	end
endmodule // Ttrigger
