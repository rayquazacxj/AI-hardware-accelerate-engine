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
	
	parameter D1 = 8;
	parameter D2 = 16;
	parameter D3 = 24;
	parameter P1 = 8;
	parameter W1 = 72;
	parameter KEEP =32;

	reg [STATE_Width-1:0] PS, NS;
	
	reg [63:0]rega;
	reg [63:0]regb;
	reg [63:0]regc;
	reg [63:0]regd;
	reg [63:0]rege;
	reg [63:0]regf;
	reg [63:0]regg;
	reg [63:0]regh;
	reg [191:0]icu[0:8];
	
	
	reg [1599:0]w;	 
	reg [3:0]widcnt;			
	reg [5:0]widstart;
	reg [79:0]wcu[0:63];
	reg [9:0]wgroup;
	reg wgroup_cnt;
	integer idx,idxx,idi;
	
	
	reg cnt5s0;					// 5 * 5 ,stride=1 , 2 cyc shift 1
	reg [1:0]cnt7s0;			// 7 * 7 ,stride=1 , 4 cyc shift 1
	reg cnts2;					// stride = 2 cnt
	reg [3:0]ccnt;				// 8 ccnt => 1 rcnt
	reg cnt7_7_2;				// 7 * 7 weight 2 round full
	
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
	
	/* get wcu */
	always@(posedge clk or negedge rst)begin
		wgroup<=wgroup;
		wgroup_cnt<= ~wgroup_cnt;
		
		if(!rst || PS==WAIT)begin
			wgroup<=0;
			wgroup_cnt<=1;
		end
		else if(stride==0 && ccnt==7)begin
			case(Wsize)
				0:wgroup<= 9*P1*8;
				1:wgroup<= 25*P1*4;
				2:wgroup<= 49*P1*2;
			endcase
		end
		else if(stride==1 && Wsize==2)wgroup<= (wgroup_cnt)? 0:49*P1*2;
		else if(stride==1)begin
			case(Wsize)
				0:wgroup<= (wgroup_cnt)? 0: 9*P1*8;
				1:wgroup<= (wgroup_cnt)? 0: 25*P1*4;
				default:wgroup<= wgroup;
			endcase
		end		
	end
	
	always@(*)begin
		case(Wsize)
			0:begin
				for(idx=0;idx<8;idx=idx+8)begin
					for(idxx=idx;idxx<8;idxx=idxx+1)begin
						wcu[idx]={8'b0,w[(W1*idx+wgroup)+:W1]};
					end
				end
			end	
			1:begin
				for(idi=0;idi<4;idi=idi+1)begin
					for(idx=0;idx<4;idx=idx+1)begin
						for(idxx=0;idxx<4;idxx=idxx+1)begin
							case(idxx)
								0:wcu[idi+idx+idxx]={8'b0,w[wgroup+idi*(P1*25) +:D3],w[(P1*5)+wgroup+idi*(P1*25) +:D3],w[(P1*10)+wgroup+idi*(P1*25) +:D3]};
								1:wcu[idi+idx+idxx]={8'b0,w[(P1*15)+wgroup+idi*(P1*25) +:D3],w[(P1*20)+wgroup+idi*(P1*25) +:D3],24'b0};
								2:wcu[idi+idx+idxx]={8'b0,w[(P1*3)+wgroup+idi*(P1*25) +:D2],8'b0,w[(P1*8)+wgroup+idi*(P1*25) +:D2],8'b0,w[(P1*13)+wgroup+idi*(P1*25) +:D2],8'b0};
								3:wcu[idi+idx+idxx]={8'b0,w[(P1*18)+wgroup+idi*(P1*25) +:D2],8'b0,w[(P1*23)+wgroup+idi*(P1*25) +:D2],8'b0,24'b0};
							endcase
						end
					end
				end
			end
			2:begin
				for(idi=0;idi<2;idi=idi+1)begin		// 0 - 31 , 32 - 63
					for(idx=0;idx<2;idx=idx+1)begin	// 16 , 16
						for(idxx=0;idxx<15;idxx=idxx+1)begin
							case(idxx)
								0:wcu[(idi+idx)*16+idxx]={w[(P1*48)+wgroup+idi*(P1*49) +:D1],w[wgroup+idi*(P1*49) +:D3],w[(P1*7)+wgroup+idi*(P1*49) +:D3],w[(P1*14)+wgroup+idi*(P1*49) +:D3]};
								1:wcu[(idi+idx)*16+idxx]={8'b0,w[(P1*21)+wgroup+idi*(P1*49) +:D3],w[(P1*28)+wgroup+idi*(P1*49) +:D3],w[(P1*35)+wgroup+idi*(P1*49) +:D3]};
								2:wcu[(idi+idx)*16+idxx]={8'b0,w[(P1*42)+wgroup+idi*(P1*49) +:D3],48'b0};
								3:wcu[(idi+idx)*16+idxx]={8'b0,w[(P1*3)+wgroup+idi*(P1*49) +:D3],w[(P1*10)+wgroup+idi*(P1*49) +:D3],w[(P1*17)+wgroup+idi*(P1*49) +:D3]};
								4:wcu[(idi+idx)*16+idxx]={8'b0,w[(P1*24)+wgroup+idi*(P1*49) +:D3],w[(P1*31)+wgroup+idi*(P1*49) +:D3],w[(P1*38)+wgroup+idi*(P1*49) +:D3]};
								5:wcu[(idi+idx)*16+idxx]={8'b0,w[(P1*45)+wgroup+idi*(P1*49) +:D3],48'b0};
								6:wcu[(idi+idx)*16+idxx]={8'b0,w[(P1*6)+wgroup+idi*(P1*49) +:D1],16'b0,w[(P1*13)+wgroup+idi*(P1*49) +:D1],16'b0,w[(P1*20)+wgroup+idi*(P1*49) +:D1],16'b0};
								7:wcu[(idi+idx)*16+idxx]={8'b0,w[(P1*27)+wgroup+idi*(P1*49) +:D1],16'b0,w[(P1*34)+wgroup+idi*(P1*49) +:D1],16'b0,w[(P1*41)+wgroup+idi*(P1*49) +:D1],16'b0};
								default:wcu[(idi+idx)*16+idxx]=0;
							endcase
						end
					end
				end	
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
			cnt7_7_2<=0;
			cnt5s0<=0;
			cnt7s0<=0;
			cnts2<=0;
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
			cnt7_7_2<=cnt7_7_2;
			cnt5s0  <=cnt5s0;
			cnt7s0  <=cnt7s0;
			cnts2   <=cnts2;
			igroup<=igroup;
			
			if(i_valid)begin
				if(PS==WAIT)begin
					rega<=regb;
					regb<=regc;
					regc<=regd;
					regd<=rege;
					rege<=regf;
					regf<=regg;
					regg<=regh;
					regh<=rega;
				end
				
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
			if(w_valid)begin //3 , 5 full	
				case(widstart)
					0:w[(widcnt*64)-1 +: 64]<=w_data;
					32:w[(widcnt*64)-1+KEEP +:KEEP]<=w_data;
				endcase
				widcnt<=widcnt+1;	
			end
		
				
			if(PS==COMPUTE)begin
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
						if(ccnt==7)ccnt<=0;
							
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
					if(ccnt==7)ccnt<=0;
						
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
					cnt5s0<=0;
					cnt7s0<=0;
					cnts2<=0;
				end	
			end			
		end
	end
	
endmodule	