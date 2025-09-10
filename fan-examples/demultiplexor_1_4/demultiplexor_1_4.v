module demultiplexor_1_4(D, X, F);

	//объявляем входы
	input  D;
	input  [1:0] X;

	//объявляем выходы
	output [3:0] F;

	assign F[0] = (X == 0) ? D : 0;
	assign F[1] = (X == 1) ? D : 0;
	assign F[2] = (X == 2) ? D : 0;
	assign F[3] = (X == 3) ? D : 0;

endmodule // demultiplexor_1_4
