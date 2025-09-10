module Dtrigger(clk, D, Q, nQ);
	//объявляем входы
	input clk, D;

	//объявляем выходы
	output Q, nQ;
	reg Q, nQ;

	always @(posedge clk) begin
		Q <= D;
		nQ <= !D;
	end
endmodule // Dtrigger
