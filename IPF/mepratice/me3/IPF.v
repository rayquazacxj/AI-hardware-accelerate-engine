module CUBE#(
	parameter id = 0
)(
	input [191:0]i,		// 3 REG
	input [71:0]w,		// 9 data 3 * 3
	output[143:0]result
);
	wire [71:0]locali; //REG C B A get row
	assign locali = (id<=5)? {i[128+23+8*id : 128+8*id] ,i[64+23+8*id : 64+8*id] ,i[23+8*id : 8*id]}: (id==6)? {i[135:128],i[191:176],i[71:64],i[127:112],i[7:0],i[63:48]}:{i[143:128],i[191,184],i[79:64],i[127:120],i[15:0],i[63:56]};
	integer j;
	always@(*)begin  
		result[15:0]   = w[7 : 0]   * locali[7 : 0]; 
		result[63:48]  = w[15 : 8]  * locali[15 : 8];
		result[111:96] = w[23 : 16] * locali[23 : 16];
		result[31:16]  = w[31 : 24] * locali[31 : 24];
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
		for(j=0;j<9;j=j+1)begin
			result[?]= w[8*j+7 : 8*j] * locali[8*j+7 : 8*j];
		end
		*/
	end
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
	input [1:0]ctrl,//0: end , 1:start , 2:hold   //input  ready,c-start replace it
	
	input  [63:0] i_data, //2 i
	input  [71:0] w_data,
	input i_valid,w_valid,
	
	output wire [1152:0] res,
	output reg res_valid,

	output finish

);
	parameter STATE_Width = 3;
	parameter FINISH  = 3'd1;
	parameter WAIT   = 3'd2;
	parameter COMPUTE = 3'd3;
	//parameter IDLE    = 3'd0;//parameter WAITW   = 3'd3;
	
	parameter HOLD = 2'd2;
	parameter START = 2'd1;
	parameter END = 2'd0;

	reg [STATE_Width-1:0] PS, NS;
    
	wire[191:0]icu; //can reg?
	reg [63:0]rega;
	reg [63:0]regb;
	reg [63:0]regc;
	reg [63:0]regd;
	
	reg [71:0]w;
	
	reg [1:0]cnt;
	CUBE #(0)C1(.i(icu),.w(w),.result(res[143:0]));
	CUBE #(1)C1(.i(icu),.w(w),.result(res[287:144]));
	CUBE #(2)C1(.i(icu),.w(w),.result(res[431:288]));
	CUBE #(3)C1(.i(icu),.w(w),.result(res[575:432]));
	CUBE #(4)C1(.i(icu),.w(w),.result(res[719:576]));
	CUBE #(5)C1(.i(icu),.w(w),.result(res[863:720]));
	CUBE #(6)C1(.i(icu),.w(w),.result(res[1007:864]));
	CUBE #(7)C1(.i(icu),.w(w),.result(res[1151:1008]));

	/*
	CUBE C1(.i({icu[9:8],icu[1:0]}),.w(w),.result(res[7:0]));
	CUBE C2(.i({icu[11:10],icu[3:2]}),.w(w),.result(res[15:8]));
	CUBE C3(.i({icu[13:12],icu[5:4]}),.w(w),.result(res[23:16]));
	CUBE C4(.i({icu[15:14],icu[7:6]}),.w(w),.result(res[31:24]));
	*/
 
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
	
	/* get data*/
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			rega<=0;
			regb<=0;
			regc<=0;
			regd<=0;
			w	<=0;
		end
		else begin
			rega<=rega;
			regb<=regb;
			regc<=regc;
			regd<=regd;
			w	<=w;
			case(PS)
				WAIT:begin
					if(i_valid)begin
						rega<=regb;
						regb<=regc;
						regc<=i_datd;
						regd<=i_data;
					end
					else if(w_valid)begin
						w<=w_data;
					end
				end
				/*
				WAITI:begin
					rega<=regb;
					regb<=regc;
					regc<=i_data;
				end
				WAITW:begin
					w<=w_data;
				end
				*/
				COMPUTE:begin
					rega<=regb;
					regb<=regc;
					regc<=regd;
					regd<=rega;
					
				end
				/*
				default:begin
					rega<=rega;
					regb<=regb;
					regc<=regc;
					w<=w;
				end*/
			endcase
		end
	end
	
endmodule	