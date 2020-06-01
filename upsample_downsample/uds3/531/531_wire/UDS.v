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
	
	reg [8*32-1:0]NEXT_PRE[0:HALF_ROWS-1];
	reg [8*32-1:0]NEXT_MID[0:HALF_ROWS-1];
	reg [8*32-1:0]NEXT_CUR[0:HALF_ROWS-1];
	reg [2*(A-8)*32-1:0]NEXT_odata;
	reg [8*32-1:0]NEXT_odata_test[0:ROW_NUMS-1];
	reg NEXT_odata_valid;
	
	reg [8*32-1:0]PRE[0:HALF_ROWS-1];
	reg [8*32-1:0]MID[0:HALF_ROWS-1];
	reg [8*32-1:0]CUR[0:HALF_ROWS-1];
	
	//reg idata_valid_reg,idata_valid_reg2;
	reg active_reg,active_reg2;
	reg shift2pre,NEXT_shift2pre;
	
	wire [31:0]ADD2_COL[0:6][0:7];
	wire [31:0]ADD2_ROW[0:7][0:7];
	wire [31:0]ADD3_COL[0:2][0:7];
	wire [31:0]ADD3_ROW[0:3][0:7];
	
	/*
	assign ADD2_COL[0][0] = ( CUR[0][0 +:6'd32] + CUR[1][0 +:6'd32] )>>2 ; 
	assign ADD2_COL[0][1] = ( CUR[0][32 +:6'd32] + CUR[1][32 +:6'd32] )>>2 ; 
	assign ADD2_COL[0][7] = ( CUR[0][224 +:6'd32] + CUR[1][224 +:6'd32] )>>2 ; 
	*/
	assign ADD2_COL[0][0] = CUR[0][8'd31 : 8'd0] + CUR[1][8'd31 : 8'd0]; 
	assign ADD2_COL[0][1] = CUR[0][8'd63 : 8'd32] + CUR[1][8'd63 : 8'd32]; 
	assign ADD2_COL[0][2] = CUR[0][8'd95 : 8'd64] + CUR[1][8'd95 : 8'd64]; 
	assign ADD2_COL[0][3] = CUR[0][8'd127 : 8'd96] + CUR[1][8'd127 : 8'd96]; 
	assign ADD2_COL[0][4] = CUR[0][8'd159 : 8'd128] + CUR[1][8'd159 : 8'd128]; 
	assign ADD2_COL[0][5] = CUR[0][8'd191 : 8'd160] + CUR[1][8'd191 : 8'd160]; 
	assign ADD2_COL[0][6] = CUR[0][8'd223 : 8'd192] + CUR[1][8'd223 : 8'd192]; 
	assign ADD2_COL[0][7] = CUR[0][8'd255 : 8'd224] + CUR[1][8'd255 : 8'd224]; 
	assign ADD2_COL[1][0] = CUR[1][8'd31 : 8'd0] + CUR[2][8'd31 : 8'd0]; 
	assign ADD2_COL[1][1] = CUR[1][8'd63 : 8'd32] + CUR[2][8'd63 : 8'd32]; 
	assign ADD2_COL[1][2] = CUR[1][8'd95 : 8'd64] + CUR[2][8'd95 : 8'd64]; 
	assign ADD2_COL[1][3] = CUR[1][8'd127 : 8'd96] + CUR[2][8'd127 : 8'd96]; 
	assign ADD2_COL[1][4] = CUR[1][8'd159 : 8'd128] + CUR[2][8'd159 : 8'd128]; 
	assign ADD2_COL[1][5] = CUR[1][8'd191 : 8'd160] + CUR[2][8'd191 : 8'd160]; 
	assign ADD2_COL[1][6] = CUR[1][8'd223 : 8'd192] + CUR[2][8'd223 : 8'd192]; 
	assign ADD2_COL[1][7] = CUR[1][8'd255 : 8'd224] + CUR[2][8'd255 : 8'd224]; 
	assign ADD2_COL[2][0] = CUR[2][8'd31 : 8'd0] + CUR[3][8'd31 : 8'd0]; 
	assign ADD2_COL[2][1] = CUR[2][8'd63 : 8'd32] + CUR[3][8'd63 : 8'd32]; 
	assign ADD2_COL[2][2] = CUR[2][8'd95 : 8'd64] + CUR[3][8'd95 : 8'd64]; 
	assign ADD2_COL[2][3] = CUR[2][8'd127 : 8'd96] + CUR[3][8'd127 : 8'd96]; 
	assign ADD2_COL[2][4] = CUR[2][8'd159 : 8'd128] + CUR[3][8'd159 : 8'd128]; 
	assign ADD2_COL[2][5] = CUR[2][8'd191 : 8'd160] + CUR[3][8'd191 : 8'd160]; 
	assign ADD2_COL[2][6] = CUR[2][8'd223 : 8'd192] + CUR[3][8'd223 : 8'd192]; 
	assign ADD2_COL[2][7] = CUR[2][8'd255 : 8'd224] + CUR[3][8'd255 : 8'd224]; 
	assign ADD2_COL[3][0] = CUR[3][8'd31 : 8'd0] + CUR[4][8'd31 : 8'd0]; 
	assign ADD2_COL[3][1] = CUR[3][8'd63 : 8'd32] + CUR[4][8'd63 : 8'd32]; 
	assign ADD2_COL[3][2] = CUR[3][8'd95 : 8'd64] + CUR[4][8'd95 : 8'd64]; 
	assign ADD2_COL[3][3] = CUR[3][8'd127 : 8'd96] + CUR[4][8'd127 : 8'd96]; 
	assign ADD2_COL[3][4] = CUR[3][8'd159 : 8'd128] + CUR[4][8'd159 : 8'd128]; 
	assign ADD2_COL[3][5] = CUR[3][8'd191 : 8'd160] + CUR[4][8'd191 : 8'd160]; 
	assign ADD2_COL[3][6] = CUR[3][8'd223 : 8'd192] + CUR[4][8'd223 : 8'd192]; 
	assign ADD2_COL[3][7] = CUR[3][8'd255 : 8'd224] + CUR[4][8'd255 : 8'd224]; 
	assign ADD2_COL[4][0] = CUR[4][8'd31 : 8'd0] + CUR[5][8'd31 : 8'd0]; 
	assign ADD2_COL[4][1] = CUR[4][8'd63 : 8'd32] + CUR[5][8'd63 : 8'd32]; 
	assign ADD2_COL[4][2] = CUR[4][8'd95 : 8'd64] + CUR[5][8'd95 : 8'd64]; 
	assign ADD2_COL[4][3] = CUR[4][8'd127 : 8'd96] + CUR[5][8'd127 : 8'd96]; 
	assign ADD2_COL[4][4] = CUR[4][8'd159 : 8'd128] + CUR[5][8'd159 : 8'd128]; 
	assign ADD2_COL[4][5] = CUR[4][8'd191 : 8'd160] + CUR[5][8'd191 : 8'd160]; 
	assign ADD2_COL[4][6] = CUR[4][8'd223 : 8'd192] + CUR[5][8'd223 : 8'd192]; 
	assign ADD2_COL[4][7] = CUR[4][8'd255 : 8'd224] + CUR[5][8'd255 : 8'd224]; 
	assign ADD2_COL[5][0] = CUR[5][8'd31 : 8'd0] + CUR[6][8'd31 : 8'd0]; 
	assign ADD2_COL[5][1] = CUR[5][8'd63 : 8'd32] + CUR[6][8'd63 : 8'd32]; 
	assign ADD2_COL[5][2] = CUR[5][8'd95 : 8'd64] + CUR[6][8'd95 : 8'd64]; 
	assign ADD2_COL[5][3] = CUR[5][8'd127 : 8'd96] + CUR[6][8'd127 : 8'd96]; 
	assign ADD2_COL[5][4] = CUR[5][8'd159 : 8'd128] + CUR[6][8'd159 : 8'd128]; 
	assign ADD2_COL[5][5] = CUR[5][8'd191 : 8'd160] + CUR[6][8'd191 : 8'd160]; 
	assign ADD2_COL[5][6] = CUR[5][8'd223 : 8'd192] + CUR[6][8'd223 : 8'd192]; 
	assign ADD2_COL[5][7] = CUR[5][8'd255 : 8'd224] + CUR[6][8'd255 : 8'd224]; 
	assign ADD2_COL[6][0] = CUR[6][8'd31 : 8'd0] + CUR[7][8'd31 : 8'd0]; 
	assign ADD2_COL[6][1] = CUR[6][8'd63 : 8'd32] + CUR[7][8'd63 : 8'd32]; 
	assign ADD2_COL[6][2] = CUR[6][8'd95 : 8'd64] + CUR[7][8'd95 : 8'd64]; 
	assign ADD2_COL[6][3] = CUR[6][8'd127 : 8'd96] + CUR[7][8'd127 : 8'd96]; 
	assign ADD2_COL[6][4] = CUR[6][8'd159 : 8'd128] + CUR[7][8'd159 : 8'd128]; 
	assign ADD2_COL[6][5] = CUR[6][8'd191 : 8'd160] + CUR[7][8'd191 : 8'd160]; 
	assign ADD2_COL[6][6] = CUR[6][8'd223 : 8'd192] + CUR[7][8'd223 : 8'd192]; 
	assign ADD2_COL[6][7] = CUR[6][8'd255 : 8'd224] + CUR[7][8'd255 : 8'd224]; 
	
