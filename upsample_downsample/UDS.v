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
	reg [8*32-1:0]NEXT_odata_test[0:ROW_NUMS-1];
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

	always@(*)begin
		
		NEXT_odata_valid = 0 ;
		NEXT_odata = odata;
		NEXT_shift2pre = 0;
		
		for(i=0; i< 8 ; i=i+1)begin 
			NEXT_CUR[i] = CUR[i];
			NEXT_MID[i] = MID[i];
			NEXT_PRE[i] = PRE[i];
			NEXT_odata_test[i] = 0;
		end
		
		
		
	//----- UPSAMPLE 2X -----
		if(function_mode[1]==1 && !active_reg && !active_reg2)begin 			//NEXT SHIFT (AT BEGINING)
			for(i=0; i< ROW_NUMS-3 ; i=i+2)begin  								// i< ROW_NUMS-3: loop until row12(G)
				for(j=0; j< 8 ; j=j+1)begin     								// 8 items in a row (depth)
					NEXT_PRE[i+1][(j<<5) +:6'd32] = (CUR[i][(j<<5) +:6'd32] + CUR[i+2][(j<<5) +:6'd32])>>1;		// compute c , even row						
				end	
			end	
			
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
		end
		
		if(function_mode[1]==1 && shift2pre)begin
			NEXT_odata = {PRE[13],PRE[12],PRE[11],PRE[10],PRE[9],PRE[8],PRE[7],PRE[6],PRE[5],PRE[4],PRE[3],PRE[2],PRE[1],PRE[0]};
			NEXT_odata_valid = 1;
		end
		
	//-------------------------------------------------------------------------------	
	//----	DOWNSAMPLE 2*2 stride2 -------	
		
	
		if(function_mode[1]==0 && scale_factor==0 && !active_reg)begin 	//NEXT  SHIFT, compute r2			
			if(function_mode[0]==0)begin								// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_PRE[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+1][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32] : CUR[i+1][j<<5 +:6'd32];
					end
				end
			end
			else begin													// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						//NEXT_PRE[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32] + CUR[i+1][j<<5 +:6'd32])>>1;
						NEXT_PRE[i][j<<5 +:6'd32] = CUR[i][{j[26:0],5'b00001} +:6'd31] + CUR[i+1][{j[26:0],5'b00001} +:6'd31] + ( CUR[i][{j[26:0],5'd0}] & CUR[i+1][{j[26:0],5'd0}] );
					end
				end
			end
		end	
		
		if(function_mode[1]==0 && scale_factor==0 && active_reg)begin 	//NEXT NO SHIFT, compute r2			
			if(function_mode[0]==0)begin								// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_CUR[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+1][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32] : CUR[i+1][j<<5 +:6'd32];
					end
				end
			end
			else begin													// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						//NEXT_CUR[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32] + CUR[i+1][j<<5 +:6'd32])>>1;
						NEXT_CUR[i][j<<5 +:6'd32] = CUR[i][{j[26:0],5'b00001} +:6'd31] + CUR[i+1][{j[26:0],5'b00001} +:6'd31] + ( CUR[i][{j[26:0],5'd0}] & CUR[i+1][{j[26:0],5'd0}] );
					end
				end
			end
		end	
		
		
		if(function_mode[1]==0 && scale_factor==0 && active_reg2)begin			//downsamle 2*2, compute r3	
			if(function_mode[0]==0)begin										// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     	
						NEXT_odata[( {i[23:1],8'd0} + {j[26:0],5'd0} ) +:6'd32] = (CUR[i][j<<5 +:6'd32]>PRE[i][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32] : PRE[i][j<<5 +:6'd32];
						NEXT_odata_test[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>PRE[i][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32] : PRE[i][j<<5 +:6'd32];
					end
				end
			end
			else begin															// AvgPooling
				for(i=0 ;i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin // (i>>1)<<8  + j<<5	
						//NEXT_odata[(  {i[23:1],8'd0} + {j[26:0],5'd0} ) +:6'd32] = (CUR[i][j<<5 +:6'd32] + PRE[i][j<<5 +:6'd32])>>1;	
						//NEXT_odata_test[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32] + PRE[i][j<<5 +:6'd32])>>1;
						NEXT_odata[(  {i[23:1],8'd0} + {j[26:0],5'd0} ) +:6'd32] = CUR[i][{j[26:0],5'b00001} +:6'd31] + PRE[i][{j[26:0],5'b00001} +:6'd31] + ( CUR[i][{j[26:0],5'd0}] & PRE[i][{j[26:0],5'd0}] );
						NEXT_odata_test[i][j<<5 +:6'd32] = CUR[i][{j[26:0],5'b00001} +:6'd31] + PRE[i][{j[26:0],5'b00001} +:6'd31] + ( CUR[i][{j[26:0],5'd0}] & PRE[i][{j[26:0],5'd0}] );
					end
				end
			end	
			
			NEXT_odata_valid = 1;
		end
		/*
	//---------------------------------------------------------------------------
	//----	DOWNSAMPLE 3*3 stride2 -------------
		if(function_mode[1]==0 && scale_factor==1 && !active_reg)begin 		//NEXT  SHIFT, compute col
					
			if(function_mode[0]==0)begin									// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_MID[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+1][j<<5 +:6'd32])? (CUR[i][j<<5 +:6'd32]>CUR[i+2][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32]: CUR[i+2][j<<5 +:6'd32] : (CUR[i+1][j<<5 +:6'd32]>CUR[i+2][j<<5 +:6'd32])? CUR[i+1][j<<5 +:6'd32]: CUR[i+2][j<<5 +:6'd32];
					end
					NEXT_PRE[i] = MID[i];
				end
			end
			else begin														// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_MID[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32] + CUR[i+1][j<<5 +:6'd32] +CUR[i+2][j<<5 +:6'd32])>>4 + (CUR[i][j<<5 +:6'd32] + CUR[i+1][j<<5 +:6'd32] +CUR[i+2][j<<5 +:6'd32])>>5 + (CUR[i][j<<5 +:6'd32] + CUR[i+1][j<<5 +:6'd32] +CUR[i+2][j<<5 +:6'd32])>>6; // * 0.109   
					end
					NEXT_PRE[i] = MID[i];
				end
			end
		end
		
		if(function_mode[1]==0 && scale_factor==1 && active_reg)begin 		//NEXT NO SHIFT, compute col
					
			if(function_mode[0]==0)begin									// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_CUR[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+1][j<<5 +:6'd32])? (CUR[i][j<<5 +:6'd32]>CUR[i+2][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32]: CUR[i+2][j<<5 +:6'd32] : (CUR[i+1][j<<5 +:6'd32]>CUR[i+2][j<<5 +:6'd32])? CUR[i+1][j<<5 +:6'd32]: CUR[i+2][j<<5 +:6'd32];
					end
				end
			end
			else begin														// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_CUR[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32] + CUR[i+1][j<<5 +:6'd32] +CUR[i+2][j<<5 +:6'd32])>>4 + (CUR[i][j<<5 +:6'd32] + CUR[i+1][j<<5 +:6'd32] +CUR[i+2][j<<5 +:6'd32])>>5 + (CUR[i][j<<5 +:6'd32] + CUR[i+1][j<<5 +:6'd32] +CUR[i+2][j<<5 +:6'd32])>>6; // * 0.109  (1/9) 
					end
				end
			end
			
		end
		
		if(function_mode[1]==0 && scale_factor==1 && active_reg2)begin			//downsamle 3*3, compute row
			
			if(function_mode[0]==0)begin										// MaxPooling
				for(i=0 ; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     							
						NEXT_odata[({i[23:1],8'd0} + {j[26:0],5'd0}) +:6'd32] = (PRE[i][j<<5 +:6'd32]>CUR[i][j<<5 +:6'd32])? (PRE[i][j<<5 +:6'd32]>MID[i][j<<5 +:6'd32])? PRE[i][j<<5 +:6'd32]: MID[i][j<<5 +:6'd32] : (CUR[i][j<<5 +:6'd32]>MID[i][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32]: MID[i][j<<5 +:6'd32];
					end
					
					NEXT_MID[i] = CUR[i];										//NEXT SHIFT				
					NEXT_PRE[i] = MID[i];
				end
			end
			else begin															// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     							// 8 items in a row (depth)
						NEXT_odata[({i[23:1],8'd0} + {j[26:0],5'd0}) +:6'd32] = CUR[i][j<<5 +:6'd32] + PRE[i][j<<5 +:6'd32] + MID[i][j<<5 +:6'd32] ;
					end
					
					NEXT_MID[i] = CUR[i];										//NEXT SHIFT
					NEXT_PRE[i] = MID[i];
				end
			end
			
			NEXT_odata_valid = 1;
		end
	*/
	end
	
endmodule
	
	