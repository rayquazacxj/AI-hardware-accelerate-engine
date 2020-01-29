module IPF #(
	parameter In_Width   = 8, 
	parameter Out_Width  = 9,
	parameter Addr_Width = 16
)(

	input clk,
	input rst,

	input  [1:0] mode,

	input                       gray_ready,
	input      [In_Width-1  :0] gray_data,
	output reg [Addr_Width-1:0] gray_addr,
	output reg                  gray_req,
    
    output reg                  ipf_valid,
	output reg [Addr_Width-1:0] ipf_addr,
	output reg [Out_Width-1 :0] ipf_data,

	output finish

);
	parameter STATE_Width = 2;
	parameter IDLE    = 2'b00;
	parameter FINISH  = 2'b01;
	parameter WAIT    = 2'b10;
	parameter COMPUTE = 2'b11;
	
	parameter Addr_RC = Addr_Width/2; //Row, Col addr

	reg [STATE_Width-1:0] PS, NS;
    reg [1:0] W_cnt;

    reg [Addr_RC-1:0] RAddr_i, RAddr_j, WAddr_i, WAddr_j;
    reg [1:0] R_cnt;
    
    reg [In_Width-1:0] data [0:8];
    reg [Out_Width-1:0] O_val [0:2];
    
    wire start, restart, terminate;
	reg data_valid;
    reg ipf_valid_t; 
	integer idx;
	
	assign start = (RAddr_j == 8'd1) & (R_cnt==2'd2);
	assign restart = (RAddr_j == 8'd255) & (R_cnt == 2'd2);
	assign terminate = (WAddr_i == 8'd255) & (WAddr_j == 8'd1);
	assign finish = (PS==FINISH);
	
	/* FSM */
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			PS<=IDLE;
		end else begin
			PS<=NS;
		end
	end
	
	always@(*)begin
		gray_req = 0;
		case(PS)
			IDLE:begin
				NS = IDLE;
				if(gray_ready)begin
					gray_req=1;
					NS = WAIT;
				end
			end
			WAIT:begin
				NS=WAIT;
				gray_req=1;
				if(start)begin
					NS=COMPUTE;
				end
				else if(terminate)begin
					NS=FINISH;
					gray_req=0;
				end
			end
			COMPUTE:begin
				NS=COMPUTE;
				gray_req=1;
				if(restart)begin
					NS=WAIT;
				end
			end
			FINISH:begin
				NS=FINISH;
			end
		endcase
	end
	
	/*READ DATA*/
	always@(*)begin
		gray_addr = {RAddr_i,RAddr_j};
	end
	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			R_cnt<=0;
		end
		else if(R_cnt==2'd2 | PS==IDLE)begin
			R_cnt<=0;
		end
		else begin
			R_cnt <= R_cnt+1;
		end
	end
	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			RAddr_i<=0;
		end
		else if(PS[1]==1)begin // WAIT or COMPUTE
			case(R_cnt)
				2'd2:begin
					RAddr_i<=RAddr_i-2;
					if(RAddr_j == {In_Width{1'b1}})begin //8'd255
						RAddr_i<=RAddr_i-1;
					end
				end
				default:begin
					RAddr_i<=RAddr_i+1;
				end
			endcase
		end
	end
	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			RAddr_j<=0;
		end
		else if(R_cnt==2'd2)begin
			RAddr_j<=RAddr_j+1; //RAddr_j: 8bits => 255+1=0!!
		end
	end
	
	/* store data & compute */
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			data_valid<=0;
		end
		else begin
			data_valid <= gray_req;
		end
	end
	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			for(idx =0;idx<8;idx=idx+1)begin
				data[idx]<=0;
			end
		end
		else if (data_valid) begin
			case(R_cnt)
				2'd0:begin
					data[0]<=gray_data;
					
					data[3]<=data[0];
					data[4]<=data[1];
					data[5]<=data[2];
					
					data[6]<=data[3];
					data[7]<=data[4];
					data[8]<=data[5];
				end
				2'd1:begin
					data[1]<=gray_data;
				end
				2'd2:begin
					data[2]<=gray_data;
				end
			endcase
		end
	end
	
	always@(*)begin
		O_val[0] = (({1'b0, data[4]}>>1)) + (~({1'b0, data[2]}>>1)+1);

		O_val[1] = (~(data[0]>>3)+1) + (~(data[3]>>3)+1) + (~(data[6]>>3)+1) +
				   (~(data[1]>>3)+1) + ( (data[4]))      + (~(data[7]>>3)+1) +
				   (~(data[2]>>3)+1) + (~(data[5]>>3)+1) + (~(data[8]>>3)+1);

		O_val[2] = ({1'b0, data[0]}>>4) + ({1'b0, data[3]}>>3) + ({1'b0, data[6]}>>4)+
				   ({1'b0, data[1]}>>3) + ({1'b0, data[4]}>>2) + ({1'b0, data[7]}>>3)+
				   ({1'b0, data[2]}>>4) + ({1'b0, data[5]}>>3) + ({1'b0, data[8]}>>4);
	end
	
	/* write data */
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			W_cnt<=0;
		end
		else if(PS==COMPUTE & W_cnt[1]==0)begin
			W_cnt<= W_cnt+1;
		end
		else begin
			W_cnt<=0;
		end
	end
	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			ipf_valid<=0;
			ipf_valid_t<=0;
		end
		else begin
			ipf_valid<=ipf_valid_t;
			ipf_valid_t<=(W_cnt==2);
		end
	end
	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			ipf_data<=0;
		end
		else if (ipf_valid_t)begin
			case(mode)
				2'd0:begin
					ipf_data<=O_val[0];
				end
				2'd1:begin
					ipf_data<=O_val[1];
				end
				2'd2:begin
					ipf_data<=O_val[2];
				end
			endcase
		end
	end	
	
	
	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			WAddr_i<=1;
		end
		else if(WAddr_j == 8'd255)begin
			WAddr_i<=WAddr_i+1;
		end
	end
	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			WAddr_j<=1;
		end
		else if(WAddr_j==8'd255)begin
			WAddr_j<=1;
		end
		else if(ipf_valid_t)begin
			WAddr_j<=WAddr_j+1;
		end
	end
	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			ipf_addr<=0;
		end
		else begin
			ipf_addr<={WAddr_i,WAddr_j};
		end
	end

endmodule