//-------------------------------------------------------------------------------------------
	assign ADD2_ROW[0][0] =  CUR[0][8'd31 : 8'd0] + PRE[0][8'd31 : 8'd0]; 
	assign ADD2_ROW[0][1] =  CUR[0][8'd63 : 8'd32] + PRE[0][8'd63 : 8'd32]; 
	assign ADD2_ROW[0][2] =  CUR[0][8'd95 : 8'd64] + PRE[0][8'd95 : 8'd64]; 
	assign ADD2_ROW[0][3] =  CUR[0][8'd127 : 8'd96] + PRE[0][8'd127 : 8'd96]; 
	assign ADD2_ROW[0][4] =  CUR[0][8'd159 : 8'd128] + PRE[0][8'd159 : 8'd128]; 
	assign ADD2_ROW[0][5] =  CUR[0][8'd191 : 8'd160] + PRE[0][8'd191 : 8'd160]; 
	assign ADD2_ROW[0][6] =  CUR[0][8'd223 : 8'd192] + PRE[0][8'd223 : 8'd192]; 
	assign ADD2_ROW[0][7] =  CUR[0][8'd255 : 8'd224] + PRE[0][8'd255 : 8'd224]; 
	assign ADD2_ROW[1][0] =  CUR[1][8'd31 : 8'd0] + PRE[1][8'd31 : 8'd0]; 
	assign ADD2_ROW[1][1] =  CUR[1][8'd63 : 8'd32] + PRE[1][8'd63 : 8'd32]; 
	assign ADD2_ROW[1][2] =  CUR[1][8'd95 : 8'd64] + PRE[1][8'd95 : 8'd64]; 
	assign ADD2_ROW[1][3] =  CUR[1][8'd127 : 8'd96] + PRE[1][8'd127 : 8'd96]; 
	assign ADD2_ROW[1][4] =  CUR[1][8'd159 : 8'd128] + PRE[1][8'd159 : 8'd128]; 
	assign ADD2_ROW[1][5] =  CUR[1][8'd191 : 8'd160] + PRE[1][8'd191 : 8'd160]; 
	assign ADD2_ROW[1][6] =  CUR[1][8'd223 : 8'd192] + PRE[1][8'd223 : 8'd192]; 
	assign ADD2_ROW[1][7] =  CUR[1][8'd255 : 8'd224] + PRE[1][8'd255 : 8'd224]; 
	assign ADD2_ROW[2][0] =  CUR[2][8'd31 : 8'd0] + PRE[2][8'd31 : 8'd0]; 
	assign ADD2_ROW[2][1] =  CUR[2][8'd63 : 8'd32] + PRE[2][8'd63 : 8'd32]; 
	assign ADD2_ROW[2][2] =  CUR[2][8'd95 : 8'd64] + PRE[2][8'd95 : 8'd64]; 
	assign ADD2_ROW[2][3] =  CUR[2][8'd127 : 8'd96] + PRE[2][8'd127 : 8'd96]; 
	assign ADD2_ROW[2][4] =  CUR[2][8'd159 : 8'd128] + PRE[2][8'd159 : 8'd128]; 
	assign ADD2_ROW[2][5] =  CUR[2][8'd191 : 8'd160] + PRE[2][8'd191 : 8'd160]; 
	assign ADD2_ROW[2][6] =  CUR[2][8'd223 : 8'd192] + PRE[2][8'd223 : 8'd192]; 
	assign ADD2_ROW[2][7] =  CUR[2][8'd255 : 8'd224] + PRE[2][8'd255 : 8'd224]; 
	assign ADD2_ROW[3][0] =  CUR[3][8'd31 : 8'd0] + PRE[3][8'd31 : 8'd0]; 
	assign ADD2_ROW[3][1] =  CUR[3][8'd63 : 8'd32] + PRE[3][8'd63 : 8'd32]; 
	assign ADD2_ROW[3][2] =  CUR[3][8'd95 : 8'd64] + PRE[3][8'd95 : 8'd64]; 
	assign ADD2_ROW[3][3] =  CUR[3][8'd127 : 8'd96] + PRE[3][8'd127 : 8'd96]; 
	assign ADD2_ROW[3][4] =  CUR[3][8'd159 : 8'd128] + PRE[3][8'd159 : 8'd128]; 
	assign ADD2_ROW[3][5] =  CUR[3][8'd191 : 8'd160] + PRE[3][8'd191 : 8'd160]; 
	assign ADD2_ROW[3][6] =  CUR[3][8'd223 : 8'd192] + PRE[3][8'd223 : 8'd192]; 
	assign ADD2_ROW[3][7] =  CUR[3][8'd255 : 8'd224] + PRE[3][8'd255 : 8'd224]; 
	assign ADD2_ROW[4][0] =  CUR[4][8'd31 : 8'd0] + PRE[4][8'd31 : 8'd0]; 
	assign ADD2_ROW[4][1] =  CUR[4][8'd63 : 8'd32] + PRE[4][8'd63 : 8'd32]; 
	assign ADD2_ROW[4][2] =  CUR[4][8'd95 : 8'd64] + PRE[4][8'd95 : 8'd64]; 
	assign ADD2_ROW[4][3] =  CUR[4][8'd127 : 8'd96] + PRE[4][8'd127 : 8'd96]; 
	assign ADD2_ROW[4][4] =  CUR[4][8'd159 : 8'd128] + PRE[4][8'd159 : 8'd128]; 
	assign ADD2_ROW[4][5] =  CUR[4][8'd191 : 8'd160] + PRE[4][8'd191 : 8'd160]; 
	assign ADD2_ROW[4][6] =  CUR[4][8'd223 : 8'd192] + PRE[4][8'd223 : 8'd192]; 
	assign ADD2_ROW[4][7] =  CUR[4][8'd255 : 8'd224] + PRE[4][8'd255 : 8'd224]; 
	assign ADD2_ROW[5][0] =  CUR[5][8'd31 : 8'd0] + PRE[5][8'd31 : 8'd0]; 
	assign ADD2_ROW[5][1] =  CUR[5][8'd63 : 8'd32] + PRE[5][8'd63 : 8'd32]; 
	assign ADD2_ROW[5][2] =  CUR[5][8'd95 : 8'd64] + PRE[5][8'd95 : 8'd64]; 
	assign ADD2_ROW[5][3] =  CUR[5][8'd127 : 8'd96] + PRE[5][8'd127 : 8'd96]; 
	assign ADD2_ROW[5][4] =  CUR[5][8'd159 : 8'd128] + PRE[5][8'd159 : 8'd128]; 
	assign ADD2_ROW[5][5] =  CUR[5][8'd191 : 8'd160] + PRE[5][8'd191 : 8'd160]; 
	assign ADD2_ROW[5][6] =  CUR[5][8'd223 : 8'd192] + PRE[5][8'd223 : 8'd192]; 
	assign ADD2_ROW[5][7] =  CUR[5][8'd255 : 8'd224] + PRE[5][8'd255 : 8'd224]; 
	assign ADD2_ROW[6][0] =  CUR[6][8'd31 : 8'd0] + PRE[6][8'd31 : 8'd0]; 
	assign ADD2_ROW[6][1] =  CUR[6][8'd63 : 8'd32] + PRE[6][8'd63 : 8'd32]; 
	assign ADD2_ROW[6][2] =  CUR[6][8'd95 : 8'd64] + PRE[6][8'd95 : 8'd64]; 
	assign ADD2_ROW[6][3] =  CUR[6][8'd127 : 8'd96] + PRE[6][8'd127 : 8'd96]; 
	assign ADD2_ROW[6][4] =  CUR[6][8'd159 : 8'd128] + PRE[6][8'd159 : 8'd128]; 
	assign ADD2_ROW[6][5] =  CUR[6][8'd191 : 8'd160] + PRE[6][8'd191 : 8'd160]; 
	assign ADD2_ROW[6][6] =  CUR[6][8'd223 : 8'd192] + PRE[6][8'd223 : 8'd192]; 
	assign ADD2_ROW[6][7] =  CUR[6][8'd255 : 8'd224] + PRE[6][8'd255 : 8'd224]; 
	assign ADD2_ROW[7][0] =  CUR[7][8'd31 : 8'd0] + PRE[7][8'd31 : 8'd0]; 
	assign ADD2_ROW[7][1] =  CUR[7][8'd63 : 8'd32] + PRE[7][8'd63 : 8'd32]; 
	assign ADD2_ROW[7][2] =  CUR[7][8'd95 : 8'd64] + PRE[7][8'd95 : 8'd64]; 
	assign ADD2_ROW[7][3] =  CUR[7][8'd127 : 8'd96] + PRE[7][8'd127 : 8'd96]; 
	assign ADD2_ROW[7][4] =  CUR[7][8'd159 : 8'd128] + PRE[7][8'd159 : 8'd128]; 
	assign ADD2_ROW[7][5] =  CUR[7][8'd191 : 8'd160] + PRE[7][8'd191 : 8'd160]; 
	assign ADD2_ROW[7][6] =  CUR[7][8'd223 : 8'd192] + PRE[7][8'd223 : 8'd192]; 
	assign ADD2_ROW[7][7] =  CUR[7][8'd255 : 8'd224] + PRE[7][8'd255 : 8'd224]; 
	
