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
	
	reg [8-1:0]CUR_firstLarger[0:HALF_ROWS-1];
	reg [8-1:0]MID_firstLarger[0:HALF_ROWS-1];
	reg [8-1:0]PRE_firstLarger[0:HALF_ROWS-1];
	
	reg [8-1:0]NEXT_CUR_firstLarger[0:HALF_ROWS-1];
	reg [8-1:0]NEXT_MID_firstLarger[0:HALF_ROWS-1];
	reg [8-1:0]NEXT_PRE_firstLarger[0:HALF_ROWS-1];
	
	//reg idata_valid_reg,idata_valid_reg2;
	reg active_reg,active_reg2,active_reg3,active_reg4;
	
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
			active_reg3 <= 0;
			active_reg4 <= 0;
		end
		else begin
			active_reg	<= active;
			active_reg2 <= active_reg;
			active_reg3 <= active_reg2;
			active_reg4 <= active_reg3;
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
					
			if(!active_reg && idata_valid)begin									//active_reg == 0 => shift
				if(function_mode[1]==1)begin									// UPSAMPLE
					for(i=0; i< ROW_NUMS ; i=i+1)begin 							//1 row = 8 items = 8 * 32 (256)bits 
						CUR[i] <= idata[ {i[23:1],8'd0} +: 9'd256]; 			//  (i>>1) *8*32 = (i>>1)<<8 = {i[31:8],8'd0}
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
			
			for(i=0; i< ROW_NUMS ; i=i+1)begin 
				MID[i] <= NEXT_MID[i];
				PRE[i] <= NEXT_PRE[i];
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
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(i=0; i< HALF_ROWS ; i=i+1)begin 											
				CUR_firstLarger[i] <= 0;	
				MID_firstLarger[i] <= 0;
				PRE_firstLarger[i] <= 0;
			end
		end
		else begin
			if(function_mode==2'b00 && scale_factor==1)begin
				for(i=0; i< HALF_ROWS ; i=i+1)begin 											
					CUR_firstLarger[i] <= NEXT_CUR_firstLarger[i];	
					MID_firstLarger[i] <= NEXT_MID_firstLarger[i];
					PRE_firstLarger[i] <= NEXT_PRE_firstLarger[i];
				end
			end
		end
	end
	
//------------------------------------------------------------------------------------------------

	always@(*)begin
		
		NEXT_odata_valid = 0 ;
		NEXT_odata = odata;
		NEXT_shift2pre = 0;
		
		for(i=0; i< ROW_NUMS ; i=i+1)begin 
			NEXT_CUR[i] = CUR[i];
			NEXT_MID[i] = MID[i];
			NEXT_PRE[i] = PRE[i];
			NEXT_odata_test[i] = 0;
		end
		
		if(function_mode==2'b00 && scale_factor==1)begin
			for(i=0; i< HALF_ROWS ; i=i+1)begin 
				NEXT_CUR_firstLarger[i] = CUR_firstLarger[i];
				NEXT_MID_firstLarger[i] = MID_firstLarger[i];
				NEXT_PRE_firstLarger[i] = PRE_firstLarger[i];
			end
		end
		
		
		/*
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
			NEXT_shift2pre = 1; 
			NEXT_odata_valid = 1;
		end
		
		if(function_mode[1]==1 && shift2pre)begin
			NEXT_odata = {PRE[13],PRE[12],PRE[11],PRE[10],PRE[9],PRE[8],PRE[7],PRE[6],PRE[5],PRE[4],PRE[3],PRE[2],PRE[1],PRE[0]};
			NEXT_odata_valid = 1;
		end
		*/
	//-------------------------------------------------------------------------------	
	//----	DOWNSAMPLE 2*2 stride2 -------	
		
		if(function_mode[1]==0 && scale_factor==0 && !active_reg)begin 			
			if(function_mode[0]==0)begin								// NEXT SHIFT, compute r2 (MaxPooling)
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin 						
						NEXT_PRE[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+1][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32] : CUR[i+1][j<<5 +:6'd32];				
					end
				end
			end
			else begin	
				if(idata_valid)begin									//NEXT  SHIFT	(AvgPooling)
					for(i=0; i< 8 ; i=i+1)begin 
						NEXT_PRE[i] = CUR[i];			
					end
				end
			end
		end

		
		if(function_mode[1]==0 && scale_factor==0 && active_reg)begin 														// MaxPooling
			if(function_mode[0]==0)begin								//NEXT NO SHIFT, compute r2	 ( MaxPooling)
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_CUR[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+1][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32] : CUR[i+1][j<<5 +:6'd32];
					end
				end	
			end
			else begin													// NEXT NO SHIFT , AvgPooling 1-firstHalf
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     									
						NEXT_CUR[i][j<<5 +:6'd16] = CUR[i][{j[26:0],5'b00010} +:6'd15] + CUR[i+1][{j[26:0],5'b00010} +:6'd15] + 1; 				 //  (a+b)/4 + 1 first half
						NEXT_CUR[i][{j[26:0],5'b10000} +:6'd16] = CUR[i][{j[26:0],5'b10001} +:6'd15] + CUR[i+1][{j[26:0],5'b10001} +:6'd15] + 1; //  (a+b)/4 + 1 last half
						
						NEXT_PRE[i][j<<5 +:6'd16] = PRE[i][{j[26:0],5'b00010} +:6'd15] + PRE[i+1][{j[26:0],5'b00010} +:6'd15] + 1; 				 //  (a+b)/4 + 1 first half
						NEXT_PRE[i][{j[26:0],5'b10000} +:6'd16] = PRE[i][{j[26:0],5'b10001} +:6'd15] + PRE[i+1][{j[26:0],5'b10001} +:6'd15] + 1; //  (a+b)/4 + 1 last half
					end
				end
			end		
		end	
		
		
		if(function_mode[1]==0 && scale_factor==0 && active_reg2)begin			//downsamle 2*2, compute r3	
			if(function_mode[0]==0)begin										// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     	
						NEXT_odata[( {i[23:1],8'd0} + {j[26:0],5'd0} ) +:6'd32] = (CUR[i][j<<5 +:6'd32]>PRE[i][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32] : PRE[i][j<<5 +:6'd32];
						//NEXT_odata_test[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>PRE[i][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32] : PRE[i][j<<5 +:6'd32];
					end
				end
				NEXT_odata_valid = 1;
			end
			else begin															// AvgPooling 1-lastHalf
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     										
						NEXT_CUR[i][{j[26:0],5'b01111} +:6'd17] = CUR[i][{j[26:0],5'b10000} +:6'd16] + CUR[i][{j[26:0],5'b01111}];
						
						NEXT_PRE[i][{j[26:0],5'b01111} +:6'd17] = PRE[i][{j[26:0],5'b10000} +:6'd16] + PRE[i][{j[26:0],5'b01111}];
					end
				end
			end		
		end
		
		if(function_mode== 2'b01 && scale_factor==0 && active_reg3)begin			
																	// AvgPooling 2-firstHalf
			for(i=0; i< HALF_ROWS ; i=i+2)begin  	
				for(j=0; j< 8 ; j=j+1)begin     										
					//NEXT_CUR[i][j<<5 +:6'd32] = {CUR[i][{j[26:0],5'b10000} +:6'd16] + CUR[i][{j[26:0],5'b01111}],CUR[i][j<<5 +:6'd15]};
					
					//NEXT_PRE[i][j<<5 +:6'd32] = {PRE[i][{j[26:0],5'b10000} +:6'd16] + PRE[i][{j[26:0],5'b01111}],PRE[i][j<<5 +:6'd15]};
					NEXT_odata[( {i[23:1],8'd0} + {j[26:0],5'd0} ) +:6'd16] = CUR[i][ j[26:0] +:6'd15] + PRE[i][ j[26:0] +:6'd15];
					NEXT_odata[( {i[23:1],8'd0} + {j[26:0],5'b10000} ) +:6'd16] = CUR[i][ {j[26:0],5'b01111} +:6'd16] + PRE[i][ {j[26:0],5'b01111} +:6'd16];
				end
			end
					
		end
		
		if(function_mode== 2'b01 && scale_factor==0 && active_reg4)begin			
																	// AvgPooling 2-firstHalf
			for(i=0; i< HALF_ROWS ; i=i+2)begin  	
				for(j=0; j< 8 ; j=j+1)begin     										

					NEXT_odata[( {i[23:1],8'd0} + {j[26:0],5'b01111} ) +:6'd17] =  odata[( {i[23:1],8'd0} + {j[26:0],5'b10000} ) +:6'd16] + odata[ {i[23:1],8'd0} + {j[26:0],5'b01111} ] ;
				
				end
			end
			NEXT_odata_valid = 1;	
		end
		
		
		
		
		
		
	//---------------------------------------------------------------------------
	//----	DOWNSAMPLE 3*3 stride2 -------------
	
	
		if(function_mode[1]==0 && scale_factor==1 && !active_reg && idata_valid)begin 	//NEXT  SHIFT
											
			for(i=0; i< 8 ; i=i+1)begin 
				NEXT_PRE[i] = CUR[i];	
				NEXT_MID[i] = PRE[i];
			end
			
			
		end
		
		if(function_mode[1]==0 && scale_factor==1 && active_reg)begin 		//NEXT NO SHIFT, 1-firstHalf
					
			if(function_mode[0]==0)begin									// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						//NEXT_CUR[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+1][j<<5 +:6'd32])? (CUR[i][j<<5 +:6'd32]>CUR[i+2][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32]: CUR[i+2][j<<5 +:6'd32] : (CUR[i+1][j<<5 +:6'd32]>CUR[i+2][j<<5 +:6'd32])? CUR[i+1][j<<5 +:6'd32]: CUR[i+2][j<<5 +:6'd32];
						NEXT_CUR_firstLarger[i][j] = (CUR[i][j<<5 +:6'd32]>CUR[i+1][j<<5 +:6'd32])? 1 : 0 ;
						
						
						NEXT_MID_firstLarger[i][j] = (MID[i][j<<5 +:6'd32]>MID[i+1][j<<5 +:6'd32])? 1 : 0 ;
						
						
						NEXT_PRE_firstLarger[i][j] = (PRE[i][j<<5 +:6'd32]>PRE[i+1][j<<5 +:6'd32])? 1 : 0 ;
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
		
		if(function_mode[1]==0 && scale_factor==1 && active_reg2)begin			//1-lastHalf
			
			if(function_mode[0]==0)begin	
				// MaxPooling
				for(i=0 ; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     
						if(CUR_firstLarger[i][j])begin
							NEXT_CUR[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+2][j<<5 +:6'd32])?  CUR[i][j<<5 +:6'd32] : CUR[i+2][j<<5 +:6'd32];
						end
						else begin
							NEXT_CUR[i][j<<5 +:6'd32] = (CUR[i+1][j<<5 +:6'd32]>CUR[i+2][j<<5 +:6'd32])?  CUR[i+1][j<<5 +:6'd32] : CUR[i+2][j<<5 +:6'd32];
						end
						
						if(CUR_firstLarger[i][j])begin
							NEXT_MID[i][j<<5 +:6'd32] = (MID[i][j<<5 +:6'd32]>MID[i+2][j<<5 +:6'd32])?  MID[i][j<<5 +:6'd32] : MID[i+2][j<<5 +:6'd32];
						end
						else begin
							NEXT_MID[i][j<<5 +:6'd32] = (MID[i+1][j<<5 +:6'd32]>MID[i+2][j<<5 +:6'd32])?  MID[i+1][j<<5 +:6'd32] : MID[i+2][j<<5 +:6'd32];
						end
						
						if(CUR_firstLarger[i][j])begin
							NEXT_PRE[i][j<<5 +:6'd32] = (PRE[i][j<<5 +:6'd32]>PRE[i+2][j<<5 +:6'd32])?  PRE[i][j<<5 +:6'd32] : PRE[i+2][j<<5 +:6'd32];
						end
						else begin
							NEXT_PRE[i][j<<5 +:6'd32] = (PRE[i+1][j<<5 +:6'd32]>PRE[i+2][j<<5 +:6'd32])?  PRE[i+1][j<<5 +:6'd32] : PRE[i+2][j<<5 +:6'd32];
						end
						//NEXT_odata[({i[23:1],8'd0} + {j[26:0],5'd0}) +:6'd32] = (PRE[i][j<<5 +:6'd32]>CUR[i][j<<5 +:6'd32])? (PRE[i][j<<5 +:6'd32]>MID[i][j<<5 +:6'd32])? PRE[i][j<<5 +:6'd32]: MID[i][j<<5 +:6'd32] : (CUR[i][j<<5 +:6'd32]>MID[i][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32]: MID[i][j<<5 +:6'd32];
					end
					
					
				end
			end/*
			else begin	
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     							// 8 items in a row (depth)
						NEXT_odata[({i[23:1],8'd0} + {j[26:0],5'd0}) +:6'd32] = CUR[i][j<<5 +:6'd32] + PRE[i][j<<5 +:6'd32] + MID[i][j<<5 +:6'd32] ;
					end
					
					NEXT_MID[i] = CUR[i];										//NEXT SHIFT
					NEXT_PRE[i] = MID[i];
				end
				NEXT_odata_valid = 1;
			end*/
			
			
		end
		
		if(function_mode[1]==0 && scale_factor==1 && active_reg3)begin	//2-firstHalf
			if(function_mode[0]==0)begin	
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						//NEXT_CUR[i][j<<5 +:6'd32] = (CUR[i][j<<5 +:6'd32]>CUR[i+1][j<<5 +:6'd32])? (CUR[i][j<<5 +:6'd32]>CUR[i+2][j<<5 +:6'd32])? CUR[i][j<<5 +:6'd32]: CUR[i+2][j<<5 +:6'd32] : (CUR[i+1][j<<5 +:6'd32]>CUR[i+2][j<<5 +:6'd32])? CUR[i+1][j<<5 +:6'd32]: CUR[i+2][j<<5 +:6'd32];
						NEXT_CUR_firstLarger[i][j] = (CUR[i][j<<5 +:6'd32]>MID[i][j<<5 +:6'd32])? 1 : 0 ;	
					end
				end
			end
			else begin
			
			end
		end
		
		if(function_mode[1]==0 && scale_factor==1 && active_reg4)begin	//2-lastHalf
			if(function_mode[0]==0)begin
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin 
						if(CUR_firstLarger[i][j])begin
							NEXT_odata[( {i[23:1],8'd0} + {j[26:0],5'd0} ) +: 6'd32] = (CUR[i][j<<5 +:6'd32]>PRE[i][j<<5 +:6'd32])?  CUR[i][j<<5 +:6'd32] : PRE[i][j<<5 +:6'd32];
						end
						else begin
							NEXT_odata[( {i[23:1],8'd0} + {j[26:0],5'd0} ) +: 6'd32] = (MID[i][j<<5 +:6'd32]>PRE[i][j<<5 +:6'd32])?  CUR[i][j<<5 +:6'd32] : PRE[i][j<<5 +:6'd32];
						end
					end
				end
				
			end
			else begin
			
			end
			NEXT_odata_valid = 1;
		end			
	
	end
	
endmodule
	
	