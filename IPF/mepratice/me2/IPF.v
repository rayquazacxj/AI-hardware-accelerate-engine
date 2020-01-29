module CUBE(
	input [3:0]i,
	input [3:0]w,
	output[7:0]result
);
	reg [3:0]re1,re2;
	
	assign result = {re1,re2};
	always@(*)begin
		re1 = i[1:0] * w[1:0];
		re2 = i[3:2] * w[3:2];
	end
endmodule


module IPF#(
	parameter In_Width   = 8, 
	parameter Out_Width  = 9,
	parameter Addr_Width = 16
)(
	input clk,
	input rst,
	input endinput,
	input  ready,
	input  [7:0] i_data, //2 i
	//input i_valid,w_valid,
	input  [3:0] w_data,
	//output reg gray_req,
	output wire [31:0] res,
	output reg res_valid,

	output finish

);
	parameter STATE_Width = 3;
	parameter IDLE    = 3'd0;
	parameter FINISH  = 3'd1;
	parameter WAITI   = 3'd2;
	parameter WAITW   = 3'd3;
	parameter COMPUTE = 3'd4;

	reg [STATE_Width-1:0] PS, NS;
    
	wire[15:0]icu;
	reg [7:0]rega;
	reg [7:0]regb;
	reg [7:0]regc;
	
	reg [3:0]w;
	
	reg [1:0]cnt;
	
	CUBE C1(.i({icu[9:8],icu[1:0]}),.w(w),.result(res[7:0]));
	CUBE C2(.i({icu[11:10],icu[3:2]}),.w(w),.result(res[15:8]));
	CUBE C3(.i({icu[13:12],icu[5:4]}),.w(w),.result(res[23:16]));
	CUBE C4(.i({icu[15:14],icu[7:6]}),.w(w),.result(res[31:24]));

 
	assign icu = {regb,rega};
	assign finish = (PS == FINISH);
		
	/* FSM */
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			PS<=IDLE;
		end
		else begin
			PS<=NS;
			//just_w<=njust_w;
		end
	end
	always@(*)begin
		NS = PS;
		res_valid=0;
		//njust_w=0;
		case(PS)
			IDLE:begin
				NS=IDLE;
				if(ready)begin
					NS=WAITI;
				end
			end
			WAITI:begin
				NS=WAITI;
				if(cnt==2)NS=WAITW;
			end
			WAITW:begin
				NS = COMPUTE;	
			end
			COMPUTE:begin
				NS=COMPUTE;
				res_valid=1;
				if(cnt==2)begin
					NS=WAITW;
					//njust_w=1;
				end
				if(endinput)begin
					NS=FINISH;
				end
			end
			FINISH:begin
				NS=FINISH;
			end
		endcase
	end
	/* counter for FSM */
	always@(posedge clk or posedge rst)begin
		if(rst)cnt<=0;
		else begin
			if(cnt==2)cnt<=0;
			else if(PS==WAITI | PS ==COMPUTE)cnt<=cnt+1;
			else cnt<=0;
		end
	end
	
	/* get data*/
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			rega<=0;
			regb<=0;
			regc<=0;
			w	<=0;
		end
		else begin
			rega<=rega;
			regb<=regb;
			regc<=regc;
			w	<=w;
			case(PS)
				WAITI:begin
					rega<=regb;
					regb<=regc;
					regc<=i_data;
				end
				WAITW:begin
					w<=w_data;
				end
				COMPUTE:begin
					rega<=regb;
					regb<=regc;
					regc<=rega;
				end
				default:begin
					rega<=rega;
					regb<=regb;
					regc<=regc;
					w<=w;
				end
			endcase
		end
	end
	
endmodule	