//-----------------------------------------------------------------------------------------------
	assign ADD3_COL[0][0] = CUR[0][8'd31 : 8'd0] + CUR[1][8'd31 : 8'd0] + CUR[2][8'd31 : 8'd0] ; 
	assign ADD3_COL[0][1] = CUR[0][8'd63 : 8'd32] + CUR[1][8'd63 : 8'd32] + CUR[2][8'd63 : 8'd32] ; 
	assign ADD3_COL[0][2] = CUR[0][8'd95 : 8'd64] + CUR[1][8'd95 : 8'd64] + CUR[2][8'd95 : 8'd64] ; 
	assign ADD3_COL[0][3] = CUR[0][8'd127 : 8'd96] + CUR[1][8'd127 : 8'd96] + CUR[2][8'd127 : 8'd96] ; 
	assign ADD3_COL[0][4] = CUR[0][8'd159 : 8'd128] + CUR[1][8'd159 : 8'd128] + CUR[2][8'd159 : 8'd128] ; 
	assign ADD3_COL[0][5] = CUR[0][8'd191 : 8'd160] + CUR[1][8'd191 : 8'd160] + CUR[2][8'd191 : 8'd160] ; 
	assign ADD3_COL[0][6] = CUR[0][8'd223 : 8'd192] + CUR[1][8'd223 : 8'd192] + CUR[2][8'd223 : 8'd192] ; 
	assign ADD3_COL[0][7] = CUR[0][8'd255 : 8'd224] + CUR[1][8'd255 : 8'd224] + CUR[2][8'd255 : 8'd224] ; 
	assign ADD3_COL[1][0] = CUR[2][8'd31 : 8'd0] + CUR[3][8'd31 : 8'd0] + CUR[4][8'd31 : 8'd0] ; 
	assign ADD3_COL[1][1] = CUR[2][8'd63 : 8'd32] + CUR[3][8'd63 : 8'd32] + CUR[4][8'd63 : 8'd32] ; 
	assign ADD3_COL[1][2] = CUR[2][8'd95 : 8'd64] + CUR[3][8'd95 : 8'd64] + CUR[4][8'd95 : 8'd64] ; 
	assign ADD3_COL[1][3] = CUR[2][8'd127 : 8'd96] + CUR[3][8'd127 : 8'd96] + CUR[4][8'd127 : 8'd96] ; 
	assign ADD3_COL[1][4] = CUR[2][8'd159 : 8'd128] + CUR[3][8'd159 : 8'd128] + CUR[4][8'd159 : 8'd128] ; 
	assign ADD3_COL[1][5] = CUR[2][8'd191 : 8'd160] + CUR[3][8'd191 : 8'd160] + CUR[4][8'd191 : 8'd160] ; 
	assign ADD3_COL[1][6] = CUR[2][8'd223 : 8'd192] + CUR[3][8'd223 : 8'd192] + CUR[4][8'd223 : 8'd192] ; 
	assign ADD3_COL[1][7] = CUR[2][8'd255 : 8'd224] + CUR[3][8'd255 : 8'd224] + CUR[4][8'd255 : 8'd224] ; 
	assign ADD3_COL[2][0] = CUR[4][8'd31 : 8'd0] + CUR[5][8'd31 : 8'd0] + CUR[6][8'd31 : 8'd0] ; 
	assign ADD3_COL[2][1] = CUR[4][8'd63 : 8'd32] + CUR[5][8'd63 : 8'd32] + CUR[6][8'd63 : 8'd32] ; 
	assign ADD3_COL[2][2] = CUR[4][8'd95 : 8'd64] + CUR[5][8'd95 : 8'd64] + CUR[6][8'd95 : 8'd64] ; 
	assign ADD3_COL[2][3] = CUR[4][8'd127 : 8'd96] + CUR[5][8'd127 : 8'd96] + CUR[6][8'd127 : 8'd96] ; 
	assign ADD3_COL[2][4] = CUR[4][8'd159 : 8'd128] + CUR[5][8'd159 : 8'd128] + CUR[6][8'd159 : 8'd128] ; 
	assign ADD3_COL[2][5] = CUR[4][8'd191 : 8'd160] + CUR[5][8'd191 : 8'd160] + CUR[6][8'd191 : 8'd160] ; 
	assign ADD3_COL[2][6] = CUR[4][8'd223 : 8'd192] + CUR[5][8'd223 : 8'd192] + CUR[6][8'd223 : 8'd192] ; 
	assign ADD3_COL[2][7] = CUR[4][8'd255 : 8'd224] + CUR[5][8'd255 : 8'd224] + CUR[6][8'd255 : 8'd224] ; 
