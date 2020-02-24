module ADD2(
	input 	clk,
	input 	rst_n,
	input i0,
	input i1,
	output ADD2_valid,
	output ADD2_out
);
	reg locali0,locali1;
	assign ADD2_out = locali0 + locali1;
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			locali0<=0;
			locali1<=0;
			ADD2_valid<=0;
		end
		else begin
			locali0<=i0;
			locali1<=i1;
			ADD2_valid<=1;
		end
	end
endmodule

module ADD3(
	input 	clk,
	input 	rst_n,
	input i0,
	input i1,
	input i2,
	output ADD3_valid,
	output ADD3_out
);
	reg locali0,locali1,locali2;
	assign ADD3_out = locali0 + locali1 + locali2;
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			locali0<=0;
			locali1<=0;
			locali2<=0;
			ADD3_valid<=0;
		end
		else begin
			locali0<=i0;
			locali1<=i1;
			locali2<=i2;
			ADD3_valid<=1;
		end
	end
endmodule

module FA(
	input 	clk,
	input 	rst_n,
	input  	[383:0]data,
	output 	FAvalid,
	output 	FAout
);
	genvar idx;
	generate
		for(idx=0;idx<8;idx=idx+1)begin
			ADD3 A3TO1(.clk(clk),.rst_n(rst_n),.i0(),.i1(),.i2(),.ADD3_valid(),.ADD3_out());
		end
		for(idx=0;idx<4;idx=idx+1)begin
			ADD2 A2TO1(.clk(clk),.rst_n(rst_n),.i0(),.i1(),.ADD2_valid(),.ADD2_out());
		end
		for(idx=0;idx<2;idx=idx+1)begin
			ADD2 A2TO1(.clk(clk),.rst_n(rst_n),.i0(),.i1(),.ADD2_valid(),.ADD2_out());
		end
		for(idx=0;idx<1;idx=idx+1)begin
			ADD2 A2TO1(.clk(clk),.rst_n(rst_n),.i0(),.i1(),.ADD2_valid(),.ADD2_out());
		end
	endgenerate
endmodule

