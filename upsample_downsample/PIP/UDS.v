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
					NEXT_III[i+1][{j[27:0],4'b0111} +:HALF_DATA_PLUS1] = II[i][{j[27:0],4'b1000} +:HALF_DATA] + II[i+2][{j[27:0],4'b1000} +:HALF_DATA] + II[i+1][{j[27:0],4'b0111}]; // COL_lasthalf 		
					NEXT_V[i+1][{j[27:0],4'b0111} +:HALF_DATA_PLUS1]   = II[i][{j[27:0],4'b1000} +:HALF_DATA] + II[i+2][{j[27:0],4'b1000} +:HALF_DATA] + II[i+1][{j[27:0],4'b0111}];	
				//---
				
					NEXT_IV[i][j<<SHIFT_ADATA +:HALF_DATA] = (II[i][j<<SHIFT_ADATA +:HALF_DATA] + III[i][j<<SHIFT_ADATA +:HALF_DATA])>>1; // EVEN_ROW_firsthalf			
				
				//------
					NEXT_odata[{i[24:0],7'd0}+ {j[27:0],4'b0111} +: ONE_DATA] = IV[i][{j[27:0],4'b1000} +:HALF_DATA] + V[i][{j[27:0],4'b1000} +:HALF_DATA] + IV[{j[27:0],4'b0111}];
				
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
	//----	DOWNSAMPLE 2*2 stride2  MAX-------------
		if(function_mode[1]==0 && function_mode[0]==0 && scale_factor==0)begin
			for(i=0; i<HALF_ROWS ; i=i+2)begin	
				NEXT_III[i] = II[i];
				for(j=0; j< 8 ; j=j+1)begin
					NEXT_II[i[31:1]][j<<SHIFT_ADATA +:ONE_DATA] = (I[i][j<<SHIFT_ADATA +:ONE_DATA] > I[i+1][j<<SHIFT_ADATA +:ONE_DATA])? I[i][j<<SHIFT_ADATA +:ONE_DATA] : I[i+1][j<<SHIFT_ADATA +:ONE_DATA];		
				end
			end	
			
			for(i=0; i<4 ; i=i+1)begin	
				NEXT_III[i] = II[i];
			//-----
				for(j=0; j< 8 ; j=j+1)begin
					NEXT_odata[{i[24:0],7'd0}+{j[27:0],4'd0} +: ONE_DATA] = ( III[i][j<<SHIFT_ADATA +:ONE_DATA] > II[i][j<<SHIFT_ADATA +:ONE_DATA])? III[i][j<<SHIFT_ADATA +:ONE_DATA] : II[i][j<<SHIFT_ADATA +:ONE_DATA];
				end
				
			end
			
		end
		
	//------------------------------------------	
	//----	DOWNSAMPLE 2*2 stride2  AVG-------------
		/*
		1. NEXT_odata_valid = ?
		*/	
		if(function_mode[1]==0 && function_mode[0]==1 && scale_factor==0)begin
			for(i=0; i<HALF_ROWS ; i=i+2)begin	
				for(j=0; j< 8 ; j=j+1)begin
					NEXT_II[i][j<<SHIFT_ADATA +:HALF_DATA] = (I[i][j<<SHIFT_ADATA +:HALF_DATA] + I[i+1][j<<SHIFT_ADATA +:HALF_DATA])>>1; // COL_firsthalf
				//---
					NEXT_III[i[31:1]][{j[27:0],4'b0111} +:HALF_DATA_PLUS1] = II[i][{j[27:0],4'b1000} +:HALF_DATA] + II[i+1][{j[27:0],4'b1000} +:HALF_DATA] + II[i][{j[27:0],4'b0111}];
					NEXT_IV[i[31:1]+4][{j[27:0],4'b0111} +:HALF_DATA_PLUS1] = II[i][{j[27:0],4'b1000} +:HALF_DATA] + II[i+1][{j[27:0],4'b1000} +:HALF_DATA] + II[i][{j[27:0],4'b0111}];
				end
			end	
			
			for(i=0; i<4 ; i=i+1)begin
				for(j=0; j< 8 ; j=j+1)begin
					NEXT_IV[i][j<<SHIFT_ADATA +:HALF_DATA] = (III[i][j<<SHIFT_ADATA +:HALF_DATA] + II[i][j<<SHIFT_ADATA +:HALF_DATA])>>1; // COL_firsthalf
				//---------
					NEXT_odata[{i[24:0],7'd0}+{j[27:0],4'd0} +: ONE_DATA] = IV[i][{j[27:0],4'b1000} +:HALF_DATA] + IV[i+4][{j[27:0],4'b1000} +:HALF_DATA] + IV[i][{j[27:0],4'b0111}];
				end
			end
		end

	
	//------------------------------------------	
	//----	DOWNSAMPLE 3*3 stride2  MAX-------------
		/*
		1. NEXT_odata_valid = ?
		2. GH"X"?
		*/
		if(function_mode[1]==0 && function_mode[0]==0 && scale_factor==1)begin
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
		
	//------------------------------------------	
	//----	DOWNSAMPLE 3*3 stride2  AVG-------------
	
		if(function_mode[1]==0 && function_mode[0]==1 && scale_factor==1)begin
		/*
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
			*/
		end
	
	
	
	
	
	
	
	
	
	
	

		
	end
	
endmodule
	
	