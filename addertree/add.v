module ADD2#(parameter N=16)(
	input clk,
	input rst_n,
	input [N-1:0]i0,
	input [N-1:0]i1,
	output ADD2_valid,
	output [N:0]ADD2_out
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

module ADD3#(parameter N=16)(
	input clk,
	input rst_n,
	input [N-1:0]i0,
	input [N-1:0]i1,
	input [N-1:0]i2,
	output ADD3_valid,
	output [N+1:0]ADD3_out
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
			ADD3 #(16)A3TO1(.clk(clk),.rst_n(rst_n),.i0(),.i1(),.i2(),.ADD3_valid(),.ADD3_out());
		end
		for(idx=0;idx<4;idx=idx+1)begin
			ADD2 #(18)A2TO1(.clk(clk),.rst_n(rst_n),.i0(),.i1(),.ADD2_valid(),.ADD2_out());
		end
		for(idx=0;idx<2;idx=idx+1)begin
			ADD2 #(19)A2TO1(.clk(clk),.rst_n(rst_n),.i0(),.i1(),.ADD2_valid(),.ADD2_out());
		end
		for(idx=0;idx<1;idx=idx+1)begin
			ADD2 #(20)A2TO1(.clk(clk),.rst_n(rst_n),.i0(),.i1(),.ADD2_valid(),.ADD2_out());
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

module A#(parameter NO5=0)(
	input clk,
	input rst_n,
	input stride,
	input [2:0]wround,
	input [45:0]i0,
	input [45:0]i1,
	input [45:0]i2,
	input [45:0]i3,
	output Avalid,
	output [53:0]Aout
);
	parameter FRONT = 23;
	parameter BACK = 0;
	parameter D1 = 23;
	
	reg[22:0]A1i[0:3];
	reg[22:0]A2_0i[0:1];
	reg[22:0]A2_1i[0:1];
	
	reg[26:0]A1out,A2_0out,A2_1out;
	
	/* A1 input */
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A1i[0]<=0;
			A1i[1]<=0;
			A1i[2]<=0;
			A1i[3]<=0;
		end
		else begin	
			case(stride)
				0:begin
					case(wround)
						0:begin
							A1i[0]<=i0[BACK +: D1];
							A1i[1]<=i1[BACK +: D1];
							A1i[2]<=i2[BACK +: D1];
							A1i[3]<=i3[BACK +: D1];
						end
						1:begin
							case(NO5)
								0:begin
									A1i[0]<=i0[BACK +: D1];
									A1i[1]<=i1[BACK +: D1];
									A1i[2]<=i2[FRONT +: D1];
									A1i[3]<=i3[FRONT +: D1];
								end
								1:no!
								2:begin
									A1i[0]<=i0[FRONT +: D1];
									A1i[1]<=i1[FRONT +: D1];
									A1i[2]<=i2[BACK +: D1];
									A1i[3]<=i3[BACK +: D1];
								end
								3:begin
									A1i[0]<=i0[BACK +: D1];
									A1i[1]<=i1[BACK +: D1];
									A1i[2]<=i2[BACK +: D1];
									A1i[3]<=i3[BACK +: D1];
								end
							endcase
						end
					endcase
				end
				1:begin
					if(NO5==2)begin
						A1i[0]<=i0[BACK +: D1];
						A1i[1]<=i1[BACK +: D1];
						A1i[2]<=i2[FRONT +: D1];
						A1i[3]<=i3[FRONT +: D1];
					end
					else begin
						A1i[0]<=i0[BACK +: D1];
						A1i[1]<=i1[BACK +: D1];
						A1i[2]<=i2[BACK +: D1];
						A1i[3]<=i3[BACK +: D1];
					end
				end
			endcase
		end
	end
	
	/* A2_0 input */
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A2_0i[0]<=0;
			A2_0i[1]<=0;
		end
		else begin	
			case(stride)
				0:begin
					case(wround)
						0:no!!
						1:begin
							case(NO5)
								0:begin
									A2_0i[0]<=i2[BACK +: D1];
									A2_0i[1]<=i3[BACK +: D1];
								end
								3:begin
									A2_0i[0]<=i0[FRONT +: D1];
									A2_0i[1]<=i1[FRONT +: D1];
								end
								default:begin
									A2_0i[0]<=i0[BACK +: D1];
									A2_0i[1]<=i1[BACK +: D1];
								end
							endcase
						end
					endcase
				end
				1:begin
					case(NO5)
						2:begin
							A2_0i[0]<=i2[BACK +: D1];
							A2_0i[1]<=i3[BACK +: D1];
						end
						3:begin
							A2_0i[0]<=i0[BACK +: D1];
							A2_0i[1]<=i1[BACK +: D1];
						end
						default:no!!
					endcase
				end
			endcase
		end
	end
	
	/* A2_1i input */
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A2_1i[0]<=0;
			A2_1i[1]<=0;
		end
		else begin	
			if(stride==0 && wround==1 && NO5==1)begin
				A2_1i[0]<=i2[BACK +: D1];
				A2_1i[1]<=i3[BACK +: D1];
			end
			else no!!
		end
	end
	