module FSA#(parameter NO3=0,parameter NO5=0,parameter ID5=0,parameter NO7=0,parameter ID7=0)(
	input 	clk,
	input 	rst_n,
	input 	stride,
	input 	wsize,
	input 	[3:0]wround,
	input  	[1151:0]data,
	output 	FSAvalid,
	output 	[45:0]FSAout
);
	parameter FRONT = 23;
	parameter BACK = 0;
	parameter D1 = 23;
	
	reg [20:0]row1,row2,row3;
	/* FA */
	FA ROW1(.clk(clk),.rst_n(rst_n),.data(data[383:0]),.FAout(row1),.FAvalid());
	FA ROW2(.clk(clk),.rst_n(rst_n),.data(data[767:384]),.FAout(row2),.FAvalid());
	FA ROW3(.clk(clk),.rst_n(rst_n),.data(data[1151:768]),.FAout(row3),.FAvalid());
	
	/* SA */
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			FSAout<=0;
			FSAvalid<=0;
		end
		else begin
			FSAvalid<=1;
			case(wsize)
				0:begin 		//3 * 3
					case(NO3)
						6:begin
							FSAout[FRONT +:D1] 	<= row3;
							FSAout[BACK +:D1] 	<= row1 + row2;
						end
						7:begin
							FSAout[FRONT +:D1] 	<= row1;
							FSAout[BACK +:D1]	<= row2 + row3;
						end
						default:begin
							FSAout[FRONT +:D1] 	<= 0;
							FSAout[BACK +:D1]	<= row1 + row2 + row3;
						end
					endcase
				end
				1:begin 		// 5 * 5
					case(stride)
						0:begin		// stride 1
							case(wround)
								0:begin
									FSAout[FRONT +:D1] 	<= 0;
									FSAout[BACK +:D1]	<= row1 + row2 + row3;
								end
								1:begin
									if((NO5==0 && (ID5==2 || ID5==3)) || (NO5==3 && (ID5==0 || ID5==1)))begin
										FSAout[FRONT +:D1] 	<= row1;
										FSAout[BACK +:D1]	<= row2 + row3;
									end
									else if(NO5==2 && (ID5==0 || ID5==1))begin
										FSAout[FRONT +:D1] 	<= row3;
										FSAout[BACK +:D1] 	<= row1 + row2;
									end
									else begin
										FSAout[FRONT +:D1] 	<= 0;
										FSAout[BACK +:D1]	<= row1 + row2 + row3;
									end
								end
							endcase
						end
						1:begin		// stride 2
							if(NO5==2 && (ID5==3 || ID5==4))begin
								FSAout[FRONT +:D1] 	<= row1;
								FSAout[BACK +:D1]	<= row2 + row3;
							end
							else if(NO5==3 && (ID5==1 || ID5==2))begin
								FSAout[FRONT +:D1] 	<= row3;
								FSAout[BACK +:D1] 	<= row1 + row2;
							end
							else begin
								FSAout[FRONT +:D1] 	<= 0;
								FSAout[BACK +:D1]	<= row1 + row2 + row3;
							end
						end
					endcase
				end
				2:begin		//7*7
					case(stride)
						0:begin
							case(wround)
								0:begin
									FSAout[FRONT +:D1] 	<= 0;
									FSAout[BACK +:D1]	<= row1 + row2 + row3;
								end
								1:begin
									if(NO7==1 && (ID7==3 || ID7==4 || ID7==5))begin
										FSAout[FRONT +:D1] 	<= row3;
										FSAout[BACK +:D1] 	<= row1 + row2;
									end
									else begin
										FSAout[FRONT +:D1] 	<= 0;
										FSAout[BACK +:D1]	<= row1 + row2 + row3;
									end
								end
								2:begin
									if(NO7==0 && (ID7==3 || ID7==4 || ID7==5))begin
										FSAout[FRONT +:D1] 	<= row1;
										FSAout[BACK +:D1] 	<= row2 + row3;
									end
									else begin
										FSAout[FRONT +:D1] 	<= 0;
										FSAout[BACK +:D1]	<= row1 + row2 + row3;
									end
								end
								3:begin
									if(NO7==0 && (ID7==0 || ID7==1 || ID7==2))begin
										FSAout[FRONT +:D1] 	<= row3;
										FSAout[BACK +:D1] 	<= row1 + row2;
									end
									else if(NO7==1 && (ID7==0 || ID7==1 || ID7==2))begin
										FSAout[FRONT +:D1] 	<= row1;
										FSAout[BACK +:D1]	<= row2 + row3;
									end
									else begin
										FSAout[FRONT +:D1] 	<= 0;
										FSAout[BACK +:D1]	<= row1 + row2 + row3;
									end
								end
							endcase
						end
						1:begin
							case(wround)
								0:begin
									FSAout[FRONT +:D1] 	<= 0;
									FSAout[BACK +:D1]	<= row1 + row2 + row3;
								end
								1:begin
									if(NO7==0 && (ID7==3 || ID7==4 || ID7==5))begin
										FSAout[FRONT +:D1] 	<= row1;
										FSAout[BACK +:D1] 	<= row2 + row3;
									end
									else if(NO7==1 && (ID7==0 || ID7==1 || ID7==2))begin
										FSAout[FRONT +:D1] 	<= row3;
										FSAout[BACK +:D1]	<= row1 + row2;
									end
									else begin
										FSAout[FRONT +:D1] 	<= 0;
										FSAout[BACK +:D1]	<= row1 + row2 + row3;
									end
								end
							endcase
						end
					endcase
				end
			endcase
		end
	end
	
endmodule

module A#(parameter NO5=0,parameter ID5=0)(
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

module A1#(parameter NO5=0,parameter ID5=0)(
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

module A2_0#(parameter NO5=0,parameter ID5=0)(
	input stride,
	input round,
	input i0,
	input i1,
	output A2_0valid,
	output A2_0out
);

endmodule

module A2_1#(parameter NO5=0,parameter ID5=0)(
	input stride,
	input round,
	input i0,
	input i1,
	output A2_1valid,
	output A2_1out
);

endmodule

module B#(parameter NO7=0,parameter ID7=0)(
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

module B1#(parameter NO7=0,parameter ID7=0)(
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

module B2#(parameter NO7=0,parameter ID7=0)(
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

