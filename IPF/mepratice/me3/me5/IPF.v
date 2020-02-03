module CUBE#(
	
	parameter NO3 = 0,
	parameter NO5 = 0,
	parameter ID5 = 0,
	parameter NO7 = 0,
	parameter ID7 = 0
	
)(
	input [1:0]wsize,
	input [191:0]i,		// 3 REG
	input [71:0]w,		// 9 data 3 * 3
	output reg[143:0]result
);
	parameter SA= 0;
	parameter SB = 64;
	parameter SC = 128;
	parameter D1 = 7;
	parameter D2 = 15;
	parameter D3 = 23;
	parameter D4 = 31;
	parameter D5 = 39;
	parameter D6 = 47;
	parameter D7 = 55;
	
	reg [71:0]locali; 	//REG C B A get row
	//assign locali = (id<=5)? {i[128+23+8*id : 128+8*id] ,i[64+23+8*id : 64+8*id] ,i[23+8*id : 8*id]}: (id==6)? {i[135:128],i[191:176],i[71:64],i[127:112],i[7:0],i[63:48]} : {i[143:128],i[191,184],i[79:64],i[127:120],i[15:0],i[63:56]};
	
	always@(*)begin
		case(wsize)		
			0:begin		//3 * 3
				case(NO3)
					6:locali={i[SC +D1:SC +0],i[SC +D2+NO3*8 : SC +NO3*8],i[SB +D1:SB +0],i[SB +D2+NO3*8 : SB +NO3*8],i[D1:0],i[D2+NO3*8 :NO3*8]};
					6:locali={i[SC +D2:SC +0],i[SC +D1+NO3*8 : SC +NO3*8],i[SB +D2:SB +0],i[SB +D1+NO3*8 : SB +NO3*8],i[D2:0],i[D1+NO3*8 :NO3*8]};
					default: locali = {i[SC +D3+NO3*8 : SC +NO3*8] ,i[SB +D3+NO3*8 :SB +NO3*8] ,i[D3+NO3*8 : NO3*8]};
				endcase	
					/*
					6:locali = {i[135:128],i[191:176],i[71:64],i[127:112],i[7:0],i[63:48]};
					7:locali = {i[143:128],i[191:184],i[79:64],i[127:120],i[15:0],i[63:56]};*/
			end
			1:begin		//5 * 5
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
							4:locali = {16{0},i[SC + D1: SC +0],i[SC + D4+NO5*8 : SC + 0+NO5*8],i[SB + D1:SB +0],i[SB + D1+(NO5+3)*8 : SB + 0+(NO5+3)*8]};
							5:locali = {16{0},i[SC + D2: SC +0],i[SC + D3+NO5*8 : SC + 0+NO5*8],i[SB + D2+(NO5-5)*8 : SB + 0+(NO5-5)*8]};
							6:locali = {16{0},i[SC + D3: SC +0],i[SC + D2+NO5*8 : SC + 0+NO5*8],i[SB + D2+(NO5-5)*8 : SB + 0+(NO5-5)*8]};
							7:locali = {16{0},i[SC + D4: SC +0],i[SC + D1+NO5*8 : SC + 0+NO5*8],i[SB + D2+(NO5-5)*8 : SB + 0+(NO5-5)*8]};
							default:locali= {16{0},i[SC +D5+NO5*8 : SC +0+NO5*8],i[SB + D2+(NO5+3)*8 : SB + 0+(NO5+3)*8]};
						endcase
					end
				endcase
			end
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
							3:locali={i[SB +D4+NO7*8:SB +0+NO7*8],i[D2:0],i[D3+(NO7+2)*8:0+(NO7+2)*8]};
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
							default:locali={i[SC +D3+NO7*8:SC +0+NO7*8],i[SB +D6+(NO7+1)*8:SB +0+(NO7+1)*8]}
						endcase
					end
					5:begin  //REG G F END
						case(NO7)	
							2:locali={40{0},i[SC +D1:SC +0],i[SC +D3+(NO7+3)*8:SC +0+(NO7+3)*8]};
							3:locali={40{0},i[SC +D2:SC +0],i[SC +D2+(NO7+3)*8:SC +0+(NO7+3)*8]};
							4:locali={40{0},i[SC +D3:SC +0],i[SC +D1+(NO7+3)*8:SC +0+(NO7+3)*8]};
							5:locali={40{0},i[SC +D4:SC +0]};
							6:locali={40{0},i[SC +D4+8:SC +8]};
							7:locali={40{0},i[SC +D4+15:SC +15]};
							default:locali={40{0},i[SC +D4+(NO7+3)*8:SC +0+(NO7+3)*8]};
						endcase
					end
				endcase
			end
		endcase
	end
	
	integer j;
	always@(*)begin
		for(j=0;j<9;j=j+1)begin
			result[16*j+15 : 16*j]= w[8*j+7 : 8*j] * locali[8*j+7 : 8*j];
		end
	end
	/*
		result[15:0]   = w[7 : 0]   * locali[7 : 0]; 	//0
		result[63:48]  = w[15 : 8]  * locali[15 : 8];   //1
		result[111:96] = w[23 : 16] * locali[23 : 16];  //2
		result[31:16]  = w[31 : 24] * locali[31 : 24];  //3
		result[79:64]  = w[39 : 32] * locali[39 : 32];
		result[127:112]= w[47 : 40] * locali[47 : 40];
		result[47:32]  = w[55 : 48] * locali[55 : 48];
		result[95:80]  = w[63 : 56] * locali[63 : 56];
		result[143:128]= w[71 : 64] * locali[71 : 64];
	*/
		/*
		 0 3 6
		 1 4 7
		 2 5 8
		 result = [ 8 , 5 , 2 , 7 , 4 , 1 , 6 , 3 , 0 ] for add
		*/
		/*
		//integer j;
		for(j=0;j<9;j=j+1)begin
			result[?]= w[8*j+7 : 8*j] * locali[8*j+7 : 8*j];
		end
		*/
	