//-----------------------------------------------------
	/* module instantiation */
	
	A1 a1(.clk(clk),.rst_n(rst_n),.i0(A1i[0]),.i1(A1i[1]),.i2(A1i[2]),.i3(A1i[3]),.A1valid(),.A1out(A1out));
	A2_0 a2_0(.clk(clk),.rst_n(rst_n),.i0(A2_0i[0]),.i1(A2_0i[1]),.A2_0valid(),.A2_0out(A2_0out));
	A2_1 a2_1(.clk(clk),.rst_n(rst_n),.i0(A2_1i[0]),.i1(A2_1i[1]),.A2_1valid(),.A2_1out(A2_1out));
	
//-----------------------------------------------------	
	/* A output */
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			Aout<=0;
		end
		else begin	
			case(stride)
				0:begin
					case(wround)
						0:begin
							Aout[BACK +: D1] <= A1out;
							Aout[FRONT +: D1]<=0;
						end
						1:begin
							case(NO5)
								0:begin
									Aout[BACK +: D1] <= A1out;
									Aout[FRONT +: D1]<= A2_0out;
								end
								1:begin
									Aout[BACK +: D1] <= A2_0out;
									Aout[FRONT +: D1]<= A2_1out;
								end
								default:begin
									Aout[BACK +: D1] <= A2_0out;
									Aout[FRONT +: D1]<= A1out;
								end
							end
						end
					endcase
				end
				1:begin		//stride 2
					case(NO5)
						2:begin
							Aout[BACK +: D1] <= A1out;
							Aout[FRONT +: D1]<= A2_0out;
						end
						3:begin
							Aout[BACK +: D1] <= A2_0out;
							Aout[FRONT +: D1]<= A1out;
						end
						default:begin
							Aout[BACK +: D1] <= A1out;
							Aout[FRONT +: D1]<= 0;
						end
					endcase
				end
			endcase
		end
	end
							
endmodule