//------------------------------------------------------------------------------------------------------------
	assign ADD3_ROW[0][0] = CUR[0][8'd31 : 8'd0] + MID[0][8'd31 : 8'd0] + PRE[0][8'd31: 8'd0] ;
	assign ADD3_ROW[0][1] = CUR[0][8'd63 : 8'd32] + MID[0][8'd63 : 8'd32] + PRE[0][8'd63: 8'd32] ;
	assign ADD3_ROW[0][2] = CUR[0][8'd95 : 8'd64] + MID[0][8'd95 : 8'd64] + PRE[0][8'd95: 8'd64] ;
	assign ADD3_ROW[0][3] = CUR[0][8'd127 : 8'd96] + MID[0][8'd127 : 8'd96] + PRE[0][8'd127: 8'd96] ;
	assign ADD3_ROW[0][4] = CUR[0][8'd159 : 8'd128] + MID[0][8'd159 : 8'd128] + PRE[0][8'd159: 8'd128] ;
	assign ADD3_ROW[0][5] = CUR[0][8'd191 : 8'd160] + MID[0][8'd191 : 8'd160] + PRE[0][8'd191: 8'd160] ;
	assign ADD3_ROW[0][6] = CUR[0][8'd223 : 8'd192] + MID[0][8'd223 : 8'd192] + PRE[0][8'd223: 8'd192] ;
	assign ADD3_ROW[0][7] = CUR[0][8'd255 : 8'd224] + MID[0][8'd255 : 8'd224] + PRE[0][8'd255: 8'd224] ;
	assign ADD3_ROW[1][0] = CUR[1][8'd31 : 8'd0] + MID[1][8'd31 : 8'd0] + PRE[1][8'd31: 8'd0] ;
	assign ADD3_ROW[1][1] = CUR[1][8'd63 : 8'd32] + MID[1][8'd63 : 8'd32] + PRE[1][8'd63: 8'd32] ;
	assign ADD3_ROW[1][2] = CUR[1][8'd95 : 8'd64] + MID[1][8'd95 : 8'd64] + PRE[1][8'd95: 8'd64] ;
	assign ADD3_ROW[1][3] = CUR[1][8'd127 : 8'd96] + MID[1][8'd127 : 8'd96] + PRE[1][8'd127: 8'd96] ;
	assign ADD3_ROW[1][4] = CUR[1][8'd159 : 8'd128] + MID[1][8'd159 : 8'd128] + PRE[1][8'd159: 8'd128] ;
	assign ADD3_ROW[1][5] = CUR[1][8'd191 : 8'd160] + MID[1][8'd191 : 8'd160] + PRE[1][8'd191: 8'd160] ;
	assign ADD3_ROW[1][6] = CUR[1][8'd223 : 8'd192] + MID[1][8'd223 : 8'd192] + PRE[1][8'd223: 8'd192] ;
	assign ADD3_ROW[1][7] = CUR[1][8'd255 : 8'd224] + MID[1][8'd255 : 8'd224] + PRE[1][8'd255: 8'd224] ;
	assign ADD3_ROW[2][0] = CUR[2][8'd31 : 8'd0] + MID[2][8'd31 : 8'd0] + PRE[2][8'd31: 8'd0] ;
	assign ADD3_ROW[2][1] = CUR[2][8'd63 : 8'd32] + MID[2][8'd63 : 8'd32] + PRE[2][8'd63: 8'd32] ;
	assign ADD3_ROW[2][2] = CUR[2][8'd95 : 8'd64] + MID[2][8'd95 : 8'd64] + PRE[2][8'd95: 8'd64] ;
	assign ADD3_ROW[2][3] = CUR[2][8'd127 : 8'd96] + MID[2][8'd127 : 8'd96] + PRE[2][8'd127: 8'd96] ;
	assign ADD3_ROW[2][4] = CUR[2][8'd159 : 8'd128] + MID[2][8'd159 : 8'd128] + PRE[2][8'd159: 8'd128] ;
	assign ADD3_ROW[2][5] = CUR[2][8'd191 : 8'd160] + MID[2][8'd191 : 8'd160] + PRE[2][8'd191: 8'd160] ;
	assign ADD3_ROW[2][6] = CUR[2][8'd223 : 8'd192] + MID[2][8'd223 : 8'd192] + PRE[2][8'd223: 8'd192] ;
	assign ADD3_ROW[2][7] = CUR[2][8'd255 : 8'd224] + MID[2][8'd255 : 8'd224] + PRE[2][8'd255: 8'd224] ;
	assign ADD3_ROW[3][0] = CUR[3][8'd31 : 8'd0] + MID[3][8'd31 : 8'd0] + PRE[3][8'd31: 8'd0] ;
	assign ADD3_ROW[3][1] = CUR[3][8'd63 : 8'd32] + MID[3][8'd63 : 8'd32] + PRE[3][8'd63: 8'd32] ;
	assign ADD3_ROW[3][2] = CUR[3][8'd95 : 8'd64] + MID[3][8'd95 : 8'd64] + PRE[3][8'd95: 8'd64] ;
	assign ADD3_ROW[3][3] = CUR[3][8'd127 : 8'd96] + MID[3][8'd127 : 8'd96] + PRE[3][8'd127: 8'd96] ;
	assign ADD3_ROW[3][4] = CUR[3][8'd159 : 8'd128] + MID[3][8'd159 : 8'd128] + PRE[3][8'd159: 8'd128] ;
	assign ADD3_ROW[3][5] = CUR[3][8'd191 : 8'd160] + MID[3][8'd191 : 8'd160] + PRE[3][8'd191: 8'd160] ;
	assign ADD3_ROW[3][6] = CUR[3][8'd223 : 8'd192] + MID[3][8'd223 : 8'd192] + PRE[3][8'd223: 8'd192] ;
	assign ADD3_ROW[3][7] = CUR[3][8'd255 : 8'd224] + MID[3][8'd255 : 8'd224] + PRE[3][8'd255: 8'd224] ;
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
			for(i=0; i< HALF_ROWS ; i=i+1)begin
				CUR[i] <= 0;
				MID[i] <= 0;
				PRE[i] <= 0;
			end
		end
		else begin
		
			for(i=0; i< HALF_ROWS ; i=i+1)begin 
				MID[i] <= NEXT_MID[i];
				PRE[i] <= NEXT_PRE[i];
			end
			
			if(!active_reg && idata_valid)begin																//DOWNSAMPLE
				for(i=0; i< HALF_ROWS ; i=i+1)begin 										
					CUR[i] <= idata[i<<8 +: 9'd256]; 						
				end
			end
			else begin
				for(i=0; i< HALF_ROWS ; i=i+1)begin  
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

	always@(*)begin
		
		NEXT_odata_valid = 0 ;
		NEXT_odata = odata;
		NEXT_shift2pre = 0;
		
		for(i=0; i< HALF_ROWS ; i=i+1)begin 
			NEXT_MID[i] = MID[i];
			NEXT_PRE[i] = PRE[i];
		end
		for(i=0; i< ROW_NUMS ; i=i+1)begin 
			NEXT_CUR[i] = CUR[i];
		end
		
		
	//----- UPSAMPLE 2X -----
	
		if(function_mode[1]==1 && !active_reg && !active_reg2)begin 			//NEXT SHIFT (AT BEGINING)
			for(i=0; i< HALF_ROWS-1 ; i=i+1)begin  								// i< ROW_NUMS-3: loop until row12(G)
				for(j=0; j< 8 ; j=j+1)begin     								// 8 items in a row (depth)
					NEXT_odata[{ i[31:1]+1,8'd0} + j<<5) +:6'd32] = ADD2_COL[i][j]>>1;		// compute c , even row						
				end	            // ( i*2+1 )<<8
			end	
			NEXT_shift2pre = 1;
		end
		
		if (function_mode[1]==1 && active_reg)begin  							//NEXT NO SHIFT    				
			for(i=0; i< HALF_ROWS-1 ; i=i+1)begin  								// i< ROW_NUMS-3: loop until row12(G)
				for(j=0; j< 8 ; j=j+1)begin     						
					NEXT_CUR[i+1][(j<<5) +:6'd32] = ADD2_COL[i][j]>>1;		// compute c , even row							
				end
			end	
			for(i=0; i< HALF_ROWS ; i=i+1)begin  						
				NEXT_MID[(i<<8 + j<<5 ) +:6'd32] = ADD2_ROW[i][j]>>1; 		// compute a,d , even row		
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
		
		/*
	
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
											
				for(i=1; i<= ROW_NUMS-3 ; i=i+4)begin  	// MaxPooling
					for(j=0; j< 8 ; j=j+1)begin     	
						NEXT_odata[( {i[23:1],8'd0} + {j[26:0],5'd0} ) +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+1][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32] : CUR[i+1][j<<5 +:6'd32];
						//NEXT_odata_test[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+1][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32] : CUR[i+1][j<<5 +:6'd32];
					end
				end
				
				for(j=0; j< 8 ; j=j+1)begin     // MaxPooling	
					NEXT_odata[( {j[26:0],5'd0} ) +:6'd32] = (CUR[1][j<<5 +:6'd32]>PRE[1][j<<5 +:6'd32])? CUR[1][j<<5 +:6'd32] : PRE[1][j<<5 +:6'd32];
					NEXT_odata[( 32'd256 + {j[26:0],5'd0} ) +:6'd32] = (CUR[5][j<<5 +:6'd32]>PRE[5][j<<5 +:6'd32])? CUR[5][j<<5 +:6'd32] : PRE[5][j<<5 +:6'd32];
					NEXT_odata[( 32'd512 + {j[26:0],5'd0} ) +:6'd32] = (CUR[9][j<<5 +:6'd32]>PRE[9][j<<5 +:6'd32])? CUR[9][j<<5 +:6'd32] : PRE[9][j<<5 +:6'd32];
					NEXT_odata[( 32'd768 + {j[26:0],5'd0} ) +:6'd32] = (CUR[13][j<<5 +:6'd32]>PRE[13][j<<5 +:6'd32])? CUR[13][j<<5 +:6'd32] : PRE[13][j<<5 +:6'd32];
				end
				
			end
			else begin	
								
				// AvgPooling
				for(i=0 ;i<= HROW_NUMS-3 ; i=i+4)begin  	
					for(j=0; j< 8 ; j=j+1)begin // (i>>1)<<8  + j<<5	
						NEXT_odata[(  {i[23:1],8'd0} + {j[26:0],5'd0} ) +:6'd32] = (CUR[i][j<<5 +:6'd32] + CUR[i+1][j<<5 +:6'd32])>>1;
						NEXT_odata_test[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32] + CUR[i+1][j<<5 +:6'd32])>>1;
					end
				end
				
				
				for(j=0; j< 8 ; j=j+1)begin     // AvgPooling
					NEXT_odata[( {j[26:0],5'd0} ) +:6'd32] = (CUR[1][j<<5 +:6'd32] + PRE[1][j<<5 +:6'd32])>>1;
					NEXT_odata[( 32'd256 + {j[26:0],5'd0} ) +:6'd32] = (CUR[5][j<<5 +:6'd32] + PRE[5][j<<5 +:6'd32])>>1;
					NEXT_odata[( 32'd512 + {j[26:0],5'd0} ) +:6'd32] = (CUR[9][j<<5 +:6'd32] + PRE[9][j<<5 +:6'd32])>>1;
					NEXT_odata[( 32'd768 + {j[26:0],5'd0} ) +:6'd32] = (CUR[13][j<<5 +:6'd32] + PRE[13][j<<5 +:6'd32])>>1;
				end
				
			end	
			
			NEXT_odata_valid = 1;
		end
		*/
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
				for(i=0 ; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     							
						NEXT_odata[({i[23:1],8'd0} + {j[26:0],5'd0}) +:6'd32] = (PRE[i][j<<5 +:6'd32]>CUR[i][j<<5 +:6'd32])? (PRE[i][j<<5 +:6'd32]>MID[i][j<<5 +:6'd32])? PRE[i][j<<5 +:6'd32]: MID[i][j<<5 +:6'd32] : (CUR[i][j<<5 +:6'd32]>MID[i][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32]: MID[i][j<<5 +:6'd32];
					end
					
					NEXT_MID[i] = CUR[i];										//NEXT SHIFT				
					NEXT_PRE[i] = MID[i];
				end
				
				for(j=0; j< 8 ; j=j+1)begin     							
					NEXT_odata[ {j[26:0],5'd0}  +:6'd32] 		  = (PRE[1][j<<5 +:6'd32]>CUR[1][j<<5 +:6'd32])? (PRE[1][j<<5 +:6'd32]>MID[1][j<<5 +:6'd32])? PRE[1][j<<5 +:6'd32]: MID[1][j<<5 +:6'd32] : (CUR[1][j<<5 +:6'd32]>MID[1][j<<5 +:6'd32])? CUR[1][j<<5 +:6'd32]: MID[1][j<<5 +:6'd32];
					NEXT_odata[ 32'd256 +{j[26:0],5'd0}  +:6'd32] = (PRE[5][j<<5 +:6'd32]>CUR[5][j<<5 +:6'd32])? (PRE[5][j<<5 +:6'd32]>MID[5][j<<5 +:6'd32])? PRE[5][j<<5 +:6'd32]: MID[5][j<<5 +:6'd32] : (CUR[5][j<<5 +:6'd32]>MID[5][j<<5 +:6'd32])? CUR[5][j<<5 +:6'd32]: MID[5][j<<5 +:6'd32];
					NEXT_odata[ 32'd512 +{j[26:0],5'd0}  +:6'd32] = (PRE[1][j<<5 +:6'd32]>CUR[1][j<<5 +:6'd32])? (PRE[9][j<<5 +:6'd32]>MID[9][j<<5 +:6'd32])? PRE[9][j<<5 +:6'd32]: MID[9][j<<5 +:6'd32] : (CUR[9][j<<5 +:6'd32]>MID[9][j<<5 +:6'd32])? CUR[9][j<<5 +:6'd32]: MID[9][j<<5 +:6'd32];
					NEXT_odata[ 32'd768 +{j[26:0],5'd0}  +:6'd32] = (PRE[1][j<<5 +:6'd32]>CUR[1][j<<5 +:6'd32])? (PRE[13][j<<5 +:6'd32]>MID[13][j<<5 +:6'd32])? PRE[13][j<<5 +:6'd32]: MID[13][j<<5 +:6'd32] : (CUR[13][j<<5 +:6'd32]>MID[13][j<<5 +:6'd32])? CUR[13][j<<5 +:6'd32]: MID[13][j<<5 +:6'd32];
				end
				
				
				
			end
			else begin	
			
			// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     							// 8 items in a row (depth)
						NEXT_odata[({i[23:1],8'd0} + {j[26:0],5'd0}) +:6'd32] = CUR[i][j<<5 +:6'd32] + PRE[i][j<<5 +:6'd32] + MID[i][j<<5 +:6'd32] ;
					end
					
					NEXT_MID[i] = CUR[i];										//NEXT SHIFT
					NEXT_PRE[i] = MID[i];
				end
				
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
	
	