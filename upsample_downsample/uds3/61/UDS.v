module UDS#(parameter A=7'd64)( // A = 8 * 8						
	input clk,
	input rst_n,
	input active,
	input [A*16-1:0]idata,
 	input idata_valid,
	input [1:0]scale_factor,
	input [1:0]function_mode,
	
	output reg [4*A*16-1:0]odata, //2 * 2 A
	output reg odata_valid
);

	localparam ROW_NUMS  = (A==7'd64)? 5'd16 : 5'd8 ;
	localparam HALF_ROWS = (A==7'd64)? 4'd8  : 4'd4 ;
	localparam ONE_DATA = 5'd16;
	localparam HALF_DATA = 4'd8;
	localparam HALF_DATA_PLUS1 = 9;
	localparam HALF_DATA_MINUS1 = 7;
	localparam EIGHT_DATAS = 8'd128;
	localparam SHIFT_ADATA = 4;
	integer i,j;
	
	reg [8*ONE_DATA-1:0]I[0:ROW_NUMS-1];
	reg [8*ONE_DATA-1:0]II[0:ROW_NUMS-1];
	reg [8*ONE_DATA-1:0]III[0:ROW_NUMS-1];
	reg [8*ONE_DATA-1:0]VI[0:ROW_NUMS-1];
	reg [8*ONE_DATA-1:0]V[0:ROW_NUMS-1];
		
	reg [8*ONE_DATA-1:0]NEXT_I[0:ROW_NUMS-1];
	reg [8*ONE_DATA-1:0]NEXT_II[0:ROW_NUMS-1];
	reg [8*ONE_DATA-1:0]NEXT_III[0:ROW_NUMS-1];
	reg [8*ONE_DATA-1:0]NEXT_VI[0:ROW_NUMS-1];
	reg [8*ONE_DATA-1:0]NEXT_V[0:ROW_NUMS-1];
	
	reg [4*A*ONE_DATA-1:0]NEXT_odata;
	reg NEXT_odata_valid;
	
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
	end
	*/
	
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
			shift2pre <= 0;
		end
		else begin
			shift2pre <= NEXT_shift2pre;
		end
	end
	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(i=0; i< ROW_NUMS ; i=i+1)begin
				I[i] 	<= 0;
				II[i] 	<= 0;
				III[i] 	<= 0;
				VI[i] 	<= 0;
				V[i]	<=0;
			end
		end
		else begin
		
			for(i=0; i< ROW_NUMS ; i=i+1)begin 
				II[i] 	<= NEXT_II[i];
				III[i] 	<= NEXT_III[i;
				VI[i] 	<= NEXT_VI[i];
				V[i]	<=NEXT_V[i];
			end
			
			if(idata_valid)begin									//active_reg == 0 => shift
				if(function_mode[1]==1)begin									// UPSAMPLE
					for(i=0; i< ROW_NUMS ; i=i+1)begin 							//1 row = 8 items = 8 * 32 (256)bits 
						I[i] <= idata[ {i[25:1],7'd0} +: EIGHT_DATAS]; 			//  (i>>1) *8*32 = (i>>1)<<8 = {i[31:8],8'd0}
					end
				end
				else begin														//DOWNSAMPLE
					for(i=0; i< ROW_NUMS ; i=i+1)begin 										
						I[i] <= idata[i<<7 +: EIGHT_DATAS]; 						
					end
				end
			end
			else begin
				for(i=0; i< ROW_NUMS ; i=i+1)begin  
					I[i] <= NEXT_I[i];
				end
			end
			
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
		
		for(i=0; i< ROW_NUMS ; i=i+1)begin 
			NEXT_I[i]	<= I[i];
			NEXT_II[i] 	<= II[i];
			NEXT_III[i] <= III[i];
			NEXT_VI[i] 	<= VI[i];
			NEXT_V[i]	<=V[i];		
		end
	
	//----- UPSAMPLE 2X -----
	
		if(function_mode[1]==1)begin 
			/*
			1. NEXT_odata_valid = ?
			*/
			for(i=0; i<=12 ; i=i+2)begin
				NEXT_II[i]  = I[i];
				NEXT_III[i] = II[i];
				NEXT_V[i] = II[i];
				
				for(j=0; j< 8 ; j=j+1)begin     								
					NEXT_II[i+1][j<<SHIFT_ADATA +:HALF_DATA] = (I[i][j<<SHIFT_ADATA +:HALF_DATA] + I[i+2][j<<SHIFT_ADATA +:HALF_DATA])>>1; // COL_firsthalf						
					
				//---
					NEXT_III[i+1][{j[27:0],4'b0111} +:HALF_DATA_PLUS1] = II[i][{j[27:0],4'b10000} +:HALF_DATA] + II[i+2][{j[27:0],4'b10000} +:HALF_DATA] + II[i+1][{j[27:0],4'b0111}]; // COL_lasthalf 		
					NEXT_V[i+1][{j[27:0],4'b0111} +:HALF_DATA_PLUS1]   = II[i][{j[27:0],4'b10000} +:HALF_DATA] + II[i+2][{j[27:0],4'b10000} +:HALF_DATA] + II[i+1][{j[27:0],4'b0111}];	
				//---
				
					NEXT_IV[i][j<<SHIFT_ADATA +:HALF_DATA] = (II[i][j<<SHIFT_ADATA +:HALF_DATA] + III[i][j<<SHIFT_ADATA +:HALF_DATA])>>1; // EVEN_ROW_firsthalf			
				
				//------
					NEXT_odata[{i[24:0],7'd0}+ {j[27:0],4'b0111} +: ONE_DATA] = IV[i][{j[27:0],4'b10000} +:HALF_DATA] + V[i][{j[27:0],4'b10000} +:HALF_DATA] + IV[{j[27:0],4'b0111}];
				
				end			
			end	
			NEXT_II[14]  = I[14];
			NEXT_III[14] = II[14];
			NEXT_V[14]   = II[14];
		
		
			for(i=1; i<=14 ; i=i+2)begin
				NEXT_III[i] = II[i];	
				NEXT_V[i]   = II[i];
				
				for(j=0; j< 8 ; j=j+1)begin
					NEXT_IV[i][j<<SHIFT_ADATA +:HALF_DATA_MINUS1] = (II[i][j<<SHIFT_ADATA +:HALF_DATA_MINUS1] + III[i][j<<SHIFT_ADATA +:HALF_DATA_MINUS1])>>1; //odd_ROW_firsthalf
				//----
					NEXT_odata[{i[24:0],7'd0}+{j[27:0],4'b0111} +: ONE_DATA] = IV[i][{j[27:0],4'b1000} +:HALF_DATA_PLUS1] + V[i][{j[27:0],4'b1000} +:HALF_DATA_PLUS1] + IV[i][{j[27:0],4'b0111}];				
				end						
			end	
			
			
			for(i=16; i<32 ; i=i+1)begin
				NEXT_odata[{i[24:0],7'd0} +: EIGHT_DATAS] = V[i-16];		
			end
		
		end
		
		
	//------------------------------------------	
	//----	DOWNSAMPLE 3*3 stride2  MAX-------------
		/*
		1. NEXT_odata_valid = ?
		2. GH"X"?
		*/
		if(function_mode[1]==0 && function_mode[0]==0)begin
			for(i=0; i<HALF_ROWS ; i=i+2)begin	
				NEXT_II[i] = I[i];
				for(j=0; j< 8 ; j=j+1)begin
					NEXT_II[i+1][j<<SHIFT_ADATA +:ONE_DATA] = (I[i][j<<SHIFT_ADATA +:ONE_DATA] > I[i+1][j<<SHIFT_ADATA +:ONE_DATA])? I[i][j<<SHIFT_ADATA +:ONE_DATA] : I[i+1][j<<SHIFT_ADATA +:ONE_DATA];
				//------
					NEXT_III[i[31:1]][j<<SHIFT_ADATA +:ONE_DATA] = ( II[i+1][j<<SHIFT_ADATA +:ONE_DATA] > II[i+2][j<<SHIFT_ADATA +:ONE_DATA])? II[i+1][j<<SHIFT_ADATA +:ONE_DATA] : II[i+2][j<<SHIFT_ADATA +:ONE_DATA];
				//------
				end
			end	
	
			
			for(i=0; i<4 ; i=i+1)begin
				//NEXT_IV[i] = III[i];
				for(j=0; j< 8 ; j=j+1)begin
					NEXT_IV[i][j<<SHIFT_ADATA +:ONE_DATA] = (III[i][j<<SHIFT_ADATA +:ONE_DATA] > IV[i][j<<SHIFT_ADATA +:ONE_DATA])? III[i][j<<SHIFT_ADATA +:ONE_DATA] : IV[i][j<<SHIFT_ADATA +:ONE_DATA];
				//--------
					NEXT_odata[{i[24:0],7'd0}+{j[27:0],4'b0} +: ONE_DATA] = (IV[i][j<<SHIFT_ADATA +:ONE_DATA] > III[i][j<<SHIFT_ADATA +:ONE_DATA])? IV[i][j<<SHIFT_ADATA +:ONE_DATA] : III[i][j<<SHIFT_ADATA +:ONE_DATA];
				end
			end
			
		end
		
		if(function_mode[1]==0 && function_mode[0]==1)begin
			
	
	
	
	
	
	
	
	
	
	
	
	
//---6/1---------------------------------------	
		if(function_mode[1]==1 && !active_reg && !active_reg2)begin 			//NEXT SHIFT (AT BEGINING)
			for(i=0; i< ROW_NUMS-3 ; i=i+2)begin  								// i< ROW_NUMS-3: loop until row12(G)
				for(j=0; j< 8 ; j=j+1)begin     								// 8 items in a row (depth)
					NEXT_PRE[i+1][j<<4 +:A_BITS] = (CUR[i][j<<4 +:A_BITS] + CUR[i+2][j<<4 +:A_BITS])>>1;		// compute c , even row						
				end	
			end	
			NEXT_shift2pre = 1; 
			
			for(i=0; i< ROW_NUMS ; i=i+2)begin  								// i< ROW_NUMS-3: loop until row14(H)
				for(j=0; j< 8 ; j=j+1)begin     								// 8 items in a row (depth)
					NEXT_odata[i<<8 + j<<5 +:6'd32] = (PRE[i][j<<5 +:6'd32] + CUR[i][j<<5 +:6'd32])>>1; 		// compute a,d , even row	
				end
			end	
			
		end
		
		if (function_mode[1]==1 && active_reg)begin  							//NEXT NO SHIFT    				
			for(i=0; i< ROW_NUMS-3 ; i=i+2)begin  								// i< ROW_NUMS-3: loop until row12(G)
				for(j=0; j< 8 ; j=j+1)begin     						
					NEXT_CUR[i+1][j<<4 +:A_BITS] = (CUR[i][j<<4 +:A_BITS] + CUR[i+2][j<<4 +:A_BITS])>>1;		// compute c , even row							
				end
			end	
			for(i=0; i< ROW_NUMS ; i=i+2)begin  						
				NEXT_odata[{i[24:0],7'd0} + {j[27:0],4'd0} +:A_BITS] = (PRE[i][j<<4 +:A_BITS] + CUR[i][j<<4 +:A_BITS])>>1; 		// compute a,d , even row	
			end
				
		end
		
		if (function_mode[1]==1 && active_reg2)begin      						//NEXT SHIFT  
			for(i=1; i< ROW_NUMS-1 ; i=i+2)begin  								// compute x , odd row
				for(j=0; j< 8 ; j=j+1)begin			 
					NEXT_odata[{i[24:0],7'd0} + {j[27:0],4'd0} +:A_BITS] = (PRE[i][j<<4 +:A_BITS] + CUR[i][j<<4 +:A_BITS] + (PRE[i-1][j<<4]^PRE[i+1][j<<4]) + (CUR[i-1][j<<4]^CUR[i+1][j<<4]) )>>1;
				end
			end	
			
			for(i=0; i< ROW_NUMS ; i=i+1)begin  								//SHIFT 	
				for(j=0; j< 8 ; j=j+1)begin			 
					NEXT_PRE[i][j<<4 +:A_BITS] = CUR[i][j<<4 +:A_BITS];	
				end
			end	
			NEXT_shift2pre = 1;
			NEXT_odata_valid = 1;
		end
		
		if(function_mode[1]==1 && shift2pre)begin
			NEXT_odata = {PRE[13],PRE[12],PRE[11],PRE[10],PRE[9],PRE[8],PRE[7],PRE[6],PRE[5],PRE[4],PRE[3],PRE[2],PRE[1],PRE[0]};
			NEXT_odata_valid = 1;
		end
		
	//-------------------------------------------------------------------------------	
	//----	DOWNSAMPLE 2*2 stride2 -------	
		
	
		if(function_mode[1]==0 && scale_factor==0 && !active_reg)begin 	// NEXT  SHIFT, compute r2			
			if(function_mode[0]==0)begin								// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_PRE[i][j<<4 +:A_BITS] = (CUR[i][j<<4+:A_BITS]>CUR[i+1][j<<4 +:A_BITS])? CUR[i][j<<4 +:A_BITS] : CUR[i+1][j<<4 +:A_BITS];
					end
				end
			end
			else begin													// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_PRE[i][j<<4 +:A_BITS] = (CUR[i][j<<4 +:A_BITS] + CUR[i+1][j<<4 +:A_BITS])>>1;
					end
				end
			end
		end	
		
		if(function_mode[1]==0 && scale_factor==0 && active_reg)begin 	//NEXT NO SHIFT, compute r2			
			if(function_mode[0]==0)begin								// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_CUR[i][j<<4 +:A_BITS] = (CUR[i][j<<4 +:A_BITS]>CUR[i+1][j<<4 +:A_BITS])? CUR[i][j<<4 +:A_BITS] : CUR[i+1][j<<4 +:A_BITS];
					end
				end
			end
			else begin													// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_CUR[i][j<<4 +:A_BITS] = (CUR[i][j<<4 +:A_BITS] + CUR[i+1][j<<4 +:A_BITS])>>1;
					end
				end
			end
		end	
		
		
		if(function_mode[1]==0 && scale_factor==0 && active_reg2)begin			//downsamle 2*2, compute r3	
			if(function_mode[0]==0)begin										// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_odata[{i[25:1],7'd0}+ {j[27:0],4'd0} +:6'd32] = (CUR[i][j<<4 +:A_BITS]>PRE[i][j<<4 +:A_BITS])? CUR[i][j<<4 +:A_BITS] : PRE[i][j<<4 +:A_BITS];
					end
				end
			end
			else begin															// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     	
						NEXT_odata[{i[25:1],7'd0} + {j[27:0],4'd0} +: A_BITS] = (CUR[i][j<<4 +:A_BITS] + PRE[i][j<<4 +:A_BITS])>>1;
					end
				end
			end	
			
			NEXT_odata_valid = 1;
		end
		
	//---------------------------------------------------------------------------
	//----	DOWNSAMPLE 3*3 stride2 -------------
		if(function_mode[1]==0 && scale_factor==1 && !active_reg)begin 		//NEXT  SHIFT, compute col
					
			if(function_mode[0]==0)begin									// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_MID[i][j<<4 +:A_BITS] = (CUR[i][j<<4 +:6'd32]>CUR[i+1][j<<4 +:6'd32])? (CUR[i][j<<4 +:6'd32]>CUR[i+2][j<<4 +:A_BITS])? CUR[i][j<<4 +:A_BITS]: CUR[i+2][j<<5 +:6'd32] : (CUR[i+1][j<<4 +:A_BITS]>CUR[i+2][j<<4 +:A_BITS])? CUR[i+1][j<<4 +:A_BITS]: CUR[i+2][j<<4 +:A_BITS];
					end
					NEXT_PRE[i] = MID[i];
				end
			end
			else begin														// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_MID[i][j<<4 +:A_BITS] = (CUR[i][j<<4 +:A_BITS] + CUR[i+1][j<<4 +:A_BITS] +CUR[i+2][j<<4 +:A_BITS])>>4 + (CUR[i][j<<4 +:A_BITS] + CUR[i+1][j<<4 +:A_BITS] +CUR[i+2][j<<4 +:A_BITS])>>5 + (CUR[i][j<<4 +:A_BITS] + CUR[i+1][j<<4 +:A_BITS] +CUR[i+2][j<<4 +:A_BITS])>>6; // * 0.343   
					end
					NEXT_PRE[i] = MID[i];
				end
			end
		end
		
		if(function_mode[1]==0 && scale_factor==1 && active_reg)begin 		//NEXT NO SHIFT, compute col
					
			if(function_mode[0]==0)begin									// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_CUR[i][j<<4 +:A_BITS] = (CUR[i][j<<4 +:A_BITS]>CUR[i+1][j<<4 +:A_BITS])? (CUR[i][j<<4 +:A_BITS]>CUR[i+2][j<<4 +:A_BITS])? CUR[i][j<<4 +:A_BITS]: CUR[i+2][j<<4 +:A_BITS] : (CUR[i+1][j<<4 +:A_BITS]>CUR[i+2][j<<4 +:A_BITS])? CUR[i+1][j<<4 +:A_BITS]: CUR[i+2][j<<4 +:A_BITS];
					end
				end
			end
			else begin														// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_CUR[i][j<<4 +:A_BITS] = (CUR[i][j<<4 +:A_BITS] + CUR[i+1][j<<4 +:A_BITS] +CUR[i+2][j<<4 +:A_BITS])>>4 + (CUR[i][j<<4 +:A_BITS] + CUR[i+1][j<<4 +:A_BITS] +CUR[i+2][j<<4 +:A_BITS])>>5 + (CUR[i][j<<4 +:A_BITS] + CUR[i+1][j<<4 +:A_BITS] +CUR[i+2][j<<4 +:A_BITS])>>6; // * 0.343   
					end
				end
			end
			
		end
		
		if(function_mode[1]==0 && scale_factor==1 && active_reg2)begin			//downsamle 3*3, compute row
			
			if(function_mode[0]==0)begin										// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     							
						NEXT_odata[{i[25:1],7'd0} + {j[27:0],4'd0} +:A_BITS] = (PRE[i][j<<4+:A_BITS]>CUR[i][j<<4 +:A_BITS])? (PRE[i][j<<4 +:A_BITS]>MID[i][j<<4+:A_BITS])? PRE[i][j<<4+:A_BITS]: MID[i][j<<4 +:A_BITS] : (CUR[i][j<<4 +:A_BITS]>MID[i][j<<4 +:A_BITS])? CUR[i][j<<4 +:A_BITS]: MID[i][j<<4 +:A_BITS];
					end
					
					NEXT_MID[i] = CUR[i];										//NEXT SHIFT				
					NEXT_PRE[i] = MID[i];
				end
			end
			else begin															// AvgPooling
				for(i=0 ; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     							// 8 items in a row (depth)
						NEXT_odata[{i[25:1],7'd0} + {j[27:0],4'd0} +:A_BITS] = CUR[i][j<<4 +:A_BITS] + PRE[i][j<<4 +:A_BITS] + MID[i][j<<4 +:A_BITS]; // * 0.343 
					end
					
					NEXT_MID[i] = CUR[i];										//NEXT SHIFT
					NEXT_PRE[i] = MID[i];
				end
			end
			
			NEXT_odata_valid = 1;
		end
		
	end
	
endmodule
	
	