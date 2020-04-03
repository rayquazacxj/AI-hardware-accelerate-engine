module ADD2#(parameter N=16,RN=16)( 						// 1 cycle
	input clk,
	input rst_n,
	input [N-1:0]i0,
	input [N-1:0]i1,
	input i_valid, 	
	output reg ADD2_valid,
	output reg[RN-1:0]ADD2_out
);
	parameter HALF = N>>1;
	reg [N-1:0]locali0,locali1;
	reg [HALF:0]ADD2_out_1;
	reg [HALF+1:0]ADD2_out_2;
	reg ADD2_valid_dff1,ADD2_valid_dff2;
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			locali0<=0;
			locali1<=0;
		end
		else begin
			locali0<=i0;
			locali1<=i1;
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			ADD2_out_1<=0;
		end
		else begin
			ADD2_out_1 <= locali0[HALF-1:0] + locali1[HALF-1:0];
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			ADD2_out_2<=0;
		end
		else begin
			ADD2_out_2 <= locali0[N-1:HALF] + locali1[N-1:HALF];
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			ADD2_out<=0;
		end
		else begin
			ADD2_out <= {ADD2_out_2,{HALF{1'd0}}} + ADD2_out_1;
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
			ADD2_valid_dff1<=0;
			ADD2_valid_dff2<=0;
			ADD2_valid <=0;
		end
		else begin
			ADD2_valid_dff1<=i_valid;
			ADD2_valid_dff2<=ADD2_valid_dff1;
			ADD2_valid<=ADD2_valid_dff2;
		end
	end
		
endmodule

module ADD3#(parameter N=16,RN=16)(							// 1 cycle
	input clk,
	input rst_n,
	input [N-1:0]i0,
	input [N-1:0]i1,
	input [N-1:0]i2,
	input i_valid,
	output reg ADD3_valid,
	output reg[RN-1:0]ADD3_out
);
	parameter HALF = N>>1;
	reg [N-1:0]locali0,locali1,locali2;
	reg [HALF+1:0]ADD3_out_1;
	reg [HALF+2:0]ADD3_out_2;
	reg ADD3_valid_dff1,ADD3_valid_dff2;
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			locali0<=0;
			locali1<=0;
			locali2<=0;
		end
		else begin
			locali0<=i0;
			locali1<=i1;
			locali2<=i2;		
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			ADD3_out_1<=0;
		end
		else begin
			ADD3_out_1 <= locali0[HALF-1:0] + locali1[HALF-1:0]+ locali2[HALF-1:0];
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			ADD3_out_2<=0;
		end
		else begin
			ADD3_out_2 <= locali0[N-1:HALF] + locali1[N-1:HALF]+ locali2[N-1:HALF];
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			ADD3_out<=0;
		end
		else begin
			ADD3_out <= {ADD3_out_2,{HALF{1'd0}}} + ADD3_out_1;
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
			ADD3_valid_dff1<=0;
			ADD3_valid_dff2<=0;
			ADD3_valid <=0;
		end
		else begin
			ADD3_valid_dff1<=i_valid;
			ADD3_valid_dff2<=ADD3_valid_dff1;
			ADD3_valid<=ADD3_valid_dff2;
		end
	end
	/*
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			ADD3_out <= 0;
		end
		else begin
			ADD3_out <= locali0 + locali1 + locali2;
		end
	end*/
	
endmodule

module FA(											// 13 cycles
	input 	clk,
	input 	rst_n,
	input  	[383:0]data,
	input 	data_valid,
	output 	FAvalid,
	output 	reg[20:0]FAout
);
	parameter D1=16;
	parameter D2=32;
	parameter D3=48;
	genvar idx;
	
	wire L1_valid,L2_valid,L3_valid;
	wire [17:0]L1_res[0:7];
	wire [18:0]L2_res[0:3];
	wire [19:0]L3_res[0:1];
	
	wire [20:0] FAout_wire;
	wire FAvalid_wire;
	
	generate
		for(idx=0;idx<8;idx=idx+1)begin:FA_L1
			ADD3 #(16,18)L1(.clk(clk),.rst_n(rst_n),.i0(data[idx*D3 +:D1]),.i1(data[idx*D3+D1 +:D1]),.i2(data[idx*D3+D2 +:D1]),.i_valid(data_valid),.ADD3_valid(L1_valid),.ADD3_out(L1_res[idx]));
		end
		for(idx=0;idx<4;idx=idx+1)begin:FA_L2
			ADD2 #(18,19)L2(.clk(clk),.rst_n(rst_n),.i0(L1_res[idx*2]),.i1(L1_res[idx*2 +1]),.i_valid(L1_valid),.ADD2_valid(L2_valid),.ADD2_out(L2_res[idx]));
		end
		for(idx=0;idx<2;idx=idx+1)begin:FA_L3
			ADD2 #(19,20)L3(.clk(clk),.rst_n(rst_n),.i0(L2_res[idx*2]),.i1(L2_res[idx*2+1]),.i_valid(L2_valid),.ADD2_valid(L3_valid),.ADD2_out(L3_res[idx]));
		end		
	endgenerate
	
	ADD2 #(20,21)L4(.clk(clk),.rst_n(rst_n),.i0(L3_res[0]),.i1(L3_res[1]),.i_valid(L3_valid),.ADD2_valid(FAvalid_wire),.ADD2_out(FAout_wire));
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			FAout<=0;
			FAvalid<=0;
		end
		else begin
			FAout	<= FAout_wire;
			FAvalid<=FAvalid_wire;
		end	
	end
	
endmodule

module FSA#(parameter NO3=0,parameter NO5=0,parameter ID5=0,parameter NO7=0,parameter ID7=0)(
	input 	clk,
	input 	rst_n,
	input 	stride,
	input 	[3:0]wsize,
	input 	[2:0]wround,
	input  	[1151:0]data,
	input   data_valid,
	output 	reg FSAvalid,
	output 	reg [45:0]FSAout
);
	parameter FRONT = 23;
	parameter BACK = 0;
	parameter D1 = 23;
	
	wire FAvalid1,FAvalid2,FAvalid3;
	reg [20:0]row1,row2,row3;
	wire [20:0]row1_wire,row2_wire,row3_wire;
	//
	reg [45:0]FSAout_1,FSAout_1_dff1;
	reg [45:0]FSAout_3,FSAout_3_dff1;
	reg [45:0]FSAout_5;
	reg [45:0]FSAout_5_s0;
	reg [45:0]FSAout_5_s1;
	reg [45:0]FSAout_7;
	reg [45:0]FSAout_7_s0;
	reg [45:0]FSAout_7_s1;
	reg FAvalid;
	wire R1R2valid,R2R3valid,R1R2R3valid;
	wire [22:0]R1R2,R2R3,R1R2R3;
	reg [22:0]R1,R1_dff1,R1_dff2,R3_dff1,R3_dff2,R3;
	reg FSAvalid_dff1,FSAvalid_dff2;
	//
	
	/* FA ,  13 cycles */
	FA ROW1(.clk(clk),.rst_n(rst_n),.data(data[383:0]),.data_valid(data_valid),.FAout(row1_wire),.FAvalid(FAvalid1));
	FA ROW2(.clk(clk),.rst_n(rst_n),.data(data[767:384]),.data_valid(data_valid),.FAout(row2_wire),.FAvalid(FAvalid2));
	FA ROW3(.clk(clk),.rst_n(rst_n),.data(data[1151:768]),.data_valid(data_valid),.FAout(row3_wire),.FAvalid(FAvalid3));
	
	/* R1R2R3 */
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			row1<=0;
			row2<=0;
			row3<=0;
			FAvalid<= 0;
		end
		else begin
			row1<=row1_wire;
			row2<=row2_wire;
			row3<=row3_wire;
			FAvalid<= (FAvalid1 && FAvalid2 && FAvalid3);
		end	
	end
	
	//3 cycles
	ADD2 #(21,23)R1R2_(.clk(clk),.rst_n(rst_n),.i0(row1),.i1(row2),.i_valid(FAvalid),.ADD2_valid(R1R2valid),.ADD2_out(R1R2));
	ADD2 #(21,23)R2R3_(.clk(clk),.rst_n(rst_n),.i0(row2),.i1(row3),.i_valid(FAvalid),.ADD2_valid(R2R3valid),.ADD2_out(R2R3));
	ADD3 #(21,23)R1R2R3_(.clk(clk),.rst_n(rst_n),.i0(row1),.i1(row2),.i2(row3),.i_valid(FAvalid),.ADD3_valid(R1R2R3valid),.ADD3_out(R1R2R3));	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			R1_dff1<=0;
			R1_dff2<=0;
			R1<=0;
			
			R3_dff1<=0;
			R3_dff2<=0;
			R3<=0;
		end
		else begin
			R1_dff1<=row1;
			R1_dff2<=R1_dff1;
			R1<=R1_dff2;
			
			R3_dff1<=row3;
			R3_dff2<=R3_dff1;
			R3<=R3_dff2;
		end	
	end
	
	/* FSAout */
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			wround_dff1<=0;
			
			stride_dff1<=0;
			stride_dff2<=0;
			
			wsize_dff1<=0;
			wsize_dff2<=0;
			wsize_dff3<=0;
			
		end
		else begin						
			wround_dff1<=wround;
			
			stride_dff1<=stride;
			stride_dff2<=stride_dff1;
			
			wsize_dff1<=wsize;
			wsize_dff2<=wsize_dff1;
			wsize_dff3<=wsize_dff2;
			
		end	
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			FSAout_1<=0;
		end
		else begin
			FSAout_1[BACK +:D1]	<= R1R2R3;
		end	
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			FSAout_1_dff1<=0;
		end
		else begin
			FSAout_1_dff1<=FSAout_1;
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			FSAout_3<=0;
		end
		else begin
		//3 * 3    
			case(NO3)
				6:begin
					FSAout_3[FRONT +:D1] 	<= R3;
					FSAout_3[BACK +:D1] 	<= R1R2;
				end
				7:begin
					FSAout_3[FRONT +:D1] 	<= R1;
					FSAout_3[BACK +:D1]		<= R2R3;
				end
				default:begin
					FSAout_3[FRONT +:D1] 	<= 0;
					FSAout_3[BACK +:D1]		<= R1R2R3;
				end
			endcase
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			FSAout_3_dff1<=0;
		end
		else begin
			FSAout_3_dff1<=FSAout_3;
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			FSAout_5_s0<=0;
		end
		else begin 
			case(wround_dff1)
				0:begin
					FSAout_5_s0[FRONT +:D1] 	<= 0;
					FSAout_5_s0[BACK +:D1]		<= R1R2R3;
				end
				1:begin
					if((NO5==0 && (ID5==2 || ID5==3)) || (NO5==3 && (ID5==0 || ID5==1)))begin
						FSAout_5_s0[FRONT +:D1] 	<= R1;
						FSAout_5_s0[BACK +:D1]		<= R2R3;
					end
					else if(NO5==2 && (ID5==0 || ID5==1))begin
						FSAout_5_s0[FRONT +:D1] 	<= row3;
						FSAout_5_s0[BACK +:D1] 		<= R1R2;
					end
					else begin
						FSAout_5_s0[FRONT +:D1] 	<= 0;
						FSAout_5_s0[BACK +:D1]		<= R1R2R3;
					end
				end
			endcase
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			FSAout_5_s1<=0;
		end
		else begin 
			if(NO5==2 && (ID5==2 || ID5==3))begin
				FSAout_5_s1[FRONT +:D1] 	<= R1;
				FSAout_5_s1[BACK +:D1]		<= R2R3;
			end
			else if(NO5==3 && (ID5==0 || ID5==1))begin
				FSAout_5_s1[FRONT +:D1] 	<= row3;
				FSAout_5_s1[BACK +:D1] 		<= R1R2;
			end
			else begin
				FSAout_5_s1[FRONT +:D1] 	<= 0;
				FSAout_5_s1[BACK +:D1]		<= R1R2R3;
			end
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			FSAout_5<=0;
		end
		else begin 
			if(stride_dff2==0)FSAout_5<= FSAout_5_s0;
			else FSAout_5<= FSAout_5_s1;			
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			FSAout_7_s0<=0;
		end
		else begin 
			case(wround_dff1)
				0:begin
					FSAout_7_s0[FRONT +:D1] 	<= 0;
					FSAout_7_s0[BACK +:D1]		<= R1R2R3;
				end
				1:begin
					if(NO7==1 && (ID7==3 || ID7==4 || ID7==5))begin
						FSAout_7_s0[FRONT +:D1] 	<= row3;
						FSAout_7_s0[BACK +:D1] 		<= R1R2;
					end
					else begin
						FSAout_7_s0[FRONT +:D1] 	<= 0;
						FSAout_7_s0[BACK +:D1]		<= R1R2R3;
					end
				end
				2:begin
					if(NO7==0 && (ID7==3 || ID7==4 || ID7==5))begin
						FSAout_7_s0[FRONT +:D1] 	<= R1;
						FSAout_7_s0[BACK +:D1] 		<= R2R3;
					end
					else begin
						FSAout_7_s0[FRONT +:D1] 	<= 0;
						FSAout_7_s0[BACK +:D1]		<= R1R2R3;
					end
				end
				3:begin
					if(NO7==0 && (ID7==0 || ID7==1 || ID7==2))begin
						FSAout_7_s0[FRONT +:D1] 	<= row3;
						FSAout_7_s0[BACK +:D1] 		<= R1R2;
					end
					else if(NO7==1 && (ID7==0 || ID7==1 || ID7==2))begin
						FSAout_7_s0[FRONT +:D1] 	<= R1;
						FSAout_7_s0[BACK +:D1]		<= R2R3;
					end
					else begin
						FSAout_7_s0[FRONT +:D1] 	<= 0;
						FSAout_7_s0[BACK +:D1]		<= R1R2R3;
					end
				end
			endcase		
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			FSAout_7_s1<=0;
		end
		else begin 
			case(wround_dff1)
				0:begin
					FSAout_7_s1[FRONT +:D1] 	<= 0;
					FSAout_7_s1[BACK +:D1]		<= R1R2R3;
				end
				1:begin
					if(NO7==0 && (ID7==3 || ID7==4 || ID7==5))begin
						FSAout_7_s1[FRONT +:D1] 	<= R1;
						FSAout_7_s1[BACK +:D1] 		<= R2R3;
					end
					else if(NO7==1 && (ID7==0 || ID7==1 || ID7==2))begin
						FSAout_7_s1[FRONT +:D1] 	<= R3;
						FSAout_7_s1[BACK +:D1]		<= R1R2;
					end
					else begin
						FSAout_7_s1[FRONT +:D1] 	<= 0;
						FSAout_7_s1[BACK +:D1]		<= R1R2R3;
					end
				end
			endcase	
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			FSAout_7<=0;
		end
		else begin 
			if(stride_dff2==0)FSAout_7<= FSAout_7_s0;
			else FSAout_7<= FSAout_7_s1;			
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			FSAout<=0;		
		end
		else begin 
			case(wsize_dff3)
				0:FSAout<=FSAout_3_dff1;
				1:FSAout<=FSAout_5;
				2:FSAout<=FSAout_7;
				3:FSAout<=FSAout_1_dff1;
			endcase		
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			FSAvalid_dff1<=0;
			FSAvalid_dff2<=0;
		end
		else begin							
			FSAvalid_dff1<=(R1R2valid && R1R2R3valid && R2R3valid);
			FSAvalid_dff2<=FSAvalid_dff1;
			FSAvalid<=FSAvalid_dff2;	
		end	
	end
	
	
	/* SA ,  1 cycle  old*//*
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			FSAout<=0;
			FSAvalid<=0;
		end
		else begin
			FSAvalid<= (FAvalid1 && FAvalid2 && FAvalid3);
			
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
							if(NO5==2 && (ID5==2 || ID5==3))begin
								FSAout[FRONT +:D1] 	<= row1;
								FSAout[BACK +:D1]	<= row2 + row3;
							end
							else if(NO5==3 && (ID5==0 || ID5==1))begin
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
	end*/
	
endmodule

module A#(parameter NO5=0)(
	input clk,
	input rst_n,
	input stride,
	input [2:0]wround,
	input [45:0]i0_,
	input [45:0]i1_,
	input [45:0]i2_,
	input [45:0]i3_,
	input i_valid,
	output reg Avalid,
	output reg [53:0]Aout
);
	parameter FRONT = 23;
	parameter BACK = 0;
	parameter FRONT_OUT = 27;
	parameter D1 = 23;
	parameter D1_OUT = 27;
	
	
	reg [45:0]i0,i1,i2,i3;
	reg[22:0]A1i[0:3];
	reg[22:0]A2_0i[0:1];
	reg[22:0]A2_1i[0:1];
	
	//
	reg[22:0]A1i_s0[0:3];
	reg[22:0]A1i_s0r0[0:3];
	reg[22:0]A1i_s0r1[0:3];
	reg[22:0]A1i_s1[0:3];
	reg[22:0]A1i_s1_dff[0:3];
	reg[22:0]A2_0i_dff[0:1];
	reg[22:0]A2_0i_dff1[0:1];
	reg[22:0]A2_0i_s0[0:1];
	reg[22:0]A2_0i_s1[0:1];
	reg[22:0]A2_1i_dff1[0:1];
	reg[22:0]A2_1i_dff2[0:1];

	
	reg [53:0]Aout_s0;
	reg [53:0]Aout_s0r0;
	reg [53:0]Aout_s0r1;
	reg [53:0]Aout_s1;
	reg [53:0]Aout_s1_dff1;
	
	reg [2:0]wround_dff1,wround_dff2,wround_dff3,wround_dff4,wround_dff5,wround_dff6,wround_dff7,wround_dff8,wround_dff9,wround_dff10,wround_dff11,wround_dff12,wround_dff13;
	reg stride_dff1,stride_dff2,stride_dff3,stride_dff4,stride_dff5,stride_dff6,stride_dff7,stride_dff8,stride_dff9,stride_dff10,stride_dff11,stride_dff12,stride_dff13;
	
	reg i_valid_dff1,i_valid_dff2,i_valid_dff3,i_valid_dff4;
	reg Avalid_dff1,Avalid_dff2;
	//
	
	//reg i_valid_tmp,i_valid_;
	//reg [2:0]wround_,wround_cnt1,wround_cnt2,wround_cnt3;
	//reg stride_,stride_cnt1,stride_cnt2,stride_cnt3;
	
	wire[26:0]A1out,A2_0out,A2_1out;
	wire A1valid,A2_0valid,A2_1valid;
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			i0<=0;
			i1<=0;
			i2<=0;
			i3<=0;
		end
		else begin
			i0<=i0_;
			i1<=i1_;
			i2<=i2_;
			i3<=i3_;
		/*
			i_valid_tmp <= i_valid;
			i_valid_    <= i_valid_tmp;
			if(i_valid)begin
				i0<=i0_;
				i1<=i1_;
				i2<=i2_;
				i3<=i3_;
			end*/
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			i_valid_dff1 <= 0;
			i_valid_dff2 <= 0;
			i_valid_dff3 <= 0;
			i_valid_dff4 <= 0;
		end
		else begin
			i_valid_dff1 <= i_valid;
			i_valid_dff2 <= i_valid_dff1;
			i_valid_dff3 <= i_valid_dff2;
			i_valid_dff4 <= i_valid_dff3;
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			stride_dff1<=0;
			stride_dff2<=0;
			stride_dff3<=0;
			stride_dff4<=0;
			stride_dff5<=0;
			stride_dff6<=0;
			stride_dff7<=0;
			stride_dff8<=0;
			stride_dff9<=0;
			stride_dff10<=0;
			stride_dff11<=0;
			stride_dff12<=0;
			stride_dff13<=0;
			
			wround_dff1<=0;
			wround_dff2<=0;
			wround_dff3<=0;
			wround_dff4<=0;
			wround_dff5<=0;
			wround_dff6<=0;
			wround_dff7<=0;
			wround_dff8<=0;
			wround_dff9<=0;
			wround_dff10<=0;
			wround_dff11<=0;
			wround_dff12<=0;
			wround_dff13<=0;			
		end
		else begin
			wround_dff1<=wround;
			wround_dff2<=wround_dff1;
			wround_dff3<=wround_dff2;
			wround_dff4<=wround_dff3;
			wround_dff5<=wround_dff4;
			wround_dff6<=wround_dff5;
			wround_dff7<=wround_dff6;
			wround_dff8<=wround_dff7;
			wround_dff9<=wround_dff8;
			wround_dff10<=wround_dff9;
			wround_dff11<=wround_dff10;
			wround_dff12<=wround_dff11;
			wround_dff13<=wround_dff12;
						
			stride_dff1<=stride;
			stride_dff2<=stride_dff1;
			stride_dff3<=stride_dff2;
			stride_dff4<=stride_dff3;
			stride_dff5<=stride_dff4;
			stride_dff6<=stride_dff5;
			stride_dff7<=stride_dff6;
			stride_dff8<=stride_dff7;
			stride_dff9<=stride_dff8;
			stride_dff10<=stride_dff9;
			stride_dff11<=stride_dff10;
			stride_dff12<=stride_dff11;
			stride_dff13<=stride_dff12;			
		end
	end
	
	/* A1 input */
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A1i_s0r0[0]<=0;
			A1i_s0r0[1]<=0;
			A1i_s0r0[2]<=0;
			A1i_s0r0[3]<=0;
		end
		else begin		
			A1i_s0r0[0]<=i0[BACK +: D1];
			A1i_s0r0[1]<=i1[BACK +: D1];
			A1i_s0r0[2]<=i2[BACK +: D1];
			A1i_s0r0[3]<=i3[BACK +: D1];			
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A1i_s0r1[0]<=0;
			A1i_s0r1[1]<=0;
			A1i_s0r1[2]<=0;
			A1i_s0r1[3]<=0;
		end
		else begin		
			case(NO5)
				0,1:begin
					A1i_s0r1[0]<=i0[BACK +: D1];
					A1i_s0r1[1]<=i1[BACK +: D1];
					A1i_s0r1[2]<=i2[FRONT +: D1];
					A1i_s0r1[3]<=i3[FRONT +: D1];
				end
				//1:no!
				2:begin
					A1i_s0r1[0]<=i0[FRONT +: D1];
					A1i_s0r1[1]<=i1[FRONT +: D1];
					A1i_s0r1[2]<=i2[BACK +: D1];
					A1i_s0r1[3]<=i3[BACK +: D1];
				end
				3:begin
					A1i_s0r1[0]<=i0[BACK +: D1];
					A1i_s0r1[1]<=i1[BACK +: D1];
					A1i_s0r1[2]<=i2[BACK +: D1];
					A1i_s0r1[3]<=i3[BACK +: D1];
				end
			endcase			
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A1i_s0[0]<=0;
			A1i_s0[1]<=0;
			A1i_s0[2]<=0;
			A1i_s0[3]<=0;
		end
		else begin		
			if(wround_dff2 == 0)begin
				A1i_s0[0]<=A1i_s0r0[0];
				A1i_s0[1]<=A1i_s0r0[1];
				A1i_s0[2]<=A1i_s0r0[2];
				A1i_s0[3]<=A1i_s0r0[3];
			end
			else begin
				A1i_s0[0]<=A1i_s0r1[0];
				A1i_s0[1]<=A1i_s0r1[1];
				A1i_s0[2]<=A1i_s0r1[2];
				A1i_s0[3]<=A1i_s0r1[3];
			end
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A1i_s1[0]<=0;
			A1i_s1[1]<=0;
			A1i_s1[2]<=0;
			A1i_s1[3]<=0;
		end
		else begin		
			if(NO5==2)begin
				A1i_s1[0]<=i0[BACK +: D1];
				A1i_s1[1]<=i1[BACK +: D1];
				A1i_s1[2]<=i2[FRONT +: D1];
				A1i_s1[3]<=i3[FRONT +: D1];
			end
			else begin
				A1i_s1[0]<=i0[BACK +: D1];
				A1i_s1[1]<=i1[BACK +: D1];
				A1i_s1[2]<=i2[BACK +: D1];
				A1i_s1[3]<=i3[BACK +: D1];
			end		
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A1i_s1_dff[0]<=0;
			A1i_s1_dff[1]<=0;
			A1i_s1_dff[2]<=0;
			A1i_s1_dff[3]<=0;
		end
		else begin			
			A1i_s1_dff[0]<=A1i_s1[0];
			A1i_s1_dff[1]<=A1i_s1[1];
			A1i_s1_dff[2]<=A1i_s1[2];
			A1i_s1_dff[3]<=A1i_s1[3];		
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A1i[0]<=0;
			A1i[1]<=0;
			A1i[2]<=0;
			A1i[3]<=0;
		end
		else begin	
			if(stride_dff3 == 0)begin
				A1i[0]<=A1i_s0[0];
				A1i[1]<=A1i_s0[1];
				A1i[2]<=A1i_s0[2];
				A1i[3]<=A1i_s0[3];
			end
			else begin
				A1i[0]<=A1i_s1_dff[0];
				A1i[1]<=A1i_s1_dff[1];
				A1i[2]<=A1i_s1_dff[2];
				A1i[3]<=A1i_s1_dff[3];
			end		
		end
	end
	
	
	/* A1 input old*//*
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A1i[0]<=0;
			A1i[1]<=0;
			A1i[2]<=0;
			A1i[3]<=0;
		end
		else begin
			case(stride_)
				0:begin
					case(wround_)
						0:begin
							A1i[0]<=i0[BACK +: D1];
							A1i[1]<=i1[BACK +: D1];
							A1i[2]<=i2[BACK +: D1];
							A1i[3]<=i3[BACK +: D1];
						end
						1:begin
							case(NO5)
								0,1:begin
									A1i[0]<=i0[BACK +: D1];
									A1i[1]<=i1[BACK +: D1];
									A1i[2]<=i2[FRONT +: D1];
									A1i[3]<=i3[FRONT +: D1];
								end
								//1:no!
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
	*/
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A2_0i_s0[0]<=0;
			A2_0i_s0[1]<=0;
		end
		else begin   //A2_0i_s0 doesn't need s0r0 (go to default)
			case(NO5)
				0:begin
					A2_0i_s0[0]<=i2[BACK +: D1];
					A2_0i_s0[1]<=i3[BACK +: D1];
				end
				3:begin
					A2_0i_s0[0]<=i0[FRONT +: D1];
					A2_0i_s0[1]<=i1[FRONT +: D1];
				end
				default:begin
					A2_0i_s0[0]<=i0[BACK +: D1];
					A2_0i_s0[1]<=i1[BACK +: D1];
				end
			endcase
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A2_0i_s1[0]<=0;
			A2_0i_s1[1]<=0;
		end
		else begin   
			case(NO5)
				2:begin
					A2_0i_s1[0]<=i2[BACK +: D1];
					A2_0i_s1[1]<=i3[BACK +: D1];
				end
				3:begin
					A2_0i_s1[0]<=i0[BACK +: D1];
					A2_0i_s1[1]<=i1[BACK +: D1];
				end
				default:begin //default:no!!
					A2_0i_s1[0]<=0;
					A2_0i_s1[1]<=0;
				end
			endcase
		end
	end	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A2_0i[0]<=0;
			A2_0i[1]<=0;
		end
		else begin  
			if(stride_dff2== 0)begin
				A2_0i[0]<=A2_0i_s0[0];
				A2_0i[1]<=A2_0i_s0[1];
			end
			else begin
				A2_0i[0]<=A2_0i_s1[0];
				A2_0i[1]<=A2_0i_s1[1];
			end
		end
	end	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A2_0i_dff[0]<=0;
			A2_0i_dff[1]<=0;
		end
		else begin  
			A2_0i_dff[0]<=A2_0i[0];
			A2_0i_dff[1]<=A2_0i[1];
		end
	end	
	
	/* A2_0 input old*//*

	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A2_0i[0]<=0;
			A2_0i[1]<=0;
		end
		else begin			
			case(stride_)
				0:begin
					case(wround_)
						0:begin //0:no!!
							A2_0i[0]<=0;
							A2_0i[1]<=0;
						end
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
						default:begin //default:no!!
							A2_0i[0]<=0;
							A2_0i[1]<=0;
						end
					endcase
				end
			endcase
		end
	end*/
	
	/* A2_1i input */
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A2_1i[0]<=0;
			A2_1i[1]<=0;
		end
		else begin	
			if(stride_dff1 ==0 && wround_dff1 ==1 && NO5==1)begin
				A2_1i[0]<=i2[BACK +: D1];
				A2_1i[1]<=i3[BACK +: D1];
			end
			else begin //else no!!
				A2_1i[0]<=0;
				A2_1i[1]<=0;
			end
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A2_1i_dff1[0]<=0;
			A2_1i_dff2[0]<=0;
			
			A2_1i_dff1[1]<=0;
			A2_1i_dff2[1]<=0;
			
		end
		else begin	
			A2_1i_dff1[0]<=A2_1i[0];
			A2_1i_dff2[0]<=A2_1i_dff1[0];
			
			A2_1i_dff1[1]<=A2_1i[1];
			A2_1i_dff2[1]<=A2_1i_dff1[1];
			
		end
	end
	
//-----------------------------------------------------
	/* module instantiation */
	
	A1 a1(.clk(clk),.rst_n(rst_n),.i0(A1i[0]),.i1(A1i[1]),.i2(A1i[2]),.i3(A1i[3]),.i_valid(i_valid_dff4),.A1valid(A1valid),.A1out(A1out));
	A2_0 a2_0(.clk(clk),.rst_n(rst_n),.i0(A2_0i_dff1[0]),.i1(A2_0i_dff1[1]),.i_valid(i_valid_dff4),.A2_0valid(A2_0valid),.A2_0out(A2_0out));
	A2_1 a2_1(.clk(clk),.rst_n(rst_n),.i0(A2_1i_dff2[0]),.i1(A2_1i_dff2[1]),.i_valid(i_valid_dff4),.A2_1valid(A2_1valid),.A2_1out(A2_1out));
	
//-----------------------------------------------------	
	/* A output */
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			Aout_s0r1<=0;	
		end
		else begin
			case(NO5)
				0:begin
					Aout_s0r1[BACK +: D1_OUT] <= A1out;
					Aout_s0r1[FRONT_OUT +: D1_OUT]<= A2_0out;
				end
				1:begin
					Aout_s0r1[BACK +: D1_OUT] <= A2_0out;
					Aout_s0r1[FRONT_OUT +: D1_OUT]<= A2_1out;
				end
				default:begin
					Aout_s0r1[BACK +: D1_OUT] <= A2_0out;
					Aout_s0r1[FRONT_OUT +: D1_OUT]<= A1out;
				end
			endcase
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			Aout_s0r0<=0;	
		end
		else begin
			Aout_s0r0[BACK +: D1_OUT] <= A1out;
			Aout_s0r0[FRONT_OUT +: D1_OUT]<=0;
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			Aout_s0<=0;	
		end
		else begin
			if(wround_dff12==0)begin
				Aout_s0[BACK +: D1_OUT] <= Aout_s0r0[BACK +: D1_OUT];
				Aout_s0[FRONT_OUT +: D1_OUT]<=Aout_s0r0[FRONT_OUT +: D1_OUT];
			end
			else begin
				Aout_s0[BACK +: D1_OUT] <= Aout_s0r1[BACK +: D1_OUT];
				Aout_s0[FRONT_OUT +: D1_OUT]<=Aout_s0r1[FRONT_OUT +: D1_OUT];
			end
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			Aout_s1<=0;	
		end
		else begin
			case(NO5)
				2:begin
					Aout_s1[BACK +: D1_OUT] <= A1out;
					Aout_s1[FRONT_OUT +: D1_OUT]<= A2_0out;
				end
				3:begin
					Aout_s1[BACK +: D1_OUT] <= A2_0out;
					Aout_s1[FRONT_OUT +: D1_OUT]<= A1out;
				end
				default:begin
					Aout_s1[BACK +: D1_OUT] <= A1out;
					Aout_s1[FRONT_OUT +: D1_OUT]<= 0;
				end
			endcase
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			Aout_s1_dff1<=0;	
		end
		else begin
			Aout_s1_dff1<=Aout_s1;	
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			Aout<=0;	
		end
		else begin
			if(stride_dff13 ==0)begin
				Aout<=Aout_s0;
			end
			else begin
				Aout<=Aout_s1_dff1;
			end
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			Avalid_dff1<=0;	
			Avalid_dff2<=0;	
			Avalid<=0;	
		end
		else begin
			Avalid_dff1<=(A1valid && A2_0valid && A2_1valid);	
			Avalid_dff2<=Avalid_dff1;	
			Avalid<=Avalid_dff2;	
		end
	end
	/* A output old*/
	/*
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			Aout<=0;
			Avalid<=0;
		end
		else begin
		
			if(A1valid || A2_0valid || A2_1valid)Avalid<=1;
			else Avalid<=0;
			
			case(stride_cnt3)
				0:begin
					case(wround_cnt3)
						0:begin
							Aout[BACK +: D1_OUT] <= A1out;
							Aout[FRONT_OUT +: D1_OUT]<=0;
						end
						1:begin
							case(NO5)
								0:begin
									Aout[BACK +: D1_OUT] <= A1out;
									Aout[FRONT_OUT +: D1_OUT]<= A2_0out;
								end
								1:begin
									Aout[BACK +: D1_OUT] <= A2_0out;
									Aout[FRONT_OUT +: D1_OUT]<= A2_1out;
								end
								default:begin
									Aout[BACK +: D1_OUT] <= A2_0out;
									Aout[FRONT_OUT +: D1_OUT]<= A1out;
								end
							endcase
						end
					endcase
				end
				1:begin		//stride 2
					case(NO5)
						2:begin
							Aout[BACK +: D1_OUT] <= A1out;
							Aout[FRONT_OUT +: D1_OUT]<= A2_0out;
						end
						3:begin
							Aout[BACK +: D1_OUT] <= A2_0out;
							Aout[FRONT_OUT +: D1_OUT]<= A1out;
						end
						default:begin
							Aout[BACK +: D1_OUT] <= A1out;
							Aout[FRONT_OUT +: D1_OUT]<= 0;
						end
					endcase
				end
			endcase
		end
	end
		*/					
endmodule

module A1(
	input clk,
	input rst_n,
	input [22:0]i0,
	input [22:0]i1,
	input [22:0]i2,
	input [22:0]i3,
	input i_valid,
	output A1valid,
	output reg [26:0]A1out
);
	reg [22:0]locali[0:3];
	reg i_valid_;
	
	wire[24:0]A1out_tmp;
	wire [23:0]L10,L11;
	wire L10_valid,L11_valid;

	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			locali[0]<= 0;
			locali[1]<= 0;
			locali[2]<= 0;
			locali[3]<= 0;
			i_valid_ <= 0;
		end
		else begin	
			locali[0]<= i0;
			locali[1]<= i1;
			locali[2]<= i2;
			locali[3]<= i3;
			i_valid_ <= i_valid;
		end
	end	
	
	ADD2 #(23,24)L1_0(.clk(clk),.rst_n(rst_n),.i0(locali[0]),.i1(locali[1]),.i_valid(i_valid_),.ADD2_out(L10),.ADD2_valid(L10_valid));
	ADD2 #(23,24)L1_1(.clk(clk),.rst_n(rst_n),.i0(locali[2]),.i1(locali[3]),.i_valid(i_valid_),.ADD2_out(L11),.ADD2_valid(L11_valid));
	ADD2 #(24,25)L2(.clk(clk),.rst_n(rst_n),.i0(L10),.i1(L11),.i_valid((L11_valid & L10_valid)),.ADD2_out(A1out_tmp),.ADD2_valid(A1valid));
	
	
	always@(*)begin
		A1out = {2'b0,A1out_tmp};
	end
	
	
endmodule

module A2_0(
	input clk,
	input rst_n,
	input [22:0]i0,
	input [22:0]i1,
	input i_valid,
	output reg A2_0valid,
	output reg [26:0]A2_0out
);
	
	reg [22:0]locali[0:1];
	reg i_valid_;
	wire [23:0]L1_res;
	wire L1_valid;
	
	reg A2_0valid_dff1,A2_0valid_dff2;
	reg [26:0]A2_0out_dff1,A2_0out_dff2;
	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			locali[0]<= 0;
			locali[1]<= 0;
			i_valid_ <= 0;
		end
		else begin	
			locali[0]<= i0;
			locali[1]<= i1;
			i_valid_ <= i_valid;
		end
	end	
	
	ADD2 #(23,24)L1(.clk(clk),.rst_n(rst_n),.i0(locali[0]),.i1(locali[1]),.i_valid(i_valid_),.ADD2_out(L1_res),.ADD2_valid(L1_valid));
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A2_0out_dff1<=0;
			A2_0out_dff2<=0;
			A2_0out	 <=0;
			
			A2_0valid_dff1<=0;
			A2_0valid_dff2<=0;
			A2_0valid<=0;
		end
		else begin	
			A2_0out_dff1<= {3'b0,L1_res};
			A2_0out_dff2<= A2_0out_dff1;
			A2_0out	 <=A2_0out_dff2;
			
			A2_0valid_dff1<= L1_valid;
			A2_0valid_dff2<= A2_0valid_dff1;
			A2_0valid<= A2_0valid_dff2;
		end
	end
	
endmodule

module A2_1(
	input clk,
	input rst_n,
	input [22:0]i0,
	input [22:0]i1,
	input i_valid,
	output reg A2_1valid,
	output reg [26:0]A2_1out
);
	reg [22:0]locali[0:1];
	reg i_valid_;
	
	wire [23:0]L1_res;
	wire L1_valid;
	
	reg A2_1valid_dff1,A2_1valid_dff2;
	reg [26:0]A2_1out_dff1,A2_1out_dff2;
	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			locali[0]<= 0;
			locali[1]<= 0;
			i_valid_ <= 0;
		end
		else begin	
			locali[0]<= i0;
			locali[1]<= i1;
			i_valid_ <= i_valid;
		end
	end	
	
	ADD2 #(23,24)L1(.clk(clk),.rst_n(rst_n),.i0(locali[0]),.i1(locali[1]),.i_valid(i_valid),.ADD2_out(L1_res),.ADD2_valid(L1_valid));
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			A2_1out_dff1<=0;
			A2_1out_dff2<=0;
			A2_1out	 <=0;
			
			A2_1valid_dff1<=0;
			A2_1valid_dff2<=0;
			A2_1valid<=0;
		end
		else begin	
			A2_1out_dff1<= {3'b0,L1_res};
			A2_1out_dff2<= A2_1out_dff1;
			A2_1out	 <=A2_1out_dff2;
			
			A2_1valid_dff1<= L1_valid;
			A2_1valid_dff2<= A2_1valid_dff1;
			A2_1valid<= A2_1valid_dff2;
		end
	end

endmodule

module B#(parameter NO7=0)(
	input clk,
	input rst_n,
	input stride,
	input [2:0]wround,
	input [413:0]data_, //46 * 9 
	input data_valid,
	output reg Bvalid,
	output reg [53:0]Bout
);
	parameter FRONT = 23;
	parameter FRONT_OUT = 27;
	parameter BACK = 0;
	parameter D1 = 23;
	parameter D2 = 46;
	parameter D1_OUT = 27;
	integer id,idx;
	
	reg[413:0]data;
	reg[22:0]B1i[0:8];
	reg[22:0]B2_0i[0:5];
	reg[22:0]B2_1i[0:5];
	reg[22:0]B3i[0:2];
	reg data_valid_tmp,data_valid_;
	
	//
	reg [2:0]wround_dff1,wround_dff2,wround_dff3,wround_dff4,wround_dff5,wround_dff6,wround_dff7,wround_dff8,wround_dff9,wround_dff10,wround_dff11,wround_dff12;
	reg stride_dff1,stride_dff2,stride_dff3,stride_dff4,stride_dff5,stride_dff6,stride_dff7,stride_dff8,stride_dff9,stride_dff10,stride_dff11,stride_dff12;
	reg[22:0]B1i_dff1[0:8];
	reg[22:0]B1i_dff2[0:8];
	reg[22:0]B2_0i_s0[0:5];
	reg[22:0]B2_0i_s0r013[0:5];
	reg[22:0]B2_0i_s0r2[0:5];
	reg[22:0]B2_0i_s1[0:5];
	reg[22:0]B2_0i_s1_dff[0:5];
	reg[22:0]B2_1i_dff1[0:5];
	reg[22:0]B2_1i_dff2[0:5];
	reg[22:0]B3i_dff1[0:2];
	reg[22:0]B3i_dff2[0:2];
	reg [53:0]Bout_s0,Bout_s1;
	
	reg data_valid_dff1,data_valid_dff2,data_valid_dff3,data_valid_dff4;
	
	reg Bvalid_dff1,Bvalid_dff2;
	//
	
	//reg [2:0]wround_,wround_cnt1,wround_cnt2,wround_cnt3;
	//reg stride_,stride_cnt1,stride_cnt2,stride_cnt3;
	
	wire[26:0]B1out,B2_0out,B2_1out,B3out;
	wire B1out_valid,B2_0out_valid,B2_1out_valid,B3out_valid;
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			data<=0;
		end
		else begin
			data<=data_;
			/*
			if(data_valid)begin
				data<=data_;
			end*/			
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			data_valid_dff1 <= 0;
			data_valid_dff2 <= 0;
			data_valid_dff3 <= 0;
			data_valid_dff4 <= 0;
		end
		else begin
			data_valid_dff1 <= data_valid;
			data_valid_dff2 <= data_valid_dff1;
			data_valid_dff3 <= data_valid_dff2;
			data_valid_dff4 <= data_valid_dff3;
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			stride_dff1<=0;
			stride_dff2<=0;
			stride_dff3<=0;
			stride_dff4<=0;
			stride_dff5<=0;
			stride_dff6<=0;
			stride_dff7<=0;
			stride_dff8<=0;
			stride_dff9<=0;
			stride_dff10<=0;
			stride_dff11<=0;
			stride_dff12<=0;
			
			
			wround_dff1<=0;
			wround_dff2<=0;
			wround_dff3<=0;
			wround_dff4<=0;
			wround_dff5<=0;
			wround_dff6<=0;
			wround_dff7<=0;
			wround_dff8<=0;
			wround_dff9<=0;
			wround_dff10<=0;
			wround_dff11<=0;
			wround_dff12<=0;
			
		end
		else begin
			wround_dff1<=wround;
			wround_dff2<=wround_dff1;
			wround_dff3<=wround_dff2;
			wround_dff4<=wround_dff3;
			wround_dff5<=wround_dff4;
			wround_dff6<=wround_dff5;
			wround_dff7<=wround_dff6;
			wround_dff8<=wround_dff7;
			wround_dff9<=wround_dff8;
			wround_dff10<=wround_dff9;
			wround_dff11<=wround_dff10;
			wround_dff12<=wround_dff11;			
						
			stride_dff1<=stride;
			stride_dff2<=stride_dff1;
			stride_dff3<=stride_dff2;
			stride_dff4<=stride_dff3;
			stride_dff5<=stride_dff4;
			stride_dff6<=stride_dff5;
			stride_dff7<=stride_dff6;
			stride_dff8<=stride_dff7;
			stride_dff9<=stride_dff8;
			stride_dff10<=stride_dff9;
			stride_dff11<=stride_dff10;
			stride_dff12<=stride_dff11;			
		end
	end
	
	/* B1 input */	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<9;id=id+1)begin
				B1i[id]<=0;
			end
		end
		else begin	
			if((stride_dff1==0 && NO7==0 && wround_dff1==3)||(stride_dff1==1 && NO7==1 && wround_dff1==1))begin
				for(id=0;id<3;id=id+1)begin
					B1i[id]<=data[FRONT+id*D2 +: D1];
				end
				for(idx=3;idx<9;idx=idx+1)begin
					B1i[idx]<=data[BACK+idx*D2 +: D1];
				end
			end
			else begin
				for(id=0;id<9;id=id+1)begin
					B1i[id]<=data[BACK+id*D2 +: D1];
				end
			end
		end			
		/* no
			case(stride)
				0:begin
					case(wround)
						1:begin
							for(id=0;id<9;id=id+1)begin
								B1i[id]<=data[BACK+id*D2 +: D1];
							end
						end
						4:begin
							if(NO7==0)begin
								for(id=0;id<3;id=id+1)begin
									B1i[id]<=data[FRONT+id*D2 +: D1];
								end
								for(idx=3;idx<9;idx=idx+1)begin
									B1i[idx]<=data[BACK+id*D2 +: D1];
								end
							end
							else begin
								for(id=0;id<9;id=id+1)begin
									B1i[id]<=data[BACK+id*D2 +: D1];
								end
							end
						end
						default:no!!
					endcase
				end
				1:begin
					if(wround==0 && NO7==0)begin
						for(idx=0;idx<9;idx=idx+1)begin
							B1i[idx]<=data[BACK+id*D2 +: D1];
						end
					end
					else if(wround==1 && NO7==1)begin
						for(id=0;id<3;id=id+1)begin
							B1i[id]<=data[FRONT+id*D2 +: D1];
						end
						for(idx=3;idx<9;idx=idx+1)begin
							B1i[idx]<=data[BACK+id*D2 +: D1];
						end
					end
					else no!!
				end
			endcase
		end*/
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<9;id=id+1)begin
				B1i_dff1[id]<=0;
				B1i_dff2[id]<=0;
			end
		end
		else begin	
			for(id=0;id<9;id=id+1)begin
				B1i_dff1[id]<=B1i[id];
				B1i_dff2[id]<=B1i_dff1[id];
			end
		end	
	end
	
	/* B2_0 input */
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<6;id=id+1)begin
				B2_0i_s0r2[id]<=0;
			end
		end
		else begin	
			case(NO7)
				0:begin
					for(id=0;id<3;id=id+1)begin
						B2_0i_s0r2[id]<=data[BACK+id*D2 +: D1];
					end
					for(idx=3;idx<6;idx=idx+1)begin
						B2_0i_s0r2[idx]<=data[FRONT+idx*D2 +: D1];
					end
				end
				1:begin
					for(id=0;id<6;id=id+1)begin
						B2_0i_s0r2[id]<=data[BACK+id*D2+3*D2 +: D1]; // i3~i8
					end
				end
			endcase				
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<6;id=id+1)begin
				B2_0i_s0r013[id]<=0;
			end
		end
		else begin		
			for(id=0;id<6;id=id+1)begin
				B2_0i_s0r013[id]<=data[BACK+id*D2 +: D1];
			end		
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<6;id=id+1)begin
				B2_0i_s0[id]<=0;
			end
		end
		else begin	
			if(wround_dff2==2)begin	
				for(id=0;id<6;id=id+1)begin
					B2_0i_s0[id]<=B2_0i_s0r2[id];
				end	
			end
			else begin
				for(id=0;id<6;id=id+1)begin
					B2_0i_s0[id]<=B2_0i_s0r013[id];
				end	
			end
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<6;id=id+1)begin
				B2_0i_s1[id]<=0;
			end
		end
		else begin	
			if(NO7==1 && wround_dff1==0)begin
				for(id=0;id<6;id=id+1)begin
					B2_0i_s1[id]<=data[BACK+id*D2 +: D1];
				end
			end
			else begin
				for(id=0;id<3;id=id+1)begin
					B2_0i_s1[id]<=data[BACK+id*D2 +: D1];
				end
				for(idx=3;idx<6;idx=idx+1)begin
					B2_0i_s1[idx]<=data[FRONT+idx*D2 +: D1];
				end
			end
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<6;id=id+1)begin
				B2_0i_s1_dff[id]<=0;
			end
		end
		else begin	
			for(id=0;id<6;id=id+1)begin
				B2_0i_s1_dff[id]<=B2_0i_s1[id];
			end
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<6;id=id+1)begin
				B2_0i[id]<=0;
			end
		end
		else begin	
			if(stride_dff3==0)begin	
				for(id=0;id<6;id=id+1)begin
					B2_0i[id]<=B2_0i_s0[id];
				end	
			end
			else begin
				for(id=0;id<6;id=id+1)begin
					B2_0i[id]<=B2_0i_s1_dff[id];
				end	
			end
		end
	end
	
	
	/* B2_0 input old*/
	/*
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<6;id=id+1)begin
				B2_0i[id]<=0;
			end
		end
		else begin	
			case(stride_)
				0:begin
					case(wround_)
						1:begin
							for(id=0;id<6;id=id+1)begin
								B2_0i[id]<=data[BACK+id*D2 +: D1];
							end
						end
						2:begin
							case(NO7)
								0:begin
									for(id=0;id<3;id=id+1)begin
										B2_0i[id]<=data[BACK+id*D2 +: D1];
									end
									for(idx=3;idx<6;idx=idx+1)begin
										B2_0i[idx]<=data[FRONT+idx*D2 +: D1];
									end
								end
								1:begin
									for(id=0;id<6;id=id+1)begin
										B2_0i[id]<=data[BACK+id*D2+3*D2 +: D1]; // i3~i8
									end
								end
							endcase
						end
						default:begin //no!
						end
					endcase
				end
				1:begin
					if(NO7==1 && wround_==0)begin
						for(id=0;id<6;id=id+1)begin
							B2_0i[id]<=data[BACK+id*D2 +: D1];
						end
					end
					else begin
						for(id=0;id<3;id=id+1)begin
							B2_0i[id]<=data[BACK+id*D2 +: D1];
						end
						for(idx=3;idx<6;idx=idx+1)begin
							B2_0i[idx]<=data[FRONT+idx*D2 +: D1];
						end
					end
				end
			endcase
		end
	end
	*/
	
	/* B2_1 input */
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<6;id=id+1)begin
				B2_1i[id]<=0;
			end
		end
		else begin	
			if(stride_dff1==0 && NO7==1 && wround_dff1==1)begin
				for(id=0;id<3;id=id+1)begin
					B2_1i[id]<=data[FRONT+id*D2+3*D2 +: D1]; // i3 ~ i5
				end
				for(idx=3;idx<6;idx=idx+1)begin
					B2_1i[idx]<=data[BACK+idx*D2+3*D2 +: D1];
				end
			end
			else begin
				for(id=0;id<6;id=id+1)begin
					B2_1i[id]<=data[BACK+id*D2+3*D2 +: D1]; // i3~i8
				end
			end
		end
	end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<6;id=id+1)begin
				B2_1i_dff1[id]<=0;
				B2_1i_dff2[id]<=0;
			end
		end
		else begin	
			for(id=0;id<6;id=id+1)begin
				B2_1i_dff1[id]<=B2_1i[id];
				B2_1i_dff2[id]<=B2_1i_dff1[id];
			end
		end	
	end
	
	/* B3 input */
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<3;id=id+1)begin
				B3i[id]<=0;
			end
		end
		else begin	
			if((stride_dff1==1 && NO7==1 && wround_dff1==0)||(stride_dff1==0 && NO7==0 && wround_dff1==1))begin
				for(id=0;id<3;id=id+1)begin
					B3i[id]<=data[BACK+id*D2+6*D2 +: D1]; // i6 ~ i8
				end
			end
			else if(stride_dff1==0 && NO7==1 && wround_dff1==3)begin
				for(id=0;id<3;id=id+1)begin
					B3i[id]<=data[FRONT+id*D2 +: D1]; // i0~i2
				end
			end
			else begin
				for(id=0;id<3;id=id+1)begin
					B3i[id]<=data[BACK+id*D2 +: D1]; // i0~i2
				end
			end
		end
	end	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<6;id=id+1)begin
				B3i_dff1[id]<=0;
				B3i_dff2[id]<=0;
			end
		end
		else begin	
			for(id=0;id<6;id=id+1)begin
				B3i_dff1[id]<=B3i[id];
				B3i_dff2[id]<=B3i_dff1[id];
			end
		end	
	end	
							
