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
	
	input  [511:0] i_data, 		
	input  [511:0] w_data,
	input i_valid,w_valid,
	input  [1:0] Wsize,
	input  [3:0] i_format,w_format,
	
	input  [1:0]RLPadding,
	input  stride,
	input  [3:0]wgroup,
	input  [2:0]wround,
	
	
	output [73727:0] result,
	output reg res_valid,
	
	output [575:0] tmp_result0,
	output [575:0] tmp_result1,
	output [575:0] tmp_result2,
	output [575:0] tmp_result3,
	output [575:0] tmp_result4,
	output [575:0] tmp_result5,
	output [575:0] tmp_result6,
	output [575:0] tmp_result7,
	output [575:0] tmp_result8,
	output [575:0] tmp_result9,
	output [575:0] tmp_result10,
	output [575:0] tmp_result11,
	output [575:0] tmp_result12,
	output [575:0] tmp_result13,
	output [575:0] tmp_result14,
	output [575:0] tmp_result15,
	output [575:0] tmp_result16,
	output [575:0] tmp_result17,
	output [575:0] tmp_result18,
	output [575:0] tmp_result19,
	output [575:0] tmp_result20,
	output [575:0] tmp_result21,
	output [575:0] tmp_result22,
	output [575:0] tmp_result23,
	output [575:0] tmp_result24,
	output [575:0] tmp_result25,
	output [575:0] tmp_result26,
	output [575:0] tmp_result27,
	output [575:0] tmp_result28,
	output [575:0] tmp_result29,
	output [575:0] tmp_result30,
	output [575:0] tmp_result31,


	output finish
);
	parameter STATE_Width = 3;
	parameter FINISH  = 3'd1;
	parameter WAIT   = 3'd2;
	parameter COMPUTE = 3'd3;
	
	parameter HOLD = 2'd2;
	parameter START = 2'd1;
	parameter END = 2'd0;
	
	parameter RPadding = 2'd1;
	parameter LPadding = 2'd2;
	
	parameter DATA1 = 64;
	parameter DATA2 = 128;
	parameter DATA3 = 192;
	parameter DATA6 = 384;
	parameter P1 = 64;
	parameter W1 = 576;  // 72*8
	parameter KEEP =256;  // 32
	

	reg [STATE_Width-1:0] PS, NS;
	
	reg res_valid_tmp,res_valid_tmp1;
	
	reg [3:0]i_format_tmp,i_format_tmp1,w_format_tmp,w_format_tmp1;
	
	reg [511:0]rega;
	reg [511:0]regb;
	reg [511:0]regc;
	reg [511:0]regd;
	reg [511:0]rege;
	reg [511:0]regf;
	reg [511:0]regg;
	reg [511:0]regh;
	reg [1535:0]icu[0:8];
	reg [2:0]round;
	
	
	reg [12799:0]w;	 
	reg [4:0]widcnt;			
	reg [8:0]widstart;
	reg [639:0]wcu[0:63];
	reg [12:0]wgroup_start;  //MAX 5*5*8*8*4 = 6400
	reg [3:0]wgroup_dff;
	integer idx,idxx,idi;
	
	reg cnt7_7_2;				// 7 * 7 weight 2 round full
	
	
	reg[20:0]widtest;
	
	CUBE #(.NO3(0),.NO5(0),.ID5(0),.NO7(0),.ID7(0))C0(.wsize(Wsize),.i_dat(icu[0]),.w_dat(wcu[0]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format_tmp1),.w_format(w_format_tmp1),.result(tmp_result0));
	CUBE #(.NO3(1),.NO5(0),.ID5(1),.NO7(0),.ID7(1))C1(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[1]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format_tmp1),.w_format(w_format_tmp1),.result(tmp_result1));
	CUBE #(.NO3(2),.NO5(0),.ID5(2),.NO7(0),.ID7(2))C2(.wsize(Wsize),.i_dat(icu[2]),.w_dat(wcu[2]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format_tmp1),.w_format(w_format_tmp1),.result(tmp_result2));
	CUBE #(.NO3(3),.NO5(0),.ID5(3),.NO7(0),.ID7(3))C3(.wsize(Wsize),.i_dat(icu[3]),.w_dat(wcu[3]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format_tmp1),.w_format(w_format_tmp1),.result(tmp_result3));
	CUBE #(.NO3(4),.NO5(1),.ID5(0),.NO7(0),.ID7(4))C4(.wsize(Wsize),.i_dat(icu[4]),.w_dat(wcu[4]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format_tmp1),.w_format(w_format_tmp1),.result(tmp_result4));
	CUBE #(.NO3(5),.NO5(1),.ID5(1),.NO7(0),.ID7(5))C5(.wsize(Wsize),.i_dat(icu[5]),.w_dat(wcu[5]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format_tmp1),.w_format(w_format_tmp1),.result(tmp_result5));
	CUBE #(.NO3(6),.NO5(1),.ID5(2),.NO7(0),.ID7(6))C6(.wsize(Wsize),.i_dat(icu[6]),.w_dat(wcu[6]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format_tmp1),.w_format(w_format_tmp1),.result(tmp_result6));
	CUBE #(.NO3(7),.NO5(1),.ID5(3),.NO7(0),.ID7(7))C7(.wsize(Wsize),.i_dat(icu[7]),.w_dat(wcu[7]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format_tmp1),.w_format(w_format_tmp1),.result(tmp_result7));
	CUBE #(.NO3(0),.NO5(2),.ID5(0),.NO7(0),.ID7(8))C8(.wsize(Wsize),.i_dat(icu[8]),.w_dat(wcu[8]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format_tmp1),.w_format(w_format_tmp1),.result(tmp_result8));
	CUBE #(.NO3(1),.NO5(2),.ID5(1),.NO7(0),.ID7(9))C9(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[9]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format_tmp1),.w_format(w_format_tmp1),.result(tmp_result9));
	CUBE #(.NO3(2),.NO5(2),.ID5(2),.NO7(0),.ID7(9))C10(.wsize(Wsize),.i_dat(icu[0]),.w_dat(wcu[10]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result10));
	CUBE #(.NO3(3),.NO5(2),.ID5(3),.NO7(0),.ID7(9))C11(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[11]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result11));
	CUBE #(.NO3(4),.NO5(3),.ID5(0),.NO7(0),.ID7(9))C12(.wsize(Wsize),.i_dat(icu[0]),.w_dat(wcu[12]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result12));
	CUBE #(.NO3(5),.NO5(3),.ID5(1),.NO7(0),.ID7(9))C13(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[13]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result13));
	CUBE #(.NO3(6),.NO5(3),.ID5(2),.NO7(0),.ID7(9))C14(.wsize(Wsize),.i_dat(icu[0]),.w_dat(wcu[14]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result14));
	CUBE #(.NO3(7),.NO5(3),.ID5(3),.NO7(0),.ID7(9))C15(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[15]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result15));
	
	CUBE #(.NO3(0),.NO5(0),.ID5(0),.NO7(1),.ID7(0))C16(.wsize(Wsize),.i_dat(icu[0]),.w_dat(wcu[16]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result16));
	CUBE #(.NO3(1),.NO5(0),.ID5(1),.NO7(1),.ID7(1))C17(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[17]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result17));
	CUBE #(.NO3(2),.NO5(0),.ID5(2),.NO7(1),.ID7(2))C18(.wsize(Wsize),.i_dat(icu[2]),.w_dat(wcu[18]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result18));
	CUBE #(.NO3(3),.NO5(0),.ID5(3),.NO7(1),.ID7(3))C19(.wsize(Wsize),.i_dat(icu[3]),.w_dat(wcu[19]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result19));
	CUBE #(.NO3(4),.NO5(1),.ID5(0),.NO7(1),.ID7(4))C20(.wsize(Wsize),.i_dat(icu[4]),.w_dat(wcu[20]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result20));
	CUBE #(.NO3(5),.NO5(1),.ID5(1),.NO7(1),.ID7(5))C21(.wsize(Wsize),.i_dat(icu[5]),.w_dat(wcu[21]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result21));
	CUBE #(.NO3(6),.NO5(1),.ID5(2),.NO7(1),.ID7(6))C22(.wsize(Wsize),.i_dat(icu[6]),.w_dat(wcu[22]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result22));
	CUBE #(.NO3(7),.NO5(1),.ID5(3),.NO7(1),.ID7(7))C23(.wsize(Wsize),.i_dat(icu[7]),.w_dat(wcu[23]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result23));
	CUBE #(.NO3(0),.NO5(2),.ID5(0),.NO7(1),.ID7(8))C24(.wsize(Wsize),.i_dat(icu[8]),.w_dat(wcu[24]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result24));
	CUBE #(.NO3(1),.NO5(2),.ID5(1),.NO7(1),.ID7(9))C25(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[25]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result25));
	CUBE #(.NO3(2),.NO5(2),.ID5(2),.NO7(1),.ID7(9))C26(.wsize(Wsize),.i_dat(icu[0]),.w_dat(wcu[26]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result26));
	CUBE #(.NO3(3),.NO5(2),.ID5(3),.NO7(1),.ID7(9))C27(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[27]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result27));
	CUBE #(.NO3(4),.NO5(3),.ID5(0),.NO7(1),.ID7(9))C28(.wsize(Wsize),.i_dat(icu[0]),.w_dat(wcu[28]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result28));
	CUBE #(.NO3(5),.NO5(3),.ID5(1),.NO7(1),.ID7(9))C29(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[29]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result29));
	CUBE #(.NO3(6),.NO5(3),.ID5(2),.NO7(1),.ID7(9))C30(.wsize(Wsize),.i_dat(icu[0]),.w_dat(wcu[30]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result30));
	CUBE #(.NO3(7),.NO5(3),.ID5(3),.NO7(1),.ID7(9))C31(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[31]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(tmp_result31));
	/*
	CUBE #(.NO3(0),.NO5(0),.ID5(0),.NO7(0),.ID7(0))C32(.wsize(Wsize),.i_dat(icu[0]),.w_dat(wcu[32]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(1),.NO5(0),.ID5(1),.NO7(0),.ID7(1))C33(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[33]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(2),.NO5(0),.ID5(2),.NO7(0),.ID7(2))C34(.wsize(Wsize),.i_dat(icu[2]),.w_dat(wcu[34]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(3),.NO5(0),.ID5(3),.NO7(0),.ID7(3))C35(.wsize(Wsize),.i_dat(icu[3]),.w_dat(wcu[35]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(4),.NO5(1),.ID5(0),.NO7(0),.ID7(4))C36(.wsize(Wsize),.i_dat(icu[4]),.w_dat(wcu[36]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(5),.NO5(1),.ID5(1),.NO7(0),.ID7(5))C37(.wsize(Wsize),.i_dat(icu[5]),.w_dat(wcu[37]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(6),.NO5(1),.ID5(2),.NO7(0),.ID7(6))C38(.wsize(Wsize),.i_dat(icu[6]),.w_dat(wcu[38]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(7),.NO5(1),.ID5(3),.NO7(0),.ID7(7))C39(.wsize(Wsize),.i_dat(icu[7]),.w_dat(wcu[39]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(0),.NO5(2),.ID5(0),.NO7(0),.ID7(8))C40(.wsize(Wsize),.i_dat(icu[8]),.w_dat(wcu[40]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(1),.NO5(2),.ID5(1),.NO7(0),.ID7(9))C41(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[44]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(2),.NO5(2),.ID5(2),.NO7(0),.ID7(9))C42(.wsize(Wsize),.i_dat(icu[0]),.w_dat(wcu[42]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(3),.NO5(2),.ID5(3),.NO7(0),.ID7(9))C43(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[45]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(4),.NO5(3),.ID5(0),.NO7(0),.ID7(9))C44(.wsize(Wsize),.i_dat(icu[0]),.w_dat(wcu[44]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(5),.NO5(3),.ID5(1),.NO7(0),.ID7(9))C45(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[45]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(6),.NO5(3),.ID5(2),.NO7(0),.ID7(9))C46(.wsize(Wsize),.i_dat(icu[0]),.w_dat(wcu[46]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(7),.NO5(3),.ID5(3),.NO7(0),.ID7(9))C47(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[47]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	
	CUBE #(.NO3(0),.NO5(0),.ID5(0),.NO7(1),.ID7(0))C48(.wsize(Wsize),.i_dat(icu[0]),.w_dat(wcu[48]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(1),.NO5(0),.ID5(1),.NO7(1),.ID7(1))C49(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[49]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(2),.NO5(0),.ID5(2),.NO7(1),.ID7(2))C50(.wsize(Wsize),.i_dat(icu[2]),.w_dat(wcu[50]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(3),.NO5(0),.ID5(3),.NO7(1),.ID7(3))C51(.wsize(Wsize),.i_dat(icu[3]),.w_dat(wcu[51]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(4),.NO5(1),.ID5(0),.NO7(1),.ID7(4))C52(.wsize(Wsize),.i_dat(icu[4]),.w_dat(wcu[52]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(5),.NO5(1),.ID5(1),.NO7(1),.ID7(5))C53(.wsize(Wsize),.i_dat(icu[5]),.w_dat(wcu[53]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(6),.NO5(1),.ID5(2),.NO7(1),.ID7(6))C54(.wsize(Wsize),.i_dat(icu[6]),.w_dat(wcu[54]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(7),.NO5(1),.ID5(3),.NO7(1),.ID7(7))C55(.wsize(Wsize),.i_dat(icu[7]),.w_dat(wcu[55]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(0),.NO5(2),.ID5(0),.NO7(1),.ID7(8))C56(.wsize(Wsize),.i_dat(icu[8]),.w_dat(wcu[56]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(1),.NO5(2),.ID5(1),.NO7(1),.ID7(9))C57(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[57]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(2),.NO5(2),.ID5(2),.NO7(1),.ID7(9))C58(.wsize(Wsize),.i_dat(icu[0]),.w_dat(wcu[58]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(3),.NO5(2),.ID5(3),.NO7(1),.ID7(9))C59(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[59]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(4),.NO5(3),.ID5(0),.NO7(1),.ID7(9))C60(.wsize(Wsize),.i_dat(icu[0]),.w_dat(wcu[60]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(5),.NO5(3),.ID5(1),.NO7(1),.ID7(9))C61(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[61]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(6),.NO5(3),.ID5(2),.NO7(1),.ID7(9))C62(.wsize(Wsize),.i_dat(icu[0]),.w_dat(wcu[62]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
	CUBE #(.NO3(7),.NO5(3),.ID5(3),.NO7(1),.ID7(9))C63(.wsize(Wsize),.i_dat(icu[1]),.w_dat(wcu[63]),.rst(rst),.clk(clk),.stride(stride),.round(round),.i_format(i_format),.w_format(w_format),.result(result[1151:1008]));
*/
	assign finish = (PS == FINISH);
	
	
	always@(posedge clk or negedge rst)begin
		if(!rst)begin
			res_valid<=0;
			res_valid_tmp<=0;
			res_valid_tmp1<=0;
		end
		else begin
			case(PS)
				WAIT:    res_valid_tmp<=0;
				COMPUTE: res_valid_tmp<=1;
				FINISH:  res_valid_tmp<=0;
			endcase
		
			res_valid_tmp1 <= res_valid_tmp;
			res_valid <= res_valid_tmp1;
		end
	end
	
	always@(posedge clk or negedge rst)begin
		if(!rst)begin
			i_format_tmp<=0;
			i_format_tmp1<=0;
			
			w_format_tmp<=0;
			w_format_tmp1<=0;
		end
		else begin
			i_format_tmp <= i_format;
			i_format_tmp1 <= i_format_tmp;
			
			w_format_tmp <= w_format;
			w_format_tmp1 <= w_format_tmp;
		end
	end
	
	
	
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
		case(PS)
			WAIT:begin
				NS=WAIT;
				//res_valid_tmp=0;
				if(ctrl==START)begin
					NS=COMPUTE;
				end
				if(ctrl==END)begin
					NS=FINISH;
				end
			end
			COMPUTE:begin
				NS=COMPUTE;
				//res_valid_tmp=1;
				if(ctrl==HOLD)begin
					NS=WAIT;
				end
				if(ctrl==END)begin
					NS=FINISH;
				end
				
			end
			FINISH:begin
				//res_valid_tmp=0;
				NS=FINISH;
			end
		endcase
	end
	
	/* get wcu */
	always@(posedge clk or negedge rst)begin
		if(!rst)wgroup_start<=0;
		else begin	
			case(wgroup_dff)
				0:wgroup_start<= 0;
				1:begin
					case(Wsize)
						0:wgroup_start<= 4608;
						1:wgroup_start<= 6400;
						2:wgroup_start<= 6272;
					endcase
				end
			endcase
		end
	end
		
	always@(*)begin	
		case(Wsize)
			0:begin
				for(idx=0; idx<8; idx=idx+1)begin
					for(idxx= (idx*8) ; idxx< 8+ (idx*8); idxx=idxx+1)begin
						wcu[idxx]={{DATA1{1'b0}},w[(W1*idx)+wgroup_start +:W1]};
					end
				end
				
			end	
			1:begin
				for(idi=0;idi<4;idi=idi+1)begin
					for(idx=0;idx<4;idx=idx+1)begin
						for(idxx=0;idxx<4;idxx=idxx+1)begin
							case(idxx)
								0:wcu[16*idi+4*idx+idxx]={{DATA1{1'b0}},w[(P1*10)+wgroup_start+idi*(P1*25) +:DATA3],w[(P1*5)+wgroup_start+idi*(P1*25) +:DATA3],w[wgroup_start+idi*(P1*25) +:DATA3]};
								1:wcu[16*idi+4*idx+idxx]={{DATA1{1'b0}},{DATA3{1'b0}},w[(P1*20)+wgroup_start+idi*(P1*25) +:DATA3],w[(P1*15)+wgroup_start+idi*(P1*25) +:DATA3]};
								2:wcu[16*idi+4*idx+idxx]={{DATA1{1'b0}},{DATA1{1'b0}},w[(P1*13)+wgroup_start+idi*(P1*25) +:DATA2],{DATA1{1'b0}},w[(P1*8)+wgroup_start+idi*(P1*25) +:DATA2],{DATA1{1'b0}},w[(P1*3)+wgroup_start+idi*(P1*25) +:DATA2]};
								3:wcu[16*idi+4*idx+idxx]={{DATA1{1'b0}},{DATA3{1'b0}},{DATA1{1'b0}},w[(P1*23)+wgroup_start+idi*(P1*25) +:DATA2],{DATA1{1'b0}},w[(P1*18)+wgroup_start+idi*(P1*25) +:DATA2]};
							endcase
						end
					end
				end
			end
			2:begin
				
				for(idi=0;idi<2;idi=idi+1)begin		// 0 - 31 , 32 - 63
					for(idx=0;idx<2;idx=idx+1)begin	// 16 , 16
						for(idxx=0;idxx<16;idxx=idxx+1)begin
							case(idxx)
								0:wcu[idi*32+idx*16+idxx]={w[(P1*48)+wgroup_start+idi*(P1*49) +:DATA1],w[(P1*14)+wgroup_start+idi*(P1*49) +:DATA3],w[(P1*7)+wgroup_start+idi*(P1*49) +:DATA3],w[wgroup_start+idi*(P1*49) +:DATA3]};
								1:wcu[idi*32+idx*16+idxx]={{DATA1{1'b0}},w[(P1*35)+wgroup_start+idi*(P1*49) +:DATA3],w[(P1*28)+wgroup_start+idi*(P1*49) +:DATA3],w[(P1*21)+wgroup_start+idi*(P1*49) +:DATA3]};
								2:wcu[idi*32+idx*16+idxx]={{DATA1{1'b0}},{DATA6{1'b0}},w[(P1*42)+wgroup_start+idi*(P1*49) +:DATA3]};
								3:wcu[idi*32+idx*16+idxx]={{DATA1{1'b0}},w[(P1*17)+wgroup_start+idi*(P1*49) +:DATA3],w[(P1*10)+wgroup_start+idi*(P1*49) +:DATA3],w[(P1*3)+wgroup_start+idi*(P1*49) +:DATA3]};
								4:wcu[idi*32+idx*16+idxx]={{DATA1{1'b0}},w[(P1*38)+wgroup_start+idi*(P1*49) +:DATA3],w[(P1*31)+wgroup_start+idi*(P1*49) +:DATA3],w[(P1*24)+wgroup_start+idi*(P1*49) +:DATA3]};
								5:wcu[idi*32+idx*16+idxx]={{DATA1{1'b0}},{DATA6{1'b0}},w[(P1*45)+wgroup_start+idi*(P1*49) +:DATA3]};
								6:wcu[idi*32+idx*16+idxx]={{DATA1{1'b0}},{DATA2{1'b0}},w[(P1*20)+wgroup_start+idi*(P1*49) +:DATA1],{DATA2{1'b0}},w[(P1*13)+wgroup_start+idi*(P1*49) +:DATA1],{DATA2{1'b0}},w[(P1*6)+wgroup_start+idi*(P1*49) +:DATA1]};
								7:wcu[idi*32+idx*16+idxx]={{DATA1{1'b0}},{DATA2{1'b0}},w[(P1*41)+wgroup_start+idi*(P1*49) +:DATA1],{DATA2{1'b0}},w[(P1*34)+wgroup_start+idi*(P1*49) +:DATA1],{DATA2{1'b0}},w[(P1*27)+wgroup_start+idi*(P1*49) +:DATA1]};
								default:wcu[idi*32+idx*16+idxx]=0;
							endcase
						end
					end
				end	
			end
		endcase
	end
	
	/* get round*/
	
	always@(posedge clk or negedge rst)begin
		if(!rst)begin
			round<=0;
		end
		else begin
			round<=wround;
		end
	end
	
	/*get icu*/
	always@(posedge clk or negedge rst)begin
		if(!rst)begin
			wgroup_dff<=0;
		end
		else begin
			wgroup_dff<=wgroup;
		end
	end
		
	
	always@(posedge clk or negedge rst)begin 
		if(!rst)begin
			for(idx=0;idx<9;idx=idx+1)begin
				icu[idx]=0;
			end
		end
		else begin	
			case(Wsize)
				0:begin
					if(stride && !wgroup_dff)begin	// B C D
						for(idx=0;idx<9;idx=idx+1)begin
							icu[idx]={regb,regc,regd};
						end
					end
					else begin					// A B C
						for(idx=0;idx<9;idx=idx+1)begin
							icu[idx]={rega,regb,regc};
						end
					end
				end
				1:begin
					if(stride && !wgroup_dff)begin	  		// B C D E F
						for(idx=0;idx<9;idx=idx+2)begin		// icu0,2,4,6,8 
							icu[idx]={regb,regc,regd};
						end
						for(idx=1;idx<=9;idx=idx+2)begin	// icu1,3,5,7,9 
							icu[idx]={rege,regf,512'b0};
						end
					end
					else begin					 			//  A B C D E
						for(idx=0;idx<9;idx=idx+2)begin		// icu0,2,4,6,8 
							icu[idx]={rega,regb,regc};
						end
						for(idx=1;idx<9;idx=idx+2)begin		// icu1,3,5,7,9 
							icu[idx]={regd,rege,512'b0};
						end
					end	
				end
				2:begin
					if(stride && !wgroup_dff)begin		//B C D E F G H 
						for(idx=0;idx<9;idx=idx+3)begin
							icu[idx]={regb,regc,regd};
						end
						for(idx=1;idx<9;idx=idx+3)begin
							icu[idx]={rege,regf,regg};
						end
						for(idx=2;idx<9;idx=idx+3)begin
							icu[idx]={regh,1024'b0};
						end
					end
					else begin   				  // A B C D E F G
						for(idx=0;idx<9;idx=idx+3)begin
							icu[idx]={rega,regb,regc};
						end
						for(idx=1;idx<9;idx=idx+3)begin
							icu[idx]={regd,rege,regf};
						end
						for(idx=2;idx<9;idx=idx+3)begin
							icu[idx]={regg,1024'b0};
						end
					end	
				end
			endcase	
		end
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
			cnt7_7_2<=0;
			
		end
		else begin
			if(RLPadding == RPadding)begin
				rega<=0;
				regb<=0;
				regc<=0;
				regd<=0;
				rege<=0;
				regf<=0;
				regg<=0;
				regh<=0;
			end
			else if(i_valid || RLPadding == LPadding)begin    
				case(Wsize)
					0:begin		// 3 * 3
						case(stride)
							0:begin
								rega<=regb;
								regb<=regc;
								regc<= (i_valid)? i_data : 0;
							end
							1:begin
								rega<=regb;
								regb<=regc;
								regc<=regd;
								regd<=(i_valid)? i_data : 0;
							end
						endcase
					end
					1:begin		// 5 * 5
						case(stride)
							0:begin
								rega<=regb;
								regb<=regc;
								regc<=regd;
								regd<=rege;
								rege<=(i_valid)? i_data : 0;
							end
							1:begin
								rega<=regb;
								regb<=regc;
								regc<=regd;
								regd<=rege;
								rege<=regf;
								regf<=(i_valid)? i_data : 0;
							end
						endcase
					end
					2:begin		// 7 * 7
						case(stride)
							0:begin
								rega<=regb;
								regb<=regc;
								regc<=regd;
								regd<=rege;
								rege<=regf;
								regf<=regg;
								regg<=(i_valid)? i_data : 0;
							end
							1:begin
								rega<=regb;
								regb<=regc;
								regc<=regd;
								regd<=rege;
								rege<=regf;
								regf<=regg;
								regg<=regh;
								regh<=(i_valid)? i_data : 0;
							end
						endcase
					end
				endcase
			end
			

			if(w_valid)begin //3 , 5 full	
				case(widstart)
					0:w[(widcnt*512) +: 512]<=w_data;
					256:w[(widcnt*512)+KEEP +:(512+KEEP)]<=w_data;
				endcase
				widtest<= (widstart==0)? widcnt*512 : (widcnt*512)+KEEP;
				widcnt<=widcnt+1;	
			end
			
			if(ctrl==HOLD)begin								
				if(Wsize==2)begin	// 7 * 7
					cnt7_7_2<= ~cnt7_7_2;		
					if(cnt7_7_2==0 && w_valid)begin
						w<=w[12799:12544];
						widstart<=256;
					end
					else if(w_valid)begin
						w<=0;
						widstart<=0;
					end
				end
				else if(w_valid)begin
					w<=0;
					widstart<=0;
				end
				widcnt<=0;	
			end	
		end
	end
	
endmodule	