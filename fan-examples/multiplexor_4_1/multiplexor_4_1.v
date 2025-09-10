module multiplexor_4_1(D, X, F);

	//объявляем входы
	input  [3:0] D;
	input  [1:0] X;

	//объявляем выходы
	output F;
	
	assign F = D[X];
endmodule // multiplexor_4_1
