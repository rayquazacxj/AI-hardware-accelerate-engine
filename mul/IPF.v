module CUBE#(
	
	parameter NO3 = 0,
	parameter NO5 = 0,
	parameter ID5 = 0,
	parameter NO7 = 0,
	parameter ID7 = 0
	
)(
	input clk,
	input rst,
	input stride,
	input [1:0]round,
	input [1:0]wsize,
	input [191:0]i_dat,		// 3 REG
	input [79:0]w_dat,		// max 7 * 7 * 8 bits
	output reg[143:0]result
);
	parameter SA= 128;
	parameter SB = 64;
	parameter SC = 0;
	parameter D1 = 7;
	parameter D2 = 15;
	parameter D3 = 23;
	parameter D4 = 31;
	parameter D5 = 39;
	parameter D6 = 47;
	parameter D7 = 55;
	parameter P1 = 8;
	parameter P2 = 16;
	parameter P3 = 24;
	parameter P4 = 32;
	parameter P5 = 40;
	parameter P6 = 48;
	parameter P7 = 56;
	
	integer j;
	
	reg [71:0]locali; 	//REG C B A get row
	reg [71:0]localw;
	
	reg [191:0]i;		
	reg [79:0]w;	
	
	always@(posedge clk or negedge rst)begin
		if(!rst)begin
			i<=0;
			w<=0;
		end
		else begin
			i<=i_dat;
			w<=w_dat;
		end
	end
			
			
	always@(*)begin
		case(wsize)		
			0:begin		//3 * 3
				case(NO3)
					6:locali={i[SA +D1:SA +0],i[SC +D2+NO3*8 : SC +NO3*8],i[SB +D1:SB +0],i[SB +D2+NO3*8 : SB +NO3*8],i[D1:0],i[D2+NO3*8 :NO3*8]};
					7:locali={i[SA +D2:SA +0],i[SC +D1+NO3*8 : SC +NO3*8],i[SB +D2:SB +0],i[SB +D1+NO3*8 : SB +NO3*8],i[D2:0],i[D1+NO3*8 :NO3*8]};
					default: locali = {i[SA +D3+NO3*8 : SC +NO3*8] ,i[SB +D3+NO3*8 :SB +NO3*8] ,i[D3+NO3*8 : NO3*8]};
				endcase	
			end
			1:begin		//5 * 5
				case(stride)
					0:begin
						case(round)	// 2 round
							0:begin
								//case(NO5) // 4 NO
								case(ID5)
									0:locali = {i[SA +D3+NO5*8:SA +NO5*8],i[SB +D3+NO5*8:SB +NO5*8],i[D3+NO5*8:NO5*8]};
									1:locali = {i[SA +D3+NO5*8:SA +NO5*8],i[SB +D3+NO5*8:SB +NO5*8],{D3{1'b0}}};
									2:locali = {i[SA +D2+NO5*8:SA +NO5*8],{D1{1'b0}},i[SB +D2+NO5*8:SB +NO5*8],{D1{1'b0}},i[D2+NO5*8:NO5*8],{D1{1'b0}}};
									3:locali = {i[SA +D2+NO5*8:SA +NO5*8],{D1{1'b0}},i[SB +D2+NO5*8:SB +NO5*8],{D1{1'b0}},{D3{1'b0}}};
								endcase
								//endcase
							end
							1:begin
								case(ID5)
									0:begin		//3 *3
										case(NO5)
											2:locali = {i[SA +D2+(NO5+4)*8:SA +(NO5+4)*8],i[SA +D1:SA],i[SB +D2+(NO5+4)*8:SB +(NO5+4)*8],i[SB +D1:SB],i[D2+(NO5+4)*8:(NO5+4)*8],i[D1:0]};
											3:locali = {i[SA +D1+(NO5+4)*8:SA +(NO5+4)*8],i[SA +D2:SA],i[SB +D1+(NO5+4)*8:SB +(NO5+4)*8],i[SB +D2:SB],i[D1+(NO5+4)*8:(NO5+4)*8],i[D2:0]};
											default:locali={i[SA +D3+(NO5+4)*8:SA +(NO5+4)*8],i[SB +D3+(NO5+4)*8:SB +(NO5+4)*8],i[D3+(NO5+4)*8:(NO5+4)*8]};
										endcase
									end
									1:begin		//3 * 2
										case(NO5)
											2:locali = {i[SA +D2+(NO5+4)*8:SA +(NO5+4)*8],i[SA +D1:SA],i[SB +D2+(NO5+4)*8:SB +(NO5+4)*8],i[SB +D1:SB],{D3{1'b0}}};
											3:locali = {i[SA +D1+(NO5+4)*8:SA +(NO5+4)*8],i[SA +D2:SA],i[SB +D1+(NO5+4)*8:SB +(NO5+4)*8],i[SB +D2:SB],{D3{1'b0}}};
											default:locali={i[SA +D3+(NO5+4)*8:SA +(NO5+4)*8],i[SB +D3+(NO5+4)*8:SB +(NO5+4)*8],{D3{1'b0}}};
										endcase
									end
									2:begin		// 2 * 3
										case(NO5)
											0:locali={i[SA +D1+(NO5+7)*8:SA +(NO5+7)*8],i[SA +D1:SA],{D1{1'b0}},i[SB +D1+(NO5+7)*8:SB +(NO5+7)*8],i[SB +D1:SB],{D1{1'b0}},i[D1+(NO5+7)*8:(NO5+7)*8],i[D1:0],{D1{1'b0}}}; //NO5_0
											default:locali = {i[SA +D2+(NO5-1)*8:SA +(NO5-1)*8],{D1{1'b0}},i[SB +D2+(NO5-1)*8:SB +(NO5-1)*8],{D1{1'b0}},i[D2+(NO5-1)*8:(NO5-1)*8],{D1{1'b0}}};
										endcase
									end
									3:begin		//2 * 2
										case(NO5)
											0:locali={i[SA +D1+(NO5+7)*8:SA +(NO5+7)*8],i[SA +D1:SA],{D1{1'b0}},i[SB +D1+(NO5+7)*8:SB +(NO5+7)*8],i[SB +D1:SB],{D1{1'b0}},{D3{1'b0}}}; //NO5_0
											default:locali = {i[SA +D2+(NO5-1)*8:SA +(NO5-1)*8],{D1{1'b0}},i[SB +D2+(NO5-1)*8:SB +(NO5-1)*8],{D1{1'b0}},{D3{1'b0}}};
										endcase
									end
								endcase
							end
						endcase		
					end
					1:begin	//stride 2
						case(ID5)
							0:begin	// 3 * 3
								case(NO5)
									3:locali = {i[SA +D2+(NO5+3)*8:SA +(NO5+3)*8],i[SA +D1:SA],i[SB +D2+(NO5+3)*8:SB +(NO5+3)*8],i[SB +D1:SB],i[D2+(NO5+3)*8:(NO5+3)*8],i[D1:0]};
									default:locali={i[SA +D3+(NO5*2)*8:SA +(NO5*2)*8],i[SB +D3+(NO5*2)*8:SB +(NO5*2)*8],i[D3+(NO5*2)*8:(NO5*2)*8]};
								endcase	
							end
							1:begin // 3 * 2
								case(NO5)
									3:locali = {i[SA +D2+(NO5+3)*8:SA +(NO5+3)*8],i[SA +D1:SA],i[SB +D2+(NO5+3)*8:SB +(NO5+3)*8],i[SB +D1:SB],{D3{1'b0}}};
									default:locali={i[SA +D3+(NO5*2)*8:SA +(NO5*2)*8],i[SB +D3+(NO5*2)*8:SB +(NO5*2)*8],{D3{1'b0}}};
								endcase	
							end
							2:begin // 2 * 3
								case(NO5)
									0:locali = {i[SA +D2+P3:SA +P3],{D1{1'b0}},i[SB +D2+P3:SB +P3],{D1{1'b0}},i[D2+P3:P3],{D1{1'b0}}};
									1:locali = {i[SA +D2+P5:SA +P5],{D1{1'b0}},i[SB +D5+P5:SB +P5],{D1{1'b0}},i[D2+P5:P5],{D1{1'b0}}};
									2:locali = {i[SA +D1+P7:SA +P7],i[SA +D1:SA],{D1{1'b0}},i[SB +D1+P7:SB +P7],i[SB +D1:SB],{D1{1'b0}},i[D1+P7:P7],i[D1:0],{D1{1'b0}}};
									3:locali = {i[SA +D2+P1:SA +P1],{D1{1'b0}},i[SB +D5+P1:SB +P1],{D1{1'b0}},i[D2+P1:P1],{D1{1'b0}}};
								endcase
							end
							3:begin // 2 * 2
								case(NO5)
									0:locali = {i[SA +D2+P3:SA +P3],{D1{1'b0}},i[SB +D2+P3:SB +P3],{D1{1'b0}},{D3{1'b0}}};
									1:locali = {i[SA +D2+P5:SA +P5],{D1{1'b0}},i[SB +D5+P5:SB +P5],{D1{1'b0}},{D3{1'b0}}};
									2:locali = {i[SA +D1+P7:SA +P7],i[SA +D1:SA],{D1{1'b0}},i[SB +D1+P7:SB +P7],i[SB +D1:SB],{D1{1'b0}},{D3{1'b0}}};
									3:locali = {i[SA +D2+P1:SA +P1],{D1{1'b0}},i[SB +D5+P1:SB +P1],{D1{1'b0}},{D3{1'b0}}};
								endcase
							end
						endcase
					end
				endcase
			end
			2:begin		// 7 * 7
				case(stride)
					0:begin		// stride 1
						case(round)
							0:begin		//0~ ,1~
								case(ID7)		//NO7 : 0 , 1
									0:locali={i[SA +D3+NO7*8:SA +NO7*8],i[SB +D3+NO7*8:SB +NO7*8],i[D3+NO7*8:NO7*8]};
									1:locali={i[SA +D3+NO7*8:SA +NO7*8],i[SB +D3+NO7*8:SB +NO7*8],i[D3+NO7*8:NO7*8]};
									2:locali={i[SA +D3+NO7*8:SA +NO7*8],{D6{1'b0}}};
									3:locali={i[SA +D3+(NO7+3)*8:SA +(NO7+3)*8],i[SB +D3+(NO7+3)*8:SB +(NO7+3)*8],i[D3+(NO7+3)*8:(NO7+3)*8]};
									4:locali={i[SA +D3+(NO7+3)*8:SA +(NO7+3)*8],i[SB +D3+(NO7+3)*8:SB +(NO7+3)*8],i[D3+(NO7+3)*8:(NO7+3)*8]};
									5:locali={i[SA +D3+(NO7+3)*8:SA +(NO7+3)*8],{D6{1'b0}}};
									6:locali={i[SA +D1+(NO7+6)*8:SA +(NO7+6)*8],{D2{1'b0}},i[SB +D1+(NO7+6)*8:SB +(NO7+6)*8],{D2{1'b0}},i[D1+(NO7+6)*8:(NO7+6)*8],{D2{1'b0}}};
									7:locali={i[SA +D1+(NO7+6)*8:SA +(NO7+6)*8],{D2{1'b0}},i[SB +D1+(NO7+6)*8:SB +(NO7+6)*8],{D2{1'b0}},i[D1+(NO7+6)*8:(NO7+6)*8],{D2{1'b0}}};
									8:locali={i[SA +D1+(NO7+6)*8:SA +(NO7+6)*8],{D7{1'b0}},{D1{1'b0}}};
								endcase
							end
							1:begin		//2~ , 3~
								case(ID7)		//NO7 : 0 , 1
									0:locali={i[SA +D3+(NO7+2)*8:SA +(NO7+2)*8],i[SB +D3+(NO7+2)*8:SB +(NO7+2)*8],i[D3+(NO7+2)*8:(NO7+2)*8]};
									1:locali={i[SA +D3+(NO7+2)*8:SA +(NO7+2)*8],i[SB +D3+(NO7+2)*8:SB +(NO7+2)*8],i[D3+(NO7+2)*8:(NO7+2)*8]};
									2:locali={i[SA +D3+(NO7+2)*8:SA +(NO7+2)*8],{D6{1'b0}}};
									3:begin
										case(NO7)
											0:locali={i[SA +D3+(NO7+5)*8:SA +(NO7+5)*8],i[SB +D3+(NO7+5)*8:SB +(NO7+5)*8],i[D3+(NO7+5)*8:(NO7+5)*8]};
											1:locali={i[SA +D2+(NO7+5)*8:SA +(NO7+5)*8],i[SA +D1+NO7*8:SA +NO7*8],i[SB +D2+(NO7+5)*8:SB +(NO7+5)*8],i[SB +D1+NO7*8:SB +NO7*8],i[D2+(NO7+5)*8:(NO7+5)*8],i[D1+NO7*8:NO7*8]};
										endcase
									end
									4:begin
										case(NO7)
											0:locali={i[SA +D3+(NO7+5)*8:SA +(NO7+5)*8],i[SB +D3+(NO7+5)*8:SB +(NO7+5)*8],i[D3+(NO7+5)*8:(NO7+5)*8]};
											1:locali={i[SA +D2+(NO7+5)*8:SA +(NO7+5)*8],i[SA +D1+NO7*8:SA +NO7*8],i[SB +D2+(NO7+5)*8:SB +(NO7+5)*8],i[SB +D1+NO7*8:SB +NO7*8],i[D2+(NO7+5)*8:(NO7+5)*8],i[D1+NO7*8:NO7*8]};
										endcase
									end
									5:begin
										case(NO7)
											0:locali={i[SA +D3+(NO7+5)*8:SA +(NO7+5)*8],{D6{1'b0}}};
											1:locali={i[SA +D2+(NO7+5)*8:SA +(NO7+5)*8],i[SA +D1+NO7*8:SA +NO7*8],{D6{1'b0}}};
										endcase
									end
									6:locali={i[SA +D1+NO7*8:SA +NO7*8],{D2{1'b0}},i[SB +D1+NO7*8:SB +NO7*8],{D2{1'b0}},i[D1+NO7*8:NO7*8],{D2{1'b0}}};
									7:locali={i[SA +D1+NO7*8:SA +NO7*8],{D2{1'b0}},i[SB +D1+NO7*8:SB +NO7*8],{D2{1'b0}},i[D1+NO7*8:NO7*8],{D2{1'b0}}};
									8:locali={i[SA +D1+NO7*8:SA +NO7*8],{D7{1'b0}},{D1{1'b0}}};
								endcase
							end
							2:begin		//4~ , 5~
								case(ID7)		//NO7 : 0 , 1
									0:locali={i[SA +D3+(NO7+4)*8:SA +(NO7+4)*8],i[SB +D3+(NO7+4)*8:SB +(NO7+3)*8],i[D3+(NO7+4)*8:(NO7+4)*8]};
									1:locali={i[SA +D3+(NO7+4)*8:SA +(NO7+4)*8],i[SB +D3+(NO7+4)*8:SB +(NO7+3)*8],i[D3+(NO7+4)*8:(NO7+4)*8]};
									2:locali={i[SA +D3+(NO7+4)*8:SA +(NO7+4)*8],{D6{1'b0}}};
									3:begin
										case(NO7)
											0:locali={i[SA +D1+(NO7+7)*8:SA +(NO7+7)*8],i[SA +D2+NO7*8:SA +NO7*8],i[SB +D1+(NO7+7)*8:SB +(NO7+7)*8],i[SB +D2+NO7*8:SB +NO7*8],i[D1+(NO7+7)*8:(NO7+7)*8],i[D2:0]};
											1:locali={i[SA +D3+(NO7-1)*8:SA +(NO7-1)*8],i[SB +D3+(NO7-1)*8:SB +(NO7-1)*8],i[D3+(NO7-1)*8:(NO7-1)*8]};
										endcase
									end
									4:begin
										case(NO7)
											0:locali={i[SA +D1+(NO7+7)*8:SA +(NO7+7)*8],i[SA +D2+NO7*8:SA +NO7*8],i[SB +D1+(NO7+7)*8:SB +(NO7+7)*8],i[SB +D2+NO7*8:SB +NO7*8],i[D1+(NO7+7)*8:(NO7+7)*8],i[D2:0]};
											1:locali={i[SA +D3+(NO7-1)*8:SA +(NO7-1)*8],i[SB +D3+(NO7-1)*8:SB +(NO7-1)*8],i[D3+(NO7-1)*8:(NO7-1)*8]};
										endcase
									end
									5:begin
										case(NO7)
											0:locali={i[SA +D1+(NO7+7)*8:SA +(NO7+7)*8],i[SA +D2+NO7*8:SA +NO7*8],{D6{1'b0}}};
											1:locali={i[SA +D3+(NO7-1)*8:SA +(NO7-1)*8],{D6{1'b0}}};
										endcase
									end
									6:locali={i[SA +D1+(NO7+2)*8:SA +(NO7+2)*8],{D2{1'b0}},i[SB +D1+(NO7+2)*8:SB +(NO7+2)*8],{D2{1'b0}},i[D1+(NO7+2)*8:(NO7+2)*8],{D2{1'b0}}};
									7:locali={i[SA +D1+(NO7+2)*8:SA +(NO7+2)*8],{D2{1'b0}},i[SB +D1+(NO7+2)*8:SB +(NO7+2)*8],{D2{1'b0}},i[D1+(NO7+2)*8:(NO7+2)*8],{D2{1'b0}}};
									8:locali={i[SA +D1+(NO7+2)*8:SA +(NO7+2)*8],{D7{1'b0}},{D1{1'b0}}};
								endcase
							end
							3:begin		//6~ , 7~
								case(ID7)		//NO7 : 0 , 1
									0:begin
										case(NO7)
											0:locali={i[SA +D2+P6:SA +P6],i[SA +D1:SA],i[SB +D2+P6:SB +P6],i[SB +D1:SB],i[D2+P6:P6],i[D1:0]};
											1:locali={i[SA +D1+P7:SA +P7],i[SA +D2:SA],i[SB +D1+P7:SB +P7],i[SB +D2:SB],i[D2+P7:P7],i[D2:0]};
										endcase
									end
									1:begin
										case(NO7)
											0:locali={i[SA +D2+P6:SA +P6],i[SA +D1:SA],i[SB +D2+P6:SB +P6],i[SB +D1:SB],i[D2+P6:P6],i[D1:0]};
											1:locali={i[SA +D1+P7:SA +P7],i[SA +D2:SA],i[SB +D1+P7:SB +P7],i[SB +D2:SB],i[D2+P7:P7],i[D2:0]};
										endcase
									end
									2:begin
										case(NO7)
											0:locali={i[SA +D2+P6:SA +P6],i[SA +D1:SA],{D6{1'b0}}};
											1:locali={i[SA +D1+P7:SA +P7],i[SA +D2:SA],{D6{1'b0}}};
										endcase
									end
									3:locali={i[SA +D3+(NO7+1)*8:SA +(NO7+1)*8],i[SB +D3+(NO7+1)*8:SB +(NO7+1)*8],i[D3+(NO7+1)*8:(NO7+1)*8]};
									4:locali={i[SA +D3+(NO7+1)*8:SA +(NO7+1)*8],i[SB +D3+(NO7+1)*8:SB +(NO7+1)*8],i[D3+(NO7+1)*8:(NO7+1)*8]};
									5:locali={i[SA +D3+(NO7+1)*8:SA +(NO7+1)*8],{D6{1'b0}}};
									6:locali={i[SA +D1+(NO7+4)*8:SA +(NO7+4)*8],{D2{1'b0}},i[SB +D1+(NO7+4)*8:SB +(NO7+4)*8],{D2{1'b0}},i[D1+(NO7+4)*8:(NO7+4)*8],{D2{1'b0}}};
									7:locali={i[SA +D1+(NO7+4)*8:SA +(NO7+4)*8],{D2{1'b0}},i[SB +D1+(NO7+4)*8:SB +(NO7+4)*8],{D2{1'b0}},i[D1+(NO7+4)*8:(NO7+4)*8],{D2{1'b0}}};
									8:locali={i[SA +D1+(NO7+4)*8:SA +(NO7+4)*8],{D7{1'b0}},{D1{1'b0}}};
								endcase
							end
						endcase
					end
					1:begin	//stride 2 round 2
						case(round)
							0:begin		// 0~ ,2~
								case(ID7)
									0:locali={i[SA +D3+(NO7*2)*8:SA +(NO7*2)*8],i[SB +D3+(NO7*2)*8:SB +(NO7*2)*8],i[D3+(NO7*2)*8:(NO7*2)*8]};
									1:locali={i[SA +D3+(NO7*2)*8:SA +(NO7*2)*8],i[SB +D3+(NO7*2)*8:SB +(NO7*2)*8],i[D3+(NO7*2)*8:(NO7*2)*8]};
									2:locali={i[SA +D3+(NO7*2)*8:SA +(NO7*2)*8],{D6{1'b0}}};
									3:begin
										case(NO7)
											0:locali={i[SA +D3+P3:SA +P3],i[SB +D3+P3:SB +P3],i[D3+P3:P3]};
											1:locali={i[SA +D3+P5:SA +P5],i[SB +D3+P5:SB +P5],i[D3+P5:P5]};
										endcase
									end
									4:begin
										case(NO7)
											0:locali={i[SA +D3+P3:SA +P3],i[SB +D3+P3:SB +P3],i[D3+P3:P3]};
											1:locali={i[SA +D3+P5:SA +P5],i[SB +D3+P5:SB +P5],i[D3+P5:P5]};
										endcase
									end
									5:begin
										case(NO7)
											0:locali={i[SA +D3+P3:SA +P3],{D6{1'b0}}};
											1:locali={i[SA +D3+P5:SA +P5],{D6{1'b0}}};
										endcase
									end
									6:begin
										case(NO7)
											0:locali={i[SA +D1+P6:SA +P6],{D2{1'b0}},i[SB +D1+P6:SB +P6],{D2{1'b0}},i[D1+P6:P6],{D2{1'b0}}};
											0:locali={i[SA +D1:SA],{D2{1'b0}},i[SB +D1:SB],{D2{1'b0}},i[D1:0],{D2{1'b0}}};
										endcase
									end
									7:begin
										case(NO7)
											0:locali={i[SA +D1+P6:SA +P6],{D2{1'b0}},i[SB +D1+P6:SB +P6],{D2{1'b0}},i[D1+P6:P6],{D2{1'b0}}};
											0:locali={i[SA +D1:SA],{D2{1'b0}},i[SB +D1:SB],{D2{1'b0}},i[D1:0],{D2{1'b0}}};
										endcase
									end
									8:begin
										case(NO7)
											0:locali={i[SA +D1+P6:SA +P6],{D7{1'b0}},{D1{1'b0}}};
											0:locali={i[SA +D1:SA],{D7{1'b0}},{D1{1'b0}}};
										endcase
									end
								endcase
							end
							1:begin		// 4~ ,6~
								case(ID7)
									0:begin
										case(NO7)
											0:locali={i[SA +D3+P4:SA +P4],i[SB +D3+P4:SB +P4],i[D3+P4:P4]};
											1:locali={i[SA +D2+P6:SA +P6],i[SA +D1:SA],i[SB +D2+P6:SB +P6],i[SB +D1:SB],i[D2+P6:P6],i[D1:0]};
										endcase
									end
									1:begin
										case(NO7)
											0:locali={i[SA +D3+P4:SA +P4],i[SB +D3+P4:SB +P4],i[D3+P4:P4]};
											1:locali={i[SA +D2+P6:SA +P6],i[SA +D1:SA],i[SB +D2+P6:SB +P6],i[SB +D1:SB],i[D2+P6:P6],i[D1:0]};
										endcase
									end
									2:begin
										case(NO7)
											0:locali={i[SA +D3+P4:SA +P4],{D6{1'b0}}};
											1:locali={i[SA +D2+P6:SA +P6],i[SA +D1:SA],{D6{1'b0}}};
										endcase
									end
									3:begin
										case(NO7)
											0:locali={i[SA +D1+P7:SA +P7],i[SA +D2:SA],i[SB +D1+P7:SB +P7],i[SB +D2:SB],i[D1+P7:P7],i[D2:0]};
											1:locali={i[SA +D3+P1:SA +P1],i[SB +D3+P1:SB +P1],i[D3+P1:P1]};
										endcase
									end
									4:begin
										case(NO7)
											0:locali={i[SA +D1+P7:SA +P7],i[SA +D2:SA],i[SB +D1+P7:SB +P7],i[SB +D2:SB],i[D1+P7:P7],i[D2:0]};
											1:locali={i[SA +D3+P1:SA +P1],i[SB +D3+P1:SB +P1],i[D3+P1:P1]};
										endcase
									end
									5:begin
										case(NO7)
											0:locali={i[SA +D1+P7:SA +P7],i[SA +D2:SA],{D6{1'b0}}};
											1:locali={i[SA +D3+P1:SA +P1],{D6{1'b0}}};
										endcase
									end
									6:begin
										case(NO7)
											0:locali={i[SA +D1+P2:SA +P2],{D2{1'b0}},i[SB +D1+P2:SB +P2],{D2{1'b0}},i[D1+P2:P2],{D2{1'b0}}};
											0:locali={i[SA +D1+P4:SA +P4],{D2{1'b0}},i[SB +D1+P4:SB +P4],{D2{1'b0}},i[D1+P4:P4],{D2{1'b0}}};
										endcase
									end
									7:begin
										case(NO7)
											0:locali={i[SA +D1+P2:SA +P2],{D2{1'b0}},i[SB +D1+P2:SB +P2],{D2{1'b0}},i[D1+P2:P2],{D2{1'b0}}};
											0:locali={i[SA +D1+P4:SA +P4],{D2{1'b0}},i[SB +D1+P4:SB +P4],{D2{1'b0}},i[D1+P4:P4],{D2{1'b0}}};
										endcase
									end
									8:begin
										case(NO7)
											0:locali={i[SA +D1+P2:SA +P2],{D7{1'b0}},{D1{1'b0}}};
											0:locali={i[SA +D1+P4:SA +P4],{D7{1'b0}},{D1{1'b0}}};
										endcase
									end
								endcase
							end
						endcase
					end	
				endcase
			end
		endcase
	end		
				/*	
				case(ID5)	
					0:begin	//REG C B A
						case(NO5)
							4:locali = {i[SB+ D4+NO5*8: SB+ 0+NO5*8],i[D1:0],i[ D4+NO5*8: 0+NO5*8]};						//	7654 | 07654
							5:locali = {i[SB+ D1: SB+ 0],i[SB+ D3+NO5*8: SB+ 0+NO5*8],i[D2:0],i[ D3+NO5*8: 0+NO5*8]};	//	0765 | 10765
							6:locali = {i[SB+ D2: SB+ 0],i[SB+ D2+NO5*8: SB+ 0+NO5*8],i[D3:0],i[ D2+NO5*8: 0+NO5*8]};	//  1076 | 21076
							7:locali = {i[SB+ D3: SB+ 0],i[SB+ D1+NO5*8: SB+ 0+NO5*8],i[D4:0],i[ D1+NO5*8: 0+NO5*8]};		//  2107 | 32107
							default:locali = {i[SB+ D4+NO5*8: SB+ 0+NO5*8],i[ D5+NO5*8: 0+NO5*8]};	
						endcase
					end
					1:begin	 // REG D C B
						case(NO5)
							4:locali = {i[SC + D3+NO5*8: SC + 0 +NO5*8],i[SB+ D1+NO5*8: SB+ 0+NO5*8],i[SB + D4+NO5*8 : SB + 0+NO5*8],i[D1+(NO5-4)*8:(NO5-4)*8]};
							5:locali = {i[SC + D3+NO5*8: SC + 0 +NO5*8],i[SB+ D2: SB+ 0],i[SB + D3+NO5*8 : SB + 0+NO5*8],i[D1+(NO5-4)*8:(NO5-4)*8]};
							6:locali = {i[SC + D1: SC + 0],i[SC + D2+NO5*8: SC + 0 +NO5*8],i[SB+ D3: SB+ 0],i[SB + D2+NO5*8 : SB + 0+NO5*8],i[D1+(NO5-4)*8:(NO5-4)*8]};
							7:locali = {i[SC + D2: SC + 0],i[SC + D1+NO5*8: SC + 0 +NO5*8],i[SB+ D4: SB+ 0],i[SB + D1+NO5*8 : SB + 0+NO5*8],i[D1+(NO5-4)*8:(NO5-4)*8]};
							default:locali = {i[SC + D3+NO5*8: SC + 0 +NO5*8],i[SB + D5+NO5*8 : SB + 0+NO5*8],i[D1+(NO5+4)*8:(NO5+4)*8]};
						endcase
					end
					2:begin	 // REG E D C
						case(NO5)
							4:locali = {{16{1'b0}},i[SC + D1: SC +0],i[SC + D4+NO5*8 : SC + 0+NO5*8],i[SB + D1:SB +0],i[SB + D1+(NO5+3)*8 : SB + 0+(NO5+3)*8]};
							5:locali = {{16{1'b0}},i[SC + D2: SC +0],i[SC + D3+NO5*8 : SC + 0+NO5*8],i[SB + D2+(NO5-5)*8 : SB + 0+(NO5-5)*8]};
							6:locali = {{16{1'b0}},i[SC + D3: SC +0],i[SC + D2+NO5*8 : SC + 0+NO5*8],i[SB + D2+(NO5-5)*8 : SB + 0+(NO5-5)*8]};
							7:locali = {{16{1'b0}},i[SC + D4: SC +0],i[SC + D1+NO5*8 : SC + 0+NO5*8],i[SB + D2+(NO5-5)*8 : SB + 0+(NO5-5)*8]};
							default:locali= {{16{1'b0}},i[SC +D5+NO5*8 : SC +0+NO5*8],i[SB + D2+(NO5+3)*8 : SB + 0+(NO5+3)*8]};
						endcase
					end
					3:locali={72{1'b0}};
				endcase
			end*/
			/*
			2:begin  //7 * 7
				case(ID7)
					0:begin		// REG C B A
						case(NO7)
							2:locali={i[SB+ D2+NO7*8:SB+ 0+NO7*8],i[D1:0],i[D6+NO7*8: 0+NO7*8]};
							3:locali={i[SB+ D2+NO7*8:SB+ 0+NO7*8],i[D2:0],i[D5+NO7*8: 0+NO7*8]};
							4:locali={i[SB+ D2+NO7*8:SB+ 0+NO7*8],i[D3:0],i[D4+NO7*8: 0+NO7*8]};
							5:locali={i[SB+ D2+NO7*8:SB+ 0+NO7*8],i[D4:0],i[D3+NO7*8: 0+NO7*8]};
							6:locali={i[SB+ D2+NO7*8:SB+ 0+NO7*8],i[D5:0],i[D2+NO7*8: 0+NO7*8]};
							7:locali={i[SB+ D1:SB+ 0],i[SB+ D1+NO7*8:SB+ 0+NO7*8],i[D6:0],i[D1+NO7*8: 0+NO7*8]};
							default:locali={i[SB+ D2+NO7*8 :SB+ 0+NO7*8],i[D7+NO7*8: 0+NO7*8]};
						endcase
					end
					1:begin	  //REG D C B
						case(NO7)
							2:locali={i[SB +D4+NO7*8:SB +0+NO7*8],i[D1:0],i[D4+(NO7+2)*8:0+(NO7+2)*8]};
							3:locali={i [SB +D4+NO7*8:SB +0+NO7*8],i[D2:0],i[D3+(NO7+2)*8:0+(NO7+2)*8]};
							4:locali={i[SB +D4+NO7*8:SB +0+NO7*8],i[D3:0],i[D2+(NO7+2)*8:0+(NO7+2)*8]};
							5:locali={i[SB +D1:SB+0],i[SB +D3+NO7*8:SB +0+NO7*8],i[D4:0],i[D1+(NO7+2)*8:0+(NO7+2)*8]};
							6:locali={i[SB +D2:SB+0],i[SB +D2+NO7*8:SB +0+NO7*8],i[D5:0]};
							7:locali={i[SB +D3:SB+0],i[SB +D1+NO7*8:SB +0+NO7*8],i[D5+8:8]};
							default:locali={i[SB +D4+NO7*8:SB +0+NO7*8],i[D5+(NO7+2)*8:0+(NO7+2)*8]};
						endcase
					end
					2:begin	 //REG E D C
						case(NO7)
							2:locali={i[SB +D6+NO7*8:SB +NO7*8],i[D1:0],i[D2+ (NO7+4)*8: (NO7+4)*8]};
							3:locali={i[SB +D1:SB+0],i[SB +D5+NO7*8:SB +NO7*8],i[D2:0],i[D1+ (NO7+4)*8: (NO7+4)*8]};
							4:locali={i[SB +D2:SB+0],i[SB +D4+NO7*8:SB +NO7*8],i[D3+ (NO7-4)*8: (NO7-4)*8]};
							5:locali={i[SB +D3:SB+0],i[SB +D3+NO7*8:SB +NO7*8],i[D3+ (NO7-4)*8: (NO7-4)*8]};
							6:locali={i[SB +D4:SB+0],i[SB +D2+NO7*8:SB +NO7*8],i[D3+ (NO7-4)*8: (NO7-4)*8]};
							7:locali={i[SB +D5:SB+0],i[SB +D1+NO7*8:SB +NO7*8],i[D3+ (NO7-4)*8: (NO7-4)*8]};
							default:locali={i[SB +D6+NO7*8:SB +NO7*8],i[D3+ (NO7+4)*8: (NO7+4)*8]};
						endcase
					end
					3:begin	 //REG F E D
						case(NO7)
							2:locali={i[SC +D1+NO7*8:SC +NO7*8],i[SB +D1:SB +0],i[SB +D6+NO7*8:SB +0+NO7*8],i[D1+(NO7-2)*8:(NO7-2)*8]};
							3:locali={i[SC +D1+NO7*8:SC +NO7*8],i[SB +D2:SB +0],i[SB +D5+NO7*8:SB +0+NO7*8],i[D1+(NO7-2)*8:(NO7-2)*8]};
							4:locali={i[SC +D1+NO7*8:SC +NO7*8],i[SB +D3:SB +0],i[SB +D4+NO7*8:SB +0+NO7*8],i[D1+(NO7-2)*8:(NO7-2)*8]};
							5:locali={i[SC +D1+NO7*8:SC +NO7*8],i[SB +D4:SB +0],i[SB +D3+NO7*8:SB +0+NO7*8],i[D1+(NO7-2)*8:(NO7-2)*8]};
							6:locali={i[SC +D1+NO7*8:SC +NO7*8],i[SB +D5:SB +0],i[SB +D2+NO7*8:SB +0+NO7*8],i[D1+(NO7-2)*8:(NO7-2)*8]};
							7:locali={i[SC +D1+NO7*8:SC +NO7*8],i[SB +D6:SB +0],i[SB +D1+NO7*8:SB +0+NO7*8],i[D1+(NO7-2)*8:(NO7-2)*8]};
							default:locali={i[SC +D1+NO7*8:SC +NO7*8],i[SB +D7+NO7*8:SB +NO7*8],i[D1+(NO7+6)*8:(NO7+6)*8]};
						endcase
					end
					4:begin	 //REG G F E
						case(NO7)
							2:locali={i[SC +D3+NO7*8:SC +0+NO7*8],i[SB +D1:SB +0],i[SB +D5+(NO7+1)*8:SB +0+(NO7+1)*8]};
							3:locali={i[SC +D3+NO7*8:SC +0+NO7*8],i[SB +D2:SB +0],i[SB +D4+(NO7+1)*8:SB +0+(NO7+1)*8]};
							4:locali={i[SC +D3+NO7*8:SC +0+NO7*8],i[SB +D3:SB +0],i[SB +D3+(NO7+1)*8:SB +0+(NO7+1)*8]};
							5:locali={i[SC +D3+NO7*8:SC +0+NO7*8],i[SB +D4:SB +0],i[SB +D2+(NO7+1)*8:SB +0+(NO7+1)*8]};
							6:locali={i[SC +D1:SC +0],i[SC +D2+NO7*8:SC +0+NO7*8],i[SB +D5:SB +0],i[SB +D1+(NO7+1)*8:SB +0+(NO7+1)*8]};
							7:locali={i[SC +D2:SC +0],i[SC +D1+NO7*8:SC +0+NO7*8],i[SB +D6:SB +0]};
							default:locali={i[SC +D3+NO7*8:SC +0+NO7*8],i[SB +D6+(NO7+1)*8:SB +0+(NO7+1)*8]};
						endcase
					end
					5:begin  //REG G F END
						case(NO7)	
							2:locali={{40{1'b0}},i[SC +D1:SC +0],i[SC +D3+(NO7+3)*8:SC +0+(NO7+3)*8]};
							3:locali={{40{1'b0}},i[SC +D2:SC +0],i[SC +D2+(NO7+3)*8:SC +0+(NO7+3)*8]};
							4:locali={{40{1'b0}},i[SC +D3:SC +0],i[SC +D1+(NO7+3)*8:SC +0+(NO7+3)*8]};
							5:locali={{40{1'b0}},i[SC +D4:SC +0]};
							6:locali={{40{1'b0}},i[SC +D4+8:SC +8]};
							7:locali={{40{1'b0}},i[SC +D4+15:SC +15]};
							default:locali={{40{1'b0}},i[SC +D4+(NO7+3)*8:SC +0+(NO7+3)*8]};
						endcase
					end
					6:locali={72{1'b0}};
				endcase
			end
		endcase
	end
	*/
	always@(*)begin
		if(wsize==2 && ID7 == 8)localw = {w[79:72],64'b0};
		else localw = w[71:0];
	end
	
	always@(*)begin
		for(j=0;j<9;j=j+1)begin
			result[16*j +: 16]= localw[8*j +: 8] * locali[8*j +: 8];
		end
	end
	
		/*
		 0 3 6
		 1 4 7
		 2 5 8
		 result = [ 8 , 5 , 2 , 7 , 4 , 1 , 6 , 3 , 0 ] for add
		*/
endmodule


module IPF#(
	parameter In_Width   = 8, 
	parameter Out_Width  = 9,
	parameter Addr_Width = 16
)(
	input clk,
	input rst,
	input [1:0]ctrl,			//0: end , 1:start , 2:hold   
	
	input  [63:0] i_data, 		
	input  [63:0] w_data,
	input i_valid,w_valid,
	input  [1:0] Wsize,
	input  stride,
	output reg [9215:0] result,
	output reg res_valid,

	output finish

);
	parameter STATE_Width = 3;
	parameter FINISH  = 3'd1;
	parameter WAIT   = 3'd2;
	parameter COMPUTE = 3'd3;
	
	parameter HOLD = 2'd2;
	parameter START = 2'd1;
	parameter END = 2'd0;
	
	parameter D1 = 63;
	parameter W1 = 72;
	parameter KEEP =32;

	reg [STATE_Width-1:0] PS, NS;
    /*
	reg[191:0]icu0; 	//REG A B C			//can reg? 3 regx
	reg[191:0]icu1;	//REG A B C ,B C D	
	reg[191:0]icu2;	//REG A B C ,C D E	
	reg[191:0]icu3;	//REG A B C ,D E F 
	reg[191:0]icu4;	//REG A B C ,B C D , E F G
	reg[191:0]icu5;	//REG A B C ,C D E , E F G 
	reg[191:0]icu6;	//REG A B C ,D E F 
	reg[191:0]icu7;	//REG A B C ,B C D , E F G
	reg[191:0]icu8;*/
	
	
	reg [63:0]rega;
	reg [63:0]regb;
	reg [63:0]regc;
	reg [63:0]regd;
	reg [63:0]rege;
	reg [63:0]regf;
	reg [63:0]regg;
	reg [63:0]regh;
	reg [191:0]icu[0:8];
	reg [10:0]igroup;
	
	reg [1599:0]w;	 
	reg [3:0]widcnt;			
	reg [5:0]widstart;
	reg [79:0]wcu[0:63];
	integer idx,idxx;
	
	reg cnt5s0;					// 5 * 5 ,stride=1 , 2 cyc shift 1
	reg [1:0]cnt7s0;			// 7 * 7 ,stride=1 , 4 cyc shift 1
	reg cnts2;					// stride = 2 cnt
	reg [3:0]ccnt,rcnt;			// 8 ccnt => 1 rcnt
	reg cnt7_7_2;				// 7 * 7 weight 2 round full
	
	
	//wire [9215:0]result_tmp;
	/*
	CUBE #(.NO3(0),.NO5(0),.ID5(0),.NO7(0),.ID7(0))C0(.wsize(Wsize),.i_dat(icu0),.w_dat(wcu[0]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(1),.NO5(0),.ID5(1),.NO7(0),.ID7(1))C1(.wsize(Wsize),.i(icu1),.w(wcu[0]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(2),.NO5(0),.ID5(2),.NO7(0),.ID7(2))C2(.wsize(Wsize),.i(icu2),.w(wcu[0]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(3),.NO5(1),.ID5(0),.NO7(0),.ID7(3))C3(.wsize(Wsize),.i(icu3),.w(wcu[0]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(4),.NO5(1),.ID5(1),.NO7(0),.ID7(4))C4(.wsize(Wsize),.i(icu4),.w(wcu[0]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(5),.NO5(1),.ID5(2),.NO7(0),.ID7(5))C5(.wsize(Wsize),.i(icu5),.w(wcu[0]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(6),.NO5(2),.ID5(0),.NO7(1),.ID7(6))C6(.wsize(Wsize),.i(icu0),.w(wcu[0]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(7),.NO5(2),.ID5(1),.NO7(1),.ID7(7))C7(.wsize(Wsize),.i(icu1),.w(wcu[0]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(0),.NO5(2),.ID5(2),.NO7(1),.ID7(0))C8(.wsize(Wsize),.i(icu2),.w(wcu[1]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(1),.NO5(3),.ID5(0),.NO7(1),.ID7(1))C9(.wsize(Wsize),.i(icu3),.w(wcu[1]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(2),.NO5(3),.ID5(1),.NO7(1),.ID7(2))C10(.wsize(Wsize),.i(icu4),.w(wcu[1]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(3),.NO5(3),.ID5(2),.NO7(1),.ID7(3))C11(.wsize(Wsize),.i(icu5),.w(wcu[1]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(4),.NO5(4),.ID5(0),.NO7(2),.ID7(4))C12(.wsize(Wsize),.i(icu0),.w(wcu[1]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(5),.NO5(4),.ID5(1),.NO7(2),.ID7(5))C13(.wsize(Wsize),.i(icu1),.w(wcu[1]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(6),.NO5(4),.ID5(2),.NO7(2),.ID7(6))C14(.wsize(Wsize),.i(icu2),.w(wcu[1]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(7),.NO5(5),.ID5(0),.NO7(2),.ID7(7))C15(.wsize(Wsize),.i(icu3),.w(wcu[1]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(0),.NO5(5),.ID5(1),.NO7(2),.ID7(0))C16(.wsize(Wsize),.i(icu4),.w(wcu[2]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(1),.NO5(5),.ID5(2),.NO7(2),.ID7(1))C17(.wsize(Wsize),.i(icu5),.w(wcu[2]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(2),.NO5(6),.ID5(0),.NO7(3),.ID7(2))C18(.wsize(Wsize),.i(icu0),.w(wcu[2]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(3),.NO5(6),.ID5(1),.NO7(3),.ID7(3))C19(.wsize(Wsize),.i(icu1),.w(wcu[2]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(4),.NO5(6),.ID5(2),.NO7(3),.ID7(4))C20(.wsize(Wsize),.i(icu2),.w(wcu[2]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(5),.NO5(7),.ID5(0),.NO7(3),.ID7(5))C21(.wsize(Wsize),.i(icu3),.w(wcu[2]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(6),.NO5(7),.ID5(1),.NO7(3),.ID7(6))C22(.wsize(Wsize),.i(icu4),.w(wcu[2]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(7),.NO5(7),.ID5(2),.NO7(3),.ID7(7))C23(.wsize(Wsize),.i(icu5),.w(wcu[2]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(0),.NO5(0),.ID5(0),.NO7(4),.ID7(0))C24(.wsize(Wsize),.i(icu0),.w(wcu[3]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(1),.NO5(0),.ID5(1),.NO7(4),.ID7(1))C25(.wsize(Wsize),.i(icu1),.w(wcu[3]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(2),.NO5(0),.ID5(2),.NO7(4),.ID7(2))C26(.wsize(Wsize),.i(icu2),.w(wcu[3]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(3),.NO5(1),.ID5(0),.NO7(4),.ID7(3))C27(.wsize(Wsize),.i(icu3),.w(wcu[3]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(4),.NO5(1),.ID5(1),.NO7(4),.ID7(4))C28(.wsize(Wsize),.i(icu4),.w(wcu[3]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(5),.NO5(1),.ID5(2),.NO7(4),.ID7(5))C29(.wsize(Wsize),.i(icu5),.w(wcu[3]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(6),.NO5(2),.ID5(0),.NO7(5),.ID7(6))C30(.wsize(Wsize),.i(icu0),.w(wcu[3]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(7),.NO5(2),.ID5(1),.NO7(5),.ID7(7))C31(.wsize(Wsize),.i(icu1),.w(wcu[3]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(0),.NO5(2),.ID5(2),.NO7(5),.ID7(0))C32(.wsize(Wsize),.i(icu2),.w(wcu[4]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(1),.NO5(3),.ID5(0),.NO7(5),.ID7(1))C33(.wsize(Wsize),.i(icu3),.w(wcu[4]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(2),.NO5(3),.ID5(1),.NO7(5),.ID7(2))C34(.wsize(Wsize),.i(icu4),.w(wcu[4]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(3),.NO5(3),.ID5(2),.NO7(5),.ID7(3))C35(.wsize(Wsize),.i(icu5),.w(wcu[4]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(4),.NO5(4),.ID5(0),.NO7(6),.ID7(4))C36(.wsize(Wsize),.i(icu0),.w(wcu[4]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(5),.NO5(4),.ID5(1),.NO7(6),.ID7(5))C37(.wsize(Wsize),.i(icu1),.w(wcu[4]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(6),.NO5(4),.ID5(2),.NO7(6),.ID7(6))C38(.wsize(Wsize),.i(icu2),.w(wcu[4]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(7),.NO5(5),.ID5(0),.NO7(6),.ID7(7))C39(.wsize(Wsize),.i(icu3),.w(wcu[4]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(0),.NO5(5),.ID5(1),.NO7(6),.ID7(0))C40(.wsize(Wsize),.i(icu4),.w(wcu[5]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(1),.NO5(5),.ID5(2),.NO7(6),.ID7(1))C41(.wsize(Wsize),.i(icu5),.w(wcu[5]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(2),.NO5(6),.ID5(0),.NO7(7),.ID7(2))C42(.wsize(Wsize),.i(icu0),.w(wcu[5]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(3),.NO5(6),.ID5(1),.NO7(7),.ID7(3))C43(.wsize(Wsize),.i(icu1),.w(wcu[5]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(4),.NO5(6),.ID5(2),.NO7(7),.ID7(4))C44(.wsize(Wsize),.i(icu2),.w(wcu[5]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(5),.NO5(7),.ID5(0),.NO7(7),.ID7(5))C45(.wsize(Wsize),.i(icu3),.w(wcu[5]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(6),.NO5(7),.ID5(1),.NO7(7),.ID7(6))C46(.wsize(Wsize),.i(icu4),.w(wcu[5]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(7),.NO5(7),.ID5(2),.NO7(7),.ID7(7))C47(.wsize(Wsize),.i(icu5),.w(wcu[5]),.result(result_tmp[1151:1008]));
	
	CUBE #(.NO3(0),.NO5(4),.ID5(3),.NO7(1),.ID7(6))C48(.wsize(Wsize),.i(icu0),.w(wcu[6]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(1),.NO5(4),.ID5(3),.NO7(1),.ID7(6))C49(.wsize(Wsize),.i(icu0),.w(wcu[6]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(2),.NO5(4),.ID5(3),.NO7(1),.ID7(6))C50(.wsize(Wsize),.i(icu0),.w(wcu[6]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(3),.NO5(4),.ID5(3),.NO7(1),.ID7(6))C51(.wsize(Wsize),.i(icu0),.w(wcu[6]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(4),.NO5(4),.ID5(3),.NO7(1),.ID7(6))C52(.wsize(Wsize),.i(icu0),.w(wcu[6]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(5),.NO5(4),.ID5(3),.NO7(1),.ID7(6))C53(.wsize(Wsize),.i(icu0),.w(wcu[6]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(6),.NO5(4),.ID5(3),.NO7(1),.ID7(6))C54(.wsize(Wsize),.i(icu0),.w(wcu[6]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(7),.NO5(4),.ID5(3),.NO7(1),.ID7(6))C55(.wsize(Wsize),.i(icu0),.w(wcu[6]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(0),.NO5(4),.ID5(3),.NO7(1),.ID7(6))C56(.wsize(Wsize),.i(icu0),.w(wcu[7]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(1),.NO5(4),.ID5(3),.NO7(1),.ID7(6))C57(.wsize(Wsize),.i(icu0),.w(wcu[7]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(2),.NO5(4),.ID5(3),.NO7(1),.ID7(6))C58(.wsize(Wsize),.i(icu0),.w(wcu[7]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(3),.NO5(4),.ID5(3),.NO7(1),.ID7(6))C59(.wsize(Wsize),.i(icu0),.w(wcu[7]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(4),.NO5(4),.ID5(3),.NO7(1),.ID7(6))C60(.wsize(Wsize),.i(icu0),.w(wcu[7]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(5),.NO5(4),.ID5(3),.NO7(1),.ID7(6))C61(.wsize(Wsize),.i(icu0),.w(wcu[7]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(6),.NO5(4),.ID5(3),.NO7(1),.ID7(6))C62(.wsize(Wsize),.i(icu0),.w(wcu[7]),.result(result_tmp[1151:1008]));
	CUBE #(.NO3(7),.NO5(4),.ID5(3),.NO7(1),.ID7(6))C63(.wsize(Wsize),.i(icu0),.w(wcu[7]),.result(result_tmp[1151:1008]));
	*/
	assign finish = (PS == FINISH);
	
	
	/* FSM */
	always@(posedge clk or negedge rst)begin
		if(!rst)begin
			PS<=WAIT;
		end
		else begin
			PS<=NS;
		end
	end
	always@(*)begin
		NS = PS;
		res_valid=0;
		case(PS)
			WAIT:begin
				NS=WAIT;
				if(ctrl==START)begin
					NS=COMPUTE;
				end
				if(ctrl==END)begin
					NS=FINISH;
				end
			end
			COMPUTE:begin
				NS=COMPUTE;
				res_valid=1;
				if(ctrl==HOLD)begin
					NS=WAIT;
				end
				if(ctrl==END)begin
					NS=FINISH;
				end
			end
			FINISH:begin
				NS=FINISH;
			end
		endcase
	end

/*
	/* get wcu 
	always@(*)begin
		case(PS)
			COMPUTE:begin
				case(Wsize)
					0:begin		//3 * 3
						case(rcnt)
							0:begin
								for(idx=0;idx<8;idx=idx+1)begin
									wcu[idx]={320'b0,w[idx*72+:72]};
								end
							end
							1:begin
								for(idx=0;idx<8;idx=idx+1)begin
									wcu[idx]={320'b0,w[576+idx*72 +:72]};
								end
							end
						endcase
					end
					1:begin		//5 * 5
						wcu[6]=0;
						wcu[7]=0;
						case(rcnt)
							0:begin
								for(idx=0;idx<3;idx=idx+1)begin
									wcu[idx]={192'b0,w[199:0]};
								end
								for(idxx=3;idxx<6;idxx=idxx+1)begin
									wcu[idxx]={192'b0,w[399 :200]};
								end
							end
							1:begin
								for(idx=0;idx<3;idx=idx+1)begin
									wcu[idx]={192'b0,w[599:400]};
								end
								for(idxx=3;idxx<6;idxx=idxx+1)begin
									wcu[idxx]={192'b0,w[799 :600]};
								end
							end
							2:begin
								for(idx=0;idx<3;idx=idx+1)begin
									wcu[idx]={192'b0,w[999:800]};
								end
								for(idxx=6;idxx<6;idxx=idxx+1)begin
									wcu[idxx]={192'b0,w[1199 :1000]};
								end
							end
							3:begin
								for(idx=0;idx<3;idx=idx+1)begin
									wcu[idx]={192'b0,w[1399:1200]};
								end
								for(idxx=3;idxx<6;idxx=idxx+1)begin
									wcu[idxx]={192'b0,w[1599 :1400]};
								end
							end
						endcase
					end
					2:begin		// 7 * 7
						wcu[6]=0;
						wcu[7]=0;
						case(rcnt)
							0:begin
								for(idx=0;idx<6;idx=idx+1)begin
									wcu[idx]=w[491:0];
								end
							end
							1:begin
								for(idx=0;idx<6;idx=idx+1)begin
									wcu[idx]={192'b0,w[783:492]};
								end
							end
							2:begin
								for(idx=0;idx<6;idx=idx+1)begin
									wcu[idx]={192'b0,w[1175:784]};
								end
							end
							3:begin
								for(idx=0;idx<6;idx=idx+1)begin
									wcu[idx]={192'b0,w[1567:1176]};
								end
							end
						endcase
					end
				endcase
			end
			default:begin
				for(idx=0;idx<8;idx=idx+1)begin
					wcu[idx]=0;
				end
			end
		endcase
	end*/
	always@(*)begin
		case(Wsize)
			0:begin
				for(idx=0;idx<8;idx=idx+8)begin
					for(idxx=idx;idxx<8;idxx=idxx+1)begin
						wcu[idx]={8'b0,w[(W1*idx+igroup)+:72]};
					end
				end
			end
				/*
				for(idx=0;idx<8;idx=idx+1)begin		//igroup = 0 / 288
					wcu[idx]={8'b0,w[(0+igroup)+:72]};
				end
				for(idx=8;idx<16;idx=idx+1)begin
					wcu[idx]={8'b0,w[(W1+igroup)+:72]};
				end
				for(idx=16;idx<24;idx=idx+1)begin
					wcu[idx]={8'b0,w[(W1*2+igroup)+:72]};
				end
				for(idx=24;idx<32;idx=idx+1)begin
					wcu[idx]={8'b0,w[W1*3+igroup)+:72]};
				end
				for(idx=32;idx<40;idx=idx+1)begin		//igroup = 0 / 288
					wcu[idx]={8'b0,w[(W1*4+igroup)+:72]};
				end
				for(idx=40;idx<48;idx=idx+1)begin
					wcu[idx]={8'b0,w[(W1*5+igroup)+:72]};
				end
				for(idx=48;idx<56;idx=idx+1)begin
					wcu[idx]={8'b0,w[(W1*6+igroup)+:72]};
				end
				for(idx=56;idx<64;idx=idx+1)begin
					wcu[idx]={8'b0,w[W1*7+igroup)+:72]};
				end
			end
			1:begin*/
			default:begin
			end
		endcase	
	end
	/*get icu*/
	always@(*)begin
		case(Wsize)
			0:begin
				if(stride && !cnts2)begin	// stride = 2
					for(idx=0;idx<9;idx=idx+1)begin
						icu[idx]={regb,regc,regd};
					end
				end
				else begin					// stride = 1 , 2
					for(idx=0;idx<9;idx=idx+1)begin
						icu[idx]={rega,regb,regc};
					end
				end
			end
			1:begin
				if(stride && !cnts2)begin
					for(idx=0;idx<9;idx=idx+2)begin
						icu[idx]={regb,regc,regd};
					end
					for(idx=1;idx<=9;idx=idx+2)begin
						icu[idx]={rege,regf,64'b0};
					end
				end
				else begin
					for(idx=0;idx<9;idx=idx+2)begin
						icu[idx]={rega,regb,regc};
					end
					for(idx=1;idx<9;idx=idx+2)begin
						icu[idx]={regd,rege,64'b0};
					end
				end	
			end
			2:begin
				if(stride && cnts2)begin
					for(idx=0;idx<9;idx=idx+3)begin
						icu[idx]={regh,rega,regb};
					end
					for(idx=1;idx<9;idx=idx+3)begin
						icu[idx]={regc,regd,rege};
					end
					for(idx=2;idx<9;idx=idx+3)begin
						icu[idx]={regf,128'b0};
					end
				end
				else begin
					for(idx=0;idx<9;idx=idx+3)begin
						icu[idx]={rega,regb,regc};
					end
					for(idx=1;idx<9;idx=idx+3)begin
						icu[idx]={regd,rege,regf};
					end
					for(idx=2;idx<9;idx=idx+3)begin
						icu[idx]={regg,128'b0};
					end
				end	
			end
		endcase			
	end
	/* get data*/
	always@(posedge clk or negedge rst)begin
		if(!rst)begin
			rega<=0;
			regb<=0;
			regc<=0;
			regd<=0;
			rege<=0;
			regf<=0;
			regg<=0;
			regh<=0;
			w	<=0;
			widcnt<=0;
			widstart<=0;
			ccnt<=0;
			rcnt<=0;
			cnt7_7_2<=0;
			cnt5s0<=0;
			cnt7s0<=0;
			cnts2<=0;
			igroup<=0;
		end
		else begin
			rega<=rega;
			regb<=regb;
			regc<=regc;
			regd<=regd;
			rege<=rege;
			regf<=regf;
			regg<=regg;
			regh<=regh;
			w	<=w;
			widcnt  <=widcnt;
			widstart<=widstart;
			ccnt<=ccnt;
			rcnt<=rcnt;
			cnt7_7_2<=cnt7_7_2;
			cnt5s0  <=cnt5s0;
			cnt7s0  <=cnt7s0;
			cnts2   <=cnts2;
			igroup<=igroup;
			case(PS)
				WAIT:begin
					if(i_valid)begin
						rega<=regb;
						regb<=regc;
						regc<=regd;
						regd<=rege;
						rege<=regf;
						regf<=regg;
						regg<=regh;
						regh<=rega;
						case(Wsize)
							0:begin
								case(stride)
									0:regc<=i_data;
									1:regd<=i_data;
								endcase	
							end
							1:begin
								case(stride)
									0:regh<=i_data;		//full
									1:regf<=i_data;
								endcase	
							end
							default:begin
								regh<=i_data;			//full
							end
						endcase	
					end
					else if(w_valid)begin //3 , 5 full	
						case(widstart)
							0:begin
								case(widcnt)
									0:w[63: 0]<=w_data;
									1:w[127:64]<=w_data;
									2:w[191:128]<=w_data;
									3:w[255:192]<=w_data;
									4:w[319:256]<=w_data;
									5:w[320+D1:320]<=w_data;
									6:w[384+D1:384]<=w_data;
									7:w[448+D1:448]<=w_data;
									8:w[512+D1:512]<=w_data;
									9:w[576+D1:576]<=w_data;
									10:w[640+D1:640]<=w_data;
									11:w[704+D1:704]<=w_data;
									12:w[768+D1:768]<=w_data;
									13:w[832+D1:832]<=w_data;
									14:w[896+D1:896]<=w_data;
									15:w[960+D1:960]<=w_data;
									16:w[1024+D1:1024]<=w_data;
									17:w[1088+D1:1088]<=w_data;
									18:w[1152+D1:1152]<=w_data;
									19:w[1216+D1:1216]<=w_data;
									20:w[1280+D1:1280]<=w_data;
									21:w[1344+D1:1344]<=w_data;
									22:w[1408+D1:1408]<=w_data;
									23:w[1472+D1:1472]<=w_data;
									24:w[1536+D1:1536]<=w_data;
								endcase
							
							end
							32:begin	
								case(widcnt)
									0:w[63+KEEP: 0+KEEP]<=w_data;
									1:w[127+KEEP:64+KEEP]<=w_data;
									2:w[191+KEEP:128+KEEP]<=w_data;
									3:w[255+KEEP:192+KEEP]<=w_data;
									4:w[319+KEEP:256+KEEP]<=w_data;
									5:w[320+D1+KEEP:320+KEEP]<=w_data;
									6:w[384+D1+KEEP:384+KEEP]<=w_data;
									7:w[448+D1+KEEP:448+KEEP]<=w_data;
									8:w[512+D1+KEEP:512+KEEP]<=w_data;
									9:w[576+D1+KEEP:576+KEEP]<=w_data;
									10:w[640+D1+KEEP:640+KEEP]<=w_data;
									11:w[704+D1+KEEP:704+KEEP]<=w_data;
									12:w[768+D1+KEEP:768+KEEP]<=w_data;
									13:w[832+D1+KEEP:832+KEEP]<=w_data;
									14:w[896+D1+KEEP:896+KEEP]<=w_data;
									15:w[960+D1+KEEP:960+KEEP]<=w_data;
									16:w[1024+D1+KEEP:1024+KEEP]<=w_data;
									17:w[1088+D1+KEEP:1088+KEEP]<=w_data;
									18:w[1152+D1+KEEP:1152+KEEP]<=w_data;
									19:w[1216+D1+KEEP:1216+KEEP]<=w_data;
									20:w[1280+D1+KEEP:1280+KEEP]<=w_data;
									21:w[1344+D1+KEEP:1344+KEEP]<=w_data;
									22:w[1408+D1+KEEP:1408+KEEP]<=w_data;
									23:w[1472+D1+KEEP:1472+KEEP]<=w_data;
									24:w[1536+D1+KEEP:1536+KEEP]<=w_data;	
								endcase
							end
						endcase
						widcnt<=widcnt+1;	
					end
				end
				
				COMPUTE:begin
					// counter
					ccnt<=ccnt+1;
					
					// shift
					if(Wsize!=0 && stride==0)begin	
						if(cnt5s0 || (!cnt7s0 && Wsize==2))begin
							rega<=regb;
							regb<=regc;
							regc<=regd;
							regd<=rege;
							rege<=regf;
							regf<=regg;
							regg<=regh;
							regh<=rega;	
							ccnt<=ccnt+1;
							if(ccnt==7)begin
								ccnt<=0;
								rcnt<=rcnt+1;
							end
						end
						cnt5s0 <= ~cnt5s0;		//2 cyc shift 1
						cnt7s0 <= cnt7s0+1;		//4 cyc shift 1
						if(cnt7s0==3)cnt7s0 <= 0;
					end
					else begin
						rega<=regb;
						regb<=regc;
						regc<=regd;
						regd<=rege;
						rege<=regf;
						regf<=regg;
						regg<=regh;
						regh<=rega;	
						
						ccnt<=ccnt+1;
						cnts2<=~cnts2;
						if(ccnt==7)begin
							ccnt<=0;
							rcnt<=rcnt+1;
						end
					end
									
					// COMPUTE -> WAIT
					if(ctrl==HOLD)begin								
						if(Wsize==2)begin	// 7 * 7
							cnt7_7_2<= ~cnt7_7_2;		
							if(cnt7_7_2==0)begin
								w<=w[1599:1568];
								widstart<=32;
							end
							else begin
								w<=0;
								widstart<=0;
							end
						end
						else begin
							w<=0;
							widstart<=0;
						end
						widcnt<=0;					
						ccnt<=0;
						rcnt<=0;
						cnt5s0<=0;
						cnt7s0<=0;
						cnts2<=0;
					end	
				end			
			endcase
		end
	end
	
endmodule	