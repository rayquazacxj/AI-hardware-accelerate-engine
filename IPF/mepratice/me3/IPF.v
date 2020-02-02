module CUBE#(
	parameter id = 0
)(
	input [191:0]i,		// 3 REG
	input [71:0]w,		// 9 data 3 * 3
	output reg[143:0]result
);
	reg [71:0]locali; //REG C B A get row
	//assign locali = (id<=5)? {i[128+23+8*id : 128+8*id] ,i[64+23+8*id : 64+8*id] ,i[23+8*id : 8*id]}: (id==6)? {i[135:128],i[191:176],i[71:64],i[127:112],i[7:0],i[63:48]} : {i[143:128],i[191,184],i[79:64],i[127:120],i[15:0],i[63:56]};
	
	always@(*)begin
		case(id)
			6:locali = {i[135:128],i[191:176],i[71:64],i[127:112],i[7:0],i[63:48]};
			7:locali = {i[143:128],i[191:184],i[79:64],i[127:120],i[15:0],i[63:56]};
			default: locali = {i[128+23+8*id : 128+8*id] ,i[64+23+8*id : 64+8*id] ,i[23+8*id : 8*id]};
		endcase
	end
	
	always@(*)begin
		result[15:0]   = w[7 : 0]   * locali[7 : 0]; 	//0
		result[63:48]  = w[15 : 8]  * locali[15 : 8];   //1
		result[111:96] = w[23 : 16] * locali[23 : 16];  //2
		result[31:16]  = w[31 : 24] * locali[31 : 24];  //3
		result[79:64]  = w[39 : 32] * locali[39 : 32];
		result[127:112]= w[47 : 40] * locali[47 : 40];
		result[47:32]  = w[55 : 48] * locali[55 : 48];
		result[95:80]  = w[63 : 56] * locali[63 : 56];
		result[143:128]= w[71 : 64] * locali[71 : 64];
		/*
		 0 3 6
		 1 4 7
		 2 5 8
		 result = [ 8 , 5 , 2 , 7 , 4 , 1 , 6 , 3 , 0 ] for add
		*/
	end
		/*
		//integer j;
		for(j=0;j<9;j=j+1)begin
			result[?]= w[8*j+7 : 8*j] * locali[8*j+7 : 8*j];
		end
		*/
	/*
	reg [3:0]re1,re2;
	assign result = {re1,re2};
	always@(*)begin
		re1 = i[1:0] * w[1:0];
		re2 = i[3:2] * w[3:2];
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

	reg [STATE_Width-1:0] PS, NS;
    
	wire[191:0]icu; //can reg? 3 regx
	reg [63:0]rega;
	reg [63:0]regb;
	reg [63:0]regc;
	reg [63:0]regd;
	reg [63:0]rege;
	reg [63:0]regf;
	reg [63:0]regg;
	reg [63:0]regh;
	
	reg [447:0]w;				//5 * 5 * 8 bits * 2 => (50 -> 56) * 8 / 64 = 7.0
	reg [71:0]wcu; 
	reg [3:0]widcnt;			//current regw save 4 w
	reg [5:0]widstart;
	
	reg [3:0]ccnt,rcnt;			// 8 ccnt => 1 rcnt
	reg cnt3_3_2;
	CUBE #(0)C0(.i(icu),.w(wcu),.result(res[143:0]));
	CUBE #(1)C1(.i(icu),.w(wcu),.result(res[287:144]));
	CUBE #(2)C2(.i(icu),.w(wcu),.result(res[431:288]));
	CUBE #(3)C3(.i(icu),.w(wcu),.result(res[575:432]));
	CUBE #(4)C4(.i(icu),.w(wcu),.result(res[719:576]));
	CUBE #(5)C5(.i(icu),.w(wcu),.result(res[863:720]));
	CUBE #(6)C6(.i(icu),.w(wcu),.result(res[1007:864]));
	CUBE #(7)C7(.i(icu),.w(wcu),.result(res[1151:1008]));

 
	assign icu = {regc,regb,rega};
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
	
	/* counter for FSM 
	always@(posedge clk or posedge rst)begin
		if(rst)cnt<=0;
		else begin
			if(cnt==2)cnt<=0;
			else if(PS==WAITI | PS ==COMPUTE)cnt<=cnt+1;
			else cnt<=0;
		end
	end
	*/
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
			cnt3_3_2<=0;
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
			cnt3_3_2<=cnt3_3_2;
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
					else if(w_valid)begin
						case(widstart)
							0:begin/*
								w[319:256]<=w_data;
								w[256:0]<=w[319:63];
							end*/
								case(widcnt)
									0:w[63: 0]<=w_data;
									1:w[127:64]<=w_data;
									2:w[191:128]<=w_data;
									3:w[255:192]<=w_data;
									4:w[319:256]<=w_data;
								endcase
							
							end
							32:begin/*
								w[256+32:256-63+32]<=w_data;
								w[256-63+32:32]<=w[256+32:63+32];
							end*/
							
								case(widcnt)
									0:w[63+32: 0+32]<=w_data;
									1:w[127+32:64+32]<=w_data;
									2:w[191+32:128+32]<=w_data;
									3:w[255+32:192+32]<=w_data;
								endcase
							end
						endcase
						//w[63+widstart+(widcnt+1)*64 : widstart+widcnt*64]<=w_data;
						widcnt<=widcnt+1;
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
						/*
						case(rcnt)
							//0:wcu<= w[71:0];
							0:wcu<= w[143:72];
							1:wcu<= w[215:144];
							2:wcu<= w[287:216];
						endcase
						*/
						rcnt<=rcnt+1;
						//wcu<= w[71+(rcnt+1)*72:(rcnt+1)*72];
					end
					
					// COMPUTE -> WAIT
					if(ctrl==HOLD)begin
						cnt3_3_2<= ~cnt3_3_2;		//3 *3 * 4w = 36 (4 8 8 8 8) , (8 8 8 8 4)
						if(!cnt3_3_2)begin
							w<=w[447:288];
							widstart<=32;
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