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
	input [2:0]round,
	input [1:0]wsize,
	input [1535:0]i_dat,		// 3 REG
	input [639:0]w_dat,
	input [3:0]i_format,w_format,
	output reg[575:0]result		//output reg[1151:0]result  //test so tmp output 575 (72*8) bits
	//output reg[143:0]result  //test so tmp output 72 bits
);
	parameter SA= 1024;		// 128*8
	parameter SB = 512;		// 64*8
	parameter SC = 0;
	parameter D1 = 63;		// 7 => 8*8 -1
	parameter D2 = 127;		// 15 => 16*8 -1
	parameter D3 = 191;		// 23 => 24*8 -1
	parameter D4 = 255;
	parameter D5 = 319;
	parameter D6 = 383;
	parameter D7 = 447;
	parameter P1 = 64;
	parameter P2 = 128;
	parameter P3 = 192;
	parameter P4 = 256;
	parameter P5 = 320;
	parameter P6 = 384;
	parameter P7 = 448;
	parameter DATA1 = 64;
	parameter DATA2 = 128;
	parameter DATA3 = 192;
	parameter DATA6 = 384;
	parameter DATA7 = 448;
	
	parameter ADD_FORMAT = 4; // tmp default
	
	integer j;
	
	reg [575:0]locali; 	
	reg [575:0]localw;
	
	reg [1535:0]i;	//REG C B A get row	
	reg [639:0]w;
	reg [3:0]i_format_dff,w_format_dff;
	
	wire test;
	wire [63:0]testres;
	assign test = (i_format_dff + w_format_dff > ADD_FORMAT);
	assign testres = result[63:0];
	
	always@(posedge clk or negedge rst)begin
		if(!rst)begin
			w<=0;
			i<=0;
			i_format_dff<=0;
			w_format_dff<=0;
		end
		else begin
			i<=i_dat;
			w<=w_dat;
			i_format_dff<=i_format;
			w_format_dff<=w_format;	
		end
	end
	
			
			
	always@(*)begin
		case(wsize)		
			0:begin		//3 * 3
				case(NO3)
					6:locali={i[D1:0],i[D2+NO3*DATA1 :NO3*DATA1],i[SB +D1:SB +0],i[SB +D2+NO3*DATA1 : SB +NO3*DATA1],i[SA +D1:SA +0],i[SA +D2+NO3*DATA1 : SA +NO3*DATA1]};
					7:locali={i[D2:0],i[D1+NO3*DATA1 :NO3*DATA1],i[SB +D2:SB +0],i[SB +D1+NO3*DATA1 : SB +NO3*DATA1],i[SA +D2:SA +0],i[SA +D1+NO3*DATA1 : SA +NO3*DATA1]};
					default: locali = {i[D3+NO3*DATA1 : NO3*DATA1] ,i[SB +D3+NO3*DATA1 :SB +NO3*DATA1] ,i[SA +D3+NO3*DATA1 : SA +NO3*DATA1] };
				endcase	
			end
			1:begin		//5 * 5
				case(stride)
					0:begin
						case(round)	// 2 round
							0:begin
								//case(NO5) // 4 NO
								case(ID5)
									0:locali = {i[D3+NO5*DATA1:NO5*DATA1],i[SB +D3+NO5*DATA1:SB +NO5*DATA1],i[SA +D3+NO5*DATA1:SA +NO5*DATA1]};
									1:locali = {{DATA3{1'b0}},i[SB +D3+NO5*DATA1:SB +NO5*DATA1],i[SA +D3+NO5*DATA1:SA +NO5*DATA1]};
									2:locali = {{DATA1{1'b0}},i[D2+P3+NO5*DATA1: P3+NO5*DATA1],{DATA1{1'b0}},i[SB +D2+P3+NO5*DATA1:SB +P3+NO5*DATA1],{DATA1{1'b0}},i[SA +D2+P3+NO5*DATA1:SA +P3+NO5*DATA1]};
									3:locali = {{DATA3{1'b0}},{DATA1{1'b0}},i[SB +D2+P3+NO5*DATA1:SB +P3+NO5*DATA1],{DATA1{1'b0}},i[SA +D2+P3+NO5*DATA1:SA +P3+NO5*DATA1]};
								endcase
								//endcase
							end
							1:begin
								case(ID5)
									0:begin		//3 *3
										case(NO5)
											2:locali = {i[D1:0],i[D2+(NO5+4)*DATA1:(NO5+4)*DATA1],i[SB +D1:SB],i[SB +D2+(NO5+4)*DATA1:SB +(NO5+4)*DATA1],i[SA +D1:SA],i[SA +D2+(NO5+4)*DATA1:SA +(NO5+4)*DATA1]};
											3:locali = {i[D2:0],i[D1+(NO5+4)*DATA1:(NO5+4)*DATA1],i[SB +D2:SB],i[SB +D1+(NO5+4)*DATA1:SB +(NO5+4)*DATA1],i[SA +D2:SA],i[SA +D1+(NO5+4)*DATA1:SA +(NO5+4)*DATA1]};
											default:locali={i[D3+(NO5+4)*DATA1:(NO5+4)*DATA1],i[SB +D3+(NO5+4)*DATA1:SB +(NO5+4)*DATA1],i[SA +D3+(NO5+4)*DATA1:SA +(NO5+4)*DATA1]};
										endcase
									end
									1:begin		//3 * 2
										case(NO5)
											2:locali = {{DATA3{1'b0}},i[SB +D1:SB],i[SB +D2+(NO5+4)*DATA1:SB +(NO5+4)*DATA1],i[SA +D1:SA],i[SA +D2+(NO5+4)*DATA1:SA +(NO5+4)*DATA1]};
											3:locali = {{DATA3{1'b0}},i[SB +D2:SB],i[SB +D1+(NO5+4)*DATA1:SB +(NO5+4)*DATA1],i[SA +D2:SA],i[SA +D1+(NO5+4)*DATA1:SA +(NO5+4)*DATA1]};
											default:locali={{DATA3{1'b0}},i[SB +D3+(NO5+4)*DATA1:SB +(NO5+4)*DATA1],i[SA +D3+(NO5+4)*DATA1:SA +(NO5+4)*DATA1]};
										endcase
									end
									2:begin		// 2 * 3
										case(NO5)
											0:locali={{DATA1{1'b0}},i[D1:0],i[D1+(NO5+7)*DATA1:(NO5+7)*DATA1],{DATA1{1'b0}},i[SB +D1:SB],i[SB +D1+(NO5+7)*DATA1:SB +(NO5+7)*DATA1],{DATA1{1'b0}},i[SA +D1:SA],i[SA +D1+(NO5+7)*DATA1:SA +(NO5+7)*DATA1]}; //NO5_0
											default:locali = {{DATA1{1'b0}},i[D2+(NO5-1)*DATA1:(NO5-1)*DATA1],i[D2+(NO5-1)*DATA1:(NO5-1)*DATA1],{DATA1{1'b0}},i[SB +D2+(NO5-1)*DATA1:SB +(NO5-1)*DATA1],{DATA1{1'b0}},i[SA +D2+(NO5-1)*DATA1:SA +(NO5-1)*DATA1]};
										endcase
									end
									3:begin		//2 * 2
										case(NO5)
											0:locali={{DATA3{1'b0}},{DATA1{1'b0}},i[SB +D1:SB],i[SB +D1+(NO5+7)*DATA1:SB +(NO5+7)*DATA1],{DATA1{1'b0}},i[SA +D1:SA],i[SA +D1+(NO5+7)*DATA1:SA +(NO5+7)*DATA1]}; //NO5_0
											default:locali = {{DATA3{1'b0}},{DATA1{1'b0}},i[SB +D2+(NO5-1)*DATA1:SB +(NO5-1)*DATA1],{DATA1{1'b0}},i[SA +D2+(NO5-1)*DATA1:SA +(NO5-1)*DATA1]};
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
									3:locali = {i[D1:0],i[D2+(NO5+3)*DATA1:(NO5+3)*DATA1],i[SB +D1:SB],i[SB +D2+(NO5+3)*DATA1:SB +(NO5+3)*DATA1],i[SA +D1:SA],i[SA +D2+(NO5+3)*DATA1:SA +(NO5+3)*DATA1]};
									default:locali={i[D3+(NO5*2)*DATA1:(NO5*2)*DATA1],i[SB +D3+(NO5*2)*DATA1:SB +(NO5*2)*DATA1],i[SA +D3+(NO5*2)*DATA1:SA +(NO5*2)*DATA1]};
								endcase	
							end
							1:begin // 3 * 2
								case(NO5)
									3:locali = {{DATA3{1'b0}},i[SB +D1:SB],i[SB +D2+(NO5+3)*DATA1:SB +(NO5+3)*DATA1],i[SA +D1:SA],i[SA +D2+(NO5+3)*DATA1:SA +(NO5+3)*DATA1]};
									default:locali={{DATA3{1'b0}},i[SB +D3+(NO5*2)*DATA1:SB +(NO5*2)*DATA1],i[SA +D3+(NO5*2)*DATA1:SA +(NO5*2)*DATA1]};
								endcase	
							end
							2:begin // 2 * 3
								case(NO5)
									0:locali = {{DATA1{1'b0}},i[D2+P3:P3],{DATA1{1'b0}},i[SB +D2+P3:SB +P3],{DATA1{1'b0}},i[SA +D2+P3:SA +P3]};
									1:locali = {{DATA1{1'b0}},i[D2+P5:P5],{DATA1{1'b0}},i[SB +D5+P5:SB +P5],{DATA1{1'b0}},i[SA +D2+P5:SA +P5]};
									2:locali = {{DATA1{1'b0}},i[D1:0],i[D1+P7:P7],{DATA1{1'b0}},i[SB +D1:SB],i[SB +D1+P7:SB +P7],{DATA1{1'b0}},i[SA +D1:SA],i[SA +D1+P7:SA +P7]};
									3:locali = {{DATA1{1'b0}},i[D2+P1:P1],{DATA1{1'b0}},i[SB +D5+P1:SB +P1],{DATA1{1'b0}},i[SA +D2+P1:SA +P1]};
								endcase
							end
							3:begin // 2 * 2
								case(NO5)
									0:locali = {{DATA3{1'b0}},{DATA1{1'b0}},i[SB +D2+P3:SB +P3],{DATA1{1'b0}},i[SA +D2+P3:SA +P3]};
									1:locali = {{DATA3{1'b0}},{DATA1{1'b0}},i[SB +D2+P5:SB +P5],{DATA1{1'b0}},i[SA +D2+P5:SA +P5]};
									2:locali = {{DATA3{1'b0}},{DATA1{1'b0}},i[SB +D1:SB],i[SB +D1+P7:SB +P7],{DATA1{1'b0}},i[SA +D1:SA],i[SA +D1+P7:SA +P7]};
									3:locali = {{DATA3{1'b0}},{DATA1{1'b0}},i[SB +D2+P1:SB +P1],{DATA1{1'b0}},i[SA +D2+P1:SA +P1]};
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
									0:locali={i[D3+NO7*DATA1:NO7*DATA1],i[SB +D3+NO7*DATA1:SB +NO7*DATA1],i[SA +D3+NO7*DATA1:SA +NO7*DATA1]};
									1:locali={i[D3+NO7*DATA1:NO7*DATA1],i[SB +D3+NO7*DATA1:SB +NO7*DATA1],i[SA +D3+NO7*DATA1:SA +NO7*DATA1]};
									2:locali={{DATA6{1'b0}},i[SA +D3+NO7*DATA1:SA +NO7*DATA1]};
									3:locali={i[D3+(NO7+3)*DATA1:(NO7+3)*DATA1],i[SB +D3+(NO7+3)*DATA1:SB +(NO7+3)*DATA1],i[SA +D3+(NO7+3)*DATA1:SA +(NO7+3)*DATA1]};
									4:locali={i[D3+(NO7+3)*DATA1:(NO7+3)*DATA1],i[SB +D3+(NO7+3)*DATA1:SB +(NO7+3)*DATA1],i[SA +D3+(NO7+3)*DATA1:SA +(NO7+3)*DATA1]};
									5:locali={{DATA6{1'b0}},i[SA +D3+(NO7+3)*DATA1:SA +(NO7+3)*DATA1]};
									6:locali={{DATA2{1'b0}},i[D1+(NO7+6)*DATA1:(NO7+6)*DATA1],{DATA2{1'b0}},i[SB +D1+(NO7+6)*DATA1:SB +(NO7+6)*DATA1],{DATA2{1'b0}},i[SA +D1+(NO7+6)*DATA1:SA +(NO7+6)*DATA1]};
									7:locali={{DATA2{1'b0}},i[D1+(NO7+6)*DATA1:(NO7+6)*DATA1],{DATA2{1'b0}},i[SB +D1+(NO7+6)*DATA1:SB +(NO7+6)*DATA1],{DATA2{1'b0}},i[SA +D1+(NO7+6)*DATA1:SA +(NO7+6)*DATA1]};
									8:locali={{DATA7{1'b0}},{DATA1{1'b0}},i[SA +D1+(NO7+6)*DATA1:SA +(NO7+6)*DATA1]};
									9:locali=576'b0;
								endcase
							end
							1:begin		//2~ , 3~
								case(ID7)		//NO7 : 0 , 1
									0:locali={i[D3+(NO7+2)*DATA1:(NO7+2)*DATA1],i[SB +D3+(NO7+2)*DATA1:SB +(NO7+2)*DATA1],i[SA +D3+(NO7+2)*DATA1:SA +(NO7+2)*DATA1]};
									1:locali={i[D3+(NO7+2)*DATA1:(NO7+2)*DATA1],i[SB +D3+(NO7+2)*DATA1:SB +(NO7+2)*DATA1],i[SA +D3+(NO7+2)*DATA1:SA +(NO7+2)*DATA1]};
									2:locali={{DATA6{1'b0}},i[SA +D3+(NO7+2)*DATA1:SA +(NO7+2)*DATA1]};
									3:begin
										case(NO7)
											0:locali={i[D3+(NO7+5)*DATA1:(NO7+5)*DATA1],i[SB +D3+(NO7+5)*DATA1:SB +(NO7+5)*DATA1],i[SA +D3+(NO7+5)*DATA1:SA +(NO7+5)*DATA1]};
											1:locali={i[D1:0],i[D2+(NO7+5)*DATA1:(NO7+5)*DATA1],i[SB +D1:SB],i[SB +D2+(NO7+5)*DATA1:SB +(NO7+5)*DATA1],i[SA +D1:SA ],i[SA +D2+(NO7+5)*DATA1:SA +(NO7+5)*DATA1]};
										endcase
									end
									4:begin
										case(NO7)
											0:locali={i[D3+(NO7+5)*DATA1:(NO7+5)*DATA1],i[SB +D3+(NO7+5)*DATA1:SB +(NO7+5)*DATA1],i[SA +D3+(NO7+5)*DATA1:SA +(NO7+5)*DATA1]};
											1:locali={i[D1:0],i[D2+(NO7+5)*DATA1:(NO7+5)*DATA1],i[SB +D1:SB],i[SB +D2+(NO7+5)*DATA1:SB +(NO7+5)*DATA1],i[SA +D1:SA ],i[SA +D2+(NO7+5)*DATA1:SA +(NO7+5)*DATA1]};
										endcase
									end
									5:begin
										case(NO7)
											0:locali={{DATA6{1'b0}},i[SA +D3+(NO7+5)*DATA1:SA +(NO7+5)*DATA1]};
											1:locali={{DATA6{1'b0}},i[SA +D1+NO7*DATA1:SA +NO7*DATA1],i[SA +D2:SA]};
										endcase
									end
									6:locali={{DATA2{1'b0}},i[D1+NO7*DATA1:NO7*DATA1],{DATA2{1'b0}},i[SB +D1+NO7*DATA1:SB +NO7*DATA1],{DATA2{1'b0}},i[SA +D1+NO7*DATA1:SA +NO7*DATA1]};
									7:locali={{DATA2{1'b0}},i[D1+NO7*DATA1:NO7*DATA1],{DATA2{1'b0}},i[SB +D1+NO7*DATA1:SB +NO7*DATA1],{DATA2{1'b0}},i[SA +D1+NO7*DATA1:SA +NO7*DATA1]};
									8:locali={{DATA7{1'b0}},{D1{1'b0}},i[SA +D1+NO7*DATA1:SA +NO7*DATA1]};
									9:locali=576'b0;
								endcase
							end
							2:begin		//4~ , 5~
								case(ID7)		//NO7 : 0 , 1
									0:locali={i[D3+(NO7+4)*DATA1:(NO7+4)*DATA1],i[SB +D3+(NO7+4)*DATA1:SB +(NO7+4)*DATA1],i[SA +D3+(NO7+4)*DATA1:SA +(NO7+4)*DATA1]};
									1:locali={i[D3+(NO7+4)*DATA1:(NO7+4)*DATA1],i[SB +D3+(NO7+4)*DATA1:SB +(NO7+4)*DATA1],i[SA +D3+(NO7+4)*DATA1:SA +(NO7+4)*DATA1]};
									2:locali={{DATA6{1'b0}},i[SA +D3+(NO7+4)*DATA1:SA +(NO7+4)*DATA1]};
									3:begin
										case(NO7)
											0:locali={i[D2:0],i[D1+(NO7+7)*DATA1:(NO7+7)*DATA1],i[SB +D2+NO7*DATA1:SB +NO7*DATA1],i[SB +D1+(NO7+7)*DATA1:SB +(NO7+7)*DATA1],i[SA +D2+NO7*DATA1:SA +NO7*DATA1],i[SA +D1+(NO7+7)*DATA1:SA +(NO7+7)*DATA1]};
											1:locali={i[D3+(NO7-1)*DATA1:(NO7-1)*DATA1],i[SB +D3+(NO7-1)*DATA1:SB +(NO7-1)*DATA1],i[SA +D3+(NO7-1)*DATA1:SA +(NO7-1)*DATA1]};
										endcase
									end
									4:begin
										case(NO7)
											0:locali={i[D2:0],i[D1+(NO7+7)*DATA1:(NO7+7)*DATA1],i[SB +D2+NO7*DATA1:SB +NO7*DATA1],i[SB +D1+(NO7+7)*DATA1:SB +(NO7+7)*DATA1],i[SA +D2+NO7*DATA1:SA +NO7*DATA1],i[SA +D1+(NO7+7)*DATA1:SA +(NO7+7)*DATA1]};
											1:locali={i[D3+(NO7-1)*DATA1:(NO7-1)*DATA1],i[SB +D3+(NO7-1)*DATA1:SB +(NO7-1)*DATA1],i[SA +D3+(NO7-1)*DATA1:SA +(NO7-1)*DATA1]};
										endcase
									end
									5:begin
										case(NO7)
											0:locali={{DATA6{1'b0}},i[SA +D2+NO7*DATA1:SA +NO7*DATA1],i[SA +D1+(NO7+7)*DATA1:SA +(NO7+7)*DATA1]};
											1:locali={{DATA6{1'b0}},i[SA +D3+(NO7-1)*DATA1:SA +(NO7-1)*DATA1]};
										endcase
									end
									6:locali={{DATA2{1'b0}},i[D1+(NO7+2)*DATA1:(NO7+2)*DATA1],{DATA2{1'b0}},i[SB +D1+(NO7+2)*DATA1:SB +(NO7+2)*DATA1],{DATA2{1'b0}},i[SA +D1+(NO7+2)*DATA1:SA +(NO7+2)*DATA1]};
									7:locali={{DATA2{1'b0}},i[D1+(NO7+2)*DATA1:(NO7+2)*DATA1],{DATA2{1'b0}},i[SB +D1+(NO7+2)*DATA1:SB +(NO7+2)*DATA1],{DATA2{1'b0}},i[SA +D1+(NO7+2)*DATA1:SA +(NO7+2)*DATA1]};
									8:locali={{DATA7{1'b0}},{DATA1{1'b0}},i[SA +D1+(NO7+2)*DATA1:SA +(NO7+2)*DATA1]};
									9:locali=576'b0;
								endcase
							end
							3:begin		//6~ , 7~
								case(ID7)		//NO7 : 0 , 1
									0:begin
										case(NO7)
											0:locali={i[D1:0],i[D2+P6:P6],i[SB +D1:SB],i[SB +D2+P6:SB +P6],i[SA +D1:SA],i[SA +D2+P6:SA +P6]};
											1:locali={i[D2:0],i[D1+P7:P7],i[SB +D2:SB],i[SB +D1+P7:SB +P7],i[SA +D2:SA],i[SA +D1+P7:SA +P7]};
										endcase
									end
									1:begin
										case(NO7)
											0:locali={i[D1:0],i[D2+P6:P6],i[SB +D1:SB],i[SB +D2+P6:SB +P6],i[SA +D1:SA],i[SA +D2+P6:SA +P6]};
											1:locali={i[D2:0],i[D1+P7:P7],i[SB +D2:SB],i[SB +D1+P7:SB +P7],i[SA +D2:SA],i[SA +D1+P7:SA +P7]};
										endcase
									end
									2:begin
										case(NO7)
											0:locali={{DATA6{1'b0}},i[SA +D1:SA],i[SA +D2+P6:SA +P6]};
											1:locali={{DATA6{1'b0}},i[SA +D2:SA],i[SA +D1+P7:SA +P7]};
										endcase
									end
									3:locali={i[D3+(NO7+1)*DATA1:(NO7+1)*DATA1],i[SB +D3+(NO7+1)*DATA1:SB +(NO7+1)*DATA1],i[SA +D3+(NO7+1)*DATA1:SA +(NO7+1)*DATA1]};
									4:locali={i[D3+(NO7+1)*DATA1:(NO7+1)*DATA1],i[SB +D3+(NO7+1)*DATA1:SB +(NO7+1)*DATA1],i[SA +D3+(NO7+1)*DATA1:SA +(NO7+1)*DATA1]};
									5:locali={{DATA6{1'b0}},i[SA +D3+(NO7+1)*DATA1:SA +(NO7+1)*DATA1]};
									6:locali={{DATA2{1'b0}},i[D1+(NO7+4)*DATA1:(NO7+4)*DATA1],{DATA2{1'b0}},i[SB +D1+(NO7+4)*DATA1:SB +(NO7+4)*DATA1],{DATA2{1'b0}},i[SA +D1+(NO7+4)*DATA1:SA +(NO7+4)*DATA1]};
									7:locali={{DATA2{1'b0}},i[D1+(NO7+4)*DATA1:(NO7+4)*DATA1],{DATA2{1'b0}},i[SB +D1+(NO7+4)*DATA1:SB +(NO7+4)*DATA1],{DATA2{1'b0}},i[SA +D1+(NO7+4)*DATA1:SA +(NO7+4)*DATA1]};
									8:locali={{DATA7{1'b0}},{DATA1{1'b0}},i[SA +D1+(NO7+4)*DATA1:SA +(NO7+4)*DATA1]};
									9:locali=576'b0;
								endcase
							end
						endcase
					end
					1:begin	//stride 2 round 2
						case(round)
							0:begin		// 0~ ,2~
								case(ID7)
									0:locali={i[D3+(NO7*2)*DATA1:(NO7*2)*DATA1],i[SB +D3+(NO7*2)*DATA1:SB +(NO7*2)*DATA1],i[SA +D3+(NO7*2)*DATA1:SA +(NO7*2)*DATA1]};
									1:locali={i[D3+(NO7*2)*DATA1:(NO7*2)*DATA1],i[SB +D3+(NO7*2)*DATA1:SB +(NO7*2)*DATA1],i[SA +D3+(NO7*2)*DATA1:SA +(NO7*2)*DATA1]};
									2:locali={{DATA6{1'b0}},i[SA +D3+(NO7*2)*DATA1:SA +(NO7*2)*DATA1]};
									3:begin
										case(NO7)
											0:locali={i[D3+P3:P3],i[SB +D3+P3:SB +P3],i[SA +D3+P3:SA +P3]};
											1:locali={i[D3+P5:P5],i[SB +D3+P5:SB +P5],i[SA +D3+P5:SA +P5]};
										endcase
									end
									4:begin
										case(NO7)
											0:locali={i[D3+P3:P3],i[SB +D3+P3:SB +P3],i[SA +D3+P3:SA +P3]};
											1:locali={i[D3+P5:P5],i[SB +D3+P5:SB +P5],i[SA +D3+P5:SA +P5]};
										endcase
									end
									5:begin
										case(NO7)
											0:locali={{DATA6{1'b0}},i[SA +D3+P3:SA +P3]};
											1:locali={{DATA6{1'b0}},i[SA +D3+P5:SA +P5]};
										endcase
									end
									6:begin
										case(NO7)
											0:locali={{DATA2{1'b0}},i[D1+P6:P6],{DATA2{1'b0}},i[SB +D1+P6:SB +P6],{DATA2{1'b0}},i[SA +D1+P6:SA +P6]};
											1:locali={{DATA2{1'b0}},i[D1:0],{DATA2{1'b0}},i[SB +D1:SB],{DATA2{1'b0}},i[SA +D1:SA]};
										endcase
									end
									7:begin
										case(NO7)
											0:locali={{DATA2{1'b0}},i[D1+P6:P6],{DATA2{1'b0}},i[SB +D1+P6:SB +P6],{DATA2{1'b0}},i[SA +D1+P6:SA +P6]};
											1:locali={{DATA2{1'b0}},i[D1:0],{DATA2{1'b0}},i[SB +D1:SB],{DATA2{1'b0}},i[SA +D1:SA]};
										endcase
									end
									8:begin
										case(NO7)
											0:locali={{DATA7{1'b0}},{DATA1{1'b0}},i[SA +D1+P6:SA +P6]};
											1:locali={{DATA7{1'b0}},{DATA1{1'b0}},i[SA +D1:SA]};
										endcase
									end
									9:locali=576'b0;
								endcase
							end
							1:begin		// 4~ ,6~
								case(ID7)
									0:begin
										case(NO7)
											0:locali={i[D3+P4:P4],i[SB +D3+P4:SB +P4],i[SA +D3+P4:SA +P4]};
											1:locali={i[D1:0],i[D2+P6:P6],i[SB +D1:SB],i[SB +D2+P6:SB +P6],i[SA +D1:SA],i[SA +D2+P6:SA +P6]};
										endcase
									end
									1:begin
										case(NO7)
											0:locali={i[D3+P4:P4],i[SB +D3+P4:SB +P4],i[SA +D3+P4:SA +P4]};
											1:locali={i[D1:0],i[D2+P6:P6],i[SB +D1:SB],i[SB +D2+P6:SB +P6],i[SA +D1:SA],i[SA +D2+P6:SA +P6]};
										endcase
									end
									2:begin
										case(NO7)
											0:locali={{DATA6{1'b0}},i[SA +D3+P4:SA +P4]};
											1:locali={{DATA6{1'b0}},i[SA +D1:SA],i[SA +D2+P6:SA +P6]};
										endcase
									end
									3:begin
										case(NO7)
											0:locali={i[D2:0],i[D1+P7:P7],i[SB +D2:SB],i[SB +D1+P7:SB +P7],i[SA +D2:SA],i[SA +D1+P7:SA +P7]};
											1:locali={i[D3+P1:P1],i[SB +D3+P1:SB +P1],i[SA +D3+P1:SA +P1]};
										endcase
									end
									4:begin
										case(NO7)
											0:locali={i[D2:0],i[D1+P7:P7],i[SB +D2:SB],i[SB +D1+P7:SB +P7],i[SA +D2:SA],i[SA +D1+P7:SA +P7]};
											1:locali={i[D3+P1:P1],i[SB +D3+P1:SB +P1],i[SA +D3+P1:SA +P1]};
										endcase
									end
									5:begin
										case(NO7)
											0:locali={{DATA6{1'b0}},i[SA +D2:SA],i[SA +D1+P7:SA +P7]};
											1:locali={{DATA6{1'b0}},i[SA +D3+P1:SA +P1]};
										endcase
									end
									6:begin
										case(NO7)
											0:locali={{DATA2{1'b0}},i[D1+P2:P2],{DATA2{1'b0}},i[SB +D1+P2:SB +P2],{DATA2{1'b0}},i[SA +D1+P2:SA +P2]};
											1:locali={{DATA2{1'b0}},i[D1+P4:P4],{DATA2{1'b0}},i[SB +D1+P4:SB +P4],{DATA2{1'b0}},i[SA +D1+P4:SA +P4]};
										endcase
									end
									7:begin
										case(NO7)
											0:locali={{DATA2{1'b0}},i[D1+P2:P2],{DATA2{1'b0}},i[SB +D1+P2:SB +P2],{DATA2{1'b0}},i[SA +D1+P2:SA +P2]};
											1:locali={{DATA2{1'b0}},i[D1+P4:P4],{DATA2{1'b0}},i[SB +D1+P4:SB +P4],{DATA2{1'b0}},i[SA +D1+P4:SA +P4]};
										endcase
									end
									8:begin
										case(NO7)
											0:locali={{DATA7{1'b0}},{DATA1{1'b0}},i[SA +D1+P2:SA +P2]};
											1:locali={{DATA7{1'b0}},{DATA1{1'b0}},i[SA +D1+P4:SA +P4]};
										endcase
									end
									9:locali=576'b0;
								endcase
							end
						endcase
					end	
				endcase
			end
		endcase
	end		

	always@(*)begin
		if(wsize==2 && ID7 == 8)localw = {512'b0,w[639:576]};
		else localw = w[575:0];
	end
	
	
	always@(posedge clk or negedge rst)begin  
		if(!rst)begin
			result<=0;
		end
		else begin
			if(i_format_dff+w_format_dff > ADD_FORMAT)begin
				for(j=0;j<72;j=j+1)begin
					result[8*j +: 8] <= (localw[8*j +: 8] * locali[8*j +: 8]) >> (i_format_dff+w_format_dff-ADD_FORMAT);
				end
			end
			else begin
				for(j=0;j<72;j=j+1)begin
					result[8*j +: 8] <= (localw[8*j +: 8] * locali[8*j +: 8]) << (ADD_FORMAT-i_format_dff-w_format_dff);
				end
			end
		end
		
	end
	
endmodule