endmodule


module IPF#(
	parameter In_Width   = 8, 
	parameter Out_Width  = 9,
	parameter Addr_Width = 16
)(
	input clk,
	input rst,
	input [1:0]ctrl,			//0: end , 1:start , 2:hold   //input  ready,c-start replace it
	
	input  [63:0] i_data, 		//2 i
	input  [63:0] w_data,
	input i_valid,w_valid,
	input  [1:0] Wsize,
	output wire [1152:0] res,
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
	parameter KEEP =32;

	reg [STATE_Width-1:0] PS, NS;
    
	wire[191:0]icu0; 	//REG A B C	(3 , 5, 7)		//can reg? 3 regx
	wire[191:0]icu1;	//REG B C D	(5 ,7)
	wire[191:0]icu2;	//REG C D E	(5 ,7)
	wire[191:0]icu3;	//REG A B C , D E F (5 ,7)
	wire[191:0]icu4;	//REG B C D , E F G (5 ,7)
	wire[191:0]icu5;	//REG C D E , E F G (5 ,7)
	
	reg [63:0]rega;
	reg [63:0]regb;
	reg [63:0]regc;
	reg [63:0]regd;
	reg [63:0]rege;
	reg [63:0]regf;
	reg [63:0]regg;
	reg [63:0]regh;
	
	//reg [447:0]w;				//5 * 5 * 8 bits * 2 => (50 -> 56) * 8 / 64 = 7.0
	reg [1599:0]w;	
	reg [71:0]wcu; 
	reg [3:0]widcnt;			//current regw save 4 w
	reg [5:0]widstart;
	
	reg [3:0]ccnt,rcnt;			// 8 ccnt => 1 rcnt
	reg cnt7_7_2;
	
	genvar idx;
	generate 
		for(idx=0 ; idx<64 ; idx =idx+1)begin: label
			CUBE #(.NO3(),.NO5(),.ID5(),.NO7(),.ID7())cube(.wsize(Wsize),.i(icu),.w(wcu),.result(res[143:0]));
		end
	endgenerate
	
	CUBE #(0)C0(.i(icu),.w(wcu),.result(res[143:0]));
	CUBE #(1)C1(.i(icu),.w(wcu),.result(res[287:144]));
	CUBE #(2)C2(.i(icu),.w(wcu),.result(res[431:288]));
	CUBE #(3)C3(.i(icu),.w(wcu),.result(res[575:432]));
	CUBE #(4)C4(.i(icu),.w(wcu),.result(res[719:576]));
	CUBE #(5)C5(.i(icu),.w(wcu),.result(res[863:720]));
	CUBE #(6)C6(.i(icu),.w(wcu),.result(res[1007:864]));
	CUBE #(7)C7(.i(icu),.w(wcu),.result(res[1151:1008]));

 
	assign icu0 = {regc,regb,rega};
	assign icu1 = {regd,regc,regb};
	assign icu2 = {rege,regd,regc};
	assign icu3 = {regf,rege,regd};
	assign icu4 = {regg,regf,rege};
	
	assign finish = (PS == FINISH);
		
	/* FSM */
	always@(posedge clk or posedge rst)begin
		if(rst)begin
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
	always@(*)begin
		case(PS)
			WAIT:wcu=w[71:0];
			COMPUTE:begin
				case(rcnt)
					0:wcu= w[71:0];
					1:wcu= w[143:72];
					2:wcu= w[215:144];
					3:wcu= w[287:216];
				endcase
			end
		endcase
	end

	/* get data*/
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			rega<=0;
			regb<=0;
			regc<=0;
			regd<=0;
			rege<=0;
			regf<=0;
			regg<=0;
			regh<=0;
			w	<=0;
			//wcu <=0;
			widcnt<=0;
			widstart<=0;
			ccnt<=0;
			rcnt<=0;
			cnt7_7_2<=0;
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
			//wcu <=wcu;
			widcnt<=widcnt;
			widstart<=widstart;
			ccnt<=ccnt;
			rcnt<=rcnt;
			cnt7_7_2<=cnt7_7_2;
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
						regh<=i_data;
					end
					else if(w_valid)begin //3 , 5 full	
						case(widstart)
							0:begin
							/*
								w[319:256]<=w_data;
								w[256:0]<=w[319:63];
							end*/
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
							/*
								w[256+32:256-63+32]<=w_data;
								w[256-63+32:32]<=w[256+32:63+32];
							end*/	
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
						//w[63+widstart+(widcnt+1)*64 : widstart+widcnt*64]<=w_data;
						widcnt<=widcnt+1;
						//if((Wsize==0 && widcnt==18)||(Wsize==1 && widcnt==25)||(Wsize==2 && widcnt==25 && cnt_7_7_2==0) || (Wsize==2 && widcnt==24 && cnt_7_7_2))widcnt<=0;
						
					end
					//wcu<= w[71:0];
				end
				
				COMPUTE:begin
					// shift
					rega<=regb;
					regb<=regc;
					regc<=regd;
					regd<=rege;
					rege<=regf;
					regf<=regg;
					regg<=regh;
					regh<=rega;	
					
					// counter
					if(ccnt<7)ccnt<=ccnt+1;
					if(ccnt==7)begin
						ccnt<=0;
						rcnt<=rcnt+1;
						//wcu<= w[71+(rcnt+1)*72:(rcnt+1)*72];
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
						//wcu<=0;
						widcnt<=0;					
						ccnt<=0;
						rcnt<=0;
					end
					
				end
				
			endcase
		end
	end
	
endmodule	