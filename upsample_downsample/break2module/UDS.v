module UDS#(parameter A=7'd64)( // A = 8 * 8						
	input clk,
	input rst_n,
	input active,
	input [A*32-1:0]idata,
 	input idata_valid,
	input [1:0]scale_factor,
	input [1:0]function_mode,
	
	output reg [2*(A-8)*32-1:0]odata, //2A
	output reg odata_valid
);

	localparam ROW_NUMS  = (A==7'd64)? 5'd16 : 5'd8 ;
	localparam HALF_ROWS = (A==7'd64)? 4'd8  : 4'd4 ;
	integer i,j;
	
	reg [8*32-1:0]NEXT_PRE[0:ROW_NUMS-1];
	reg [8*32-1:0]NEXT_MID[0:ROW_NUMS-1];
	reg [8*32-1:0]NEXT_CUR[0:ROW_NUMS-1];
	
	reg [2*(A-8)*32-1:0]NEXT_odata;
	//reg [8*32-1:0]NEXT_odata_test[0:ROW_NUMS-1];
	reg NEXT_odata_valid;
	
	reg [8*32-1:0]PRE[0:ROW_NUMS-1];
	reg [8*32-1:0]MID[0:ROW_NUMS-1];
	reg [8*32-1:0]CUR[0:ROW_NUMS-1];
	
	//reg idata_valid_reg,idata_valid_reg2;
	reg active_reg,active_reg2;
	reg shift2pre,NEXT_shift2pre;
	
	/*
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			idata_valid_reg	 <= 0;
			idata_valid_reg2 <= 0;
		end
			idata_valid_reg	 <= idata_valid;
			idata_valid_reg2 <= idata_valid_reg;
		end
	end*/
	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			active_reg	<= 0;
			active_reg2 <= 0;
		end
		else begin
			active_reg	<= active;
			active_reg2 <= active_reg;
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(i=0; i< ROW_NUMS ; i=i+1)begin
				CUR[i] <= 0;
				MID[i] <= 0;
				PRE[i] <= 0;
			end
		end
		else begin
		
			for(i=0; i< ROW_NUMS ; i=i+1)begin 
				MID[i] <= NEXT_MID[i];
				PRE[i] <= NEXT_PRE[i];
			end
			
			
			if(!active_reg && idata_valid)begin									//active_reg == 0 => shift
				
				if(function_mode[1]==1)begin									// UPSAMPLE
					for(i=0; i< ROW_NUMS ; i=i+1)begin 							//1 row = 8 items = 8 * 32 (256)bits 
						CUR[i] <= idata[ {i[31:1],8'd0} +: 9'd256]; 			//  (i>>1) *8*32 = (i>>1)<<8 = {i[31:8],8'd0}
					end
				end
				else begin														//DOWNSAMPLE
					for(i=0; i< ROW_NUMS ; i=i+1)begin 										
						CUR[i] <= idata[i<<8 +: 9'd256]; 						
					end
				end
			end
			else begin
				for(i=0; i< ROW_NUMS ; i=i+1)begin  
					CUR[i] <= NEXT_CUR[i];
				end
			end
			
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			shift2pre <= 0;
		end
		else begin
			shift2pre <= NEXT_shift2pre;
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			odata_valid <= 0;
		end
		else begin
			odata_valid <= NEXT_odata_valid;
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			odata <= 0;
		end
		else begin
			odata <= NEXT_odata;
		end
	end
//------------------------------------------------------------------------------------------------
	assign ADD2_COL_in1[0][0] = CUR[0][31 : 0];
	assign ADD2_COL_in2[0][0] = (function_mode[1]==0)? CUR[1][31 : 0] : CUR[2][31 : 0];
	assign ADD2_COL_in1[0][1] = CUR[0][63 : 32];
	assign ADD2_COL_in2[0][1] = (function_mode[1]==0)? CUR[1][63 : 32] : CUR[2][63 : 32];
	assign ADD2_COL_in1[0][2] = CUR[0][95 : 64];
	assign ADD2_COL_in2[0][2] = (function_mode[1]==0)? CUR[1][95 : 64] : CUR[2][95 : 64];
	assign ADD2_COL_in1[0][3] = CUR[0][127 : 96];
	assign ADD2_COL_in2[0][3] = (function_mode[1]==0)? CUR[1][127 : 96] : CUR[2][127 : 96];
	assign ADD2_COL_in1[0][4] = CUR[0][159 : 128];
	assign ADD2_COL_in2[0][4] = (function_mode[1]==0)? CUR[1][159 : 128] : CUR[2][159 : 128];
	assign ADD2_COL_in1[0][5] = CUR[0][191 : 160];
	assign ADD2_COL_in2[0][5] = (function_mode[1]==0)? CUR[1][191 : 160] : CUR[2][191 : 160];
	assign ADD2_COL_in1[0][6] = CUR[0][223 : 192];
	assign ADD2_COL_in2[0][6] = (function_mode[1]==0)? CUR[1][223 : 192] : CUR[2][223 : 192];
	assign ADD2_COL_in1[0][7] = CUR[0][255 : 224];
	assign ADD2_COL_in2[0][7] = (function_mode[1]==0)? CUR[1][255 : 224] : CUR[2][255 : 224];
	assign ADD2_COL_in1[1][0] = CUR[1][31 : 0];
	assign ADD2_COL_in2[1][0] = (function_mode[1]==0)? CUR[2][31 : 0] : CUR[3][31 : 0];
	assign ADD2_COL_in1[1][1] = CUR[1][63 : 32];
	assign ADD2_COL_in2[1][1] = (function_mode[1]==0)? CUR[2][63 : 32] : CUR[3][63 : 32];
	assign ADD2_COL_in1[1][2] = CUR[1][95 : 64];
	assign ADD2_COL_in2[1][2] = (function_mode[1]==0)? CUR[2][95 : 64] : CUR[3][95 : 64];
	assign ADD2_COL_in1[1][3] = CUR[1][127 : 96];
	assign ADD2_COL_in2[1][3] = (function_mode[1]==0)? CUR[2][127 : 96] : CUR[3][127 : 96];
	assign ADD2_COL_in1[1][4] = CUR[1][159 : 128];
	assign ADD2_COL_in2[1][4] = (function_mode[1]==0)? CUR[2][159 : 128] : CUR[3][159 : 128];
	assign ADD2_COL_in1[1][5] = CUR[1][191 : 160];
	assign ADD2_COL_in2[1][5] = (function_mode[1]==0)? CUR[2][191 : 160] : CUR[3][191 : 160];
	assign ADD2_COL_in1[1][6] = CUR[1][223 : 192];
	assign ADD2_COL_in2[1][6] = (function_mode[1]==0)? CUR[2][223 : 192] : CUR[3][223 : 192];
	assign ADD2_COL_in1[1][7] = CUR[1][255 : 224];
	assign ADD2_COL_in2[1][7] = (function_mode[1]==0)? CUR[2][255 : 224] : CUR[3][255 : 224];
	assign ADD2_COL_in1[2][0] = CUR[2][31 : 0];
	assign ADD2_COL_in2[2][0] = (function_mode[1]==0)? CUR[3][31 : 0] : CUR[4][31 : 0];
	assign ADD2_COL_in1[2][1] = CUR[2][63 : 32];
	assign ADD2_COL_in2[2][1] = (function_mode[1]==0)? CUR[3][63 : 32] : CUR[4][63 : 32];
	assign ADD2_COL_in1[2][2] = CUR[2][95 : 64];
	assign ADD2_COL_in2[2][2] = (function_mode[1]==0)? CUR[3][95 : 64] : CUR[4][95 : 64];
	assign ADD2_COL_in1[2][3] = CUR[2][127 : 96];
	assign ADD2_COL_in2[2][3] = (function_mode[1]==0)? CUR[3][127 : 96] : CUR[4][127 : 96];
	assign ADD2_COL_in1[2][4] = CUR[2][159 : 128];
	assign ADD2_COL_in2[2][4] = (function_mode[1]==0)? CUR[3][159 : 128] : CUR[4][159 : 128];
	assign ADD2_COL_in1[2][5] = CUR[2][191 : 160];
	assign ADD2_COL_in2[2][5] = (function_mode[1]==0)? CUR[3][191 : 160] : CUR[4][191 : 160];
	assign ADD2_COL_in1[2][6] = CUR[2][223 : 192];
	assign ADD2_COL_in2[2][6] = (function_mode[1]==0)? CUR[3][223 : 192] : CUR[4][223 : 192];
	assign ADD2_COL_in1[2][7] = CUR[2][255 : 224];
	assign ADD2_COL_in2[2][7] = (function_mode[1]==0)? CUR[3][255 : 224] : CUR[4][255 : 224];
	assign ADD2_COL_in1[3][0] = CUR[3][31 : 0];
	assign ADD2_COL_in2[3][0] = (function_mode[1]==0)? CUR[4][31 : 0] : CUR[5][31 : 0];
	assign ADD2_COL_in1[3][1] = CUR[3][63 : 32];
	assign ADD2_COL_in2[3][1] = (function_mode[1]==0)? CUR[4][63 : 32] : CUR[5][63 : 32];
	assign ADD2_COL_in1[3][2] = CUR[3][95 : 64];
	assign ADD2_COL_in2[3][2] = (function_mode[1]==0)? CUR[4][95 : 64] : CUR[5][95 : 64];
	assign ADD2_COL_in1[3][3] = CUR[3][127 : 96];
	assign ADD2_COL_in2[3][3] = (function_mode[1]==0)? CUR[4][127 : 96] : CUR[5][127 : 96];
	assign ADD2_COL_in1[3][4] = CUR[3][159 : 128];
	assign ADD2_COL_in2[3][4] = (function_mode[1]==0)? CUR[4][159 : 128] : CUR[5][159 : 128];
	assign ADD2_COL_in1[3][5] = CUR[3][191 : 160];
	assign ADD2_COL_in2[3][5] = (function_mode[1]==0)? CUR[4][191 : 160] : CUR[5][191 : 160];
	assign ADD2_COL_in1[3][6] = CUR[3][223 : 192];
	assign ADD2_COL_in2[3][6] = (function_mode[1]==0)? CUR[4][223 : 192] : CUR[5][223 : 192];
	assign ADD2_COL_in1[3][7] = CUR[3][255 : 224];
	assign ADD2_COL_in2[3][7] = (function_mode[1]==0)? CUR[4][255 : 224] : CUR[5][255 : 224];
	assign ADD2_COL_in1[4][0] = CUR[4][31 : 0];
	assign ADD2_COL_in2[4][0] = (function_mode[1]==0)? CUR[5][31 : 0] : CUR[6][31 : 0];
	assign ADD2_COL_in1[4][1] = CUR[4][63 : 32];
	assign ADD2_COL_in2[4][1] = (function_mode[1]==0)? CUR[5][63 : 32] : CUR[6][63 : 32];
	assign ADD2_COL_in1[4][2] = CUR[4][95 : 64];
	assign ADD2_COL_in2[4][2] = (function_mode[1]==0)? CUR[5][95 : 64] : CUR[6][95 : 64];
	assign ADD2_COL_in1[4][3] = CUR[4][127 : 96];
	assign ADD2_COL_in2[4][3] = (function_mode[1]==0)? CUR[5][127 : 96] : CUR[6][127 : 96];
	assign ADD2_COL_in1[4][4] = CUR[4][159 : 128];
	assign ADD2_COL_in2[4][4] = (function_mode[1]==0)? CUR[5][159 : 128] : CUR[6][159 : 128];
	assign ADD2_COL_in1[4][5] = CUR[4][191 : 160];
	assign ADD2_COL_in2[4][5] = (function_mode[1]==0)? CUR[5][191 : 160] : CUR[6][191 : 160];
	assign ADD2_COL_in1[4][6] = CUR[4][223 : 192];
	assign ADD2_COL_in2[4][6] = (function_mode[1]==0)? CUR[5][223 : 192] : CUR[6][223 : 192];
	assign ADD2_COL_in1[4][7] = CUR[4][255 : 224];
	assign ADD2_COL_in2[4][7] = (function_mode[1]==0)? CUR[5][255 : 224] : CUR[6][255 : 224];
	assign ADD2_COL_in1[5][0] = CUR[5][31 : 0];
	assign ADD2_COL_in2[5][0] = (function_mode[1]==0)? CUR[6][31 : 0] : CUR[7][31 : 0];
	assign ADD2_COL_in1[5][1] = CUR[5][63 : 32];
	assign ADD2_COL_in2[5][1] = (function_mode[1]==0)? CUR[6][63 : 32] : CUR[7][63 : 32];
	assign ADD2_COL_in1[5][2] = CUR[5][95 : 64];
	assign ADD2_COL_in2[5][2] = (function_mode[1]==0)? CUR[6][95 : 64] : CUR[7][95 : 64];
	assign ADD2_COL_in1[5][3] = CUR[5][127 : 96];
	assign ADD2_COL_in2[5][3] = (function_mode[1]==0)? CUR[6][127 : 96] : CUR[7][127 : 96];
	assign ADD2_COL_in1[5][4] = CUR[5][159 : 128];
	assign ADD2_COL_in2[5][4] = (function_mode[1]==0)? CUR[6][159 : 128] : CUR[7][159 : 128];
	assign ADD2_COL_in1[5][5] = CUR[5][191 : 160];
	assign ADD2_COL_in2[5][5] = (function_mode[1]==0)? CUR[6][191 : 160] : CUR[7][191 : 160];
	assign ADD2_COL_in1[5][6] = CUR[5][223 : 192];
	assign ADD2_COL_in2[5][6] = (function_mode[1]==0)? CUR[6][223 : 192] : CUR[7][223 : 192];
	assign ADD2_COL_in1[5][7] = CUR[5][255 : 224];
	assign ADD2_COL_in2[5][7] = (function_mode[1]==0)? CUR[6][255 : 224] : CUR[7][255 : 224];
	assign ADD2_COL_in1[6][0] = CUR[6][31 : 0];
	assign ADD2_COL_in2[6][0] = (function_mode[1]==0)? CUR[7][31 : 0] : CUR[8][31 : 0];
	assign ADD2_COL_in1[6][1] = CUR[6][63 : 32];
	assign ADD2_COL_in2[6][1] = (function_mode[1]==0)? CUR[7][63 : 32] : CUR[8][63 : 32];
	assign ADD2_COL_in1[6][2] = CUR[6][95 : 64];
	assign ADD2_COL_in2[6][2] = (function_mode[1]==0)? CUR[7][95 : 64] : CUR[8][95 : 64];
	assign ADD2_COL_in1[6][3] = CUR[6][127 : 96];
	assign ADD2_COL_in2[6][3] = (function_mode[1]==0)? CUR[7][127 : 96] : CUR[8][127 : 96];
	assign ADD2_COL_in1[6][4] = CUR[6][159 : 128];
	assign ADD2_COL_in2[6][4] = (function_mode[1]==0)? CUR[7][159 : 128] : CUR[8][159 : 128];
	assign ADD2_COL_in1[6][5] = CUR[6][191 : 160];
	assign ADD2_COL_in2[6][5] = (function_mode[1]==0)? CUR[7][191 : 160] : CUR[8][191 : 160];
	assign ADD2_COL_in1[6][6] = CUR[6][223 : 192];
	assign ADD2_COL_in2[6][6] = (function_mode[1]==0)? CUR[7][223 : 192] : CUR[8][223 : 192];
	assign ADD2_COL_in1[6][7] = CUR[6][255 : 224];
	assign ADD2_COL_in2[6][7] = (function_mode[1]==0)? CUR[7][255 : 224] : CUR[8][255 : 224];
	
	assign ADD2_ROW_in1[0][0] = (active_reg2)? CUR[0][31 : 0] : CUR[1][31 : 0];
	assign ADD2_ROW_in2[0][0] = (active_reg2)? PRE[0][31 : 0] : PRE[1][31 : 0];
	assign ADD2_ROW_in1[0][1] = (active_reg2)? CUR[0][63 : 32] : CUR[1][63 : 32];
	assign ADD2_ROW_in2[0][1] = (active_reg2)? PRE[0][63 : 32] : PRE[1][63 : 32];
	assign ADD2_ROW_in1[0][2] = (active_reg2)? CUR[0][95 : 64] : CUR[1][95 : 64];
	assign ADD2_ROW_in2[0][2] = (active_reg2)? PRE[0][95 : 64] : PRE[1][95 : 64];
	assign ADD2_ROW_in1[0][3] = (active_reg2)? CUR[0][127 : 96] : CUR[1][127 : 96];
	assign ADD2_ROW_in2[0][3] = (active_reg2)? PRE[0][127 : 96] : PRE[1][127 : 96];
	assign ADD2_ROW_in1[0][4] = (active_reg2)? CUR[0][159 : 128] : CUR[1][159 : 128];
	assign ADD2_ROW_in2[0][4] = (active_reg2)? PRE[0][159 : 128] : PRE[1][159 : 128];
	assign ADD2_ROW_in1[0][5] = (active_reg2)? CUR[0][191 : 160] : CUR[1][191 : 160];
	assign ADD2_ROW_in2[0][5] = (active_reg2)? PRE[0][191 : 160] : PRE[1][191 : 160];
	assign ADD2_ROW_in1[0][6] = (active_reg2)? CUR[0][223 : 192] : CUR[1][223 : 192];
	assign ADD2_ROW_in2[0][6] = (active_reg2)? PRE[0][223 : 192] : PRE[1][223 : 192];
	assign ADD2_ROW_in1[0][7] = (active_reg2)? CUR[0][255 : 224] : CUR[1][255 : 224];
	assign ADD2_ROW_in2[0][7] = (active_reg2)? PRE[0][255 : 224] : PRE[1][255 : 224];
	assign ADD2_ROW_in1[1][0] = (active_reg2)? CUR[1][31 : 0] : CUR[2][31 : 0];
	assign ADD2_ROW_in2[1][0] = (active_reg2)? PRE[1][31 : 0] : PRE[2][31 : 0];
	assign ADD2_ROW_in1[1][1] = (active_reg2)? CUR[1][63 : 32] : CUR[2][63 : 32];
	assign ADD2_ROW_in2[1][1] = (active_reg2)? PRE[1][63 : 32] : PRE[2][63 : 32];
	assign ADD2_ROW_in1[1][2] = (active_reg2)? CUR[1][95 : 64] : CUR[2][95 : 64];
	assign ADD2_ROW_in2[1][2] = (active_reg2)? PRE[1][95 : 64] : PRE[2][95 : 64];
	assign ADD2_ROW_in1[1][3] = (active_reg2)? CUR[1][127 : 96] : CUR[2][127 : 96];
	assign ADD2_ROW_in2[1][3] = (active_reg2)? PRE[1][127 : 96] : PRE[2][127 : 96];
	assign ADD2_ROW_in1[1][4] = (active_reg2)? CUR[1][159 : 128] : CUR[2][159 : 128];
	assign ADD2_ROW_in2[1][4] = (active_reg2)? PRE[1][159 : 128] : PRE[2][159 : 128];
	assign ADD2_ROW_in1[1][5] = (active_reg2)? CUR[1][191 : 160] : CUR[2][191 : 160];
	assign ADD2_ROW_in2[1][5] = (active_reg2)? PRE[1][191 : 160] : PRE[2][191 : 160];
	assign ADD2_ROW_in1[1][6] = (active_reg2)? CUR[1][223 : 192] : CUR[2][223 : 192];
	assign ADD2_ROW_in2[1][6] = (active_reg2)? PRE[1][223 : 192] : PRE[2][223 : 192];
	assign ADD2_ROW_in1[1][7] = (active_reg2)? CUR[1][255 : 224] : CUR[2][255 : 224];
	assign ADD2_ROW_in2[1][7] = (active_reg2)? PRE[1][255 : 224] : PRE[2][255 : 224];
	assign ADD2_ROW_in1[2][0] = (active_reg2)? CUR[2][31 : 0] : CUR[3][31 : 0];
	assign ADD2_ROW_in2[2][0] = (active_reg2)? PRE[2][31 : 0] : PRE[3][31 : 0];
	assign ADD2_ROW_in1[2][1] = (active_reg2)? CUR[2][63 : 32] : CUR[3][63 : 32];
	assign ADD2_ROW_in2[2][1] = (active_reg2)? PRE[2][63 : 32] : PRE[3][63 : 32];
	assign ADD2_ROW_in1[2][2] = (active_reg2)? CUR[2][95 : 64] : CUR[3][95 : 64];
	assign ADD2_ROW_in2[2][2] = (active_reg2)? PRE[2][95 : 64] : PRE[3][95 : 64];
	assign ADD2_ROW_in1[2][3] = (active_reg2)? CUR[2][127 : 96] : CUR[3][127 : 96];
	assign ADD2_ROW_in2[2][3] = (active_reg2)? PRE[2][127 : 96] : PRE[3][127 : 96];
	assign ADD2_ROW_in1[2][4] = (active_reg2)? CUR[2][159 : 128] : CUR[3][159 : 128];
	assign ADD2_ROW_in2[2][4] = (active_reg2)? PRE[2][159 : 128] : PRE[3][159 : 128];
	assign ADD2_ROW_in1[2][5] = (active_reg2)? CUR[2][191 : 160] : CUR[3][191 : 160];
	assign ADD2_ROW_in2[2][5] = (active_reg2)? PRE[2][191 : 160] : PRE[3][191 : 160];
	assign ADD2_ROW_in1[2][6] = (active_reg2)? CUR[2][223 : 192] : CUR[3][223 : 192];
	assign ADD2_ROW_in2[2][6] = (active_reg2)? PRE[2][223 : 192] : PRE[3][223 : 192];
	assign ADD2_ROW_in1[2][7] = (active_reg2)? CUR[2][255 : 224] : CUR[3][255 : 224];
	assign ADD2_ROW_in2[2][7] = (active_reg2)? PRE[2][255 : 224] : PRE[3][255 : 224];
	assign ADD2_ROW_in1[3][0] = (active_reg2)? CUR[3][31 : 0] : CUR[4][31 : 0];
	assign ADD2_ROW_in2[3][0] = (active_reg2)? PRE[3][31 : 0] : PRE[4][31 : 0];
	assign ADD2_ROW_in1[3][1] = (active_reg2)? CUR[3][63 : 32] : CUR[4][63 : 32];
	assign ADD2_ROW_in2[3][1] = (active_reg2)? PRE[3][63 : 32] : PRE[4][63 : 32];
	assign ADD2_ROW_in1[3][2] = (active_reg2)? CUR[3][95 : 64] : CUR[4][95 : 64];
	assign ADD2_ROW_in2[3][2] = (active_reg2)? PRE[3][95 : 64] : PRE[4][95 : 64];
	assign ADD2_ROW_in1[3][3] = (active_reg2)? CUR[3][127 : 96] : CUR[4][127 : 96];
	assign ADD2_ROW_in2[3][3] = (active_reg2)? PRE[3][127 : 96] : PRE[4][127 : 96];
	assign ADD2_ROW_in1[3][4] = (active_reg2)? CUR[3][159 : 128] : CUR[4][159 : 128];
	assign ADD2_ROW_in2[3][4] = (active_reg2)? PRE[3][159 : 128] : PRE[4][159 : 128];
	assign ADD2_ROW_in1[3][5] = (active_reg2)? CUR[3][191 : 160] : CUR[4][191 : 160];
	assign ADD2_ROW_in2[3][5] = (active_reg2)? PRE[3][191 : 160] : PRE[4][191 : 160];
	assign ADD2_ROW_in1[3][6] = (active_reg2)? CUR[3][223 : 192] : CUR[4][223 : 192];
	assign ADD2_ROW_in2[3][6] = (active_reg2)? PRE[3][223 : 192] : PRE[4][223 : 192];
	assign ADD2_ROW_in1[3][7] = (active_reg2)? CUR[3][255 : 224] : CUR[4][255 : 224];
	assign ADD2_ROW_in2[3][7] = (active_reg2)? PRE[3][255 : 224] : PRE[4][255 : 224];
	assign ADD2_ROW_in1[4][0] = (active_reg2)? CUR[4][31 : 0] : CUR[5][31 : 0];
	assign ADD2_ROW_in2[4][0] = (active_reg2)? PRE[4][31 : 0] : PRE[5][31 : 0];
	assign ADD2_ROW_in1[4][1] = (active_reg2)? CUR[4][63 : 32] : CUR[5][63 : 32];
	assign ADD2_ROW_in2[4][1] = (active_reg2)? PRE[4][63 : 32] : PRE[5][63 : 32];
	assign ADD2_ROW_in1[4][2] = (active_reg2)? CUR[4][95 : 64] : CUR[5][95 : 64];
	assign ADD2_ROW_in2[4][2] = (active_reg2)? PRE[4][95 : 64] : PRE[5][95 : 64];
	assign ADD2_ROW_in1[4][3] = (active_reg2)? CUR[4][127 : 96] : CUR[5][127 : 96];
	assign ADD2_ROW_in2[4][3] = (active_reg2)? PRE[4][127 : 96] : PRE[5][127 : 96];
	assign ADD2_ROW_in1[4][4] = (active_reg2)? CUR[4][159 : 128] : CUR[5][159 : 128];
	assign ADD2_ROW_in2[4][4] = (active_reg2)? PRE[4][159 : 128] : PRE[5][159 : 128];
	assign ADD2_ROW_in1[4][5] = (active_reg2)? CUR[4][191 : 160] : CUR[5][191 : 160];
	assign ADD2_ROW_in2[4][5] = (active_reg2)? PRE[4][191 : 160] : PRE[5][191 : 160];
	assign ADD2_ROW_in1[4][6] = (active_reg2)? CUR[4][223 : 192] : CUR[5][223 : 192];
	assign ADD2_ROW_in2[4][6] = (active_reg2)? PRE[4][223 : 192] : PRE[5][223 : 192];
	assign ADD2_ROW_in1[4][7] = (active_reg2)? CUR[4][255 : 224] : CUR[5][255 : 224];
	assign ADD2_ROW_in2[4][7] = (active_reg2)? PRE[4][255 : 224] : PRE[5][255 : 224];
	assign ADD2_ROW_in1[5][0] = (active_reg2)? CUR[5][31 : 0] : CUR[6][31 : 0];
	assign ADD2_ROW_in2[5][0] = (active_reg2)? PRE[5][31 : 0] : PRE[6][31 : 0];
	assign ADD2_ROW_in1[5][1] = (active_reg2)? CUR[5][63 : 32] : CUR[6][63 : 32];
	assign ADD2_ROW_in2[5][1] = (active_reg2)? PRE[5][63 : 32] : PRE[6][63 : 32];
	assign ADD2_ROW_in1[5][2] = (active_reg2)? CUR[5][95 : 64] : CUR[6][95 : 64];
	assign ADD2_ROW_in2[5][2] = (active_reg2)? PRE[5][95 : 64] : PRE[6][95 : 64];
	assign ADD2_ROW_in1[5][3] = (active_reg2)? CUR[5][127 : 96] : CUR[6][127 : 96];
	assign ADD2_ROW_in2[5][3] = (active_reg2)? PRE[5][127 : 96] : PRE[6][127 : 96];
	assign ADD2_ROW_in1[5][4] = (active_reg2)? CUR[5][159 : 128] : CUR[6][159 : 128];
	assign ADD2_ROW_in2[5][4] = (active_reg2)? PRE[5][159 : 128] : PRE[6][159 : 128];
	assign ADD2_ROW_in1[5][5] = (active_reg2)? CUR[5][191 : 160] : CUR[6][191 : 160];
	assign ADD2_ROW_in2[5][5] = (active_reg2)? PRE[5][191 : 160] : PRE[6][191 : 160];
	assign ADD2_ROW_in1[5][6] = (active_reg2)? CUR[5][223 : 192] : CUR[6][223 : 192];
	assign ADD2_ROW_in2[5][6] = (active_reg2)? PRE[5][223 : 192] : PRE[6][223 : 192];
	assign ADD2_ROW_in1[5][7] = (active_reg2)? CUR[5][255 : 224] : CUR[6][255 : 224];
	assign ADD2_ROW_in2[5][7] = (active_reg2)? PRE[5][255 : 224] : PRE[6][255 : 224];
	assign ADD2_ROW_in1[6][0] = (active_reg2)? CUR[6][31 : 0] : CUR[7][31 : 0];
	assign ADD2_ROW_in2[6][0] = (active_reg2)? PRE[6][31 : 0] : PRE[7][31 : 0];
	assign ADD2_ROW_in1[6][1] = (active_reg2)? CUR[6][63 : 32] : CUR[7][63 : 32];
	assign ADD2_ROW_in2[6][1] = (active_reg2)? PRE[6][63 : 32] : PRE[7][63 : 32];
	assign ADD2_ROW_in1[6][2] = (active_reg2)? CUR[6][95 : 64] : CUR[7][95 : 64];
	assign ADD2_ROW_in2[6][2] = (active_reg2)? PRE[6][95 : 64] : PRE[7][95 : 64];
	assign ADD2_ROW_in1[6][3] = (active_reg2)? CUR[6][127 : 96] : CUR[7][127 : 96];
	assign ADD2_ROW_in2[6][3] = (active_reg2)? PRE[6][127 : 96] : PRE[7][127 : 96];
	assign ADD2_ROW_in1[6][4] = (active_reg2)? CUR[6][159 : 128] : CUR[7][159 : 128];
	assign ADD2_ROW_in2[6][4] = (active_reg2)? PRE[6][159 : 128] : PRE[7][159 : 128];
	assign ADD2_ROW_in1[6][5] = (active_reg2)? CUR[6][191 : 160] : CUR[7][191 : 160];
	assign ADD2_ROW_in2[6][5] = (active_reg2)? PRE[6][191 : 160] : PRE[7][191 : 160];
	assign ADD2_ROW_in1[6][6] = (active_reg2)? CUR[6][223 : 192] : CUR[7][223 : 192];
	assign ADD2_ROW_in2[6][6] = (active_reg2)? PRE[6][223 : 192] : PRE[7][223 : 192];
	assign ADD2_ROW_in1[6][7] = (active_reg2)? CUR[6][255 : 224] : CUR[7][255 : 224];
	assign ADD2_ROW_in2[6][7] = (active_reg2)? PRE[6][255 : 224] : PRE[7][255 : 224];
	assign ADD2_ROW_in1[7][0] = (active_reg2)? CUR[7][31 : 0] : CUR[8][31 : 0];
	assign ADD2_ROW_in2[7][0] = (active_reg2)? PRE[7][31 : 0] : PRE[8][31 : 0];
	assign ADD2_ROW_in1[7][1] = (active_reg2)? CUR[7][63 : 32] : CUR[8][63 : 32];
	assign ADD2_ROW_in2[7][1] = (active_reg2)? PRE[7][63 : 32] : PRE[8][63 : 32];
	assign ADD2_ROW_in1[7][2] = (active_reg2)? CUR[7][95 : 64] : CUR[8][95 : 64];
	assign ADD2_ROW_in2[7][2] = (active_reg2)? PRE[7][95 : 64] : PRE[8][95 : 64];
	assign ADD2_ROW_in1[7][3] = (active_reg2)? CUR[7][127 : 96] : CUR[8][127 : 96];
	assign ADD2_ROW_in2[7][3] = (active_reg2)? PRE[7][127 : 96] : PRE[8][127 : 96];
	assign ADD2_ROW_in1[7][4] = (active_reg2)? CUR[7][159 : 128] : CUR[8][159 : 128];
	assign ADD2_ROW_in2[7][4] = (active_reg2)? PRE[7][159 : 128] : PRE[8][159 : 128];
	assign ADD2_ROW_in1[7][5] = (active_reg2)? CUR[7][191 : 160] : CUR[8][191 : 160];
	assign ADD2_ROW_in2[7][5] = (active_reg2)? PRE[7][191 : 160] : PRE[8][191 : 160];
	assign ADD2_ROW_in1[7][6] = (active_reg2)? CUR[7][223 : 192] : CUR[8][223 : 192];
	assign ADD2_ROW_in2[7][6] = (active_reg2)? PRE[7][223 : 192] : PRE[8][223 : 192];
	assign ADD2_ROW_in1[7][7] = (active_reg2)? CUR[7][255 : 224] : CUR[8][255 : 224];
	assign ADD2_ROW_in2[7][7] = (active_reg2)? PRE[7][255 : 224] : PRE[8][255 : 224];
	
	ADD2 aCOL00(.a(ADD2_COL_in1[0][0]),.b(ADD2_COL_in2[0][0]),.ADD2_res(ADD2_COL_res[0][0]));
	ADD2 aCOL01(.a(ADD2_COL_in1[0][1]),.b(ADD2_COL_in2[0][1]),.ADD2_res(ADD2_COL_res[0][1]));
	ADD2 aCOL02(.a(ADD2_COL_in1[0][2]),.b(ADD2_COL_in2[0][2]),.ADD2_res(ADD2_COL_res[0][2]));
	ADD2 aCOL03(.a(ADD2_COL_in1[0][3]),.b(ADD2_COL_in2[0][3]),.ADD2_res(ADD2_COL_res[0][3]));
	ADD2 aCOL04(.a(ADD2_COL_in1[0][4]),.b(ADD2_COL_in2[0][4]),.ADD2_res(ADD2_COL_res[0][4]));
	ADD2 aCOL05(.a(ADD2_COL_in1[0][5]),.b(ADD2_COL_in2[0][5]),.ADD2_res(ADD2_COL_res[0][5]));
	ADD2 aCOL06(.a(ADD2_COL_in1[0][6]),.b(ADD2_COL_in2[0][6]),.ADD2_res(ADD2_COL_res[0][6]));
	ADD2 aCOL07(.a(ADD2_COL_in1[0][7]),.b(ADD2_COL_in2[0][7]),.ADD2_res(ADD2_COL_res[0][7]));
	ADD2 aCOL10(.a(ADD2_COL_in1[1][0]),.b(ADD2_COL_in2[1][0]),.ADD2_res(ADD2_COL_res[1][0]));
	ADD2 aCOL11(.a(ADD2_COL_in1[1][1]),.b(ADD2_COL_in2[1][1]),.ADD2_res(ADD2_COL_res[1][1]));
	ADD2 aCOL12(.a(ADD2_COL_in1[1][2]),.b(ADD2_COL_in2[1][2]),.ADD2_res(ADD2_COL_res[1][2]));
	ADD2 aCOL13(.a(ADD2_COL_in1[1][3]),.b(ADD2_COL_in2[1][3]),.ADD2_res(ADD2_COL_res[1][3]));
	ADD2 aCOL14(.a(ADD2_COL_in1[1][4]),.b(ADD2_COL_in2[1][4]),.ADD2_res(ADD2_COL_res[1][4]));
	ADD2 aCOL15(.a(ADD2_COL_in1[1][5]),.b(ADD2_COL_in2[1][5]),.ADD2_res(ADD2_COL_res[1][5]));
	ADD2 aCOL16(.a(ADD2_COL_in1[1][6]),.b(ADD2_COL_in2[1][6]),.ADD2_res(ADD2_COL_res[1][6]));
	ADD2 aCOL17(.a(ADD2_COL_in1[1][7]),.b(ADD2_COL_in2[1][7]),.ADD2_res(ADD2_COL_res[1][7]));
	ADD2 aCOL20(.a(ADD2_COL_in1[2][0]),.b(ADD2_COL_in2[2][0]),.ADD2_res(ADD2_COL_res[2][0]));
	ADD2 aCOL21(.a(ADD2_COL_in1[2][1]),.b(ADD2_COL_in2[2][1]),.ADD2_res(ADD2_COL_res[2][1]));
	ADD2 aCOL22(.a(ADD2_COL_in1[2][2]),.b(ADD2_COL_in2[2][2]),.ADD2_res(ADD2_COL_res[2][2]));
	ADD2 aCOL23(.a(ADD2_COL_in1[2][3]),.b(ADD2_COL_in2[2][3]),.ADD2_res(ADD2_COL_res[2][3]));
	ADD2 aCOL24(.a(ADD2_COL_in1[2][4]),.b(ADD2_COL_in2[2][4]),.ADD2_res(ADD2_COL_res[2][4]));
	ADD2 aCOL25(.a(ADD2_COL_in1[2][5]),.b(ADD2_COL_in2[2][5]),.ADD2_res(ADD2_COL_res[2][5]));
	ADD2 aCOL26(.a(ADD2_COL_in1[2][6]),.b(ADD2_COL_in2[2][6]),.ADD2_res(ADD2_COL_res[2][6]));
	ADD2 aCOL27(.a(ADD2_COL_in1[2][7]),.b(ADD2_COL_in2[2][7]),.ADD2_res(ADD2_COL_res[2][7]));
	ADD2 aCOL30(.a(ADD2_COL_in1[3][0]),.b(ADD2_COL_in2[3][0]),.ADD2_res(ADD2_COL_res[3][0]));
	ADD2 aCOL31(.a(ADD2_COL_in1[3][1]),.b(ADD2_COL_in2[3][1]),.ADD2_res(ADD2_COL_res[3][1]));
	ADD2 aCOL32(.a(ADD2_COL_in1[3][2]),.b(ADD2_COL_in2[3][2]),.ADD2_res(ADD2_COL_res[3][2]));
	ADD2 aCOL33(.a(ADD2_COL_in1[3][3]),.b(ADD2_COL_in2[3][3]),.ADD2_res(ADD2_COL_res[3][3]));
	ADD2 aCOL34(.a(ADD2_COL_in1[3][4]),.b(ADD2_COL_in2[3][4]),.ADD2_res(ADD2_COL_res[3][4]));
	ADD2 aCOL35(.a(ADD2_COL_in1[3][5]),.b(ADD2_COL_in2[3][5]),.ADD2_res(ADD2_COL_res[3][5]));
	ADD2 aCOL36(.a(ADD2_COL_in1[3][6]),.b(ADD2_COL_in2[3][6]),.ADD2_res(ADD2_COL_res[3][6]));
	ADD2 aCOL37(.a(ADD2_COL_in1[3][7]),.b(ADD2_COL_in2[3][7]),.ADD2_res(ADD2_COL_res[3][7]));
	ADD2 aCOL40(.a(ADD2_COL_in1[4][0]),.b(ADD2_COL_in2[4][0]),.ADD2_res(ADD2_COL_res[4][0]));
	ADD2 aCOL41(.a(ADD2_COL_in1[4][1]),.b(ADD2_COL_in2[4][1]),.ADD2_res(ADD2_COL_res[4][1]));
	ADD2 aCOL42(.a(ADD2_COL_in1[4][2]),.b(ADD2_COL_in2[4][2]),.ADD2_res(ADD2_COL_res[4][2]));
	ADD2 aCOL43(.a(ADD2_COL_in1[4][3]),.b(ADD2_COL_in2[4][3]),.ADD2_res(ADD2_COL_res[4][3]));
	ADD2 aCOL44(.a(ADD2_COL_in1[4][4]),.b(ADD2_COL_in2[4][4]),.ADD2_res(ADD2_COL_res[4][4]));
	ADD2 aCOL45(.a(ADD2_COL_in1[4][5]),.b(ADD2_COL_in2[4][5]),.ADD2_res(ADD2_COL_res[4][5]));
	ADD2 aCOL46(.a(ADD2_COL_in1[4][6]),.b(ADD2_COL_in2[4][6]),.ADD2_res(ADD2_COL_res[4][6]));
	ADD2 aCOL47(.a(ADD2_COL_in1[4][7]),.b(ADD2_COL_in2[4][7]),.ADD2_res(ADD2_COL_res[4][7]));
	ADD2 aCOL50(.a(ADD2_COL_in1[5][0]),.b(ADD2_COL_in2[5][0]),.ADD2_res(ADD2_COL_res[5][0]));
	ADD2 aCOL51(.a(ADD2_COL_in1[5][1]),.b(ADD2_COL_in2[5][1]),.ADD2_res(ADD2_COL_res[5][1]));
	ADD2 aCOL52(.a(ADD2_COL_in1[5][2]),.b(ADD2_COL_in2[5][2]),.ADD2_res(ADD2_COL_res[5][2]));
	ADD2 aCOL53(.a(ADD2_COL_in1[5][3]),.b(ADD2_COL_in2[5][3]),.ADD2_res(ADD2_COL_res[5][3]));
	ADD2 aCOL54(.a(ADD2_COL_in1[5][4]),.b(ADD2_COL_in2[5][4]),.ADD2_res(ADD2_COL_res[5][4]));
	ADD2 aCOL55(.a(ADD2_COL_in1[5][5]),.b(ADD2_COL_in2[5][5]),.ADD2_res(ADD2_COL_res[5][5]));
	ADD2 aCOL56(.a(ADD2_COL_in1[5][6]),.b(ADD2_COL_in2[5][6]),.ADD2_res(ADD2_COL_res[5][6]));
	ADD2 aCOL57(.a(ADD2_COL_in1[5][7]),.b(ADD2_COL_in2[5][7]),.ADD2_res(ADD2_COL_res[5][7]));
	ADD2 aCOL60(.a(ADD2_COL_in1[6][0]),.b(ADD2_COL_in2[6][0]),.ADD2_res(ADD2_COL_res[6][0]));
	ADD2 aCOL61(.a(ADD2_COL_in1[6][1]),.b(ADD2_COL_in2[6][1]),.ADD2_res(ADD2_COL_res[6][1]));
	ADD2 aCOL62(.a(ADD2_COL_in1[6][2]),.b(ADD2_COL_in2[6][2]),.ADD2_res(ADD2_COL_res[6][2]));
	ADD2 aCOL63(.a(ADD2_COL_in1[6][3]),.b(ADD2_COL_in2[6][3]),.ADD2_res(ADD2_COL_res[6][3]));
	ADD2 aCOL64(.a(ADD2_COL_in1[6][4]),.b(ADD2_COL_in2[6][4]),.ADD2_res(ADD2_COL_res[6][4]));
	ADD2 aCOL65(.a(ADD2_COL_in1[6][5]),.b(ADD2_COL_in2[6][5]),.ADD2_res(ADD2_COL_res[6][5]));
	ADD2 aCOL66(.a(ADD2_COL_in1[6][6]),.b(ADD2_COL_in2[6][6]),.ADD2_res(ADD2_COL_res[6][6]));
	ADD2 aCOL67(.a(ADD2_COL_in1[6][7]),.b(ADD2_COL_in2[6][7]),.ADD2_res(ADD2_COL_res[6][7]));
	
	ADD2 aROW00(.a(ADD2_ROW_in1[0][0]),.b(ADD2_ROW_in2[0][0]),.ADD2_res(ADD2_ROW_res[0][0]));
	ADD2 aROW01(.a(ADD2_ROW_in1[0][1]),.b(ADD2_ROW_in2[0][1]),.ADD2_res(ADD2_ROW_res[0][1]));
	ADD2 aROW02(.a(ADD2_ROW_in1[0][2]),.b(ADD2_ROW_in2[0][2]),.ADD2_res(ADD2_ROW_res[0][2]));
	ADD2 aROW03(.a(ADD2_ROW_in1[0][3]),.b(ADD2_ROW_in2[0][3]),.ADD2_res(ADD2_ROW_res[0][3]));
	ADD2 aROW04(.a(ADD2_ROW_in1[0][4]),.b(ADD2_ROW_in2[0][4]),.ADD2_res(ADD2_ROW_res[0][4]));
	ADD2 aROW05(.a(ADD2_ROW_in1[0][5]),.b(ADD2_ROW_in2[0][5]),.ADD2_res(ADD2_ROW_res[0][5]));
	ADD2 aROW06(.a(ADD2_ROW_in1[0][6]),.b(ADD2_ROW_in2[0][6]),.ADD2_res(ADD2_ROW_res[0][6]));
	ADD2 aROW07(.a(ADD2_ROW_in1[0][7]),.b(ADD2_ROW_in2[0][7]),.ADD2_res(ADD2_ROW_res[0][7]));
	ADD2 aROW10(.a(ADD2_ROW_in1[1][0]),.b(ADD2_ROW_in2[1][0]),.ADD2_res(ADD2_ROW_res[1][0]));
	ADD2 aROW11(.a(ADD2_ROW_in1[1][1]),.b(ADD2_ROW_in2[1][1]),.ADD2_res(ADD2_ROW_res[1][1]));
	ADD2 aROW12(.a(ADD2_ROW_in1[1][2]),.b(ADD2_ROW_in2[1][2]),.ADD2_res(ADD2_ROW_res[1][2]));
	ADD2 aROW13(.a(ADD2_ROW_in1[1][3]),.b(ADD2_ROW_in2[1][3]),.ADD2_res(ADD2_ROW_res[1][3]));
	ADD2 aROW14(.a(ADD2_ROW_in1[1][4]),.b(ADD2_ROW_in2[1][4]),.ADD2_res(ADD2_ROW_res[1][4]));
	ADD2 aROW15(.a(ADD2_ROW_in1[1][5]),.b(ADD2_ROW_in2[1][5]),.ADD2_res(ADD2_ROW_res[1][5]));
	ADD2 aROW16(.a(ADD2_ROW_in1[1][6]),.b(ADD2_ROW_in2[1][6]),.ADD2_res(ADD2_ROW_res[1][6]));
	ADD2 aROW17(.a(ADD2_ROW_in1[1][7]),.b(ADD2_ROW_in2[1][7]),.ADD2_res(ADD2_ROW_res[1][7]));
	ADD2 aROW20(.a(ADD2_ROW_in1[2][0]),.b(ADD2_ROW_in2[2][0]),.ADD2_res(ADD2_ROW_res[2][0]));
	ADD2 aROW21(.a(ADD2_ROW_in1[2][1]),.b(ADD2_ROW_in2[2][1]),.ADD2_res(ADD2_ROW_res[2][1]));
	ADD2 aROW22(.a(ADD2_ROW_in1[2][2]),.b(ADD2_ROW_in2[2][2]),.ADD2_res(ADD2_ROW_res[2][2]));
	ADD2 aROW23(.a(ADD2_ROW_in1[2][3]),.b(ADD2_ROW_in2[2][3]),.ADD2_res(ADD2_ROW_res[2][3]));
	ADD2 aROW24(.a(ADD2_ROW_in1[2][4]),.b(ADD2_ROW_in2[2][4]),.ADD2_res(ADD2_ROW_res[2][4]));
	ADD2 aROW25(.a(ADD2_ROW_in1[2][5]),.b(ADD2_ROW_in2[2][5]),.ADD2_res(ADD2_ROW_res[2][5]));
	ADD2 aROW26(.a(ADD2_ROW_in1[2][6]),.b(ADD2_ROW_in2[2][6]),.ADD2_res(ADD2_ROW_res[2][6]));
	ADD2 aROW27(.a(ADD2_ROW_in1[2][7]),.b(ADD2_ROW_in2[2][7]),.ADD2_res(ADD2_ROW_res[2][7]));
	ADD2 aROW30(.a(ADD2_ROW_in1[3][0]),.b(ADD2_ROW_in2[3][0]),.ADD2_res(ADD2_ROW_res[3][0]));
	ADD2 aROW31(.a(ADD2_ROW_in1[3][1]),.b(ADD2_ROW_in2[3][1]),.ADD2_res(ADD2_ROW_res[3][1]));
	ADD2 aROW32(.a(ADD2_ROW_in1[3][2]),.b(ADD2_ROW_in2[3][2]),.ADD2_res(ADD2_ROW_res[3][2]));
	ADD2 aROW33(.a(ADD2_ROW_in1[3][3]),.b(ADD2_ROW_in2[3][3]),.ADD2_res(ADD2_ROW_res[3][3]));
	ADD2 aROW34(.a(ADD2_ROW_in1[3][4]),.b(ADD2_ROW_in2[3][4]),.ADD2_res(ADD2_ROW_res[3][4]));
	ADD2 aROW35(.a(ADD2_ROW_in1[3][5]),.b(ADD2_ROW_in2[3][5]),.ADD2_res(ADD2_ROW_res[3][5]));
	ADD2 aROW36(.a(ADD2_ROW_in1[3][6]),.b(ADD2_ROW_in2[3][6]),.ADD2_res(ADD2_ROW_res[3][6]));
	ADD2 aROW37(.a(ADD2_ROW_in1[3][7]),.b(ADD2_ROW_in2[3][7]),.ADD2_res(ADD2_ROW_res[3][7]));
	ADD2 aROW40(.a(ADD2_ROW_in1[4][0]),.b(ADD2_ROW_in2[4][0]),.ADD2_res(ADD2_ROW_res[4][0]));
	ADD2 aROW41(.a(ADD2_ROW_in1[4][1]),.b(ADD2_ROW_in2[4][1]),.ADD2_res(ADD2_ROW_res[4][1]));
	ADD2 aROW42(.a(ADD2_ROW_in1[4][2]),.b(ADD2_ROW_in2[4][2]),.ADD2_res(ADD2_ROW_res[4][2]));
	ADD2 aROW43(.a(ADD2_ROW_in1[4][3]),.b(ADD2_ROW_in2[4][3]),.ADD2_res(ADD2_ROW_res[4][3]));
	ADD2 aROW44(.a(ADD2_ROW_in1[4][4]),.b(ADD2_ROW_in2[4][4]),.ADD2_res(ADD2_ROW_res[4][4]));
	ADD2 aROW45(.a(ADD2_ROW_in1[4][5]),.b(ADD2_ROW_in2[4][5]),.ADD2_res(ADD2_ROW_res[4][5]));
	ADD2 aROW46(.a(ADD2_ROW_in1[4][6]),.b(ADD2_ROW_in2[4][6]),.ADD2_res(ADD2_ROW_res[4][6]));
	ADD2 aROW47(.a(ADD2_ROW_in1[4][7]),.b(ADD2_ROW_in2[4][7]),.ADD2_res(ADD2_ROW_res[4][7]));
	ADD2 aROW50(.a(ADD2_ROW_in1[5][0]),.b(ADD2_ROW_in2[5][0]),.ADD2_res(ADD2_ROW_res[5][0]));
	ADD2 aROW51(.a(ADD2_ROW_in1[5][1]),.b(ADD2_ROW_in2[5][1]),.ADD2_res(ADD2_ROW_res[5][1]));
	ADD2 aROW52(.a(ADD2_ROW_in1[5][2]),.b(ADD2_ROW_in2[5][2]),.ADD2_res(ADD2_ROW_res[5][2]));
	ADD2 aROW53(.a(ADD2_ROW_in1[5][3]),.b(ADD2_ROW_in2[5][3]),.ADD2_res(ADD2_ROW_res[5][3]));
	ADD2 aROW54(.a(ADD2_ROW_in1[5][4]),.b(ADD2_ROW_in2[5][4]),.ADD2_res(ADD2_ROW_res[5][4]));
	ADD2 aROW55(.a(ADD2_ROW_in1[5][5]),.b(ADD2_ROW_in2[5][5]),.ADD2_res(ADD2_ROW_res[5][5]));
	ADD2 aROW56(.a(ADD2_ROW_in1[5][6]),.b(ADD2_ROW_in2[5][6]),.ADD2_res(ADD2_ROW_res[5][6]));
	ADD2 aROW57(.a(ADD2_ROW_in1[5][7]),.b(ADD2_ROW_in2[5][7]),.ADD2_res(ADD2_ROW_res[5][7]));
	ADD2 aROW60(.a(ADD2_ROW_in1[6][0]),.b(ADD2_ROW_in2[6][0]),.ADD2_res(ADD2_ROW_res[6][0]));
	ADD2 aROW61(.a(ADD2_ROW_in1[6][1]),.b(ADD2_ROW_in2[6][1]),.ADD2_res(ADD2_ROW_res[6][1]));
	ADD2 aROW62(.a(ADD2_ROW_in1[6][2]),.b(ADD2_ROW_in2[6][2]),.ADD2_res(ADD2_ROW_res[6][2]));
	ADD2 aROW63(.a(ADD2_ROW_in1[6][3]),.b(ADD2_ROW_in2[6][3]),.ADD2_res(ADD2_ROW_res[6][3]));
	ADD2 aROW64(.a(ADD2_ROW_in1[6][4]),.b(ADD2_ROW_in2[6][4]),.ADD2_res(ADD2_ROW_res[6][4]));
	ADD2 aROW65(.a(ADD2_ROW_in1[6][5]),.b(ADD2_ROW_in2[6][5]),.ADD2_res(ADD2_ROW_res[6][5]));
	ADD2 aROW66(.a(ADD2_ROW_in1[6][6]),.b(ADD2_ROW_in2[6][6]),.ADD2_res(ADD2_ROW_res[6][6]));
	ADD2 aROW67(.a(ADD2_ROW_in1[6][7]),.b(ADD2_ROW_in2[6][7]),.ADD2_res(ADD2_ROW_res[6][7]));
	ADD2 aROW70(.a(ADD2_ROW_in1[7][0]),.b(ADD2_ROW_in2[7][0]),.ADD2_res(ADD2_ROW_res[7][0]));
	ADD2 aROW71(.a(ADD2_ROW_in1[7][1]),.b(ADD2_ROW_in2[7][1]),.ADD2_res(ADD2_ROW_res[7][1]));
	ADD2 aROW72(.a(ADD2_ROW_in1[7][2]),.b(ADD2_ROW_in2[7][2]),.ADD2_res(ADD2_ROW_res[7][2]));
	ADD2 aROW73(.a(ADD2_ROW_in1[7][3]),.b(ADD2_ROW_in2[7][3]),.ADD2_res(ADD2_ROW_res[7][3]));
	ADD2 aROW74(.a(ADD2_ROW_in1[7][4]),.b(ADD2_ROW_in2[7][4]),.ADD2_res(ADD2_ROW_res[7][4]));
	ADD2 aROW75(.a(ADD2_ROW_in1[7][5]),.b(ADD2_ROW_in2[7][5]),.ADD2_res(ADD2_ROW_res[7][5]));
	ADD2 aROW76(.a(ADD2_ROW_in1[7][6]),.b(ADD2_ROW_in2[7][6]),.ADD2_res(ADD2_ROW_res[7][6]));
	ADD2 aROW77(.a(ADD2_ROW_in1[7][7]),.b(ADD2_ROW_in2[7][7]),.ADD2_res(ADD2_ROW_res[7][7]));
​	
	
//------------------------------------------------------------------------------------------------
	assign CMP_ADD3_in1[0][0] = CUR[0][31 : 0];
	assign CMP_ADD3_in2[0][0] = (active_reg)? CUR[1][31 : 0] : PRE[0][31 : 0];
	assign CMP_ADD3_in3[0][0] = (active_reg)? CUR[2][31 : 0] : MID[0][31 : 0];
	assign CMP_ADD3_in1[0][1] = CUR[0][63 : 32];
	assign CMP_ADD3_in2[0][1] = (active_reg)? CUR[1][63 : 32] : PRE[0][63 : 32];
	assign CMP_ADD3_in3[0][1] = (active_reg)? CUR[2][63 : 32] : MID[0][63 : 32];
	assign CMP_ADD3_in1[0][2] = CUR[0][95 : 64];
	assign CMP_ADD3_in2[0][2] = (active_reg)? CUR[1][95 : 64] : PRE[0][95 : 64];
	assign CMP_ADD3_in3[0][2] = (active_reg)? CUR[2][95 : 64] : MID[0][95 : 64];
	assign CMP_ADD3_in1[0][3] = CUR[0][127 : 96];
	assign CMP_ADD3_in2[0][3] = (active_reg)? CUR[1][127 : 96] : PRE[0][127 : 96];
	assign CMP_ADD3_in3[0][3] = (active_reg)? CUR[2][127 : 96] : MID[0][127 : 96];
	assign CMP_ADD3_in1[0][4] = CUR[0][159 : 128];
	assign CMP_ADD3_in2[0][4] = (active_reg)? CUR[1][159 : 128] : PRE[0][159 : 128];
	assign CMP_ADD3_in3[0][4] = (active_reg)? CUR[2][159 : 128] : MID[0][159 : 128];
	assign CMP_ADD3_in1[0][5] = CUR[0][191 : 160];
	assign CMP_ADD3_in2[0][5] = (active_reg)? CUR[1][191 : 160] : PRE[0][191 : 160];
	assign CMP_ADD3_in3[0][5] = (active_reg)? CUR[2][191 : 160] : MID[0][191 : 160];
	assign CMP_ADD3_in1[0][6] = CUR[0][223 : 192];
	assign CMP_ADD3_in2[0][6] = (active_reg)? CUR[1][223 : 192] : PRE[0][223 : 192];
	assign CMP_ADD3_in3[0][6] = (active_reg)? CUR[2][223 : 192] : MID[0][223 : 192];
	assign CMP_ADD3_in1[0][7] = CUR[0][255 : 224];
	assign CMP_ADD3_in2[0][7] = (active_reg)? CUR[1][255 : 224] : PRE[0][255 : 224];
	assign CMP_ADD3_in3[0][7] = (active_reg)? CUR[2][255 : 224] : MID[0][255 : 224];
	assign CMP_ADD3_in1[1][0] = CUR[2][31 : 0];
	assign CMP_ADD3_in2[1][0] = (active_reg)? CUR[3][31 : 0] : PRE[2][31 : 0];
	assign CMP_ADD3_in3[1][0] = (active_reg)? CUR[4][31 : 0] : MID[2][31 : 0];
	assign CMP_ADD3_in1[1][1] = CUR[2][63 : 32];
	assign CMP_ADD3_in2[1][1] = (active_reg)? CUR[3][63 : 32] : PRE[2][63 : 32];
	assign CMP_ADD3_in3[1][1] = (active_reg)? CUR[4][63 : 32] : MID[2][63 : 32];
	assign CMP_ADD3_in1[1][2] = CUR[2][95 : 64];
	assign CMP_ADD3_in2[1][2] = (active_reg)? CUR[3][95 : 64] : PRE[2][95 : 64];
	assign CMP_ADD3_in3[1][2] = (active_reg)? CUR[4][95 : 64] : MID[2][95 : 64];
	assign CMP_ADD3_in1[1][3] = CUR[2][127 : 96];
	assign CMP_ADD3_in2[1][3] = (active_reg)? CUR[3][127 : 96] : PRE[2][127 : 96];
	assign CMP_ADD3_in3[1][3] = (active_reg)? CUR[4][127 : 96] : MID[2][127 : 96];
	assign CMP_ADD3_in1[1][4] = CUR[2][159 : 128];
	assign CMP_ADD3_in2[1][4] = (active_reg)? CUR[3][159 : 128] : PRE[2][159 : 128];
	assign CMP_ADD3_in3[1][4] = (active_reg)? CUR[4][159 : 128] : MID[2][159 : 128];
	assign CMP_ADD3_in1[1][5] = CUR[2][191 : 160];
	assign CMP_ADD3_in2[1][5] = (active_reg)? CUR[3][191 : 160] : PRE[2][191 : 160];
	assign CMP_ADD3_in3[1][5] = (active_reg)? CUR[4][191 : 160] : MID[2][191 : 160];
	assign CMP_ADD3_in1[1][6] = CUR[2][223 : 192];
	assign CMP_ADD3_in2[1][6] = (active_reg)? CUR[3][223 : 192] : PRE[2][223 : 192];
	assign CMP_ADD3_in3[1][6] = (active_reg)? CUR[4][223 : 192] : MID[2][223 : 192];
	assign CMP_ADD3_in1[1][7] = CUR[2][255 : 224];
	assign CMP_ADD3_in2[1][7] = (active_reg)? CUR[3][255 : 224] : PRE[2][255 : 224];
	assign CMP_ADD3_in3[1][7] = (active_reg)? CUR[4][255 : 224] : MID[2][255 : 224];
	assign CMP_ADD3_in1[2][0] = CUR[4][31 : 0];
	assign CMP_ADD3_in2[2][0] = (active_reg)? CUR[5][31 : 0] : PRE[4][31 : 0];
	assign CMP_ADD3_in3[2][0] = (active_reg)? CUR[6][31 : 0] : MID[4][31 : 0];
	assign CMP_ADD3_in1[2][1] = CUR[4][63 : 32];
	assign CMP_ADD3_in2[2][1] = (active_reg)? CUR[5][63 : 32] : PRE[4][63 : 32];
	assign CMP_ADD3_in3[2][1] = (active_reg)? CUR[6][63 : 32] : MID[4][63 : 32];
	assign CMP_ADD3_in1[2][2] = CUR[4][95 : 64];
	assign CMP_ADD3_in2[2][2] = (active_reg)? CUR[5][95 : 64] : PRE[4][95 : 64];
	assign CMP_ADD3_in3[2][2] = (active_reg)? CUR[6][95 : 64] : MID[4][95 : 64];
	assign CMP_ADD3_in1[2][3] = CUR[4][127 : 96];
	assign CMP_ADD3_in2[2][3] = (active_reg)? CUR[5][127 : 96] : PRE[4][127 : 96];
	assign CMP_ADD3_in3[2][3] = (active_reg)? CUR[6][127 : 96] : MID[4][127 : 96];
	assign CMP_ADD3_in1[2][4] = CUR[4][159 : 128];
	assign CMP_ADD3_in2[2][4] = (active_reg)? CUR[5][159 : 128] : PRE[4][159 : 128];
	assign CMP_ADD3_in3[2][4] = (active_reg)? CUR[6][159 : 128] : MID[4][159 : 128];
	assign CMP_ADD3_in1[2][5] = CUR[4][191 : 160];
	assign CMP_ADD3_in2[2][5] = (active_reg)? CUR[5][191 : 160] : PRE[4][191 : 160];
	assign CMP_ADD3_in3[2][5] = (active_reg)? CUR[6][191 : 160] : MID[4][191 : 160];
	assign CMP_ADD3_in1[2][6] = CUR[4][223 : 192];
	assign CMP_ADD3_in2[2][6] = (active_reg)? CUR[5][223 : 192] : PRE[4][223 : 192];
	assign CMP_ADD3_in3[2][6] = (active_reg)? CUR[6][223 : 192] : MID[4][223 : 192];
	assign CMP_ADD3_in1[2][7] = CUR[4][255 : 224];
	assign CMP_ADD3_in2[2][7] = (active_reg)? CUR[5][255 : 224] : PRE[4][255 : 224];
	assign CMP_ADD3_in3[2][7] = (active_reg)? CUR[6][255 : 224] : MID[4][255 : 224];
	assign CMP_ADD3_in1[3][0] = CUR[6][31 : 0];
	assign CMP_ADD3_in2[3][0] = (active_reg)? CUR[7][31 : 0] : PRE[6][31 : 0];
	assign CMP_ADD3_in3[3][0] = (active_reg)? CUR[8][31 : 0] : MID[6][31 : 0];
	assign CMP_ADD3_in1[3][1] = CUR[6][63 : 32];
	assign CMP_ADD3_in2[3][1] = (active_reg)? CUR[7][63 : 32] : PRE[6][63 : 32];
	assign CMP_ADD3_in3[3][1] = (active_reg)? CUR[8][63 : 32] : MID[6][63 : 32];
	assign CMP_ADD3_in1[3][2] = CUR[6][95 : 64];
	assign CMP_ADD3_in2[3][2] = (active_reg)? CUR[7][95 : 64] : PRE[6][95 : 64];
	assign CMP_ADD3_in3[3][2] = (active_reg)? CUR[8][95 : 64] : MID[6][95 : 64];
	assign CMP_ADD3_in1[3][3] = CUR[6][127 : 96];
	assign CMP_ADD3_in2[3][3] = (active_reg)? CUR[7][127 : 96] : PRE[6][127 : 96];
	assign CMP_ADD3_in3[3][3] = (active_reg)? CUR[8][127 : 96] : MID[6][127 : 96];
	assign CMP_ADD3_in1[3][4] = CUR[6][159 : 128];
	assign CMP_ADD3_in2[3][4] = (active_reg)? CUR[7][159 : 128] : PRE[6][159 : 128];
	assign CMP_ADD3_in3[3][4] = (active_reg)? CUR[8][159 : 128] : MID[6][159 : 128];
	assign CMP_ADD3_in1[3][5] = CUR[6][191 : 160];
	assign CMP_ADD3_in2[3][5] = (active_reg)? CUR[7][191 : 160] : PRE[6][191 : 160];
	assign CMP_ADD3_in3[3][5] = (active_reg)? CUR[8][191 : 160] : MID[6][191 : 160];
	assign CMP_ADD3_in1[3][6] = CUR[6][223 : 192];
	assign CMP_ADD3_in2[3][6] = (active_reg)? CUR[7][223 : 192] : PRE[6][223 : 192];
	assign CMP_ADD3_in3[3][6] = (active_reg)? CUR[8][223 : 192] : MID[6][223 : 192];
	assign CMP_ADD3_in1[3][7] = CUR[6][255 : 224];
	assign CMP_ADD3_in2[3][7] = (active_reg)? CUR[7][255 : 224] : PRE[6][255 : 224];
	assign CMP_ADD3_in3[3][7] = (active_reg)? CUR[8][255 : 224] : MID[6][255 : 224];
	
	CMP c00(.cmp1(CMP_ADD3_in1[0][0]),.cmp2(CMP_ADD3_in2[0][0]),.cmp3(CMP_ADD3_in3[0][0]),.active(CMP_active),.cmp_res(cmp_res[0][0]));
	CMP c01(.cmp1(CMP_ADD3_in1[0][1]),.cmp2(CMP_ADD3_in2[0][1]),.cmp3(CMP_ADD3_in3[0][1]),.active(CMP_active),.cmp_res(cmp_res[0][1]));
	CMP c02(.cmp1(CMP_ADD3_in1[0][2]),.cmp2(CMP_ADD3_in2[0][2]),.cmp3(CMP_ADD3_in3[0][2]),.active(CMP_active),.cmp_res(cmp_res[0][2]));
	CMP c03(.cmp1(CMP_ADD3_in1[0][3]),.cmp2(CMP_ADD3_in2[0][3]),.cmp3(CMP_ADD3_in3[0][3]),.active(CMP_active),.cmp_res(cmp_res[0][3]));
	CMP c04(.cmp1(CMP_ADD3_in1[0][4]),.cmp2(CMP_ADD3_in2[0][4]),.cmp3(CMP_ADD3_in3[0][4]),.active(CMP_active),.cmp_res(cmp_res[0][4]));
	CMP c05(.cmp1(CMP_ADD3_in1[0][5]),.cmp2(CMP_ADD3_in2[0][5]),.cmp3(CMP_ADD3_in3[0][5]),.active(CMP_active),.cmp_res(cmp_res[0][5]));
	CMP c06(.cmp1(CMP_ADD3_in1[0][6]),.cmp2(CMP_ADD3_in2[0][6]),.cmp3(CMP_ADD3_in3[0][6]),.active(CMP_active),.cmp_res(cmp_res[0][6]));
	CMP c07(.cmp1(CMP_ADD3_in1[0][7]),.cmp2(CMP_ADD3_in2[0][7]),.cmp3(CMP_ADD3_in3[0][7]),.active(CMP_active),.cmp_res(cmp_res[0][7]));
	CMP c10(.cmp1(CMP_ADD3_in1[1][0]),.cmp2(CMP_ADD3_in2[1][0]),.cmp3(CMP_ADD3_in3[1][0]),.active(CMP_active),.cmp_res(cmp_res[1][0]));
	CMP c11(.cmp1(CMP_ADD3_in1[1][1]),.cmp2(CMP_ADD3_in2[1][1]),.cmp3(CMP_ADD3_in3[1][1]),.active(CMP_active),.cmp_res(cmp_res[1][1]));
	CMP c12(.cmp1(CMP_ADD3_in1[1][2]),.cmp2(CMP_ADD3_in2[1][2]),.cmp3(CMP_ADD3_in3[1][2]),.active(CMP_active),.cmp_res(cmp_res[1][2]));
	CMP c13(.cmp1(CMP_ADD3_in1[1][3]),.cmp2(CMP_ADD3_in2[1][3]),.cmp3(CMP_ADD3_in3[1][3]),.active(CMP_active),.cmp_res(cmp_res[1][3]));
	CMP c14(.cmp1(CMP_ADD3_in1[1][4]),.cmp2(CMP_ADD3_in2[1][4]),.cmp3(CMP_ADD3_in3[1][4]),.active(CMP_active),.cmp_res(cmp_res[1][4]));
	CMP c15(.cmp1(CMP_ADD3_in1[1][5]),.cmp2(CMP_ADD3_in2[1][5]),.cmp3(CMP_ADD3_in3[1][5]),.active(CMP_active),.cmp_res(cmp_res[1][5]));
	CMP c16(.cmp1(CMP_ADD3_in1[1][6]),.cmp2(CMP_ADD3_in2[1][6]),.cmp3(CMP_ADD3_in3[1][6]),.active(CMP_active),.cmp_res(cmp_res[1][6]));
	CMP c17(.cmp1(CMP_ADD3_in1[1][7]),.cmp2(CMP_ADD3_in2[1][7]),.cmp3(CMP_ADD3_in3[1][7]),.active(CMP_active),.cmp_res(cmp_res[1][7]));
	CMP c20(.cmp1(CMP_ADD3_in1[2][0]),.cmp2(CMP_ADD3_in2[2][0]),.cmp3(CMP_ADD3_in3[2][0]),.active(CMP_active),.cmp_res(cmp_res[2][0]));
	CMP c21(.cmp1(CMP_ADD3_in1[2][1]),.cmp2(CMP_ADD3_in2[2][1]),.cmp3(CMP_ADD3_in3[2][1]),.active(CMP_active),.cmp_res(cmp_res[2][1]));
	CMP c22(.cmp1(CMP_ADD3_in1[2][2]),.cmp2(CMP_ADD3_in2[2][2]),.cmp3(CMP_ADD3_in3[2][2]),.active(CMP_active),.cmp_res(cmp_res[2][2]));
	CMP c23(.cmp1(CMP_ADD3_in1[2][3]),.cmp2(CMP_ADD3_in2[2][3]),.cmp3(CMP_ADD3_in3[2][3]),.active(CMP_active),.cmp_res(cmp_res[2][3]));
	CMP c24(.cmp1(CMP_ADD3_in1[2][4]),.cmp2(CMP_ADD3_in2[2][4]),.cmp3(CMP_ADD3_in3[2][4]),.active(CMP_active),.cmp_res(cmp_res[2][4]));
	CMP c25(.cmp1(CMP_ADD3_in1[2][5]),.cmp2(CMP_ADD3_in2[2][5]),.cmp3(CMP_ADD3_in3[2][5]),.active(CMP_active),.cmp_res(cmp_res[2][5]));
	CMP c26(.cmp1(CMP_ADD3_in1[2][6]),.cmp2(CMP_ADD3_in2[2][6]),.cmp3(CMP_ADD3_in3[2][6]),.active(CMP_active),.cmp_res(cmp_res[2][6]));
	CMP c27(.cmp1(CMP_ADD3_in1[2][7]),.cmp2(CMP_ADD3_in2[2][7]),.cmp3(CMP_ADD3_in3[2][7]),.active(CMP_active),.cmp_res(cmp_res[2][7]));
	CMP c30(.cmp1(CMP_ADD3_in1[3][0]),.cmp2(CMP_ADD3_in2[3][0]),.cmp3(CMP_ADD3_in3[3][0]),.active(CMP_active),.cmp_res(cmp_res[3][0]));
	CMP c31(.cmp1(CMP_ADD3_in1[3][1]),.cmp2(CMP_ADD3_in2[3][1]),.cmp3(CMP_ADD3_in3[3][1]),.active(CMP_active),.cmp_res(cmp_res[3][1]));
	CMP c32(.cmp1(CMP_ADD3_in1[3][2]),.cmp2(CMP_ADD3_in2[3][2]),.cmp3(CMP_ADD3_in3[3][2]),.active(CMP_active),.cmp_res(cmp_res[3][2]));
	CMP c33(.cmp1(CMP_ADD3_in1[3][3]),.cmp2(CMP_ADD3_in2[3][3]),.cmp3(CMP_ADD3_in3[3][3]),.active(CMP_active),.cmp_res(cmp_res[3][3]));
	CMP c34(.cmp1(CMP_ADD3_in1[3][4]),.cmp2(CMP_ADD3_in2[3][4]),.cmp3(CMP_ADD3_in3[3][4]),.active(CMP_active),.cmp_res(cmp_res[3][4]));
	CMP c35(.cmp1(CMP_ADD3_in1[3][5]),.cmp2(CMP_ADD3_in2[3][5]),.cmp3(CMP_ADD3_in3[3][5]),.active(CMP_active),.cmp_res(cmp_res[3][5]));
	CMP c36(.cmp1(CMP_ADD3_in1[3][6]),.cmp2(CMP_ADD3_in2[3][6]),.cmp3(CMP_ADD3_in3[3][6]),.active(CMP_active),.cmp_res(cmp_res[3][6]));
	CMP c37(.cmp1(CMP_ADD3_in1[3][7]),.cmp2(CMP_ADD3_in2[3][7]),.cmp3(CMP_ADD3_in3[3][7]),.active(CMP_active),.cmp_res(cmp_res[3][7]));
	​
	ADD3 a00(.a(CMP_ADD3_in1[0][0]),.b(CMP_ADD3_in2[0][0]),.c(CMP_ADD3_in3[0][0]),.ADD3_res(ADD3_res[0][0]));
	ADD3 a01(.a(CMP_ADD3_in1[0][1]),.b(CMP_ADD3_in2[0][1]),.c(CMP_ADD3_in3[0][1]),.ADD3_res(ADD3_res[0][1]));
	ADD3 a02(.a(CMP_ADD3_in1[0][2]),.b(CMP_ADD3_in2[0][2]),.c(CMP_ADD3_in3[0][2]),.ADD3_res(ADD3_res[0][2]));
	ADD3 a03(.a(CMP_ADD3_in1[0][3]),.b(CMP_ADD3_in2[0][3]),.c(CMP_ADD3_in3[0][3]),.ADD3_res(ADD3_res[0][3]));
	ADD3 a04(.a(CMP_ADD3_in1[0][4]),.b(CMP_ADD3_in2[0][4]),.c(CMP_ADD3_in3[0][4]),.ADD3_res(ADD3_res[0][4]));
	ADD3 a05(.a(CMP_ADD3_in1[0][5]),.b(CMP_ADD3_in2[0][5]),.c(CMP_ADD3_in3[0][5]),.ADD3_res(ADD3_res[0][5]));
	ADD3 a06(.a(CMP_ADD3_in1[0][6]),.b(CMP_ADD3_in2[0][6]),.c(CMP_ADD3_in3[0][6]),.ADD3_res(ADD3_res[0][6]));
	ADD3 a07(.a(CMP_ADD3_in1[0][7]),.b(CMP_ADD3_in2[0][7]),.c(CMP_ADD3_in3[0][7]),.ADD3_res(ADD3_res[0][7]));
	ADD3 a10(.a(CMP_ADD3_in1[1][0]),.b(CMP_ADD3_in2[1][0]),.c(CMP_ADD3_in3[1][0]),.ADD3_res(ADD3_res[1][0]));
	ADD3 a11(.a(CMP_ADD3_in1[1][1]),.b(CMP_ADD3_in2[1][1]),.c(CMP_ADD3_in3[1][1]),.ADD3_res(ADD3_res[1][1]));
	ADD3 a12(.a(CMP_ADD3_in1[1][2]),.b(CMP_ADD3_in2[1][2]),.c(CMP_ADD3_in3[1][2]),.ADD3_res(ADD3_res[1][2]));
	ADD3 a13(.a(CMP_ADD3_in1[1][3]),.b(CMP_ADD3_in2[1][3]),.c(CMP_ADD3_in3[1][3]),.ADD3_res(ADD3_res[1][3]));
	ADD3 a14(.a(CMP_ADD3_in1[1][4]),.b(CMP_ADD3_in2[1][4]),.c(CMP_ADD3_in3[1][4]),.ADD3_res(ADD3_res[1][4]));
	ADD3 a15(.a(CMP_ADD3_in1[1][5]),.b(CMP_ADD3_in2[1][5]),.c(CMP_ADD3_in3[1][5]),.ADD3_res(ADD3_res[1][5]));
	ADD3 a16(.a(CMP_ADD3_in1[1][6]),.b(CMP_ADD3_in2[1][6]),.c(CMP_ADD3_in3[1][6]),.ADD3_res(ADD3_res[1][6]));
	ADD3 a17(.a(CMP_ADD3_in1[1][7]),.b(CMP_ADD3_in2[1][7]),.c(CMP_ADD3_in3[1][7]),.ADD3_res(ADD3_res[1][7]));
	ADD3 a20(.a(CMP_ADD3_in1[2][0]),.b(CMP_ADD3_in2[2][0]),.c(CMP_ADD3_in3[2][0]),.ADD3_res(ADD3_res[2][0]));
	ADD3 a21(.a(CMP_ADD3_in1[2][1]),.b(CMP_ADD3_in2[2][1]),.c(CMP_ADD3_in3[2][1]),.ADD3_res(ADD3_res[2][1]));
	ADD3 a22(.a(CMP_ADD3_in1[2][2]),.b(CMP_ADD3_in2[2][2]),.c(CMP_ADD3_in3[2][2]),.ADD3_res(ADD3_res[2][2]));
	ADD3 a23(.a(CMP_ADD3_in1[2][3]),.b(CMP_ADD3_in2[2][3]),.c(CMP_ADD3_in3[2][3]),.ADD3_res(ADD3_res[2][3]));
	ADD3 a24(.a(CMP_ADD3_in1[2][4]),.b(CMP_ADD3_in2[2][4]),.c(CMP_ADD3_in3[2][4]),.ADD3_res(ADD3_res[2][4]));
	ADD3 a25(.a(CMP_ADD3_in1[2][5]),.b(CMP_ADD3_in2[2][5]),.c(CMP_ADD3_in3[2][5]),.ADD3_res(ADD3_res[2][5]));
	ADD3 a26(.a(CMP_ADD3_in1[2][6]),.b(CMP_ADD3_in2[2][6]),.c(CMP_ADD3_in3[2][6]),.ADD3_res(ADD3_res[2][6]));
	ADD3 a27(.a(CMP_ADD3_in1[2][7]),.b(CMP_ADD3_in2[2][7]),.c(CMP_ADD3_in3[2][7]),.ADD3_res(ADD3_res[2][7]));
	ADD3 a30(.a(CMP_ADD3_in1[3][0]),.b(CMP_ADD3_in2[3][0]),.c(CMP_ADD3_in3[3][0]),.ADD3_res(ADD3_res[3][0]));
	ADD3 a31(.a(CMP_ADD3_in1[3][1]),.b(CMP_ADD3_in2[3][1]),.c(CMP_ADD3_in3[3][1]),.ADD3_res(ADD3_res[3][1]));
	ADD3 a32(.a(CMP_ADD3_in1[3][2]),.b(CMP_ADD3_in2[3][2]),.c(CMP_ADD3_in3[3][2]),.ADD3_res(ADD3_res[3][2]));
	ADD3 a33(.a(CMP_ADD3_in1[3][3]),.b(CMP_ADD3_in2[3][3]),.c(CMP_ADD3_in3[3][3]),.ADD3_res(ADD3_res[3][3]));
	ADD3 a34(.a(CMP_ADD3_in1[3][4]),.b(CMP_ADD3_in2[3][4]),.c(CMP_ADD3_in3[3][4]),.ADD3_res(ADD3_res[3][4]));
	ADD3 a35(.a(CMP_ADD3_in1[3][5]),.b(CMP_ADD3_in2[3][5]),.c(CMP_ADD3_in3[3][5]),.ADD3_res(ADD3_res[3][5]));
	ADD3 a36(.a(CMP_ADD3_in1[3][6]),.b(CMP_ADD3_in2[3][6]),.c(CMP_ADD3_in3[3][6]),.ADD3_res(ADD3_res[3][6]));
	ADD3 a37(.a(CMP_ADD3_in1[3][7]),.b(CMP_ADD3_in2[3][7]),.c(CMP_ADD3_in3[3][7]),.ADD3_res(ADD3_res[3][7]));
//------------------------------------------------------------------------------------------------

	
	always@(*)begin
		
		NEXT_odata_valid = 0 ;
		NEXT_odata = odata;
		NEXT_shift2pre = 0;
		
		/*
		for(i=0; i< ROW_NUMS ; i=i+1)begin 
			NEXT_CUR[i] = CUR[i];
			NEXT_MID[i] = MID[i];
			NEXT_PRE[i] = PRE[i];
		end
		*/
		
		
	//----- UPSAMPLE 2X -----
		if(function_mode[1]==1 && !active_reg && !active_reg2)begin 			//NEXT SHIFT (AT BEGINING)
			for(i=0; i< ROW_NUMS-3 ; i=i+2)begin  								// i< ROW_NUMS-3: loop until row12(G)
				for(j=0; j< 8 ; j=j+1)begin     								// 8 items in a row (depth)
					NEXT_PRE[i+1][(j<<5) +:6'd32] = (CUR[i][(j<<5) +:6'd32] + CUR[i+2][(j<<5) +:6'd32])>>1;		// compute c , even row						
				end	
			end	
			NEXT_shift2pre = 1;
		end
		
		if (function_mode[1]==1 && active_reg)begin  							//NEXT NO SHIFT    				
			for(i=0; i< ROW_NUMS-3 ; i=i+2)begin  								// i< ROW_NUMS-3: loop until row12(G)
				for(j=0; j< 8 ; j=j+1)begin     						
					NEXT_CUR[i+1][(j<<5) +:6'd32] = (CUR[i][(j<<5)  +:6'd32] + CUR[i+2][(j<<5)  +:6'd32])>>1;		// compute c , even row							
				end
			end	
			for(i=0; i< ROW_NUMS-3 ; i=i+2)begin  						
					NEXT_odata[(i<<8 + j<<5 ) +:6'd32] = (PRE[i][(j<<5 ) +:6'd32] + CUR[i][(j<<5 ) +:6'd32])>>1; 		// compute a,d , even row		
			end		
		end
		
		if (function_mode[1]==1 && active_reg2)begin      						//NEXT SHIFT  
			for(i=1; i< ROW_NUMS-2 ; i=i+2)begin  								// compute x , odd row
				for(j=0; j< 8 ; j=j+1)begin			 
					NEXT_odata[(i<<8 + j<<5) +:6'd32] = (PRE[i][(j<<5)+:6'd32] + CUR[i][(j<<5) +:6'd32] + (PRE[i-1][j<<5]^PRE[i+1][j<<5]) + (CUR[i-1][j<<5]^CUR[i+1][j<<5]) )>>1;
				end
			end	
			
			for(i=0; i< ROW_NUMS ; i=i+1)begin  								//SHIFT 	
				for(j=0; j< 8 ; j=j+1)begin			 
					NEXT_PRE[i][(j<<5 )+:6'd32] = CUR[i][(j<<5) +:6'd32];	
				end
			end	
			
			NEXT_odata_valid = 1;
			NEXT_shift2pre = 1;
		end
	
		if(function_mode[1]==1 && shift2pre)begin
			NEXT_odata = {PRE[13],PRE[12],PRE[11],PRE[10],PRE[9],PRE[8],PRE[7],PRE[6],PRE[5],PRE[4],PRE[3],PRE[2],PRE[1],PRE[0]};
			NEXT_odata_valid = 1;
		end
		
		
	//-------------------------------------------------------------------------------	
	//----	DOWNSAMPLE 2*2 stride2 -------	
		
		
	
		if(function_mode[1]==0 && scale_factor==0 && active_reg)begin 	//NEXT  SHIFT	
			if(function_mode[0]==0)begin								// MaxPooling
				for(i=0; i< ROW_NUMS-3 ; i=i+4)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_PRE[i+1][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+2][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32] : CUR[i+2][j<<5 +:6'd32];
					end
				end
			end
			else begin													// AvgPooling
				for(i=0; i< ROW_NUMS-3 ; i=i+4)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_PRE[i+1][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32] + CUR[i+2][j<<5 +:6'd32])>>1;
					end
				end
			end
		end	
		
		if(function_mode[1]==0 && scale_factor==0 && active_reg)begin 	//NEXT NO SHIFT, compute r2			
			if(function_mode[0]==0)begin								// MaxPooling
				for(i=0; i< ROW_NUMS-3 ; i=i+4)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_CUR[i+1][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+2][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32] : CUR[i+2][j<<5 +:6'd32];
					end
				end
			end
			else begin													// AvgPooling
				for(i=0; i< ROW_NUMS-3 ; i=i+4)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_CUR[i+1][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32] + CUR[i+2][j<<5 +:6'd32])>>1;
					end
				end
			end
		end	
		
		
		if(function_mode[1]==0 && scale_factor==0 && active_reg2)begin			//downsamle 2*2, compute r3	
			if(function_mode[0]==0)begin
			/*									
				for(i=1; i<= ROW_NUMS-3 ; i=i+4)begin  	// MaxPooling
					for(j=0; j< 8 ; j=j+1)begin     	
						NEXT_odata[( {i[23:1],8'd0} + {j[26:0],5'd0} ) +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+1][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32] : CUR[i+1][j<<5 +:6'd32];
						//NEXT_odata_test[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+1][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32] : CUR[i+1][j<<5 +:6'd32];
					end
				end
				*/
				for(j=0; j< 8 ; j=j+1)begin     // MaxPooling	
					NEXT_odata[( {j[26:0],5'd0} ) +:6'd32] = (CUR[1][j<<5 +:6'd32]>PRE[1][j<<5 +:6'd32])? CUR[1][j<<5 +:6'd32] : PRE[1][j<<5 +:6'd32];
					NEXT_odata[( 32'd256 + {j[26:0],5'd0} ) +:6'd32] = (CUR[5][j<<5 +:6'd32]>PRE[5][j<<5 +:6'd32])? CUR[5][j<<5 +:6'd32] : PRE[5][j<<5 +:6'd32];
					NEXT_odata[( 32'd512 + {j[26:0],5'd0} ) +:6'd32] = (CUR[9][j<<5 +:6'd32]>PRE[9][j<<5 +:6'd32])? CUR[9][j<<5 +:6'd32] : PRE[9][j<<5 +:6'd32];
					NEXT_odata[( 32'd768 + {j[26:0],5'd0} ) +:6'd32] = (CUR[13][j<<5 +:6'd32]>PRE[13][j<<5 +:6'd32])? CUR[13][j<<5 +:6'd32] : PRE[13][j<<5 +:6'd32];
				end
				
			end
			else begin	
					/*			
				// AvgPooling
				for(i=0 ;i<= HROW_NUMS-3 ; i=i+4)begin  	
					for(j=0; j< 8 ; j=j+1)begin // (i>>1)<<8  + j<<5	
						NEXT_odata[(  {i[23:1],8'd0} + {j[26:0],5'd0} ) +:6'd32] = (CUR[i][j<<5 +:6'd32] + CUR[i+1][j<<5 +:6'd32])>>1;
						NEXT_odata_test[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32] + CUR[i+1][j<<5 +:6'd32])>>1;
					end
				end
				*/
				
				for(j=0; j< 8 ; j=j+1)begin     // AvgPooling
					NEXT_odata[( {j[26:0],5'd0} ) +:6'd32] = (CUR[1][j<<5 +:6'd32] + PRE[1][j<<5 +:6'd32])>>1;
					NEXT_odata[( 32'd256 + {j[26:0],5'd0} ) +:6'd32] = (CUR[5][j<<5 +:6'd32] + PRE[5][j<<5 +:6'd32])>>1;
					NEXT_odata[( 32'd512 + {j[26:0],5'd0} ) +:6'd32] = (CUR[9][j<<5 +:6'd32] + PRE[9][j<<5 +:6'd32])>>1;
					NEXT_odata[( 32'd768 + {j[26:0],5'd0} ) +:6'd32] = (CUR[13][j<<5 +:6'd32] + PRE[13][j<<5 +:6'd32])>>1;
				end
				
			end	
			
			NEXT_odata_valid = 1;
		end
		/*
	//---------------------------------------------------------------------------
	//----	DOWNSAMPLE 3*3 stride2 -------------
		if(function_mode[1]==0 && scale_factor==1 && !active_reg)begin 		//NEXT  SHIFT, compute col
					
			if(function_mode[0]==0)begin									// MaxPooling
				for(i=0; i< ROW_NUMS-3 ; i=i+4)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_MID[i+1][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+2][j<<5 +:6'd32])? (CUR[i][j<<5 +:6'd32]>CUR[i+4][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32]: CUR[i+4][j<<5 +:6'd32] : (CUR[i+2][j<<5 +:6'd32]>CUR[i+4][j<<5 +:6'd32])? CUR[i+2][j<<5 +:6'd32]: CUR[i+4][j<<5 +:6'd32];
					end
					NEXT_PRE[i] = MID[i];
				end
			end
			else begin														// AvgPooling
				for(i=0; i< ROW_NUMS-3 ; i=i+4)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_MID[i+1][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32] + CUR[i+2][j<<5 +:6'd32] +CUR[i+4][j<<5 +:6'd32])>>4 + (CUR[i][j<<5 +:6'd32] + CUR[i+2][j<<5 +:6'd32] +CUR[i+4][j<<5 +:6'd32])>>5 + (CUR[i][j<<5 +:6'd32] + CUR[i+2][j<<5 +:6'd32] +CUR[i+4][j<<5 +:6'd32])>>6; // * 0.109   
					end
					NEXT_PRE[i] = MID[i];
				end
			end
		end
		
		if(function_mode[1]==0 && scale_factor==1 && active_reg)begin 		//NEXT NO SHIFT, compute col
					
			if(function_mode[0]==0)begin									// MaxPooling
				for(i=0; i< ROW_NUMS-3 ; i=i+4)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_CUR[i+1][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+2][j<<5 +:6'd32])? (CUR[i][j<<5 +:6'd32]>CUR[i+4][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32]: CUR[i+4][j<<5 +:6'd32] : (CUR[i+2][j<<5 +:6'd32]>CUR[i+4][j<<5 +:6'd32])? CUR[i+2][j<<5 +:6'd32]: CUR[i+4][j<<5 +:6'd32];
					end
				end
			end
			else begin														// AvgPooling
				for(i=0; i< ROW_NUMS-3 ; i=i+4)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_CUR[i+1][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32] + CUR[i+2][j<<5 +:6'd32] +CUR[i+4][j<<5 +:6'd32])>>4 + (CUR[i][j<<5 +:6'd32] + CUR[i+2][j<<5 +:6'd32] +CUR[i+4][j<<5 +:6'd32])>>5 + (CUR[i][j<<5 +:6'd32] + CUR[i+2][j<<5 +:6'd32] +CUR[i+4][j<<5 +:6'd32])>>6; // * 0.109  (1/9) 
					end
				end
			end
			
		end
		
		if(function_mode[1]==0 && scale_factor==1 && active_reg2)begin			//downsamle 3*3, compute row
			
			if(function_mode[0]==0)begin	
										// MaxPooling
				//for(i=0 ; i< HALF_ROWS ; i=i+2)begin  	
				//	for(j=0; j< 8 ; j=j+1)begin     							
				//		NEXT_odata[({i[23:1],8'd0} + {j[26:0],5'd0}) +:6'd32] = (PRE[i][j<<5 +:6'd32]>CUR[i][j<<5 +:6'd32])? (PRE[i][j<<5 +:6'd32]>MID[i][j<<5 +:6'd32])? PRE[i][j<<5 +:6'd32]: MID[i][j<<5 +:6'd32] : (CUR[i][j<<5 +:6'd32]>MID[i][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32]: MID[i][j<<5 +:6'd32];
				//	end
				//	
				//	NEXT_MID[i] = CUR[i];										//NEXT SHIFT				
				//	NEXT_PRE[i] = MID[i];
				//end
				
				for(j=0; j< 8 ; j=j+1)begin     							
					NEXT_odata[ {j[26:0],5'd0}  +:6'd32] 		  = (PRE[1][j<<5 +:6'd32]>CUR[1][j<<5 +:6'd32])? (PRE[1][j<<5 +:6'd32]>MID[1][j<<5 +:6'd32])? PRE[1][j<<5 +:6'd32]: MID[1][j<<5 +:6'd32] : (CUR[1][j<<5 +:6'd32]>MID[1][j<<5 +:6'd32])? CUR[1][j<<5 +:6'd32]: MID[1][j<<5 +:6'd32];
					NEXT_odata[ 32'd256 +{j[26:0],5'd0}  +:6'd32] = (PRE[5][j<<5 +:6'd32]>CUR[5][j<<5 +:6'd32])? (PRE[5][j<<5 +:6'd32]>MID[5][j<<5 +:6'd32])? PRE[5][j<<5 +:6'd32]: MID[5][j<<5 +:6'd32] : (CUR[5][j<<5 +:6'd32]>MID[5][j<<5 +:6'd32])? CUR[5][j<<5 +:6'd32]: MID[5][j<<5 +:6'd32];
					NEXT_odata[ 32'd512 +{j[26:0],5'd0}  +:6'd32] = (PRE[1][j<<5 +:6'd32]>CUR[1][j<<5 +:6'd32])? (PRE[9][j<<5 +:6'd32]>MID[9][j<<5 +:6'd32])? PRE[9][j<<5 +:6'd32]: MID[9][j<<5 +:6'd32] : (CUR[9][j<<5 +:6'd32]>MID[9][j<<5 +:6'd32])? CUR[9][j<<5 +:6'd32]: MID[9][j<<5 +:6'd32];
					NEXT_odata[ 32'd768 +{j[26:0],5'd0}  +:6'd32] = (PRE[1][j<<5 +:6'd32]>CUR[1][j<<5 +:6'd32])? (PRE[13][j<<5 +:6'd32]>MID[13][j<<5 +:6'd32])? PRE[13][j<<5 +:6'd32]: MID[13][j<<5 +:6'd32] : (CUR[13][j<<5 +:6'd32]>MID[13][j<<5 +:6'd32])? CUR[13][j<<5 +:6'd32]: MID[13][j<<5 +:6'd32];
				end
				
				
				
			end
			else begin	
			
			// AvgPooling
				//for(i=0; i< HALF_ROWS ; i=i+2)begin  	
				//	for(j=0; j< 8 ; j=j+1)begin     							// 8 items in a row (depth)
				//		NEXT_odata[({i[23:1],8'd0} + {j[26:0],5'd0}) +:6'd32] = CUR[i][j<<5 +:6'd32] + PRE[i][j<<5 +:6'd32] + MID[i][j<<5 +:6'd32] ;
				//	end
				//	
				//	NEXT_MID[i] = CUR[i];										//NEXT SHIFT
				//	NEXT_PRE[i] = MID[i];
				//end
				
				for(j=0; j< 8 ; j=j+1)begin     							// AvgPooling
					NEXT_odata[ {j[26:0],5'd0}  +:6'd32]  		   = CUR[1][j<<5 +:6'd32] + PRE[1][j<<5 +:6'd32] + MID[1][j<<5 +:6'd32] ;
					NEXT_odata[ 32'd256 +{j[26:0],5'd0}  +:6'd32]  = CUR[5][j<<5 +:6'd32] + PRE[5][j<<5 +:6'd32] + MID[5][j<<5 +:6'd32] ;
					NEXT_odata[ 32'd512 +{j[26:0],5'd0}  +:6'd32]  = CUR[9][j<<5 +:6'd32] + PRE[9][j<<5 +:6'd32] + MID[9][j<<5 +:6'd32] ;
					NEXT_odata[ 32'd768 +{j[26:0],5'd0}  +:6'd32]  = CUR[13][j<<5 +:6'd32] + PRE[13][j<<5 +:6'd32] + MID[13][j<<5 +:6'd32] ;
				end
				
				
			end
			
			NEXT_MID[1] = CUR[1];										//NEXT SHIFT				
			NEXT_PRE[1] = MID[1];
			NEXT_MID[5] = CUR[5];													
			NEXT_PRE[5] = MID[5];
			NEXT_MID[9] = CUR[9];													
			NEXT_PRE[9] = MID[9];
			NEXT_MID[13] = CUR[13];													
			NEXT_PRE[13] = MID[13];
			
			NEXT_odata_valid = 1;
		end
	*/
	end
	
endmodule
	
	