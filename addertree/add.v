module FSA#(NO3,NO5,ID5,NO7,ID7)(
	input  data,
	output FSAvalid,
	output FSAout
);

endmodule

module A#(NO5,ID5)(
	input stride,
	input round,
	input i0,
	input i1,
	input i2,
	input i3,
	output Avalid,
	output Aout
);

endmodule

module A1#(NO5,ID5)(
	input stride,
	input round,
	input i0,
	input i1,
	input i2,
	input i3,
	output A1valid,
	output A1out
);

endmodule

module A2_0#(NO5,ID5)(
	input stride,
	input round,
	input i0,
	input i1,
	output A2_0valid,
	output A2_0out
);

endmodule

module A2_1#(NO5,ID5)(
	input stride,
	input round,
	input i0,
	input i1,
	output A2_1valid,
	output A2_1out
);

endmodule

module B#(NO7,ID7)(
	input stride,
	input round,
	input i0,
	input i1,
	input i2,
	input i3,
	input i4,
	input i5,
	input i6,
	input i7,
	input i8,
	output B_valid,
	output Bout
);
endmodule

module B1(
	input stride,
	input round,
	input i0,
	input i1,
	input i2,
	input i3,
	input i4,
	input i5,
	input i6,
	input i7,
	input i8,
	output B1_valid,
	output B1out
);
endmodule

module B2#(NO7,ID7)(
	input stride,
	input round,
	input i0,
	input i1,
	input i2,
	input i3,
	input i4,
	input i5,
	output B2_valid,
	output B2out
);
endmodule

module B3#(NO7,ID7)(
	input stride,
	input round,
	input i0,
	input i1,
	input i2,
	output B3_valid,
	output B3out
);
endmodule

module ADDER(
	input stride,
	input round,
	input data,
	input wsize,
	input RLPadding,
	output res_valid,
	output res
);
endmodule
	