//-----------------------------------------------------------------			
	/* module instantiation */
	
	
	B1 b1(.clk(clk),.rst_n(rst_n),.i0(B1i[0]),.i1(B1i[1]),.i2(B1i[2]),.i3(B1i[3]),.i4(B1i[4]),.i5(B1i[5]),.i6(B1i[6]),.i7(B1i[7]),.i8(B1i[8]),.i_valid(data_valid_dff4),.B1_valid(B1out_valid),.B1out(B1out));
	B2 b2_0(.clk(clk),.rst_n(rst_n),.i0(B2_0i[0]),.i1(B2_0i[1]),.i2(B2_0i[2]),.i3(B2_0i[3]),.i4(B2_0i[4]),.i5(B2_0i[5]),.i_valid(data_valid_dff4),.B2_valid(B2_0out_valid),.B2out(B2_0out));
	B2 b2_1(.clk(clk),.rst_n(rst_n),.i0(B2_1i[0]),.i1(B2_1i[1]),.i2(B2_1i[2]),.i3(B2_1i[3]),.i4(B2_1i[4]),.i5(B2_1i[5]),.i_valid(data_valid_dff4),.B2_valid(B2_1out_valid),.B2out(B2_1out));
	B3 b3(.clk(clk),.rst_n(rst_n),.i0(B3i[0]),.i1(B3i[1]),.i2(B3i[2]),.i_valid(data_valid_dff4),.B3_valid(B3out_valid),.B3out(B3out));
	