module B3#(parameter NO7=0,parameter ID7=0)(
	input clk,
	input rst_n,
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
	input clk,
	input rst_n,
	input stride,
	input [2:0]wround,
	input [73727:0]MUL_results, //4608*16
	input MUL_DATA_valid,
	input [3:0]wsize,
	output Psum_valid,
	output Psum
);
	FSA#(.NO3(0),.NO5(0),.ID5(0),.NO7(0),.ID7(0))C0(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(1),.NO5(0),.ID5(1),.NO7(0),.ID7(1))C1(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(2),.NO5(0),.ID5(2),.NO7(0),.ID7(2))C2(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(3),.NO5(0),.ID5(3),.NO7(0),.ID7(3))C3(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(4),.NO5(1),.ID5(0),.NO7(0),.ID7(4))C4(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(5),.NO5(1),.ID5(1),.NO7(0),.ID7(5))C5(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(6),.NO5(1),.ID5(2),.NO7(0),.ID7(6))C6(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(7),.NO5(1),.ID5(3),.NO7(0),.ID7(7))C7(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(0),.NO5(2),.ID5(0),.NO7(0),.ID7(8))C8(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(1),.NO5(2),.ID5(1),.NO7(0),.ID7(9))C9(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(2),.NO5(2),.ID5(2),.NO7(0),.ID7(9))C10(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(3),.NO5(2),.ID5(3),.NO7(0),.ID7(9))C11(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(4),.NO5(3),.ID5(0),.NO7(0),.ID7(9))C12(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(5),.NO5(3),.ID5(1),.NO7(0),.ID7(9))C13(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(6),.NO5(3),.ID5(2),.NO7(0),.ID7(9))C14(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(7),.NO5(3),.ID5(3),.NO7(0),.ID7(9))C15(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	
	FSA#(.NO3(0),.NO5(0),.ID5(0),.NO7(1),.ID7(0))C16(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(1),.NO5(0),.ID5(1),.NO7(1),.ID7(1))C17(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(2),.NO5(0),.ID5(2),.NO7(1),.ID7(2))C18(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(3),.NO5(0),.ID5(3),.NO7(1),.ID7(3))C19(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(4),.NO5(1),.ID5(0),.NO7(1),.ID7(4))C20(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(5),.NO5(1),.ID5(1),.NO7(1),.ID7(5))C21(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(6),.NO5(1),.ID5(2),.NO7(1),.ID7(6))C22(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(7),.NO5(1),.ID5(3),.NO7(1),.ID7(7))C23(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(0),.NO5(2),.ID5(0),.NO7(1),.ID7(8))C24(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(1),.NO5(2),.ID5(1),.NO7(1),.ID7(9))C25(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(2),.NO5(2),.ID5(2),.NO7(1),.ID7(9))C26(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(3),.NO5(2),.ID5(3),.NO7(1),.ID7(9))C27(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(4),.NO5(3),.ID5(0),.NO7(1),.ID7(9))C28(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(5),.NO5(3),.ID5(1),.NO7(1),.ID7(9))C29(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(6),.NO5(3),.ID5(2),.NO7(1),.ID7(9))C30(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(7),.NO5(3),.ID5(3),.NO7(1),.ID7(9))C31(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	
	FSA#(.NO3(0),.NO5(0),.ID5(0),.NO7(0),.ID7(0))C32(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(1),.NO5(0),.ID5(1),.NO7(0),.ID7(1))C33(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(2),.NO5(0),.ID5(2),.NO7(0),.ID7(2))C34(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(3),.NO5(0),.ID5(3),.NO7(0),.ID7(3))C35(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(4),.NO5(1),.ID5(0),.NO7(0),.ID7(4))C36(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(5),.NO5(1),.ID5(1),.NO7(0),.ID7(5))C37(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(6),.NO5(1),.ID5(2),.NO7(0),.ID7(6))C38(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(7),.NO5(1),.ID5(3),.NO7(0),.ID7(7))C39(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(0),.NO5(2),.ID5(0),.NO7(0),.ID7(8))C40(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(1),.NO5(2),.ID5(1),.NO7(0),.ID7(9))C41(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(2),.NO5(2),.ID5(2),.NO7(0),.ID7(9))C42(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(3),.NO5(2),.ID5(3),.NO7(0),.ID7(9))C43(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(4),.NO5(3),.ID5(0),.NO7(0),.ID7(9))C44(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(5),.NO5(3),.ID5(1),.NO7(0),.ID7(9))C45(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(6),.NO5(3),.ID5(2),.NO7(0),.ID7(9))C46(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(7),.NO5(3),.ID5(3),.NO7(0),.ID7(9))C47(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	
	FSA#(.NO3(0),.NO5(0),.ID5(0),.NO7(1),.ID7(0))C48(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(1),.NO5(0),.ID5(1),.NO7(1),.ID7(1))C49(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(2),.NO5(0),.ID5(2),.NO7(1),.ID7(2))C50(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(3),.NO5(0),.ID5(3),.NO7(1),.ID7(3))C51(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(4),.NO5(1),.ID5(0),.NO7(1),.ID7(4))C52(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(5),.NO5(1),.ID5(1),.NO7(1),.ID7(5))C53(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(6),.NO5(1),.ID5(2),.NO7(1),.ID7(6))C54(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(7),.NO5(1),.ID5(3),.NO7(1),.ID7(7))C55(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(0),.NO5(2),.ID5(0),.NO7(1),.ID7(8))C56(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(1),.NO5(2),.ID5(1),.NO7(1),.ID7(9))C57(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(2),.NO5(2),.ID5(2),.NO7(1),.ID7(9))C58(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(3),.NO5(2),.ID5(3),.NO7(1),.ID7(9))C59(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(4),.NO5(3),.ID5(0),.NO7(1),.ID7(9))C60(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(5),.NO5(3),.ID5(1),.NO7(1),.ID7(9))C61(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(6),.NO5(3),.ID5(2),.NO7(1),.ID7(9))C62(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	FSA#(.NO3(7),.NO5(3),.ID5(3),.NO7(1),.ID7(9))C63(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(),.FSAvalid());
	
	
endmodule
	