module A1(
	input clk,
	input rst_n,
	input [22:0]i0,
	input [22:0]i1,
	input [22:0]i2,
	input [22:0]i3,
	output A1valid,
	output [26:0]A1out
);
	wire[24:0]A1out_tmp;
	reg [23:0]L10,L11;
	reg [22:0]locali[0:3];
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			locali[0]<= 0;
			locali[1]<= 0;
			locali[2]<= 0;
			locali[3]<= 0;
		end
		else begin	
			locali[0]<= i0;
			locali[1]<= i1;
			locali[2]<= i2;
			locali[3]<= i3;
		end
	end		
	ADD2 #(23)L1_0(.clk(clk),.rst_n(rst_n),.i0(locali[0]),.i1(locali[1]),.ADD2_out(L10),.ADD2_valid());
	ADD2 #(23)L1_1(.clk(clk),.rst_n(rst_n),.i0(locali[2]),.i1(locali[3]),.ADD2_out(L11),.ADD2_valid());
	ADD2 #(24)L2(.clk(clk),.rst_n(rst_n),.i0(L10),.i1(L11),.ADD2_out(A1out_tmp),.ADD2_valid(A1valid));
	
	always@(*)begin
		A1out = {2'b0,A1out_tmp};
	end
	
endmodule

module A2_0(
	input clk,
	input rst_n,
	input [22:0]i0,
	input [22:0]i1,
	output A2_0valid,
	output [26:0]A2_0out
);
	reg [23:0]L1;
	reg L1_valid;
	reg [22:0]locali[0:1];
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			locali[0]<= 0;
			locali[1]<= 0;
		end
		else begin	
			locali[0]<= i0;
			locali[1]<= i1;
		end
	end		
	ADD2 #(23)L1(.clk(clk),.rst_n(rst_n),.i0(locali[0]),.i1(locali[1]),.ADD2_out(L1),.ADD2_valid(L1_valid));
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A2_0out	 <=0;
			A2_0valid<=0;
		end
		else begin	
			A2_0out	 <= L1;
			A2_0valid<= {3'b0,L1_valid};
		end
	end
endmodule

module A2_1(
	input clk,
	input rst_n,
	input [22:0]i0,
	input [22:0]i1,
	output A2_1valid,
	output [26:0]A2_1out
);
	reg [23:0]L1;
	reg L1_valid;
	reg [22:0]locali[0:1];
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			locali[0]<= 0;
			locali[1]<= 0;
		end
		else begin	
			locali[0]<= i0;
			locali[1]<= i1;
		end
	end		
	ADD2 #(23)L1(.clk(clk),.rst_n(rst_n),.i0(locali[0]),.i1(locali[1]),.ADD2_out(L1),.ADD2_valid(L1_valid));
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A2_1out	 <=0;
			A2_1valid<=0;
		end
		else begin	
			A2_1out	 <= L1;
			A2_1valid<= {3'b0,L1_valid};
		end
	end

endmodule

module B#(parameter NO7=0)(
	input clk,
	input rst_n,
	input stride,
	input [2:0]wround,
	input [45:0]i0,
	input [45:0]i1,
	input [45:0]i2,
	input [45:0]i3,
	input [45:0]i4,
	input [45:0]i5,
	input [45:0]i6,
	input [45:0]i7,
	input [45:0]i8,
	output B_valid,
	output [53:0]Bout
);
	parameter FRONT = 23;
	parameter BACK = 0;
	parameter D1 = 23;
	integer id;
	
	reg[22:0]B1i[0:8];
	reg[22:0]B2_0i[0:5];
	reg[22:0]B2_1i[0:5];
	reg[22:0]B3i[0:2];
	
	reg[26:0]B1out,B2_0out,B2_1out,B3out;
	
	/* B1 input */
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<9;id=id+1)begin
				B1i[id]<=0;
			end
		end
		else begin	
			case(stride)

endmodule

module B1(
	input clk,
	input rst_n,
	input [22:0]i0,
	input [22:0]i1,
	input [22:0]i2,
	input [22:0]i3,
	input [22:0]i4,
	input [22:0]i5,
	input [22:0]i6,
	input [22:0]i7,
	input [22:0]i8,
	output B1_valid,
	output[26:0]B1out
);
	integer id
	reg[24:0]L10,L11,L12;
	reg [22:0]locali[0:8];
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<9;id=id+1)begin
				locali[id]<=0;
			end
		end
		else begin	
			locali[0]<= i0;
			locali[1]<= i1;
			locali[2]<= i2;
			locali[3]<= i3;
			locali[4]<= i4;
			locali[5]<= i5;
			locali[6]<= i6;
			locali[7]<= i7;
			locali[8]<= i8;
		end
	end		
			
	ADD3#(23)L1_0(.clk(clk),.rst_n(rst_n),.i0(locali[0]),.i1(locali[1]),.i2(locali[2]),.ADD3_out(L10),.ADD3_valid());
	ADD3#(23)L1_1(.clk(clk),.rst_n(rst_n),.i0(locali[3]),.i1(locali[4]),.i2(locali[5]),.ADD3_out(L11),.ADD3_valid());
	ADD3#(23)L1_2(.clk(clk),.rst_n(rst_n),.i0(locali[6]),.i1(locali[7]),.i2(locali[8]),.ADD3_out(L12),.ADD3_valid());
	
	ADD3#(25)L2(.clk(clk),.rst_n(rst_n),.i0(L10),.i1(L11),.i2(L12),.ADD3_out(B1out),.ADD3_valid(B1_valid));

endmodule