//------------------------------------------------------------------
	/* B output */
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			Bout_s0   <=0;
			
		end
		else begin	
			case(wround_dff11)
				0:begin
					Bout_s0[BACK +: D1_OUT]<= B1out;
					Bout_s0[FRONT_OUT +: D1_OUT]<= 0;
				end
				1:begin
					if(NO7==0)begin
						Bout_s0[BACK +: D1_OUT]<= B2_0out;
						Bout_s0[FRONT_OUT +: D1_OUT]<= B3out;
					end
					else begin
						Bout_s0[BACK +: D1_OUT]<= B2_0out;
						Bout_s0[FRONT_OUT +: D1_OUT]<= B2_1out;
					end
				end
				2:begin
					if(NO7==0)begin
						Bout_s0[BACK +: D1_OUT]<= B2_0out;
						Bout_s0[FRONT_OUT +: D1_OUT]<= B2_1out;
					end
					else begin
						Bout_s0[BACK +: D1_OUT]<= B3out;
						Bout_s0[FRONT_OUT +: D1_OUT]<= B2_0out;
					end
				end
				3:begin
					Bout_s0[BACK +: D1_OUT]<= B3out;
					Bout_s0[FRONT_OUT +: D1_OUT]<= B1out;
				end
			endcase
		end
	end	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			Bout_s1   <=0;	
		end
		else begin	
			case(wround_dff11)
				0:begin
					if(NO7==0)begin
						Bout_s1[BACK +: D1_OUT]<= B1out;
						Bout_s1[FRONT_OUT +: D1_OUT]<= 0;
					end
					else begin
						Bout_s1[BACK +: D1_OUT]<= B2_0out;
						Bout_s1[FRONT_OUT +: D1_OUT]<= B3out;
					end
				end
				1:begin
					if(NO7==0)begin
						Bout_s1[BACK +: D1_OUT]<= B2_0out;
						Bout_s1[FRONT_OUT +: D1_OUT]<= B2_1out;
					end
					else begin
						Bout_s1[BACK +: D1_OUT]<= B3out;
						Bout_s1[FRONT_OUT +: D1_OUT]<= B1out;
					end
				end
			endcase
		end
	end	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			Bout   <=0;	
		end
		else begin	
			if(stride_dff12==0)Bout <= Bout_s0;
			else Bout <= Bout_s1;		
		end
	end	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			Bvalid_dff1<=0;	
			Bvalid_dff2<=0;	
			Bvalid<=0;	
		end
		else begin
			Bvalid_dff1<=(B1out_valid && B2_0out_valid && B2_1out_valid && B3out_valid);	
			Bvalid_dff2<=Bvalid_dff1;	
			Bvalid<=Bvalid_dff2;	
		end
	end
	
	/* B output old*/
	/*
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			Bout   <=0;
			Bvalid<=0;
		end
		else begin	
		
			if(B1out_valid || B2_0out_valid || B2_1out_valid ||B3out_valid)Bvalid<=1;
			else Bvalid<=0;
			
			case(stride_cnt3)
				0:begin
					case(wround_cnt3)
						0:begin
							Bout[BACK +: D1_OUT]<= B1out;
							Bout[FRONT_OUT +: D1_OUT]<= 0;
						end
						1:begin
							if(NO7==0)begin
								Bout[BACK +: D1_OUT]<= B2_0out;
								Bout[FRONT_OUT +: D1_OUT]<= B3out;
							end
							else begin
								Bout[BACK +: D1_OUT]<= B2_0out;
								Bout[FRONT_OUT +: D1_OUT]<= B2_1out;
							end
						end
						2:begin
							if(NO7==0)begin
								Bout[BACK +: D1_OUT]<= B2_0out;
								Bout[FRONT_OUT +: D1_OUT]<= B2_1out;
							end
							else begin
								Bout[BACK +: D1_OUT]<= B3out;
								Bout[FRONT_OUT +: D1_OUT]<= B2_0out;
							end
						end
						3:begin
							Bout[BACK +: D1_OUT]<= B3out;
							Bout[FRONT_OUT +: D1_OUT]<= B1out;
						end
					endcase
				end
				1:begin
					case(wround_cnt3)
						0:begin
							if(NO7==0)begin
								Bout[BACK +: D1_OUT]<= B1out;
								Bout[FRONT_OUT +: D1_OUT]<= 0;
							end
							else begin
								Bout[BACK +: D1_OUT]<= B2_0out;
								Bout[FRONT_OUT +: D1_OUT]<= B3out;
							end
						end
						1:begin
							if(NO7==0)begin
								Bout[BACK +: D1_OUT]<= B2_0out;
								Bout[FRONT_OUT +: D1_OUT]<= B2_1out;
							end
							else begin
								Bout[BACK +: D1_OUT]<= B3out;
								Bout[FRONT_OUT +: D1_OUT]<= B1out;
							end
						end
					endcase
				end
			endcase
		end
	end
	*/
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
	input i_valid,
	output B1_valid,
	output [26:0]B1out
);
	integer id;
	
	reg [22:0]locali[0:8];
	reg i_valid_;
	
	wire[24:0]L10,L11,L12;
	wire L10_valid,L11_valid,L12_valid;
	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<9;id=id+1)begin
				locali[id]<=0;
			end
			i_valid_<=0;
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
			i_valid_<=i_valid;
		end
	end		
			
	ADD3#(23,25)L1_0(.clk(clk),.rst_n(rst_n),.i0(locali[0]),.i1(locali[1]),.i2(locali[2]),.i_valid(i_valid_),.ADD3_out(L10),.ADD3_valid(L10_valid));
	ADD3#(23,25)L1_1(.clk(clk),.rst_n(rst_n),.i0(locali[3]),.i1(locali[4]),.i2(locali[5]),.i_valid(i_valid_),.ADD3_out(L11),.ADD3_valid(L11_valid));
	ADD3#(23,25)L1_2(.clk(clk),.rst_n(rst_n),.i0(locali[6]),.i1(locali[7]),.i2(locali[8]),.i_valid(i_valid_),.ADD3_out(L12),.ADD3_valid(L12_valid));
	
	ADD3#(25,27)L2(.clk(clk),.rst_n(rst_n),.i0(L10),.i1(L11),.i2(L12),.i_valid(L10_valid & L11_valid & L12_valid),.ADD3_out(B1out),.ADD3_valid(B1_valid));

