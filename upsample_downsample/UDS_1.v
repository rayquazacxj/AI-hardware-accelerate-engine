module UDS#(parameter A=64)( // A = 8 * 8						
	input clk,
	input rst_n,
	input active,
	input [A*32-1:0]idata,
 	input idata_valid,
	input [1:0]scale_factor,
	input [1:0]function_mode,
	
	output reg [2*A*32-1:0]odata, //2A
	output reg odata_valid
);
	localparam ROW_NUMS  = (A==64)? 16 : 8 ;
	localparam HALF_ROWS = (A==64)? 8  : 4 ;
	
	wire [8*32-1:0]NEXT_PRE[0:ROW_NUMS-1];
	wire [8*32-1:0]NEXT_MID[0:ROW_NUMS-1];
	wire [8*32-1:0]NEXT_CUR[0:ROW_NUMS-1];
	wire [2*A*32-1:0]NEXT_odata;
	
	//reg [A*2*32-1:0]PRE,MID,CUR;
	reg [8*32-1:0]PRE[0:ROW_NUMS-1];
	reg [8*32-1:0]MID[0:ROW_NUMS-1];
	reg [8*32-1:0]CUR[0:ROW_NUMS-1];
	
	
	reg idata_valid_reg,idata_valid_reg2;
	reg active_reg,active_reg2;
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			idata_valid_reg	 <= 0;
			idata_valid_reg2 <= 0;
		end
			idata_valid_reg	 <= idata_valid;
			idata_valid_reg2 <= idata_valid_reg;
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			active_reg	<= 0;
			active_reg2 <= 0;
		end
			active_reg	<= active_valid;
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
			
			if(!active_reg && idata_valid)begin					//active_reg == 0 => shift
				for(i=0; i< ROW_NUMS ; i=i+1)begin 				//1 row = 8 items = 8 * 32 (256)bits 
					CUR[i] <= idata[ {i[31:8],8'd0} +: 256]; 	//  (i>>1) *8*32 = (i>>1)<<8 = {i[31:8],7'd0}
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
			odata_valid <= 0;
		end
		else begin
			if(function_mode[1]==0)begin // downsamle
				odata_valid <= active_reg;
			end
			else begin // upsamle
				odata_valid <= active_reg || ( active_reg2 && idata_valid_reg2) || (idata_valid_reg && !active_reg) ; // MID / PRE (others) / PRE (first) 
			end
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
	
	//----- UPSAMPLE 2X -----
		if(function_mode[1]==1 && !active_reg && !active_reg2)begin 	//NEXT SHIFT (AT BEGINING)
			for(i=0; i< ROW_NUMS ; i=i+2)begin  	
				for(j=0; j< 8 ; j=j+1)begin     						// 8 items in a row (depth)
					NEXT_PRE[i+1][:] = (CUR[i][] + CUR[i+2][])>>1;		// compute c
					NEXT_odata[i][:] = (PRE[i][] + CUR[i][])>>1; 		// compute a,d
				end
			end		
		end
		
		if (function_mode[1]==1 && active_reg)begin  					//NEXT NO SHIFT    				
			for(i=1; i< ROW_NUMS ; i=i+2)begin  	
				for(j=0; j< 8 ; j=j+1)begin	
					NEXT_CUR[i+1][:] = (CUR[i][] + CUR[i+2][])>>1;		// compute c
					NEXT_odata[i][:] = (PRE[i][] + CUR[i][])>>1; 		// compute a,d		
				end
			end		
		end
		
		if (function_mode[1]==1 && active_reg2)begin      				//NEXT SHIFT  
			for(i=1; i< ROW_NUMS ; i=i+2)begin  						// compute x
				for(j=0; j< 8 ; j=j+1)begin			 
					NEXT_odata[i][:] = (PRE[i][] + CUR[i][] + (PRE[i-1][(1 bit)]^PRE[i+1][(1 bit)]) + (CUR[i-1][(1 bit)]^CUR[i+1][(1 bit)]) )>>1;
				end
			end	
			
			for(i=0; i< ROW_NUMS ; i=i+1)begin  	
				for(j=0; j< 8 ; j=j+1)begin			 
					NEXT_PRE[i][:] = CUR[i][];	
				end
			end	
			
		end
		
	//-------------------------------------------------------------------------------	
	//----	DOWNSAMPLE 2*2 stride2 -------	
		
		if(function_mode[1]==0 && scale_factor==0 && !active_reg)begin 	//NEXT  SHIFT, compute r2			
			if(function_mode[0]==0)begin								// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_PRE[i][:] = (CUR[i][]>CUR[i+1][])? CUR[i][] : CUR[i+1][];
					end
				end
			end
			else begin													// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_PRE[i][:] = (CUR[i][] + CUR[i+1][])>>1;
					end
				end
			end
		end	
		
		if(function_mode[1]==0 && scale_factor==0 && active_reg)begin 	//NEXT NO SHIFT, compute r2			
			if(function_mode[0]==0)begin								// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_CUR[i][:] = (CUR[i][]>CUR[i+1][])? CUR[i][] : CUR[i+1][];
					end
				end
			end
			else begin													// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_CUR[i][:] = (CUR[i][] + CUR[i+1][])>>1;
					end
				end
			end
		end	
		
			
		if(function_mode[1]==0 && scale_factor==0 && active_reg2)begin			//downsamle 2*2, compute r3	
			if(function_mode[0]==0)begin										// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_odata[i][:] = (CUR[i][]>PRE[i][])? CUR[i][] : PRE[i][];
					end
				end
			end
			else begin															// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     	
						NEXT_odata[i][:] = (CUR[i][] + PRE[i][])>>1;
					end
				end
				
			end	
		end
		
	//---------------------------------------------------------------------------
	//----	DOWNSAMPLE 3*3 stride2 -------------
		if(function_mode[1]==0 && scale_factor==1 && !active_reg)begin 	//NEXT  SHIFT, compute col
					
			if(function_mode[0]==0)begin								// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_MID[i][:] = (CUR[i][]>CUR[i+1][])? (CUR[i][]>CUR[i+2][])? CUR[i][]: CUR[i+2][] : (CUR[i+1][]>CUR[i+2][])? CUR[i+1][]: CUR[i+2][];
					end
				end
			end
			else begin													// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_MID[i][:] = (CUR[i][] + CUR[i+1][] +CUR[i+2][])>>2 + (CUR[i][] + CUR[i+1][] +CUR[i+2][])>>4 + (CUR[i][] + CUR[i+1][] +CUR[i+2][])>>5; // * 0.343   
					end
				end
			end
		end
		
		if(function_mode[1]==0 && scale_factor==1 && active_reg)begin 	//NEXT NO SHIFT, compute col
					
			if(function_mode[0]==0)begin								// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_CUR[i][:] = (CUR[i][]>CUR[i+1][])? (CUR[i][]>CUR[i+2][])? CUR[i][]: CUR[i+2][] : (CUR[i+1][]>CUR[i+2][])? CUR[i+1][]: CUR[i+2][];
					end
				end
			end
			else begin													// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					
						NEXT_CUR[i][:] = (CUR[i][] + CUR[i+1][] +CUR[i+2][])>>2 + (CUR[i][] + CUR[i+1][] +CUR[i+2][])>>4 + (CUR[i][] + CUR[i+1][] +CUR[i+2][])>>5; // * 0.343   
					end
				end
			end
			
		end
		
		if(function_mode[1]==0 && scale_factor==1 && active_reg2)begin			//downsamle 3*3, compute row
			
			if(function_mode[0]==0)begin								// MaxPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     					// 8 items in a row (depth)
						NEXT_odata[i][:] <= (PRE[i][]>CUR[i][])? (PRE[i][]>MID[i][])? PRE[i][]: MID[i][] : (CUR[i][]>MID[i][])? CUR[i][]: MID[i][];
					end
				end
			end
			else begin									// AvgPooling
				for(i=0; i< HALF_ROWS ; i=i+2)begin  	
					for(j=0; j< 8 ; j=j+1)begin     	// 8 items in a row (depth)
						NEXT_odata[i][:] <= (CUR[i][] + PRE[i][] + MID[i][])>>2 + (CUR[i][] + PRE[i][] + MID[i][])>>4 + (CUR[i][] + PRE[i][] + MID[i][])>>5; // * 0.343 
					end
				end
			end
			
		end
		
	end
	
endmodule
	
	
	/*
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			
		end
		else begin
			if(function_mode[1]==1 && !active_reg)begin //upsamle , compute a,d / c 
				
				for(i=0; i< ROW_NUMS ; i=i+2)begin  	// compute c
					for(j=0; j< 8 ; j=j+1)begin     	// 8 items in a row (depth)
						CUR[i+1][:] <= (CUR[i][] + CUR[i+2][])>>1;
					end
				end
				
				for(i=1; i< ROW_NUMS ; i=i+2)begin  	// compute a,d
					for(j=0; j< 8 ; j=j+1)begin			// 8 items in a row 
						MID[i][:] <= (PRE[i][] + CUR[i][])>>1;
					end
				end
				
			end
			else if (function_mode[1]==1)begin      	// active_reg == 1 
				
				for(i=1; i< ROW_NUMS ; i=i+2)begin  	// compute x
					for(j=0; j< 8 ; j=j+1)begin			// 8 items in a row 
						MID[i][:] <= (PRE[i][] + CUR[i][] + (PRE[i-1][(1 bit)]^PRE[i+1][(1 bit)]) + (CUR[i-1][(1 bit)]^CUR[i+1][(1 bit)]) )>>1;
					end
				end
				
			end
		end
	end
	*/
//--------------------------------------------------------------------------------------
//----	DOWNSAMPLE 2*2 stride2 
 /*
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			
		end
		else begin
			if(function_mode[1]==0 && scale_factor==0 && !active_reg)begin 	//downsamle 2*2, compute r2
				
				if(function_mode[0]==0)begin								// MaxPooling
					for(i=0; i< HALF_ROWS ; i=i+2)begin  	
						for(j=0; j< 8 ; j=j+1)begin     					// 8 items in a row (depth)
							CUR[i][:] <= (CUR[i][]>CUR[i+1][])? CUR[i][] : CUR[i+1][];
						end
					end
				end
				else begin													// AvgPooling
					for(i=0; i< HALF_ROWS ; i=i+2)begin  	
						for(j=0; j< 8 ; j=j+1)begin     					// 8 items in a row (depth)
							CUR[i][:] <= (CUR[i][] + CUR[i+1][])>>1;
						end
					end
				end
				
			end
			else if(function_mode[1]==0 && scale_factor==0)begin			//downsamle 2*2, compute r3
				
				if(function_mode[0]==0)begin								// MaxPooling
					for(i=0; i< HALF_ROWS ; i=i+2)begin  	
						for(j=0; j< 8 ; j=j+1)begin     					// 8 items in a row (depth)
							MID[i][:] <= (CUR[i][]>PRE[i][])? CUR[i][] : PRE[i][];
						end
					end
				end
				else begin									// AvgPooling
					for(i=0; i< HALF_ROWS ; i=i+2)begin  	
						for(j=0; j< 8 ; j=j+1)begin     	// 8 items in a row (depth)
							MID[i][:] <= (CUR[i][] + PRE[i][])>>1;
						end
					end
				end
				
			end
		
		end
	end
	*/
//-------------------------------------------------------------------------------
//----	DOWNSAMPLE 3*3 stride2 
/*
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			
		end
		else begin
			if(function_mode[1]==0 && scale_factor==1 && !active_reg)begin 	//downsamle 3*3, compute col
				
				if(function_mode[0]==0)begin								// MaxPooling
					for(i=0; i< HALF_ROWS ; i=i+2)begin  	
						for(j=0; j< 8 ; j=j+1)begin     					// 8 items in a row (depth)
							CUR[i][:] <= (CUR[i][]>CUR[i+1][])? (CUR[i][]>CUR[i+2][])? CUR[i][]: CUR[i+2][] : (CUR[i+1][]>CUR[i+2][])? CUR[i+1][]: CUR[i+2][];
						end
					end
				end
				else begin													// AvgPooling
					for(i=0; i< HALF_ROWS ; i=i+2)begin  	
						for(j=0; j< 8 ; j=j+1)begin     					// 8 items in a row (depth)
							CUR[i][:] <= (CUR[i][] + CUR[i+1][] +CUR[i+2][])>>2 + (CUR[i][] + CUR[i+1][] +CUR[i+2][])>>4 + (CUR[i][] + CUR[i+1][] +CUR[i+2][])>>5; // * 0.343   
						end
					end
				end
				
			end
			else if(function_mode[1]==0 && scale_factor==1)begin			//downsamle 3*3, compute row
				
				if(function_mode[0]==0)begin								// MaxPooling
					for(i=0; i< HALF_ROWS ; i=i+2)begin  	
						for(j=0; j< 8 ; j=j+1)begin     					// 8 items in a row (depth)
							MID[i][:] <= (PRE[i][]>CUR[i][])? (PRE[i][]>MID[i][])? PRE[i][]: MID[i][] : (CUR[i][]>MID[i][])? CUR[i][]: MID[i][];
						end
					end
				end
				else begin									// AvgPooling
					for(i=0; i< HALF_ROWS ; i=i+2)begin  	
						for(j=0; j< 8 ; j=j+1)begin     	// 8 items in a row (depth)
							MID[i][:] <= (CUR[i][] + PRE[i][] + MID[i][])>>2 + (CUR[i][] + PRE[i][] + MID[i][])>>4 + (CUR[i][] + PRE[i][] + MID[i][])>>5; // * 0.343 
						end
					end
				end
				
			end
	
		end
	end
	
*/