module B2(
	input clk,
	input rst_n,
	input stride,
	input round,
	input [22:0]i0,
	input [22:0]i1,
	input [22:0]i2,
	input [22:0]i3,
	input [22:0]i4,
	input [22:0]i5,
	output B2_valid,
	output [26:0]B2out
);
	integer id;
	wire [25:0]B2out_tmp;
	reg[24:0]L10,L11;
	reg [22:0]locali[0:5];
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<6;id=id+1)begin
				locali[id]<=0;
			end
		end
		else begin	
			locali[0]<= i0;
			locali[1]<= i1;
			locali[2]<= i2;
			locali[3]<= i3;
			locali[4]<= i4;
			locali[5]<= i5;
		end
	end		
			
	ADD3#(23)L1_0(.clk(clk),.rst_n(rst_n),.i0(locali[0]),.i1(locali[1]),.i2(locali[2]),.ADD3_out(L10),.ADD3_valid());
	ADD3#(23)L1_1(.clk(clk),.rst_n(rst_n),.i0(locali[3]),.i1(locali[4]),.i2(locali[5]),.ADD3_out(L11),.ADD3_valid());
	
	ADD2#(25)L2(.clk(clk),.rst_n(rst_n),.i0(L10),.i1(L11),.ADD3_out(B2out_tmp),.ADD3_valid(B2_valid));
	
	always@(*)begin
		B2out = {1'b0,B2out_tmp};
	end
	
endmodule

module B3(
	input clk,
	input rst_n,
	input [22:0]i0,
	input [22:0]i1,
	input [22:0]i2,
	output B3_valid,
	output [26:0]B3out
);
	wire [25:0]B3out_tmp;
	wire B3_valid_tmp;
	reg[24:0]L1;
	reg [22:0]locali[0:2];
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			locali[0]<= 0;
			locali[1]<= 0;
			locali[2]<= 0;
		end
		else begin	
			locali[0]<= i0;
			locali[1]<= i1;
			locali[2]<= i2;
		end
	end	
	
	ADD3#(23)L1_0(.clk(clk),.rst_n(rst_n),.i0(locali[0]),.i1(locali[1]),.i2(locali[2]),.ADD3_out(L1),.ADD3_valid(B3_valid_tmp));
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			B3out	<= 0;
			B3_valid<= 0;
		end
		else begin	
			B3out<= {2'b0,L1};
			B3_valid<= B3_valid_tmp;	
		end
	end	
	
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
	genvar id,idx;
	reg [45:0]fsa_res[0:63];
	/* FSA
	FSA#(.NO3(0),.NO5(0),.ID5(0),.NO7(0),.ID7(0))C0(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[0]),.FSAvalid());
	FSA#(.NO3(1),.NO5(0),.ID5(1),.NO7(0),.ID7(1))C1(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[1]),.FSAvalid());
	FSA#(.NO3(2),.NO5(0),.ID5(2),.NO7(0),.ID7(2))C2(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[2]),.FSAvalid());
	FSA#(.NO3(3),.NO5(0),.ID5(3),.NO7(0),.ID7(3))C3(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[3]),.FSAvalid());
	FSA#(.NO3(4),.NO5(1),.ID5(0),.NO7(0),.ID7(4))C4(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[4]),.FSAvalid());
	FSA#(.NO3(5),.NO5(1),.ID5(1),.NO7(0),.ID7(5))C5(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[5]),.FSAvalid());
	FSA#(.NO3(6),.NO5(1),.ID5(2),.NO7(0),.ID7(6))C6(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[6]),.FSAvalid());
	FSA#(.NO3(7),.NO5(1),.ID5(3),.NO7(0),.ID7(7))C7(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[7]),.FSAvalid());
	FSA#(.NO3(0),.NO5(2),.ID5(0),.NO7(0),.ID7(8))C8(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[8]),.FSAvalid());
	FSA#(.NO3(1),.NO5(2),.ID5(1),.NO7(0),.ID7(9))C9(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[9]),.FSAvalid());
	FSA#(.NO3(2),.NO5(2),.ID5(2),.NO7(0),.ID7(9))C10(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[10]),.FSAvalid());
	FSA#(.NO3(3),.NO5(2),.ID5(3),.NO7(0),.ID7(9))C11(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[11]),.FSAvalid());
	FSA#(.NO3(4),.NO5(3),.ID5(0),.NO7(0),.ID7(9))C12(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[12]),.FSAvalid());
	FSA#(.NO3(5),.NO5(3),.ID5(1),.NO7(0),.ID7(9))C13(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[13]),.FSAvalid());
	FSA#(.NO3(6),.NO5(3),.ID5(2),.NO7(0),.ID7(9))C14(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[14]),.FSAvalid());
	FSA#(.NO3(7),.NO5(3),.ID5(3),.NO7(0),.ID7(9))C15(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[15]),.FSAvalid());
	
	FSA#(.NO3(0),.NO5(0),.ID5(0),.NO7(1),.ID7(0))C16(.clk(clk),.rst_n(rst_n),.wsize(wsize),.stride(stride),.wround(wround),.data(),.FSAout(fsa_res[0]),.FSAvalid());
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
	*/
	generate
		for(id=0;id<4;id=id+1)begin
			for(idx=0;idx=4;idx=idx+1)begin
				A #(.NO5(idx))aa(.clk(clk),.rst_n(rst_n),.wround(wround),.stride(stride),.i0(fsa_res[id*4+idx*4]),.i1(fsa_res[id*4+idx*4+1]),.i2(fsa_res[id*4+idx*4+2]),.i3(fsa_res[id*4+idx*4+3]),.Aout(),.Avalid());
			end
		end
	endgenerate
	
	generate
		for(id=0;id<2;id=id+1)begin
			for(idx=0;idx=2;idx=idx+1)begin
				B #(.NO7(idx))bb(.clk(clk),.rst_n(rst_n),.wround(wround),.stride(stride),.i0(fsa_res[id*32+idx*16]),.i1(fsa_res[id*32+idx*16+1]),.i2(fsa_res[id*32+idx*16+2]),.i3(fsa_res[id*32+idx*16+3]),.i4(fsa_res[id*32+idx*16+4]),.i5(fsa_res[id*32+idx*16+5]),.i6(fsa_res[id*32+idx*16+6]),.i7(fsa_res[id*32+idx*16+7]),.i8(fsa_res[id*32+idx*16+8]),.Bout(),.Bvalid());
			end
		end
	endgenerate
	
endmodule
	