endmodule

module B2(
	input clk,
	input rst_n,
	input [22:0]i0,
	input [22:0]i1,
	input [22:0]i2,
	input [22:0]i3,
	input [22:0]i4,
	input [22:0]i5,
	input i_valid,
	output B2_valid,
	output reg [26:0]B2out
);
	integer id;
	
	reg [22:0]locali[0:5];
	reg i_valid_;
	
	wire [25:0]B2out_tmp;
	wire[24:0]L10,L11;
	wire L10_valid,L11_valid;
	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(id=0;id<6;id=id+1)begin
				locali[id]<=0;
			end
			i_valid_<=0;
		end
		else begin	
			locali[0]<= i0;
			locali[1]<= i1;
			locali[2]<= i2;
			locali[3]<= i3;
			locali[4]<= i4;
			locali[5]<= i5;
			i_valid_ <= i_valid;
		end
	end		
			
	ADD3#(23,25)L1_0(.clk(clk),.rst_n(rst_n),.i0(locali[0]),.i1(locali[1]),.i2(locali[2]),.i_valid(i_valid_),.ADD3_out(L10),.ADD3_valid(L10_valid));
	ADD3#(23,25)L1_1(.clk(clk),.rst_n(rst_n),.i0(locali[3]),.i1(locali[4]),.i2(locali[5]),.i_valid(i_valid_),.ADD3_out(L11),.ADD3_valid(L11_valid));
	
	ADD2#(25,26)L2(.clk(clk),.rst_n(rst_n),.i0(L10),.i1(L11),.i_valid(L10_valid & L11_valid),.ADD2_out(B2out_tmp),.ADD2_valid(B2_valid));
	
	always@(*)begin
		B2out = {1'd0,B2out_tmp};
	end
	
endmodule

module B3(
	input clk,
	input rst_n,
	input [22:0]i0,
	input [22:0]i1,
	input [22:0]i2,
	input i_valid,
	output reg B3_valid,
	output reg [26:0]B3out
);

	reg [22:0]locali[0:2];
	reg i_valid_;
	
	wire [25:0]B3out_tmp;
	wire B3_valid_tmp;
	wire [24:0]L1;
	reg B3_valid_dff1,B3_valid_dff2;
	reg [26:0]B3out_dff1,B3out_dff2;
	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			locali[0]<= 0;
			locali[1]<= 0;
			locali[2]<= 0;
			i_valid_ <= 0;
		end
		else begin	
			locali[0]<= i0;
			locali[1]<= i1;
			locali[2]<= i2;
			i_valid_ <= i_valid;
		end
	end	
	
	
	ADD3#(23,25)L1_0(.clk(clk),.rst_n(rst_n),.i0(locali[0]),.i1(locali[1]),.i2(locali[2]),.i_valid(i_valid_),.ADD3_out(L1),.ADD3_valid(B3_valid_tmp));
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			B3out_dff1	<= 0;
			B3out_dff2	<= 0;
			B3out	<= 0;
			
			B3_valid_dff1<=0;
			B3_valid_dff2<=0;
			B3_valid<= 0;
		end
		else begin	
			B3out_dff1<= {2'b0,L1};
			B3out_dff2<=B3out_dff1;
			B3out<=B3out_dff2;
			
			B3_valid_dff1<= B3_valid_tmp;
			B3_valid_dff2<= B3_valid_dff1;
			B3_valid<=B3_valid_dff2;
		end
	end	
	
endmodule

module ADDER(
	input clk,
	input rst_n,
	input stride,
	input [2:0]wround,
	input [73727:0]MUL_results, //4608*16  //TO DO : NEED DFF (2020/2/27
	input MUL_DATA_valid,
	input [3:0]wsize,
	output reg Psum_valid,		
	output reg [863:0]Psum			//max 54 * 16
);
	parameter CUBE_D1 = 1152;
	genvar id,idx;
	
	reg [73727:0]MUL_results_dff;
	reg MUL_DATA_valid_dff,stride_dff;
	reg [2:0]wround_dff;
	reg [3:0]wsize_dff;
	
	
	reg [2:0]wround_dff1,wround_dff2,wround_dff3,wround_dff4,wround_dff5,wround_dff6,wround_dff7,wround_dff8,wround_dff9,wround_dff10,wround_dff11,wround_dff12,wround_dff13,wround_dff14,wround_dff15,wround_dff16,wround_dff17,wround_dff18,wround_dff19,wround_dff20,wround_dff21;
	reg stride_dff1,stride_dff2,stride_dff3,stride_dff4,stride_dff5,stride_dff6,stride_dff7,stride_dff8,stride_dff9,stride_dff10,stride_dff11,stride_dff12,stride_dff13,stride_dff14,stride_dff15,stride_dff16,stride_dff17,stride_dff18,stride_dff19,stride_dff20,stride_dff21;
	reg [3:0]wsize_dff1,wsize_dff2,wsize_dff3,wsize_dff4,wsize_dff5,wsize_dff6,wsize_dff7,wsize_dff8,wsize_dff9,wsize_dff10,wsize_dff11,wsize_dff12,wsize_dff13,wsize_dff14,wsize_dff15,wsize_dff16,wsize_dff17,wsize_dff18,wsize_dff19,wsize_dff20,wsize_dff21;
	reg wsize_is3,wsize_is5,wsize_is7;
	
	wire [45:0]fsa_res[0:63];
	wire [53:0]Bout[0:3];
	wire [53:0]Aout[0:15];
	wire Avalid,Bvalid;
	reg [1:0]wsize_;
	
	/* FSA */
	FSA#(.NO3(0),.NO5(0),.ID5(0),.NO7(0),.ID7(0))C0(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[0 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[0]),.FSAvalid(FSAvalid));
	FSA#(.NO3(1),.NO5(0),.ID5(1),.NO7(0),.ID7(1))C1(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[1152 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[1]),.FSAvalid(FSAvalid));
	FSA#(.NO3(2),.NO5(0),.ID5(2),.NO7(0),.ID7(2))C2(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[2304 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[2]),.FSAvalid(FSAvalid));
	FSA#(.NO3(3),.NO5(0),.ID5(3),.NO7(0),.ID7(3))C3(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[3456 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[3]),.FSAvalid(FSAvalid));
	FSA#(.NO3(4),.NO5(1),.ID5(0),.NO7(0),.ID7(4))C4(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[4608 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[4]),.FSAvalid(FSAvalid));
	FSA#(.NO3(5),.NO5(1),.ID5(1),.NO7(0),.ID7(5))C5(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[5760 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[5]),.FSAvalid(FSAvalid));
	FSA#(.NO3(6),.NO5(1),.ID5(2),.NO7(0),.ID7(6))C6(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[6912 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[6]),.FSAvalid(FSAvalid));
	FSA#(.NO3(7),.NO5(1),.ID5(3),.NO7(0),.ID7(7))C7(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[8064 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[7]),.FSAvalid(FSAvalid));
	FSA#(.NO3(0),.NO5(2),.ID5(0),.NO7(0),.ID7(8))C8(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[9216 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[8]),.FSAvalid(FSAvalid));
	FSA#(.NO3(1),.NO5(2),.ID5(1),.NO7(0),.ID7(9))C9(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[10368 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[9]),.FSAvalid(FSAvalid));
	FSA#(.NO3(2),.NO5(2),.ID5(2),.NO7(0),.ID7(9))C10(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[11520 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[10]),.FSAvalid(FSAvalid));
	FSA#(.NO3(3),.NO5(2),.ID5(3),.NO7(0),.ID7(9))C11(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[12672 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[11]),.FSAvalid(FSAvalid));
	FSA#(.NO3(4),.NO5(3),.ID5(0),.NO7(0),.ID7(9))C12(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[13824 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[12]),.FSAvalid(FSAvalid));
	FSA#(.NO3(5),.NO5(3),.ID5(1),.NO7(0),.ID7(9))C13(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[14976 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[13]),.FSAvalid(FSAvalid));
	FSA#(.NO3(6),.NO5(3),.ID5(2),.NO7(0),.ID7(9))C14(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[16128 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[14]),.FSAvalid(FSAvalid));
	FSA#(.NO3(7),.NO5(3),.ID5(3),.NO7(0),.ID7(9))C15(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[17280 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[15]),.FSAvalid(FSAvalid));
	
	FSA#(.NO3(0),.NO5(0),.ID5(0),.NO7(1),.ID7(0))C16(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[18432 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[16]),.FSAvalid(FSAvalid));
	FSA#(.NO3(1),.NO5(0),.ID5(1),.NO7(1),.ID7(1))C17(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[19584 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[17]),.FSAvalid(FSAvalid));
	FSA#(.NO3(2),.NO5(0),.ID5(2),.NO7(1),.ID7(2))C18(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[20736 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[18]),.FSAvalid(FSAvalid));
	FSA#(.NO3(3),.NO5(0),.ID5(3),.NO7(1),.ID7(3))C19(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[21888 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[19]),.FSAvalid(FSAvalid));
	FSA#(.NO3(4),.NO5(1),.ID5(0),.NO7(1),.ID7(4))C20(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[23040 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[20]),.FSAvalid(FSAvalid));
	FSA#(.NO3(5),.NO5(1),.ID5(1),.NO7(1),.ID7(5))C21(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[24192 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[21]),.FSAvalid(FSAvalid));
	FSA#(.NO3(6),.NO5(1),.ID5(2),.NO7(1),.ID7(6))C22(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[25344 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[22]),.FSAvalid(FSAvalid));
	FSA#(.NO3(7),.NO5(1),.ID5(3),.NO7(1),.ID7(7))C23(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[26496 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[23]),.FSAvalid(FSAvalid));
	FSA#(.NO3(0),.NO5(2),.ID5(0),.NO7(1),.ID7(8))C24(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[27648 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[24]),.FSAvalid(FSAvalid));
	FSA#(.NO3(1),.NO5(2),.ID5(1),.NO7(1),.ID7(9))C25(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[28800 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[25]),.FSAvalid(FSAvalid));
	FSA#(.NO3(2),.NO5(2),.ID5(2),.NO7(1),.ID7(9))C26(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[29952 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[26]),.FSAvalid(FSAvalid));
	FSA#(.NO3(3),.NO5(2),.ID5(3),.NO7(1),.ID7(9))C27(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[31104 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[27]),.FSAvalid(FSAvalid));
	FSA#(.NO3(4),.NO5(3),.ID5(0),.NO7(1),.ID7(9))C28(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[32256 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[28]),.FSAvalid(FSAvalid));
	FSA#(.NO3(5),.NO5(3),.ID5(1),.NO7(1),.ID7(9))C29(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[33408 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[29]),.FSAvalid(FSAvalid));
	FSA#(.NO3(6),.NO5(3),.ID5(2),.NO7(1),.ID7(9))C30(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[34560 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[30]),.FSAvalid(FSAvalid));
	FSA#(.NO3(7),.NO5(3),.ID5(3),.NO7(1),.ID7(9))C31(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[35712 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[31]),.FSAvalid(FSAvalid));
	
	FSA#(.NO3(0),.NO5(0),.ID5(0),.NO7(0),.ID7(0))C32(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[36864 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[32]),.FSAvalid(FSAvalid));
	FSA#(.NO3(1),.NO5(0),.ID5(1),.NO7(0),.ID7(1))C33(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[38016 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[33]),.FSAvalid(FSAvalid));
	FSA#(.NO3(2),.NO5(0),.ID5(2),.NO7(0),.ID7(2))C34(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[39168 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[34]),.FSAvalid(FSAvalid));
	FSA#(.NO3(3),.NO5(0),.ID5(3),.NO7(0),.ID7(3))C35(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[40320 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[35]),.FSAvalid(FSAvalid));
	FSA#(.NO3(4),.NO5(1),.ID5(0),.NO7(0),.ID7(4))C36(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[41472 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[36]),.FSAvalid(FSAvalid));
	FSA#(.NO3(5),.NO5(1),.ID5(1),.NO7(0),.ID7(5))C37(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[42624 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[37]),.FSAvalid(FSAvalid));
	FSA#(.NO3(6),.NO5(1),.ID5(2),.NO7(0),.ID7(6))C38(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[43776 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[38]),.FSAvalid(FSAvalid));
	FSA#(.NO3(7),.NO5(1),.ID5(3),.NO7(0),.ID7(7))C39(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[44928 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[39]),.FSAvalid(FSAvalid));
	FSA#(.NO3(0),.NO5(2),.ID5(0),.NO7(0),.ID7(8))C40(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[46080 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[40]),.FSAvalid(FSAvalid));
	FSA#(.NO3(1),.NO5(2),.ID5(1),.NO7(0),.ID7(9))C41(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[47232 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[41]),.FSAvalid(FSAvalid));
	FSA#(.NO3(2),.NO5(2),.ID5(2),.NO7(0),.ID7(9))C42(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[48384 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[42]),.FSAvalid(FSAvalid));
	FSA#(.NO3(3),.NO5(2),.ID5(3),.NO7(0),.ID7(9))C43(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[49536 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[43]),.FSAvalid(FSAvalid));
	FSA#(.NO3(4),.NO5(3),.ID5(0),.NO7(0),.ID7(9))C44(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[50688 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[44]),.FSAvalid(FSAvalid));
	FSA#(.NO3(5),.NO5(3),.ID5(1),.NO7(0),.ID7(9))C45(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[51840 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[45]),.FSAvalid(FSAvalid));
	FSA#(.NO3(6),.NO5(3),.ID5(2),.NO7(0),.ID7(9))C46(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[52992 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[46]),.FSAvalid(FSAvalid));
	FSA#(.NO3(7),.NO5(3),.ID5(3),.NO7(0),.ID7(9))C47(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[54144 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[47]),.FSAvalid(FSAvalid));
	
	FSA#(.NO3(0),.NO5(0),.ID5(0),.NO7(1),.ID7(0))C48(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[55296 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[48]),.FSAvalid(FSAvalid));
	FSA#(.NO3(1),.NO5(0),.ID5(1),.NO7(1),.ID7(1))C49(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[56448 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[49]),.FSAvalid(FSAvalid));
	FSA#(.NO3(2),.NO5(0),.ID5(2),.NO7(1),.ID7(2))C50(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[57600 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[50]),.FSAvalid(FSAvalid));
	FSA#(.NO3(3),.NO5(0),.ID5(3),.NO7(1),.ID7(3))C51(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[58752 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[51]),.FSAvalid(FSAvalid));
	FSA#(.NO3(4),.NO5(1),.ID5(0),.NO7(1),.ID7(4))C52(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[59904 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[52]),.FSAvalid(FSAvalid));
	FSA#(.NO3(5),.NO5(1),.ID5(1),.NO7(1),.ID7(5))C53(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[61056 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[53]),.FSAvalid(FSAvalid));
	FSA#(.NO3(6),.NO5(1),.ID5(2),.NO7(1),.ID7(6))C54(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[62208 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[54]),.FSAvalid(FSAvalid));
	FSA#(.NO3(7),.NO5(1),.ID5(3),.NO7(1),.ID7(7))C55(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[63360 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[55]),.FSAvalid(FSAvalid));
	FSA#(.NO3(0),.NO5(2),.ID5(0),.NO7(1),.ID7(8))C56(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[64512 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[56]),.FSAvalid(FSAvalid));
	FSA#(.NO3(1),.NO5(2),.ID5(1),.NO7(1),.ID7(9))C57(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[65664 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[57]),.FSAvalid(FSAvalid));
	FSA#(.NO3(2),.NO5(2),.ID5(2),.NO7(1),.ID7(9))C58(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[66816 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[58]),.FSAvalid(FSAvalid));
	FSA#(.NO3(3),.NO5(2),.ID5(3),.NO7(1),.ID7(9))C59(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[67968 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[59]),.FSAvalid(FSAvalid));
	FSA#(.NO3(4),.NO5(3),.ID5(0),.NO7(1),.ID7(9))C60(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[69120 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[60]),.FSAvalid(FSAvalid));
	FSA#(.NO3(5),.NO5(3),.ID5(1),.NO7(1),.ID7(9))C61(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[70272 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[61]),.FSAvalid(FSAvalid));
	FSA#(.NO3(6),.NO5(3),.ID5(2),.NO7(1),.ID7(9))C62(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[71424 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[62]),.FSAvalid(FSAvalid));
	FSA#(.NO3(7),.NO5(3),.ID5(3),.NO7(1),.ID7(9))C63(.clk(clk),.rst_n(rst_n),.wsize(wsize_dff19),.stride(stride_dff18),.wround(wround_dff17),.data(MUL_results_dff[72576 +: CUBE_D1]),.data_valid(MUL_DATA_valid_dff),.FSAout(fsa_res[63]),.FSAvalid(FSAvalid));
	
	/* stride & wround put off 6 cycles */
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			MUL_results_dff <=0;
			MUL_DATA_valid_dff <=0;	
		end
		else begin	
			MUL_results_dff <= MUL_results;
			MUL_DATA_valid_dff <=MUL_DATA_valid;
		end
	end	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin	
			wround_dff1<=0;
			wround_dff2<=0;
			wround_dff3<=0;
			wround_dff4<=0;
			wround_dff5<=0;
			wround_dff6<=0;
			wround_dff7<=0;
			wround_dff8<=0;
			wround_dff9<=0;
			wround_dff10<=0;
			wround_dff11<=0;
			wround_dff12<=0;
			wround_dff13<=0;
			wround_dff14<=0;
			wround_dff15<=0;
			wround_dff16<=0;
			wround_dff17<=0;
			wround_dff18<=0;
			wround_dff19<=0;
			wround_dff20<=0;
			wround_dff21<=0;
		
			stride_dff1<=0;
			stride_dff2<=0;
			stride_dff3<=0;
			stride_dff4<=0;
			stride_dff5<=0;
			stride_dff6<=0;
			stride_dff7<=0;
			stride_dff8<=0;
			stride_dff9<=0;
			stride_dff10<=0;
			stride_dff11<=0;
			stride_dff12<=0;
			stride_dff13<=0;
			stride_dff14<=0;
			stride_dff15<=0;
			stride_dff16<=0;
			stride_dff17<=0;
			stride_dff18<=0;
			stride_dff19<=0;
			stride_dff20<=0;
			stride_dff21<=0;
					
			wsize_dff1<=0;
			wsize_dff2<=0;
			wsize_dff3<=0;
			wsize_dff4<=0;
			wsize_dff5<=0;
			wsize_dff6<=0;
			wsize_dff7<=0;
			wsize_dff8<=0;
			wsize_dff9<=0;
			wsize_dff10<=0;
			wsize_dff11<=0;
			wsize_dff12<=0;
			wsize_dff13<=0;
			wsize_dff14<=0;
			wsize_dff15<=0;
			wsize_dff16<=0;
			wsize_dff17<=0;
			wsize_dff18<=0;
			wsize_dff19<=0;
			wsize_dff20<=0;
			wsize_dff21<=0;
					
		end
		else begin	
			
			wround_dff1<=wround;
			wround_dff2<=wround_dff1;
			wround_dff3<=wround_dff2;
			wround_dff4<=wround_dff3;
			wround_dff5<=wround_dff4;
			wround_dff6<=wround_dff5;
			wround_dff7<=wround_dff6;
			wround_dff8<=wround_dff7;
			wround_dff9<=wround_dff8;
			wround_dff10<=wround_dff9;
			wround_dff11<=wround_dff10;
			wround_dff12<=wround_dff11;
			wround_dff13<=wround_dff12;
			wround_dff14<=wround_dff13;
			wround_dff15<=wround_dff14;
			wround_dff16<=wround_dff15;
			wround_dff17<=wround_dff16;
			wround_dff18<=wround_dff17;
			wround_dff19<=wround_dff18;
			wround_dff20<=wround_dff19;
			wround_dff21<=wround_dff20;
			
			
			stride_dff1<=stride;
			stride_dff2<=stride_dff1;
			stride_dff3<=stride_dff2;
			stride_dff4<=stride_dff3;
			stride_dff5<=stride_dff4;
			stride_dff6<=stride_dff5;
			stride_dff7<=stride_dff6;
			stride_dff8<=stride_dff7;
			stride_dff9<=stride_dff8;
			stride_dff10<=stride_dff9;
			stride_dff11<=stride_dff10;
			stride_dff12<=stride_dff11;
			stride_dff13<=stride_dff12;
			stride_dff14<=stride_dff13;
			stride_dff15<=stride_dff14;
			stride_dff16<=stride_dff15;
			stride_dff17<=stride_dff16;
			stride_dff18<=stride_dff17;
			stride_dff19<=stride_dff18;
			stride_dff20<=stride_dff19;
			stride_dff21<=stride_dff20;
			
				
			
			wsize_dff1<= wsize;
			wsize_dff2<= wsize_dff1;
			wsize_dff3<= wsize_dff2;
			wsize_dff4<= wsize_dff3;
			wsize_dff5<= wsize_dff4;
			wsize_dff6<= wsize_dff5;
			wsize_dff7<= wsize_dff6;
			wsize_dff8<= wsize_dff7;
			wsize_dff9<= wsize_dff8;
			wsize_dff10<= wsize_dff9;
			wsize_dff11<= wsize_dff10;
			wsize_dff12<= wsize_dff11;
			wsize_dff13<= wsize_dff12;
			wsize_dff14<= wsize_dff13;
			wsize_dff15<= wsize_dff14;
			wsize_dff16<= wsize_dff15;
			wsize_dff17<= wsize_dff16;
			wsize_dff18<= wsize_dff17;
			wsize_dff19<= wsize_dff18;
			wsize_dff20<= wsize_dff19;
			wsize_dff21<= wsize_dff20;
			
		end
	end	
	
	always@(*)begin
		wsize_is13=0;
		wsize_is5=0;
		wsize_is7=0;
		
		if(wsize_dff21 ==0)wsize_is13=1;
		if(wsize_dff21 ==1)wsize_is5=1;
		if(wsize_dff21 ==2)wsize_is7=1;
	end
	
	
	
	/* module A instantiation , stride & wround put off 5 cycles */
	generate
		for(id=0;id<4;id=id+1)begin:A_CH
			for(idx=0;idx<4;idx=idx+1)begin:A_ID
				A #(.NO5(idx))aa(.clk(clk),.rst_n(rst_n),.wround(wround_dff21),.stride(stride_dff21),.i0_(fsa_res[id*16+idx*4]),.i1_(fsa_res[id*16+idx*4+1]),.i2_(fsa_res[id*16+idx*4+2]),.i3_(fsa_res[id*16+idx*4+3]),.i_valid(FSAvalid & wsize_is5),.Aout(Aout[id*4+idx]),.Avalid(Avalid));
			end
		end
	endgenerate
	
	/* module B instantiation , stride & wround put off 5 cycles */
	generate
		for(id=0;id<2;id=id+1)begin:B_CH
			for(idx=0;idx<2;idx=idx+1)begin:B_ID
				B #(.NO7(idx))bb(.clk(clk),.rst_n(rst_n),.wround(wround_dff21),.stride(stride_dff21),.data_({fsa_res[id*32+idx*16+8],fsa_res[id*32+idx*16+7],fsa_res[id*32+idx*16+6],fsa_res[id*32+idx*16+5],fsa_res[id*32+idx*16+4],fsa_res[id*32+idx*16+3],fsa_res[id*32+idx*16+2],fsa_res[id*32+idx*16+1],fsa_res[id*32+idx*16]}),.data_valid(FSAvalid & wsize_is7),.Bout(Bout[id*2+idx]),.Bvalid(Bvalid));
			end
		end
	endgenerate
	
	
	/* Psum */
	always@(*)begin
		wsize_=0;
		
		//if(FSAvalid)wsize_=0;		//3 * 3
		if(Avalid)wsize_=1;
		if(Bvalid)wsize_=2;
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			Psum	  <= 0;
			Psum_valid<= 0;	
		end
		else begin
			Psum_valid<= ((wsize_is13 & FSAvalid) || Avalid || Bvalid);
			
			case(wsize_)
				0:Psum<={fsa_res[63],fsa_res[62],fsa_res[61],fsa_res[60],fsa_res[59],fsa_res[58],fsa_res[57],fsa_res[56],fsa_res[55],fsa_res[54],fsa_res[53],fsa_res[52],fsa_res[51],fsa_res[50],fsa_res[49],fsa_res[48],fsa_res[47],fsa_res[46],fsa_res[45],fsa_res[44],fsa_res[43],fsa_res[42],fsa_res[41],fsa_res[40],fsa_res[39],fsa_res[38],fsa_res[37],fsa_res[36],fsa_res[35],fsa_res[34],fsa_res[33],fsa_res[32],fsa_res[31],fsa_res[30],fsa_res[29],fsa_res[28],fsa_res[27],fsa_res[26],fsa_res[25],fsa_res[24],fsa_res[23],fsa_res[22],fsa_res[21],fsa_res[20],fsa_res[19],fsa_res[18],fsa_res[17],fsa_res[16],fsa_res[15],fsa_res[14],fsa_res[13],fsa_res[12],fsa_res[11],fsa_res[10],fsa_res[9],fsa_res[8],fsa_res[7],fsa_res[6],fsa_res[5],fsa_res[4],fsa_res[3],fsa_res[2],fsa_res[1],fsa_res[0]};
				1:Psum<={Aout[15],Aout[14],Aout[13],Aout[12],Aout[11],Aout[10],Aout[9],Aout[8],Aout[7],Aout[6],Aout[5],Aout[4],Aout[3],Aout[2],Aout[1],Aout[0]};
				2:Psum<={Bout[3],Bout[2],Bout[1],Bout[0]};
			endcase
		end
	end
	
	
endmodule
	