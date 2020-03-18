module CUBE#(
	parameter NO3 = 3'd0,
	parameter NO5 = 2'd0,
	parameter ID5 = 2'd0,
	parameter NO7 = 1'd0,
	parameter ID7 = 4'd0
	
)(
	input clk,
	input rst_n,
	input stride,
	input [2:0]round,
	input [1:0]wsize,
	input [191:0]i_dat,		// 3 regX
	input [79:0]w_dat,		// 10 data 
	input [3:0]i_format,w_format,
	output reg[143:0]result
);
	parameter SA= 128;  //rega start position , i_dat[191: SA] is rega's data
	parameter SB = 64;  //i_dat[SB+63: SB] is regb's data
	parameter SC = 0;
	parameter D1 = 7;   
	parameter D2 = 15;
	parameter D3 = 23;
	parameter D4 = 31;
	parameter D5 = 39;
	parameter D6 = 47;
	parameter D7 = 55;
	parameter P1 = 8;   //data 1 start position
	parameter P2 = 16;
	parameter P3 = 24;
	parameter P4 = 32;
	parameter P5 = 40;
	parameter P6 = 48;
	parameter P7 = 56;
	parameter DATA1 = 8; // 1 data contain 8 bits , used for filling 0, ex: {DATA1{1'b0}}
	parameter DATA2 = 16;
	parameter DATA3 = 24;
	parameter DATA6 = 48;
	parameter DATA7 = 56;
	
	parameter ADD_FORMAT = 4; // tmp default
	
	integer ja,ja1,ja2,jb,jb1,jb2;
	
	reg [143:0]result_A,result_B;
	reg [71:0]locali_A,locali_B; 	
	reg [71:0]localw_A,localw_B;
	reg [143:0]mul_result_A,mul_result_B;
	reg clk_2A,clk_2B;
	
	reg [191:0]i_A,i_B;	
	reg [79:0]w_A,w_B;
	reg [3:0]i_format_dff_A,w_format_dff_A,i_format_dff_B,w_format_dff_B;
	reg [4:0]format_A,format_B;
	reg shift_direction_A,shift_direction_B;
	
	reg stride_dff_A,stride_dff_B;
	reg [1:0]wsize_dff_A,wsize_dff_B;
	reg [2:0]round_dff_A,round_dff_B;
	
	reg[143:0]result_neg;
	
	reg [17:0]test;
	wire [11:0]ttt;
	assign ttt = {NO3,9'b0} + {ID5,7'b0} + {NO5,5'b0} + {ID7,1'b0} + NO7;
	always@(posedge clk_2A or negedge rst_n)begin
		if(!rst_n)begin
			i_A<=0;
			round_dff_A<=0;
			stride_dff_A<=0;
			wsize_dff_A<=0;
			
			w_A<=0;
			w_format_dff_A<=0;
			i_format_dff_A<=0;
		end
		else begin
			i_A<=i_dat;	
			round_dff_A<=round;
			stride_dff_A<=stride;
			wsize_dff_A<=wsize;
			
			
			w_A<=w_dat;
			w_format_dff_A<=w_format;
			i_format_dff_A<=i_format;	
		end
	end
	
	always@(posedge clk_2B or negedge rst_n)begin
		if(!rst_n)begin
			i_B<=0;
			round_dff_B<=0;
			stride_dff_B<=0;
			wsize_dff_B<=0;
			
			w_B<=0;
			w_format_dff_B<=0;
			i_format_dff_B<=0;
		end
		else begin
			i_B<=i_dat;
			round_dff_B<=round;
			stride_dff_B<=stride;
			wsize_dff_B<=wsize;
			
			w_B<=w_dat;
			w_format_dff_B<=w_format;
			i_format_dff_B<=i_format;	
		end
	end
	
	always@(negedge clk or negedge rst_n)begin
		if(!rst_n)begin
			clk_2B<=1;
		end
		else begin
			clk_2B<=~clk_2B;	
		end
	end
	
	always@(negedge clk or negedge rst_n)begin
		if(!rst_n)begin
			clk_2A<=0;
			
		end
		else begin
			clk_2A<=~clk_2A;
						
		end
	end
	
	
	always@(posedge clk_2A or negedge rst_n)begin
		if(!rst_n)begin
			locali_A<=0;
			test<=0;
		end
		else begin
			test<={wsize_dff_A,stride_dff_A,round_dff_A,ttt};
			casez({wsize_dff_A,stride_dff_A,round_dff_A,ttt})
			//----------3			
				18'b00_z_zzz_110_zz_zz_zzzz_z:locali_A <= {i_A[D1:0],i_A[D2+NO3*8 :NO3*8],i_A[SB +D1:SB +0],i_A[SB +D2+NO3*8 : SB +NO3*8],i_A[SA +D1:SA +0],i_A[SA +D2+NO3*8 : SA +NO3*8]};
				18'b00_z_zzz_111_zz_zz_zzzz_z:locali_A <= {i_A[D2:0],i_A[D1+NO3*8 :NO3*8],i_A[SB +D2:SB +0],i_A[SB +D1+NO3*8 : SB +NO3*8],i_A[SA +D2:SA +0],i_A[SA +D1+NO3*8 : SA +NO3*8]};
				18'b00_z_zzz_zzz_zz_zz_zzzz_z:locali_A <= {i_A[D3+NO3*8 : NO3*8] ,i_A[SB +D3+NO3*8 :SB +NO3*8] ,i_A[SA +D3+NO3*8 : SA +NO3*8] };
			//-----------5s0r0
				18'b01_0_000_zzz_00_zz_zzzz_z:locali_A <= {i_A[D3+NO5*8:NO5*8],i_A[SB +D3+NO5*8:SB +NO5*8],i_A[SA +D3+NO5*8:SA +NO5*8]};
				18'b01_0_000_zzz_01_zz_zzzz_z:locali_A <= {{DATA3{1'b0}},i_A[SB +D3+NO5*8:SB +NO5*8],i_A[SA +D3+NO5*8:SA +NO5*8]};
				18'b01_0_000_zzz_10_zz_zzzz_z:locali_A <= {{DATA1{1'b0}},i_A[D2+P3+NO5*8: P3+NO5*8],{DATA1{1'b0}},i_A[SB +D2+P3+NO5*8:SB +P3+NO5*8],{DATA1{1'b0}},i_A[SA +D2+P3+NO5*8:SA +P3+NO5*8]};
				18'b01_0_000_zzz_11_zz_zzzz_z:locali_A <= {{DATA3{1'b0}},{DATA1{1'b0}},i_A[SB +D2+P3+NO5*8:SB +P3+NO5*8],{DATA1{1'b0}},i_A[SA +D2+P3+NO5*8:SA +P3+NO5*8]};
			//-----------5s0r1
				18'b01_0_001_zzz_00_10_zzzz_z:locali_A <= {i_A[D1:0],i_A[D2+(NO5+4)*8:(NO5+4)*8],i_A[SB +D1:SB],i_A[SB +D2+(NO5+4)*8:SB +(NO5+4)*8],i_A[SA +D1:SA],i_A[SA +D2+(NO5+4)*8:SA +(NO5+4)*8]};
				18'b01_0_001_zzz_00_11_zzzz_z:locali_A <= {i_A[D2:0],i_A[D1+(NO5+4)*8:(NO5+4)*8],i_A[SB +D2:SB],i_A[SB +D1+(NO5+4)*8:SB +(NO5+4)*8],i_A[SA +D2:SA],i_A[SA +D1+(NO5+4)*8:SA +(NO5+4)*8]};
				18'b01_0_001_zzz_00_zz_zzzz_z:locali_A <= {i_A[D3+(NO5+4)*8:(NO5+4)*8],i_A[SB +D3+(NO5+4)*8:SB +(NO5+4)*8],i_A[SA +D3+(NO5+4)*8:SA +(NO5+4)*8]};
				18'b01_0_001_zzz_01_10_zzzz_z:locali_A <= {{DATA3{1'b0}},i_A[SB +D1:SB],i_A[SB +D2+(NO5+4)*8:SB +(NO5+4)*8],i_A[SA +D1:SA],i_A[SA +D2+(NO5+4)*8:SA +(NO5+4)*8]};
				18'b01_0_001_zzz_01_11_zzzz_z:locali_A <= {{DATA3{1'b0}},i_A[SB +D2:SB],i_A[SB +D1+(NO5+4)*8:SB +(NO5+4)*8],i_A[SA +D2:SA],i_A[SA +D1+(NO5+4)*8:SA +(NO5+4)*8]};
				18'b01_0_001_zzz_01_zz_zzzz_z:locali_A <= {{DATA3{1'b0}},i_A[SB +D3+(NO5+4)*8:SB +(NO5+4)*8],i_A[SA +D3+(NO5+4)*8:SA +(NO5+4)*8]};
				18'b01_0_001_zzz_10_00_zzzz_z:locali_A <= {{DATA1{1'b0}},i_A[D1:0],i_A[D1+(NO5+7)*8:(NO5+7)*8],{DATA1{1'b0}},i_A[SB +D1:SB],i_A[SB +D1+(NO5+7)*8:SB +(NO5+7)*8],{DATA1{1'b0}},i_A[SA +D1:SA],i_A[SA +D1+(NO5+7)*8:SA +(NO5+7)*8]};
				18'b01_0_001_zzz_10_zz_zzzz_z:locali_A <= {{DATA1{1'b0}},i_A[D2+(NO5-1)*8:(NO5-1)*8],i_A[D2+(NO5-1)*8:(NO5-1)*8],{DATA1{1'b0}},i_A[SB +D2+(NO5-1)*8:SB +(NO5-1)*8],{DATA1{1'b0}},i_A[SA +D2+(NO5-1)*8:SA +(NO5-1)*8]};
				18'b01_0_001_zzz_11_00_zzzz_z:locali_A <= {{DATA3{1'b0}},{DATA1{1'b0}},i_A[SB +D1:SB],i_A[SB +D1+(NO5+7)*8:SB +(NO5+7)*8],{DATA1{1'b0}},i_A[SA +D1:SA],i_A[SA +D1+(NO5+7)*8:SA +(NO5+7)*8]}; //NO5_0
				18'b01_0_001_zzz_11_zz_zzzz_z:locali_A <= {{DATA3{1'b0}},{DATA1{1'b0}},i_A[SB +D2+(NO5-1)*8:SB +(NO5-1)*8],{DATA1{1'b0}},i_A[SA +D2+(NO5-1)*8:SA +(NO5-1)*8]};
			//------------5s1
				18'b01_1_zzz_zzz_00_11_zzzz_z:locali_A <= {i_A[D1:0],i_A[D2+(NO5+3)*8:(NO5+3)*8],i_A[SB +D1:SB],i_A[SB +D2+(NO5+3)*8:SB +(NO5+3)*8],i_A[SA +D1:SA],i_A[SA +D2+(NO5+3)*8:SA +(NO5+3)*8]};
				18'b01_1_zzz_zzz_00_zz_zzzz_z:locali_A <= {i_A[D3+(NO5*2)*8:(NO5*2)*8],i_A[SB +D3+(NO5*2)*8:SB +(NO5*2)*8],i_A[SA +D3+(NO5*2)*8:SA +(NO5*2)*8]};
				18'b01_1_zzz_zzz_01_11_zzzz_z:locali_A <= {{DATA3{1'b0}},i_A[SB +D1:SB],i_A[SB +D2+(NO5+3)*8:SB +(NO5+3)*8],i_A[SA +D1:SA],i_A[SA +D2+(NO5+3)*8:SA +(NO5+3)*8]};
				18'b01_1_zzz_zzz_01_zz_zzzz_z:locali_A <= {{DATA3{1'b0}},i_A[SB +D3+(NO5*2)*8:SB +(NO5*2)*8],i_A[SA +D3+(NO5*2)*8:SA +(NO5*2)*8]};
				18'b01_1_zzz_zzz_10_00_zzzz_z:locali_A <= {{DATA1{1'b0}},i_A[D2+P3:P3],{DATA1{1'b0}},i_A[SB +D2+P3:SB +P3],{DATA1{1'b0}},i_A[SA +D2+P3:SA +P3]};
				18'b01_1_zzz_zzz_10_01_zzzz_z:locali_A <= {{DATA1{1'b0}},i_A[D2+P5:P5],{DATA1{1'b0}},i_A[SB +D5+P5:SB +P5],{DATA1{1'b0}},i_A[SA +D2+P5:SA +P5]};
				18'b01_1_zzz_zzz_10_10_zzzz_z:locali_A <= {{DATA1{1'b0}},i_A[D1:0],i_A[D1+P7:P7],{DATA1{1'b0}},i_A[SB +D1:SB],i_A[SB +D1+P7:SB +P7],{DATA1{1'b0}},i_A[SA +D1:SA],i_A[SA +D1+P7:SA +P7]};
				18'b01_1_zzz_zzz_10_11_zzzz_z:locali_A <= {{DATA1{1'b0}},i_A[D2+P1:P1],{DATA1{1'b0}},i_A[SB +D5+P1:SB +P1],{DATA1{1'b0}},i_A[SA +D2+P1:SA +P1]};
				18'b01_1_zzz_zzz_11_00_zzzz_z:locali_A <= {{DATA3{1'b0}},{DATA1{1'b0}},i_A[SB +D2+P3:SB +P3],{DATA1{1'b0}},i_A[SA +D2+P3:SA +P3]};
				18'b01_1_zzz_zzz_11_01_zzzz_z:locali_A <= {{DATA3{1'b0}},{DATA1{1'b0}},i_A[SB +D2+P5:SB +P5],{DATA1{1'b0}},i_A[SA +D2+P5:SA +P5]};
				18'b01_1_zzz_zzz_11_10_zzzz_z:locali_A <= {{DATA3{1'b0}},{DATA1{1'b0}},i_A[SB +D1:SB],i_A[SB +D1+P7:SB +P7],{DATA1{1'b0}},i_A[SA +D1:SA],i_A[SA +D1+P7:SA +P7]};
				18'b01_1_zzz_zzz_11_11_zzzz_z:locali_A <= {{DATA3{1'b0}},{DATA1{1'b0}},i_A[SB +D2+P1:SB +P1],{DATA1{1'b0}},i_A[SA +D2+P1:SA +P1]};
			//-----------7s0r0
				18'b10_0_000_zzz_zz_zz_0000_z:locali_A <= {i_A[D3+NO7*8:NO7*8],i_A[SB +D3+NO7*8:SB +NO7*8],i_A[SA +D3+NO7*8:SA +NO7*8]};
				18'b10_0_000_zzz_zz_zz_0001_z:locali_A <= {i_A[D3+NO7*8:NO7*8],i_A[SB +D3+NO7*8:SB +NO7*8],i_A[SA +D3+NO7*8:SA +NO7*8]};
				18'b10_0_000_zzz_zz_zz_0010_z:locali_A <= {{DATA6{1'b0}},i_A[SA +D3+NO7*8:SA +NO7*8]};
				18'b10_0_000_zzz_zz_zz_0011_z:locali_A <= {i_A[D3+(NO7+3)*8:(NO7+3)*8],i_A[SB +D3+(NO7+3)*8:SB +(NO7+3)*8],i_A[SA +D3+(NO7+3)*8:SA +(NO7+3)*8]};
				18'b10_0_000_zzz_zz_zz_0100_z:locali_A <= {i_A[D3+(NO7+3)*8:(NO7+3)*8],i_A[SB +D3+(NO7+3)*8:SB +(NO7+3)*8],i_A[SA +D3+(NO7+3)*8:SA +(NO7+3)*8]};
				18'b10_0_000_zzz_zz_zz_0101_z:locali_A <= {{DATA6{1'b0}},i_A[SA +D3+(NO7+3)*8:SA +(NO7+3)*8]};
				18'b10_0_000_zzz_zz_zz_0110_z:locali_A <= {{DATA2{1'b0}},i_A[D1+(NO7+6)*8:(NO7+6)*8],{DATA2{1'b0}},i_A[SB +D1+(NO7+6)*8:SB +(NO7+6)*8],{DATA2{1'b0}},i_A[SA +D1+(NO7+6)*8:SA +(NO7+6)*8]};
				18'b10_0_000_zzz_zz_zz_0111_z:locali_A <= {{DATA2{1'b0}},i_A[D1+(NO7+6)*8:(NO7+6)*8],{DATA2{1'b0}},i_A[SB +D1+(NO7+6)*8:SB +(NO7+6)*8],{DATA2{1'b0}},i_A[SA +D1+(NO7+6)*8:SA +(NO7+6)*8]};
				18'b10_0_000_zzz_zz_zz_1000_z:locali_A <= {{DATA7{1'b0}},{DATA1{1'b0}},i_A[SA +D1+(NO7+6)*8:SA +(NO7+6)*8]};
				18'b10_0_000_zzz_zz_zz_1001_z:locali_A <= 72'b0;
			//----------7s0r1
				18'b10_0_001_zzz_zz_zz_0000_z:locali_A <= {i_A[D3+(NO7+2)*8:(NO7+2)*8],i_A[SB +D3+(NO7+2)*8:SB +(NO7+2)*8],i_A[SA +D3+(NO7+2)*8:SA +(NO7+2)*8]};
				18'b10_0_001_zzz_zz_zz_0001_z:locali_A <= {i_A[D3+(NO7+2)*8:(NO7+2)*8],i_A[SB +D3+(NO7+2)*8:SB +(NO7+2)*8],i_A[SA +D3+(NO7+2)*8:SA +(NO7+2)*8]};
				18'b10_0_001_zzz_zz_zz_0010_z:locali_A <= {{DATA6{1'b0}},i_A[SA +D3+(NO7+2)*8:SA +(NO7+2)*8]};
				18'b10_0_001_zzz_zz_zz_0011_0:locali_A <= {i_A[D3+(NO7+5)*8:(NO7+5)*8],i_A[SB +D3+(NO7+5)*8:SB +(NO7+5)*8],i_A[SA +D3+(NO7+5)*8:SA +(NO7+5)*8]};
				18'b10_0_001_zzz_zz_zz_0011_1:locali_A <= {i_A[D1:0],i_A[D2+(NO7+5)*8:(NO7+5)*8],i_A[SB +D1:SB],i_A[SB +D2+(NO7+5)*8:SB +(NO7+5)*8],i_A[SA +D1:SA ],i_A[SA +D2+(NO7+5)*8:SA +(NO7+5)*8]};
				18'b10_0_001_zzz_zz_zz_0100_0:locali_A <= {i_A[D3+(NO7+5)*8:(NO7+5)*8],i_A[SB +D3+(NO7+5)*8:SB +(NO7+5)*8],i_A[SA +D3+(NO7+5)*8:SA +(NO7+5)*8]};
				18'b10_0_001_zzz_zz_zz_0100_1:locali_A <= {i_A[D1:0],i_A[D2+(NO7+5)*8:(NO7+5)*8],i_A[SB +D1:SB],i_A[SB +D2+(NO7+5)*8:SB +(NO7+5)*8],i_A[SA +D1:SA ],i_A[SA +D2+(NO7+5)*8:SA +(NO7+5)*8]};
				18'b10_0_001_zzz_zz_zz_0101_0:locali_A <= {{DATA6{1'b0}},i_A[SA +D3+(NO7+5)*8:SA +(NO7+5)*8]};
				18'b10_0_001_zzz_zz_zz_0101_1:locali_A <= {{DATA6{1'b0}},i_A[SA +D1+NO7*8:SA +NO7*8],i_A[SA +D2:SA]};
				18'b10_0_001_zzz_zz_zz_0110_z:locali_A <= {{DATA2{1'b0}},i_A[D1+NO7*8:NO7*8],{DATA2{1'b0}},i_A[SB +D1+NO7*8:SB +NO7*8],{DATA2{1'b0}},i_A[SA +D1+NO7*8:SA +NO7*8]};
				18'b10_0_001_zzz_zz_zz_0111_z:locali_A <= {{DATA2{1'b0}},i_A[D1+NO7*8:NO7*8],{DATA2{1'b0}},i_A[SB +D1+NO7*8:SB +NO7*8],{DATA2{1'b0}},i_A[SA +D1+NO7*8:SA +NO7*8]};
				18'b10_0_001_zzz_zz_zz_1000_z:locali_A <= {{DATA7{1'b0}},{D1{1'b0}},i_A[SA +D1+NO7*8:SA +NO7*8]};
				18'b10_0_001_zzz_zz_zz_1001_z:locali_A <= 72'b0;
			//-----------7s0r2
				18'b10_0_010_zzz_zz_zz_0000_z:locali_A <= {i_A[D3+(NO7+4)*8:(NO7+4)*8],i_A[SB +D3+(NO7+4)*8:SB +(NO7+4)*8],i_A[SA +D3+(NO7+4)*8:SA +(NO7+4)*8]};
				18'b10_0_010_zzz_zz_zz_0001_z:locali_A <= {i_A[D3+(NO7+4)*8:(NO7+4)*8],i_A[SB +D3+(NO7+4)*8:SB +(NO7+4)*8],i_A[SA +D3+(NO7+4)*8:SA +(NO7+4)*8]};
				18'b10_0_010_zzz_zz_zz_0010_z:locali_A <= {{DATA6{1'b0}},i_A[SA +D3+(NO7+4)*8:SA +(NO7+4)*8]};
				18'b10_0_010_zzz_zz_zz_0011_0:locali_A <= {i_A[D2:0],i_A[D1+(NO7+7)*8:(NO7+7)*8],i_A[SB +D2+NO7*8:SB +NO7*8],i_A[SB +D1+(NO7+7)*8:SB +(NO7+7)*8],i_A[SA +D2+NO7*8:SA +NO7*8],i_A[SA +D1+(NO7+7)*8:SA +(NO7+7)*8]};
				18'b10_0_010_zzz_zz_zz_0011_1:locali_A <= {i_A[D3+(NO7-1)*8:(NO7-1)*8],i_A[SB +D3+(NO7-1)*8:SB +(NO7-1)*8],i_A[SA +D3+(NO7-1)*8:SA +(NO7-1)*8]};
				18'b10_0_010_zzz_zz_zz_0100_0:locali_A <= {i_A[D2:0],i_A[D1+(NO7+7)*8:(NO7+7)*8],i_A[SB +D2+NO7*8:SB +NO7*8],i_A[SB +D1+(NO7+7)*8:SB +(NO7+7)*8],i_A[SA +D2+NO7*8:SA +NO7*8],i_A[SA +D1+(NO7+7)*8:SA +(NO7+7)*8]};
				18'b10_0_010_zzz_zz_zz_0100_1:locali_A <= {i_A[D3+(NO7-1)*8:(NO7-1)*8],i_A[SB +D3+(NO7-1)*8:SB +(NO7-1)*8],i_A[SA +D3+(NO7-1)*8:SA +(NO7-1)*8]};
				18'b10_0_010_zzz_zz_zz_0101_0:locali_A <= {{DATA6{1'b0}},i_A[SA +D2+NO7*8:SA +NO7*8],i_A[SA +D1+(NO7+7)*8:SA +(NO7+7)*8]};
				18'b10_0_010_zzz_zz_zz_0101_1:locali_A <= {{DATA6{1'b0}},i_A[SA +D3+(NO7-1)*8:SA +(NO7-1)*8]};
				18'b10_0_010_zzz_zz_zz_0110_z:locali_A <= {{DATA2{1'b0}},i_A[D1+(NO7+2)*8:(NO7+2)*8],{DATA2{1'b0}},i_A[SB +D1+(NO7+2)*8:SB +(NO7+2)*8],{DATA2{1'b0}},i_A[SA +D1+(NO7+2)*8:SA +(NO7+2)*8]};
				18'b10_0_010_zzz_zz_zz_0111_z:locali_A <= {{DATA2{1'b0}},i_A[D1+(NO7+2)*8:(NO7+2)*8],{DATA2{1'b0}},i_A[SB +D1+(NO7+2)*8:SB +(NO7+2)*8],{DATA2{1'b0}},i_A[SA +D1+(NO7+2)*8:SA +(NO7+2)*8]};
				18'b10_0_010_zzz_zz_zz_1000_z:locali_A <= {{DATA7{1'b0}},{DATA1{1'b0}},i_A[SA +D1+(NO7+2)*8:SA +(NO7+2)*8]};
				18'b10_0_010_zzz_zz_zz_1001_z:locali_A <= 72'b0;
			//--------------7s0r3
				18'b10_0_011_zzz_zz_zz_0000_0:locali_A <= {i_A[D1:0],i_A[D2+P6:P6],i_A[SB +D1:SB],i_A[SB +D2+P6:SB +P6],i_A[SA +D1:SA],i_A[SA +D2+P6:SA +P6]};
				18'b10_0_011_zzz_zz_zz_0000_1:locali_A <= {i_A[D2:0],i_A[D1+P7:P7],i_A[SB +D2:SB],i_A[SB +D1+P7:SB +P7],i_A[SA +D2:SA],i_A[SA +D1+P7:SA +P7]};
				18'b10_0_011_zzz_zz_zz_0001_0:locali_A <= {i_A[D1:0],i_A[D2+P6:P6],i_A[SB +D1:SB],i_A[SB +D2+P6:SB +P6],i_A[SA +D1:SA],i_A[SA +D2+P6:SA +P6]};
				18'b10_0_011_zzz_zz_zz_0001_1:locali_A <= {i_A[D2:0],i_A[D1+P7:P7],i_A[SB +D2:SB],i_A[SB +D1+P7:SB +P7],i_A[SA +D2:SA],i_A[SA +D1+P7:SA +P7]};
				18'b10_0_011_zzz_zz_zz_0010_0:locali_A <= {{DATA6{1'b0}},i_A[SA +D1:SA],i_A[SA +D2+P6:SA +P6]};
				18'b10_0_011_zzz_zz_zz_0010_1:locali_A <= {{DATA6{1'b0}},i_A[SA +D2:SA],i_A[SA +D1+P7:SA +P7]};
				18'b10_0_011_zzz_zz_zz_0011_z:locali_A <= {i_A[D3+(NO7+1)*8:(NO7+1)*8],i_A[SB +D3+(NO7+1)*8:SB +(NO7+1)*8],i_A[SA +D3+(NO7+1)*8:SA +(NO7+1)*8]};
				18'b10_0_011_zzz_zz_zz_0100_z:locali_A <= {i_A[D3+(NO7+1)*8:(NO7+1)*8],i_A[SB +D3+(NO7+1)*8:SB +(NO7+1)*8],i_A[SA +D3+(NO7+1)*8:SA +(NO7+1)*8]};
				18'b10_0_011_zzz_zz_zz_0101_z:locali_A <= {{DATA6{1'b0}},i_A[SA +D3+(NO7+1)*8:SA +(NO7+1)*8]};
				18'b10_0_011_zzz_zz_zz_0110_z:locali_A <= {{DATA2{1'b0}},i_A[D1+(NO7+4)*8:(NO7+4)*8],{DATA2{1'b0}},i_A[SB +D1+(NO7+4)*8:SB +(NO7+4)*8],{DATA2{1'b0}},i_A[SA +D1+(NO7+4)*8:SA +(NO7+4)*8]};
				18'b10_0_011_zzz_zz_zz_0111_z:locali_A <= {{DATA2{1'b0}},i_A[D1+(NO7+4)*8:(NO7+4)*8],{DATA2{1'b0}},i_A[SB +D1+(NO7+4)*8:SB +(NO7+4)*8],{DATA2{1'b0}},i_A[SA +D1+(NO7+4)*8:SA +(NO7+4)*8]};
				18'b10_0_011_zzz_zz_zz_1000_z:locali_A <= {{DATA7{1'b0}},{DATA1{1'b0}},i_A[SA +D1+(NO7+4)*8:SA +(NO7+4)*8]};
				18'b10_0_011_zzz_zz_zz_1001_z:locali_A <= 72'b0;
			//--------------7s1r0
				18'b10_1_000_zzz_zz_zz_0000_z:locali_A <= {i_A[D3+(NO7*2)*8:(NO7*2)*8],i_A[SB +D3+(NO7*2)*8:SB +(NO7*2)*8],i_A[SA +D3+(NO7*2)*8:SA +(NO7*2)*8]};
				18'b10_1_000_zzz_zz_zz_0001_z:locali_A <= {i_A[D3+(NO7*2)*8:(NO7*2)*8],i_A[SB +D3+(NO7*2)*8:SB +(NO7*2)*8],i_A[SA +D3+(NO7*2)*8:SA +(NO7*2)*8]};
				18'b10_1_000_zzz_zz_zz_0010_z:locali_A <= {{DATA6{1'b0}},i_A[SA +D3+(NO7*2)*8:SA +(NO7*2)*8]};
				18'b10_1_000_zzz_zz_zz_0011_0:locali_A <= {i_A[D3+P3:P3],i_A[SB +D3+P3:SB +P3],i_A[SA +D3+P3:SA +P3]};
				18'b10_1_000_zzz_zz_zz_0011_1:locali_A <= {i_A[D3+P5:P5],i_A[SB +D3+P5:SB +P5],i_A[SA +D3+P5:SA +P5]};
				18'b10_1_000_zzz_zz_zz_0100_0:locali_A <= {i_A[D3+P3:P3],i_A[SB +D3+P3:SB +P3],i_A[SA +D3+P3:SA +P3]};
				18'b10_1_000_zzz_zz_zz_0100_1:locali_A <= {i_A[D3+P5:P5],i_A[SB +D3+P5:SB +P5],i_A[SA +D3+P5:SA +P5]};
				18'b10_1_000_zzz_zz_zz_0101_0:locali_A <= {{DATA6{1'b0}},i_A[SA +D3+P3:SA +P3]};
				18'b10_1_000_zzz_zz_zz_0101_1:locali_A <= {{DATA6{1'b0}},i_A[SA +D3+P5:SA +P5]};
				18'b10_1_000_zzz_zz_zz_0110_0:locali_A <= {{DATA2{1'b0}},i_A[D1+P6:P6],{DATA2{1'b0}},i_A[SB +D1+P6:SB +P6],{DATA2{1'b0}},i_A[SA +D1+P6:SA +P6]};
				18'b10_1_000_zzz_zz_zz_0110_1:locali_A <= {{DATA2{1'b0}},i_A[D1:0],{DATA2{1'b0}},i_A[SB +D1:SB],{DATA2{1'b0}},i_A[SA +D1:SA]};
				18'b10_1_000_zzz_zz_zz_0111_0:locali_A <= {{DATA2{1'b0}},i_A[D1+P6:P6],{DATA2{1'b0}},i_A[SB +D1+P6:SB +P6],{DATA2{1'b0}},i_A[SA +D1+P6:SA +P6]};
				18'b10_1_000_zzz_zz_zz_0111_1:locali_A <= {{DATA2{1'b0}},i_A[D1:0],{DATA2{1'b0}},i_A[SB +D1:SB],{DATA2{1'b0}},i_A[SA +D1:SA]};
				18'b10_1_000_zzz_zz_zz_1000_0:locali_A <= {{DATA7{1'b0}},{DATA1{1'b0}},i_A[SA +D1+P6:SA +P6]};
				18'b10_1_000_zzz_zz_zz_1000_1:locali_A <= {{DATA7{1'b0}},{DATA1{1'b0}},i_A[SA +D1:SA]};
				18'b10_1_000_zzz_zz_zz_1001_z:locali_A <= 72'b0;
			//------------7s1r1
				18'b10_1_001_zzz_zz_zz_0000_0:locali_A <= {i_A[D3+P4:P4],i_A[SB +D3+P4:SB +P4],i_A[SA +D3+P4:SA +P4]};
				18'b10_1_001_zzz_zz_zz_0000_1:locali_A <= {i_A[D1:0],i_A[D2+P6:P6],i_A[SB +D1:SB],i_A[SB +D2+P6:SB +P6],i_A[SA +D1:SA],i_A[SA +D2+P6:SA +P6]};
				18'b10_1_001_zzz_zz_zz_0001_0:locali_A <= {i_A[D3+P4:P4],i_A[SB +D3+P4:SB +P4],i_A[SA +D3+P4:SA +P4]};
				18'b10_1_001_zzz_zz_zz_0001_1:locali_A <= {i_A[D1:0],i_A[D2+P6:P6],i_A[SB +D1:SB],i_A[SB +D2+P6:SB +P6],i_A[SA +D1:SA],i_A[SA +D2+P6:SA +P6]};
				18'b10_1_001_zzz_zz_zz_0010_0:locali_A <= {{DATA6{1'b0}},i_A[SA +D3+P4:SA +P4]};
				18'b10_1_001_zzz_zz_zz_0010_1:locali_A <= {{DATA6{1'b0}},i_A[SA +D1:SA],i_A[SA +D2+P6:SA +P6]};
				18'b10_1_001_zzz_zz_zz_0011_0:locali_A <= {i_A[D2:0],i_A[D1+P7:P7],i_A[SB +D2:SB],i_A[SB +D1+P7:SB +P7],i_A[SA +D2:SA],i_A[SA +D1+P7:SA +P7]};
				18'b10_1_001_zzz_zz_zz_0011_1:locali_A <= {i_A[D3+P1:P1],i_A[SB +D3+P1:SB +P1],i_A[SA +D3+P1:SA +P1]};
				18'b10_1_001_zzz_zz_zz_0100_0:locali_A <= {i_A[D2:0],i_A[D1+P7:P7],i_A[SB +D2:SB],i_A[SB +D1+P7:SB +P7],i_A[SA +D2:SA],i_A[SA +D1+P7:SA +P7]};
				18'b10_1_001_zzz_zz_zz_0100_1:locali_A <= {i_A[D3+P1:P1],i_A[SB +D3+P1:SB +P1],i_A[SA +D3+P1:SA +P1]};
				18'b10_1_001_zzz_zz_zz_0101_0:locali_A <= {{DATA6{1'b0}},i_A[SA +D2:SA],i_A[SA +D1+P7:SA +P7]};
				18'b10_1_001_zzz_zz_zz_0101_1:locali_A <= {{DATA6{1'b0}},i_A[SA +D3+P1:SA +P1]};
				18'b10_1_001_zzz_zz_zz_0110_0:locali_A <= {{DATA2{1'b0}},i_A[D1+P2:P2],{DATA2{1'b0}},i_A[SB +D1+P2:SB +P2],{DATA2{1'b0}},i_A[SA +D1+P2:SA +P2]};
				18'b10_1_001_zzz_zz_zz_0110_1:locali_A <= {{DATA2{1'b0}},i_A[D1+P4:P4],{DATA2{1'b0}},i_A[SB +D1+P4:SB +P4],{DATA2{1'b0}},i_A[SA +D1+P4:SA +P4]};
				18'b10_1_001_zzz_zz_zz_0111_0:locali_A <= {{DATA2{1'b0}},i_A[D1+P2:P2],{DATA2{1'b0}},i_A[SB +D1+P2:SB +P2],{DATA2{1'b0}},i_A[SA +D1+P2:SA +P2]};
				18'b10_1_001_zzz_zz_zz_0111_1:locali_A <= {{DATA2{1'b0}},i_A[D1+P4:P4],{DATA2{1'b0}},i_A[SB +D1+P4:SB +P4],{DATA2{1'b0}},i_A[SA +D1+P4:SA +P4]};
				18'b10_1_001_zzz_zz_zz_1000_0:locali_A <= {{DATA7{1'b0}},{DATA1{1'b0}},i_A[SA +D1+P2:SA +P2]};
				18'b10_1_001_zzz_zz_zz_1000_1:locali_A <= {{DATA7{1'b0}},{DATA1{1'b0}},i_A[SA +D1+P4:SA +P4]};
				18'b10_1_001_zzz_zz_zz_1001_z:locali_A <= 72'b0;
				default:locali_A <=2;
			endcase
		end
	end
	
	always@(posedge clk_2B or negedge rst_n)begin
		if(!rst_n)begin
			locali_B<=0;
		end
		else begin
			casez({wsize_dff_B,stride_dff_B,round_dff_B,ttt})
			//----------3			
				18'b00_z_zzz_110_zz_zz_zzzz_z:locali_B <= {i_B[D1:0],i_B[D2+NO3*8 :NO3*8],i_B[SB +D1:SB +0],i_B[SB +D2+NO3*8 : SB +NO3*8],i_B[SA +D1:SA +0],i_B[SA +D2+NO3*8 : SA +NO3*8]};
				18'b00_z_zzz_111_zz_zz_zzzz_z:locali_B <= {i_B[D2:0],i_B[D1+NO3*8 :NO3*8],i_B[SB +D2:SB +0],i_B[SB +D1+NO3*8 : SB +NO3*8],i_B[SA +D2:SA +0],i_B[SA +D1+NO3*8 : SA +NO3*8]};
				18'b00_z_zzz_000_zz_zz_zzzz_z:locali_B <= {i_B[D3+NO3*8 : NO3*8] ,i_B[SB +D3+NO3*8 :SB +NO3*8] ,i_B[SA +D3+NO3*8 : SA +NO3*8] };
			//-----------5s0r0
				18'b01_0_000_zzz_00_zz_zzzz_z:locali_B <= {i_B[D3+NO5*8:NO5*8],i_B[SB +D3+NO5*8:SB +NO5*8],i_B[SA +D3+NO5*8:SA +NO5*8]};
				18'b01_0_000_zzz_01_zz_zzzz_z:locali_B <= {{DATA3{1'b0}},i_B[SB +D3+NO5*8:SB +NO5*8],i_B[SA +D3+NO5*8:SA +NO5*8]};
				18'b01_0_000_zzz_10_zz_zzzz_z:locali_B <= {{DATA1{1'b0}},i_B[D2+P3+NO5*8: P3+NO5*8],{DATA1{1'b0}},i_B[SB +D2+P3+NO5*8:SB +P3+NO5*8],{DATA1{1'b0}},i_B[SA +D2+P3+NO5*8:SA +P3+NO5*8]};
				18'b01_0_000_zzz_11_zz_zzzz_z:locali_B <= {{DATA3{1'b0}},{DATA1{1'b0}},i_B[SB +D2+P3+NO5*8:SB +P3+NO5*8],{DATA1{1'b0}},i_B[SA +D2+P3+NO5*8:SA +P3+NO5*8]};
			//-----------5s0r1
				18'b01_0_001_zzz_00_10_zzzz_z:locali_B <= {i_B[D1:0],i_B[D2+(NO5+4)*8:(NO5+4)*8],i_B[SB +D1:SB],i_B[SB +D2+(NO5+4)*8:SB +(NO5+4)*8],i_B[SA +D1:SA],i_B[SA +D2+(NO5+4)*8:SA +(NO5+4)*8]};
				18'b01_0_001_zzz_00_11_zzzz_z:locali_B <= {i_B[D2:0],i_B[D1+(NO5+4)*8:(NO5+4)*8],i_B[SB +D2:SB],i_B[SB +D1+(NO5+4)*8:SB +(NO5+4)*8],i_B[SA +D2:SA],i_B[SA +D1+(NO5+4)*8:SA +(NO5+4)*8]};
				18'b01_0_001_zzz_00_zz_zzzz_z:locali_B <= {i_B[D3+(NO5+4)*8:(NO5+4)*8],i_B[SB +D3+(NO5+4)*8:SB +(NO5+4)*8],i_B[SA +D3+(NO5+4)*8:SA +(NO5+4)*8]};
				18'b01_0_001_zzz_01_10_zzzz_z:locali_B <= {{DATA3{1'b0}},i_B[SB +D1:SB],i_B[SB +D2+(NO5+4)*8:SB +(NO5+4)*8],i_B[SA +D1:SA],i_B[SA +D2+(NO5+4)*8:SA +(NO5+4)*8]};
				18'b01_0_001_zzz_01_11_zzzz_z:locali_B <= {{DATA3{1'b0}},i_B[SB +D2:SB],i_B[SB +D1+(NO5+4)*8:SB +(NO5+4)*8],i_B[SA +D2:SA],i_B[SA +D1+(NO5+4)*8:SA +(NO5+4)*8]};
				18'b01_0_001_zzz_01_zz_zzzz_z:locali_B <= {{DATA3{1'b0}},i_B[SB +D3+(NO5+4)*8:SB +(NO5+4)*8],i_B[SA +D3+(NO5+4)*8:SA +(NO5+4)*8]};
				18'b01_0_001_zzz_10_00_zzzz_z:locali_B <= {{DATA1{1'b0}},i_B[D1:0],i_B[D1+(NO5+7)*8:(NO5+7)*8],{DATA1{1'b0}},i_B[SB +D1:SB],i_B[SB +D1+(NO5+7)*8:SB +(NO5+7)*8],{DATA1{1'b0}},i_B[SA +D1:SA],i_B[SA +D1+(NO5+7)*8:SA +(NO5+7)*8]};
				18'b01_0_001_zzz_10_zz_zzzz_z:locali_B <= {{DATA1{1'b0}},i_B[D2+(NO5-1)*8:(NO5-1)*8],i_B[D2+(NO5-1)*8:(NO5-1)*8],{DATA1{1'b0}},i_B[SB +D2+(NO5-1)*8:SB +(NO5-1)*8],{DATA1{1'b0}},i_B[SA +D2+(NO5-1)*8:SA +(NO5-1)*8]};
				18'b01_0_001_zzz_11_00_zzzz_z:locali_B <= {{DATA3{1'b0}},{DATA1{1'b0}},i_B[SB +D1:SB],i_B[SB +D1+(NO5+7)*8:SB +(NO5+7)*8],{DATA1{1'b0}},i_B[SA +D1:SA],i_B[SA +D1+(NO5+7)*8:SA +(NO5+7)*8]}; //NO5_0
				18'b01_0_001_zzz_11_zz_zzzz_z:locali_B <= {{DATA3{1'b0}},{DATA1{1'b0}},i_B[SB +D2+(NO5-1)*8:SB +(NO5-1)*8],{DATA1{1'b0}},i_B[SA +D2+(NO5-1)*8:SA +(NO5-1)*8]};
			//------------5s1
				18'b01_1_zzz_zzz_00_11_zzzz_z:locali_B <= {i_B[D1:0],i_B[D2+(NO5+3)*8:(NO5+3)*8],i_B[SB +D1:SB],i_B[SB +D2+(NO5+3)*8:SB +(NO5+3)*8],i_B[SA +D1:SA],i_B[SA +D2+(NO5+3)*8:SA +(NO5+3)*8]};
				18'b01_1_zzz_zzz_00_zz_zzzz_z:locali_B <= {i_B[D3+(NO5*2)*8:(NO5*2)*8],i_B[SB +D3+(NO5*2)*8:SB +(NO5*2)*8],i_B[SA +D3+(NO5*2)*8:SA +(NO5*2)*8]};
				18'b01_1_zzz_zzz_01_11_zzzz_z:locali_B <= {{DATA3{1'b0}},i_B[SB +D1:SB],i_B[SB +D2+(NO5+3)*8:SB +(NO5+3)*8],i_B[SA +D1:SA],i_B[SA +D2+(NO5+3)*8:SA +(NO5+3)*8]};
				18'b01_1_zzz_zzz_01_zz_zzzz_z:locali_B <= {{DATA3{1'b0}},i_B[SB +D3+(NO5*2)*8:SB +(NO5*2)*8],i_B[SA +D3+(NO5*2)*8:SA +(NO5*2)*8]};
				18'b01_1_zzz_zzz_10_00_zzzz_z:locali_B <= {{DATA1{1'b0}},i_B[D2+P3:P3],{DATA1{1'b0}},i_B[SB +D2+P3:SB +P3],{DATA1{1'b0}},i_B[SA +D2+P3:SA +P3]};
				18'b01_1_zzz_zzz_10_01_zzzz_z:locali_B <= {{DATA1{1'b0}},i_B[D2+P5:P5],{DATA1{1'b0}},i_B[SB +D5+P5:SB +P5],{DATA1{1'b0}},i_B[SA +D2+P5:SA +P5]};
				18'b01_1_zzz_zzz_10_10_zzzz_z:locali_B <= {{DATA1{1'b0}},i_B[D1:0],i_B[D1+P7:P7],{DATA1{1'b0}},i_B[SB +D1:SB],i_B[SB +D1+P7:SB +P7],{DATA1{1'b0}},i_B[SA +D1:SA],i_B[SA +D1+P7:SA +P7]};
				18'b01_1_zzz_zzz_10_11_zzzz_z:locali_B <= {{DATA1{1'b0}},i_B[D2+P1:P1],{DATA1{1'b0}},i_B[SB +D5+P1:SB +P1],{DATA1{1'b0}},i_B[SA +D2+P1:SA +P1]};
				18'b01_1_zzz_zzz_11_00_zzzz_z:locali_B <= {{DATA3{1'b0}},{DATA1{1'b0}},i_B[SB +D2+P3:SB +P3],{DATA1{1'b0}},i_B[SA +D2+P3:SA +P3]};
				18'b01_1_zzz_zzz_11_01_zzzz_z:locali_B <= {{DATA3{1'b0}},{DATA1{1'b0}},i_B[SB +D2+P5:SB +P5],{DATA1{1'b0}},i_B[SA +D2+P5:SA +P5]};
				18'b01_1_zzz_zzz_11_10_zzzz_z:locali_B <= {{DATA3{1'b0}},{DATA1{1'b0}},i_B[SB +D1:SB],i_B[SB +D1+P7:SB +P7],{DATA1{1'b0}},i_B[SA +D1:SA],i_B[SA +D1+P7:SA +P7]};
				18'b01_1_zzz_zzz_11_11_zzzz_z:locali_B <= {{DATA3{1'b0}},{DATA1{1'b0}},i_B[SB +D2+P1:SB +P1],{DATA1{1'b0}},i_B[SA +D2+P1:SA +P1]};
			//-----------7s0r0
				18'b10_0_000_zzz_zz_zz_0000_z:locali_B <= {i_B[D3+NO7*8:NO7*8],i_B[SB +D3+NO7*8:SB +NO7*8],i_B[SA +D3+NO7*8:SA +NO7*8]};
				18'b10_0_000_zzz_zz_zz_0001_z:locali_B <= {i_B[D3+NO7*8:NO7*8],i_B[SB +D3+NO7*8:SB +NO7*8],i_B[SA +D3+NO7*8:SA +NO7*8]};
				18'b10_0_000_zzz_zz_zz_0010_z:locali_B <= {{DATA6{1'b0}},i_B[SA +D3+NO7*8:SA +NO7*8]};
				18'b10_0_000_zzz_zz_zz_0011_z:locali_B <= {i_B[D3+(NO7+3)*8:(NO7+3)*8],i_B[SB +D3+(NO7+3)*8:SB +(NO7+3)*8],i_B[SA +D3+(NO7+3)*8:SA +(NO7+3)*8]};
				18'b10_0_000_zzz_zz_zz_0100_z:locali_B <= {i_B[D3+(NO7+3)*8:(NO7+3)*8],i_B[SB +D3+(NO7+3)*8:SB +(NO7+3)*8],i_B[SA +D3+(NO7+3)*8:SA +(NO7+3)*8]};
				18'b10_0_000_zzz_zz_zz_0101_z:locali_B <= {{DATA6{1'b0}},i_B[SA +D3+(NO7+3)*8:SA +(NO7+3)*8]};
				18'b10_0_000_zzz_zz_zz_0110_z:locali_B <= {{DATA2{1'b0}},i_B[D1+(NO7+6)*8:(NO7+6)*8],{DATA2{1'b0}},i_B[SB +D1+(NO7+6)*8:SB +(NO7+6)*8],{DATA2{1'b0}},i_B[SA +D1+(NO7+6)*8:SA +(NO7+6)*8]};
				18'b10_0_000_zzz_zz_zz_0111_z:locali_B <= {{DATA2{1'b0}},i_B[D1+(NO7+6)*8:(NO7+6)*8],{DATA2{1'b0}},i_B[SB +D1+(NO7+6)*8:SB +(NO7+6)*8],{DATA2{1'b0}},i_B[SA +D1+(NO7+6)*8:SA +(NO7+6)*8]};
				18'b10_0_000_zzz_zz_zz_1000_z:locali_B <= {{DATA7{1'b0}},{DATA1{1'b0}},i_B[SA +D1+(NO7+6)*8:SA +(NO7+6)*8]};
				18'b10_0_000_zzz_zz_zz_1001_z:locali_B <= 72'b0;
			//----------7s0r1
				18'b10_0_001_zzz_zz_zz_0000_z:locali_B <= {i_B[D3+(NO7+2)*8:(NO7+2)*8],i_B[SB +D3+(NO7+2)*8:SB +(NO7+2)*8],i_B[SA +D3+(NO7+2)*8:SA +(NO7+2)*8]};
				18'b10_0_001_zzz_zz_zz_0001_z:locali_B <= {i_B[D3+(NO7+2)*8:(NO7+2)*8],i_B[SB +D3+(NO7+2)*8:SB +(NO7+2)*8],i_B[SA +D3+(NO7+2)*8:SA +(NO7+2)*8]};
				18'b10_0_001_zzz_zz_zz_0010_z:locali_B <= {{DATA6{1'b0}},i_B[SA +D3+(NO7+2)*8:SA +(NO7+2)*8]};
				18'b10_0_001_zzz_zz_zz_0011_0:locali_B <= {i_B[D3+(NO7+5)*8:(NO7+5)*8],i_B[SB +D3+(NO7+5)*8:SB +(NO7+5)*8],i_B[SA +D3+(NO7+5)*8:SA +(NO7+5)*8]};
				18'b10_0_001_zzz_zz_zz_0011_1:locali_B <= {i_B[D1:0],i_B[D2+(NO7+5)*8:(NO7+5)*8],i_B[SB +D1:SB],i_B[SB +D2+(NO7+5)*8:SB +(NO7+5)*8],i_B[SA +D1:SA ],i_B[SA +D2+(NO7+5)*8:SA +(NO7+5)*8]};
				18'b10_0_001_zzz_zz_zz_0100_0:locali_B <= {i_B[D3+(NO7+5)*8:(NO7+5)*8],i_B[SB +D3+(NO7+5)*8:SB +(NO7+5)*8],i_B[SA +D3+(NO7+5)*8:SA +(NO7+5)*8]};
				18'b10_0_001_zzz_zz_zz_0100_1:locali_B <= {i_B[D1:0],i_B[D2+(NO7+5)*8:(NO7+5)*8],i_B[SB +D1:SB],i_B[SB +D2+(NO7+5)*8:SB +(NO7+5)*8],i_B[SA +D1:SA ],i_B[SA +D2+(NO7+5)*8:SA +(NO7+5)*8]};
				18'b10_0_001_zzz_zz_zz_0101_0:locali_B <= {{DATA6{1'b0}},i_B[SA +D3+(NO7+5)*8:SA +(NO7+5)*8]};
				18'b10_0_001_zzz_zz_zz_0101_1:locali_B <= {{DATA6{1'b0}},i_B[SA +D1+NO7*8:SA +NO7*8],i_B[SA +D2:SA]};
				18'b10_0_000_zzz_zz_zz_0110_z:locali_B <= {{DATA2{1'b0}},i_B[D1+NO7*8:NO7*8],{DATA2{1'b0}},i_B[SB +D1+NO7*8:SB +NO7*8],{DATA2{1'b0}},i_B[SA +D1+NO7*8:SA +NO7*8]};
				18'b10_0_000_zzz_zz_zz_0111_z:locali_B <= {{DATA2{1'b0}},i_B[D1+NO7*8:NO7*8],{DATA2{1'b0}},i_B[SB +D1+NO7*8:SB +NO7*8],{DATA2{1'b0}},i_B[SA +D1+NO7*8:SA +NO7*8]};
				18'b10_0_000_zzz_zz_zz_1000_z:locali_B <= {{DATA7{1'b0}},{D1{1'b0}},i_B[SA +D1+NO7*8:SA +NO7*8]};
				18'b10_0_000_zzz_zz_zz_1001_z:locali_B <= 72'b0;
			//-----------7s0r2
				18'b10_0_010_zzz_zz_zz_0000_z:locali_B <= {i_B[D3+(NO7+4)*8:(NO7+4)*8],i_B[SB +D3+(NO7+4)*8:SB +(NO7+4)*8],i_B[SA +D3+(NO7+4)*8:SA +(NO7+4)*8]};
				18'b10_0_010_zzz_zz_zz_0001_z:locali_B <= {i_B[D3+(NO7+4)*8:(NO7+4)*8],i_B[SB +D3+(NO7+4)*8:SB +(NO7+4)*8],i_B[SA +D3+(NO7+4)*8:SA +(NO7+4)*8]};
				18'b10_0_010_zzz_zz_zz_0010_z:locali_B <= {{DATA6{1'b0}},i_B[SA +D3+(NO7+4)*8:SA +(NO7+4)*8]};
				18'b10_0_010_zzz_zz_zz_0011_0:locali_B <= {i_B[D2:0],i_B[D1+(NO7+7)*8:(NO7+7)*8],i_B[SB +D2+NO7*8:SB +NO7*8],i_B[SB +D1+(NO7+7)*8:SB +(NO7+7)*8],i_B[SA +D2+NO7*8:SA +NO7*8],i_B[SA +D1+(NO7+7)*8:SA +(NO7+7)*8]};
				18'b10_0_010_zzz_zz_zz_0011_1:locali_B <= {i_B[D3+(NO7-1)*8:(NO7-1)*8],i_B[SB +D3+(NO7-1)*8:SB +(NO7-1)*8],i_B[SA +D3+(NO7-1)*8:SA +(NO7-1)*8]};
				18'b10_0_010_zzz_zz_zz_0100_0:locali_B <= {i_B[D2:0],i_B[D1+(NO7+7)*8:(NO7+7)*8],i_B[SB +D2+NO7*8:SB +NO7*8],i_B[SB +D1+(NO7+7)*8:SB +(NO7+7)*8],i_B[SA +D2+NO7*8:SA +NO7*8],i_B[SA +D1+(NO7+7)*8:SA +(NO7+7)*8]};
				18'b10_0_010_zzz_zz_zz_0100_1:locali_B <= {i_B[D3+(NO7-1)*8:(NO7-1)*8],i_B[SB +D3+(NO7-1)*8:SB +(NO7-1)*8],i_B[SA +D3+(NO7-1)*8:SA +(NO7-1)*8]};
				18'b10_0_010_zzz_zz_zz_0101_0:locali_B <= {{DATA6{1'b0}},i_B[SA +D2+NO7*8:SA +NO7*8],i_B[SA +D1+(NO7+7)*8:SA +(NO7+7)*8]};
				18'b10_0_010_zzz_zz_zz_0101_1:locali_B <= {{DATA6{1'b0}},i_B[SA +D3+(NO7-1)*8:SA +(NO7-1)*8]};
				18'b10_0_010_zzz_zz_zz_0110_z:locali_B <= {{DATA2{1'b0}},i_B[D1+(NO7+2)*8:(NO7+2)*8],{DATA2{1'b0}},i_B[SB +D1+(NO7+2)*8:SB +(NO7+2)*8],{DATA2{1'b0}},i_B[SA +D1+(NO7+2)*8:SA +(NO7+2)*8]};
				18'b10_0_010_zzz_zz_zz_0111_z:locali_B <= {{DATA2{1'b0}},i_B[D1+(NO7+2)*8:(NO7+2)*8],{DATA2{1'b0}},i_B[SB +D1+(NO7+2)*8:SB +(NO7+2)*8],{DATA2{1'b0}},i_B[SA +D1+(NO7+2)*8:SA +(NO7+2)*8]};
				18'b10_0_010_zzz_zz_zz_1000_z:locali_B <= {{DATA7{1'b0}},{DATA1{1'b0}},i_B[SA +D1+(NO7+2)*8:SA +(NO7+2)*8]};
				18'b10_0_010_zzz_zz_zz_1001_z:locali_B <= 72'b0;
			//--------------7s0r3
				18'b10_0_011_zzz_zz_zz_0000_0:locali_B <= {i_B[D1:0],i_B[D2+P6:P6],i_B[SB +D1:SB],i_B[SB +D2+P6:SB +P6],i_B[SA +D1:SA],i_B[SA +D2+P6:SA +P6]};
				18'b10_0_011_zzz_zz_zz_0000_1:locali_B <= {i_B[D2:0],i_B[D1+P7:P7],i_B[SB +D2:SB],i_B[SB +D1+P7:SB +P7],i_B[SA +D2:SA],i_B[SA +D1+P7:SA +P7]};
				18'b10_0_011_zzz_zz_zz_0001_0:locali_B <= {i_B[D1:0],i_B[D2+P6:P6],i_B[SB +D1:SB],i_B[SB +D2+P6:SB +P6],i_B[SA +D1:SA],i_B[SA +D2+P6:SA +P6]};
				18'b10_0_011_zzz_zz_zz_0001_1:locali_B <= {i_B[D2:0],i_B[D1+P7:P7],i_B[SB +D2:SB],i_B[SB +D1+P7:SB +P7],i_B[SA +D2:SA],i_B[SA +D1+P7:SA +P7]};
				18'b10_0_011_zzz_zz_zz_0010_0:locali_B <= {{DATA6{1'b0}},i_B[SA +D1:SA],i_B[SA +D2+P6:SA +P6]};
				18'b10_0_011_zzz_zz_zz_0010_1:locali_B <= {{DATA6{1'b0}},i_B[SA +D2:SA],i_B[SA +D1+P7:SA +P7]};
				18'b10_0_011_zzz_zz_zz_0011_z:locali_B <= {i_B[D3+(NO7+1)*8:(NO7+1)*8],i_B[SB +D3+(NO7+1)*8:SB +(NO7+1)*8],i_B[SA +D3+(NO7+1)*8:SA +(NO7+1)*8]};
				18'b10_0_011_zzz_zz_zz_0100_z:locali_B <= {i_B[D3+(NO7+1)*8:(NO7+1)*8],i_B[SB +D3+(NO7+1)*8:SB +(NO7+1)*8],i_B[SA +D3+(NO7+1)*8:SA +(NO7+1)*8]};
				18'b10_0_011_zzz_zz_zz_0101_z:locali_B <= {{DATA6{1'b0}},i_B[SA +D3+(NO7+1)*8:SA +(NO7+1)*8]};
				18'b10_0_011_zzz_zz_zz_0110_z:locali_B <= {{DATA2{1'b0}},i_B[D1+(NO7+4)*8:(NO7+4)*8],{DATA2{1'b0}},i_B[SB +D1+(NO7+4)*8:SB +(NO7+4)*8],{DATA2{1'b0}},i_B[SA +D1+(NO7+4)*8:SA +(NO7+4)*8]};
				18'b10_0_011_zzz_zz_zz_0111_z:locali_B <= {{DATA2{1'b0}},i_B[D1+(NO7+4)*8:(NO7+4)*8],{DATA2{1'b0}},i_B[SB +D1+(NO7+4)*8:SB +(NO7+4)*8],{DATA2{1'b0}},i_B[SA +D1+(NO7+4)*8:SA +(NO7+4)*8]};
				18'b10_0_011_zzz_zz_zz_1000_z:locali_B <= {{DATA7{1'b0}},{DATA1{1'b0}},i_B[SA +D1+(NO7+4)*8:SA +(NO7+4)*8]};
				18'b10_0_011_zzz_zz_zz_1001_z:locali_B <= 72'b0;
			//--------------7s1r0
				18'b10_1_000_zzz_zz_zz_0000_z:locali_B <= {i_B[D3+(NO7*2)*8:(NO7*2)*8],i_B[SB +D3+(NO7*2)*8:SB +(NO7*2)*8],i_B[SA +D3+(NO7*2)*8:SA +(NO7*2)*8]};
				18'b10_1_000_zzz_zz_zz_0001_z:locali_B <= {i_B[D3+(NO7*2)*8:(NO7*2)*8],i_B[SB +D3+(NO7*2)*8:SB +(NO7*2)*8],i_B[SA +D3+(NO7*2)*8:SA +(NO7*2)*8]};
				18'b10_1_000_zzz_zz_zz_0010_z:locali_B <= {{DATA6{1'b0}},i_B[SA +D3+(NO7*2)*8:SA +(NO7*2)*8]};
				18'b10_1_000_zzz_zz_zz_0011_0:locali_B <= {i_B[D3+P3:P3],i_B[SB +D3+P3:SB +P3],i_B[SA +D3+P3:SA +P3]};
				18'b10_1_000_zzz_zz_zz_0011_1:locali_B <= {i_B[D3+P5:P5],i_B[SB +D3+P5:SB +P5],i_B[SA +D3+P5:SA +P5]};
				18'b10_1_000_zzz_zz_zz_0100_0:locali_B <= {i_B[D3+P3:P3],i_B[SB +D3+P3:SB +P3],i_B[SA +D3+P3:SA +P3]};
				18'b10_1_000_zzz_zz_zz_0100_1:locali_B <= {i_B[D3+P5:P5],i_B[SB +D3+P5:SB +P5],i_B[SA +D3+P5:SA +P5]};
				18'b10_1_000_zzz_zz_zz_0101_0:locali_B <= {{DATA6{1'b0}},i_B[SA +D3+P3:SA +P3]};
				18'b10_1_000_zzz_zz_zz_0101_1:locali_B <= {{DATA6{1'b0}},i_B[SA +D3+P5:SA +P5]};
				18'b10_1_000_zzz_zz_zz_0110_0:locali_B <= {{DATA2{1'b0}},i_B[D1+P6:P6],{DATA2{1'b0}},i_B[SB +D1+P6:SB +P6],{DATA2{1'b0}},i_B[SA +D1+P6:SA +P6]};
				18'b10_1_000_zzz_zz_zz_0110_1:locali_B <= {{DATA2{1'b0}},i_B[D1:0],{DATA2{1'b0}},i_B[SB +D1:SB],{DATA2{1'b0}},i_B[SA +D1:SA]};
				18'b10_1_000_zzz_zz_zz_0111_0:locali_B <= {{DATA2{1'b0}},i_B[D1+P6:P6],{DATA2{1'b0}},i_B[SB +D1+P6:SB +P6],{DATA2{1'b0}},i_B[SA +D1+P6:SA +P6]};
				18'b10_1_000_zzz_zz_zz_0111_1:locali_B <= {{DATA2{1'b0}},i_B[D1:0],{DATA2{1'b0}},i_B[SB +D1:SB],{DATA2{1'b0}},i_B[SA +D1:SA]};
				18'b10_1_000_zzz_zz_zz_1000_0:locali_B <= {{DATA7{1'b0}},{DATA1{1'b0}},i_B[SA +D1+P6:SA +P6]};
				18'b10_1_000_zzz_zz_zz_1000_1:locali_B <= {{DATA7{1'b0}},{DATA1{1'b0}},i_B[SA +D1:SA]};
				18'b10_1_000_zzz_zz_zz_1001_z:locali_B <= 72'b0;
			//------------7s1r1
				18'b10_1_001_zzz_zz_zz_0000_0:locali_B <= {i_B[D3+P4:P4],i_B[SB +D3+P4:SB +P4],i_B[SA +D3+P4:SA +P4]};
				18'b10_1_001_zzz_zz_zz_0000_1:locali_B <= {i_B[D1:0],i_B[D2+P6:P6],i_B[SB +D1:SB],i_B[SB +D2+P6:SB +P6],i_B[SA +D1:SA],i_B[SA +D2+P6:SA +P6]};
				18'b10_1_001_zzz_zz_zz_0001_0:locali_B <= {i_B[D3+P4:P4],i_B[SB +D3+P4:SB +P4],i_B[SA +D3+P4:SA +P4]};
				18'b10_1_001_zzz_zz_zz_0001_1:locali_B <= {i_B[D1:0],i_B[D2+P6:P6],i_B[SB +D1:SB],i_B[SB +D2+P6:SB +P6],i_B[SA +D1:SA],i_B[SA +D2+P6:SA +P6]};
				18'b10_1_001_zzz_zz_zz_0010_0:locali_B <= {{DATA6{1'b0}},i_B[SA +D3+P4:SA +P4]};
				18'b10_1_001_zzz_zz_zz_0010_1:locali_B <= {{DATA6{1'b0}},i_B[SA +D1:SA],i_B[SA +D2+P6:SA +P6]};
				18'b10_1_001_zzz_zz_zz_0011_0:locali_B <= {i_B[D2:0],i_B[D1+P7:P7],i_B[SB +D2:SB],i_B[SB +D1+P7:SB +P7],i_B[SA +D2:SA],i_B[SA +D1+P7:SA +P7]};
				18'b10_1_001_zzz_zz_zz_0011_1:locali_B <= {i_B[D3+P1:P1],i_B[SB +D3+P1:SB +P1],i_B[SA +D3+P1:SA +P1]};
				18'b10_1_001_zzz_zz_zz_0100_0:locali_B <= {i_B[D2:0],i_B[D1+P7:P7],i_B[SB +D2:SB],i_B[SB +D1+P7:SB +P7],i_B[SA +D2:SA],i_B[SA +D1+P7:SA +P7]};
				18'b10_1_001_zzz_zz_zz_0100_1:locali_B <= {i_B[D3+P1:P1],i_B[SB +D3+P1:SB +P1],i_B[SA +D3+P1:SA +P1]};
				18'b10_1_001_zzz_zz_zz_0101_0:locali_B <= {{DATA6{1'b0}},i_B[SA +D2:SA],i_B[SA +D1+P7:SA +P7]};
				18'b10_1_001_zzz_zz_zz_0101_1:locali_B <= {{DATA6{1'b0}},i_B[SA +D3+P1:SA +P1]};
				18'b10_1_001_zzz_zz_zz_0110_0:locali_B <= {{DATA2{1'b0}},i_B[D1+P2:P2],{DATA2{1'b0}},i_B[SB +D1+P2:SB +P2],{DATA2{1'b0}},i_B[SA +D1+P2:SA +P2]};
				18'b10_1_001_zzz_zz_zz_0110_1:locali_B <= {{DATA2{1'b0}},i_B[D1+P4:P4],{DATA2{1'b0}},i_B[SB +D1+P4:SB +P4],{DATA2{1'b0}},i_B[SA +D1+P4:SA +P4]};
				18'b10_1_001_zzz_zz_zz_0111_0:locali_B <= {{DATA2{1'b0}},i_B[D1+P2:P2],{DATA2{1'b0}},i_B[SB +D1+P2:SB +P2],{DATA2{1'b0}},i_B[SA +D1+P2:SA +P2]};
				18'b10_1_001_zzz_zz_zz_0111_1:locali_B <= {{DATA2{1'b0}},i_B[D1+P4:P4],{DATA2{1'b0}},i_B[SB +D1+P4:SB +P4],{DATA2{1'b0}},i_B[SA +D1+P4:SA +P4]};
				18'b10_1_001_zzz_zz_zz_1000_0:locali_B <= {{DATA7{1'b0}},{DATA1{1'b0}},i_B[SA +D1+P2:SA +P2]};
				18'b10_1_001_zzz_zz_zz_1000_1:locali_B <= {{DATA7{1'b0}},{DATA1{1'b0}},i_B[SA +D1+P4:SA +P4]};
				18'b10_1_001_zzz_zz_zz_1001_z:locali_B <= 72'b0;
				default:locali_B <=2;
			endcase
		end
	end
	
	
	always@(posedge clk_2B   or negedge rst_n)begin
		if(!rst_n)begin
			localw_B<=0;
		end
		else begin
		
			if(wsize_dff_B==2 && ID7 == 8)localw_B <= {64'b0,w_B[79:72]}; 
			else localw_B <= w_B[71:0];
		end
	end
	
	always@(posedge clk_2A   or negedge rst_n)begin
		if(!rst_n)begin
			localw_A<=0;
		end
		else begin
		
			if(wsize_dff_A==2 && ID7 == 8)localw_A <= {64'b0,w_A[79:72]}; 
			else localw_A <= w_A[71:0];
		end
	end
	
	/* multiple */
	
	always@(posedge clk_2A  or negedge rst_n)begin  
		if(!rst_n)begin
			format_A<=0;
			shift_direction_A<=0;
		end
		else begin
			format_A<= i_format_dff_A + w_format_dff_A - ADD_FORMAT ;
			
			if(i_format_dff_A + w_format_dff_A > ADD_FORMAT)shift_direction_A<=1;
			else shift_direction_A<=0;
		end
	end
	
	always@(posedge clk_2B  or negedge rst_n)begin  
		if(!rst_n)begin
			format_B<=0;
			shift_direction_B<=0;
		end
		else begin
			format_B<= i_format_dff_B + w_format_dff_B - ADD_FORMAT ;
			
			if(i_format_dff_B + w_format_dff_B > ADD_FORMAT)shift_direction_B<=1;
			else shift_direction_B<=0;
		end
	end
	
	always@(posedge clk_2A  or negedge rst_n)begin  
		if(!rst_n)begin
			mul_result_A<=0;
		end
		else begin
			for(ja=0;ja<9;ja=ja+1)begin
				mul_result_A[16*ja +: 16] <= localw_A[8*ja +: 8] * locali_A[8*ja +: 8] ;
			end
		end
	end
	
	always@(posedge clk_2B  or negedge rst_n)begin  
		if(!rst_n)begin
			mul_result_B<=0;
		end
		else begin
			for(jb=0;jb<9;jb=jb+1)begin
				mul_result_B[16*jb +: 16] <= localw_B[8*jb +: 8] * locali_B[8*jb +: 8] ;
			end
		end
	end
	

	always@(posedge clk_2A  or negedge rst_n)begin  
		if(!rst_n)begin
			result_A<=0;
		end
		else begin
			if(shift_direction_A)begin
				for(ja1=0;ja1<9;ja1=ja1+1)begin
					result_A[16*ja1 +: 16] <= mul_result_A[16*ja1 +: 16] >> format_A;
				end
			end
			else begin
				for(ja2=0;ja2<9;ja2=ja2+1)begin
					result_A[16*ja2 +: 16] <= mul_result_A[16*ja2 +: 16] << format_A;
				end
			end
			
		end
	end
	
	always@(posedge clk_2B  or negedge rst_n)begin  
		if(!rst_n)begin
			result_B<=0;
		end
		else begin
			if(shift_direction_B)begin
				for(jb1=0;jb1<9;jb1=jb1+1)begin
					result_B[16*jb1 +: 16] <= mul_result_B[16*jb1 +: 16] >> format_B;
				end
			end
			else begin
				for(jb2=0;jb2<9;jb2=jb2+1)begin
					result_B[16*jb2 +: 16] <= mul_result_B[16*jb2 +: 16] << format_B;
				end
			end
			
		end
	end
	
	always@(negedge clk  or negedge rst_n)begin 
		if(!rst_n)begin
			result_neg<=0;
		end
		else begin
			if(clk_2A)result_neg<=result_A;
			else result_neg<=result_B;
		end
	end
	
	always@(posedge clk  or negedge rst_n)begin 
		if(!rst_n)begin
			result<=0;
		end
		else begin
			result<=result_neg;
		end
	end
	
		/*
		0 3 6
		1 4 7
		2 5 8
		current : result = [ 8 , 7 , 6 , 5 , 4 , 3 , 2 , 1 , 0 ]
		seem to be better for add_tree(?) : result = [ 8 , 5 , 2 , 7 , 4 , 1 , 6 , 3 , 0 ] 
		*/
endmodule

module W_DATA(
	input clk,
	input rst_n,
	input [1:0]ctrl,
	input [2:0]PS,
	input [1:0]Wsize,
	input [63:0] w_data,
	input w_valid,
	output reg[1599:0]w,
	output reg cnt7_7_2
);
	
	parameter COMPUTE = 3'd3;
	parameter FINI = 2'd2;
	parameter KEEP = 32'd32;
	
	reg [4:0]widcnt;	
	reg [31:0]widstart;
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			w	<=0;
			widcnt<=0;
			widstart<=0;
			cnt7_7_2<=0;	
		end
		else begin
			if(PS==COMPUTE && ctrl==FINI )begin								
				if(Wsize==2)begin	// 7 * 7
					cnt7_7_2<= ~cnt7_7_2;		
					if(cnt7_7_2==0 && w_valid)begin
						w<=w[1599:1568];
						widstart<=32;
					end
					else if(w_valid)begin
						w<=0;
						widstart<=0;
					end
				end
				else if(w_valid)begin
					w<=0;
					widstart<=0;
				end
				widcnt<=0;	
			end	
			
			
			if(w_valid)begin //3 , 5 full	
				case(widstart)
					0:w[(widcnt*64) +: 64]<=w_data;
					32:w[(widcnt*64)+KEEP +:(64+KEEP)]<=w_data;
				endcase
				widcnt<=widcnt+1;	
			end	
		end
	end
	
	
endmodule
	
module IPF#(
	parameter In_Width   = 8, 
	parameter Out_Width  = 9,
	parameter Addr_Width = 16
)(
	input clk,
	input rst_n,
	input [1:0]ctrl,			//0: end , 1:start , 2:hold   
	
	input  [63:0] i_data, 		
	input  [63:0] w_data,
	input i_valid,w_valid,
	input  [1:0] Wsize,
	input  [3:0] i_format,w_format,
	
	input  [1:0]RLPadding,
	input  stride,
	input  [3:0]wgroup,
	input  [2:0]wround,
	
	
	output [9215:0] result,
	output reg res_valid

);
	parameter STATE_Width = 3;
	parameter WAIT   = 3'd2;
	parameter COMPUTE = 3'd3;
	
	parameter START = 2'd1;
	parameter FINI = 2'd2;
	
	parameter RPadding = 2'd1;
	parameter LPadding = 2'd2;
	
	parameter RES_LEN = 144;
	
	parameter D1 = 32'd8;
	parameter D2 = 32'd6;
	parameter D3 = 32'd24;
	parameter P1 = 32'd8;
	parameter W1 = 32'd72;
	parameter KEEP = 32'd32;

	reg [STATE_Width-1:0] PS, NS;
	
	reg res_valid_tmp,res_valid_tmp1,res_valid_tmp2,res_valid_tmp3,res_valid_tmp4,res_valid_tmp5,res_valid_tmp6,res_valid_tmp7,res_valid_tmp8,res_valid_tmp9,res_valid_tmp10,res_valid_tmp11;
	
	reg [3:0]i_format_tmp,i_format_tmp1,w_format_tmp,w_format_tmp1,i_format_tmp2,w_format_tmp2;
	
	reg [63:0]rega;
	reg [63:0]regb;
	reg [63:0]regc;
	reg [63:0]regd;
	reg [63:0]rege;
	reg [63:0]regf;
	reg [63:0]regg;
	reg [63:0]regh;
	reg [191:0]icu[0:8];
	reg [191:0]icuu[0:8];
	reg [2:0]round_dff1,round_dff2,round_dff3;
	reg stride_dff1,stride_dff2,stride_dff3;
	reg [1:0]wsize_dff1,wsize_dff2,wsize_dff3,wsize_dff1_A,wsize_dff1_B;
	reg clk_2A,clk_2B;
	
	wire [1599:0]w;	 
	//reg [4:0]widcnt;			
	reg [31:0]widstart;
	reg [79:0]wcu[0:63];
	reg [79:0]wcu_A[0:63];
	reg [79:0]wcu_B[0:63];
	
	reg [31:0]wgroup_start_A,wgroup_start_B;
	reg [31:0]wgroup_dff;
	integer idx,idxx,idi;
	wire cnt7_7_2;	// 7 * 7 weight 2 round full 
	
	
	CUBE #(.NO3(0),.NO5(0),.ID5(0),.NO7(0),.ID7(0))C0(.wsize(wsize_dff3),.i_dat(icu[0]),.w_dat(wcu[0]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[0 +: RES_LEN]));
	CUBE #(.NO3(1),.NO5(0),.ID5(1),.NO7(0),.ID7(1))C1(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[1]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[144 +: RES_LEN]));
	CUBE #(.NO3(2),.NO5(0),.ID5(2),.NO7(0),.ID7(2))C2(.wsize(wsize_dff3),.i_dat(icu[2]),.w_dat(wcu[2]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[288 +: RES_LEN]));
	CUBE #(.NO3(3),.NO5(0),.ID5(3),.NO7(0),.ID7(3))C3(.wsize(wsize_dff3),.i_dat(icu[3]),.w_dat(wcu[3]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[432 +: RES_LEN]));
	CUBE #(.NO3(4),.NO5(1),.ID5(0),.NO7(0),.ID7(4))C4(.wsize(wsize_dff3),.i_dat(icu[4]),.w_dat(wcu[4]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[576 +: RES_LEN]));
	CUBE #(.NO3(5),.NO5(1),.ID5(1),.NO7(0),.ID7(5))C5(.wsize(wsize_dff3),.i_dat(icu[5]),.w_dat(wcu[5]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[720 +: RES_LEN]));
	CUBE #(.NO3(6),.NO5(1),.ID5(2),.NO7(0),.ID7(6))C6(.wsize(wsize_dff3),.i_dat(icu[6]),.w_dat(wcu[6]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[864 +: RES_LEN]));
	CUBE #(.NO3(7),.NO5(1),.ID5(3),.NO7(0),.ID7(7))C7(.wsize(wsize_dff3),.i_dat(icu[7]),.w_dat(wcu[7]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[1008 +: RES_LEN]));
	CUBE #(.NO3(0),.NO5(2),.ID5(0),.NO7(0),.ID7(8))C8(.wsize(wsize_dff3),.i_dat(icu[8]),.w_dat(wcu[8]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[1152 +: RES_LEN]));
	CUBE #(.NO3(1),.NO5(2),.ID5(1),.NO7(0),.ID7(9))C9(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[9]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[1296 +: RES_LEN]));
	CUBE #(.NO3(2),.NO5(2),.ID5(2),.NO7(0),.ID7(9))C10(.wsize(wsize_dff3),.i_dat(icu[0]),.w_dat(wcu[10]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[1440 +: RES_LEN]));
	CUBE #(.NO3(3),.NO5(2),.ID5(3),.NO7(0),.ID7(9))C11(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[11]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[1584 +: RES_LEN]));
	CUBE #(.NO3(4),.NO5(3),.ID5(0),.NO7(0),.ID7(9))C12(.wsize(wsize_dff3),.i_dat(icu[0]),.w_dat(wcu[12]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[1728 +: RES_LEN]));
	CUBE #(.NO3(5),.NO5(3),.ID5(1),.NO7(0),.ID7(9))C13(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[13]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[1872 +: RES_LEN]));
	CUBE #(.NO3(6),.NO5(3),.ID5(2),.NO7(0),.ID7(9))C14(.wsize(wsize_dff3),.i_dat(icu[0]),.w_dat(wcu[14]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[2016 +: RES_LEN]));
	CUBE #(.NO3(7),.NO5(3),.ID5(3),.NO7(0),.ID7(9))C15(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[15]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[2160 +: RES_LEN]));
	
	CUBE #(.NO3(0),.NO5(0),.ID5(0),.NO7(1),.ID7(0))C16(.wsize(wsize_dff3),.i_dat(icu[0]),.w_dat(wcu[16]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[2304 +: RES_LEN]));
	CUBE #(.NO3(1),.NO5(0),.ID5(1),.NO7(1),.ID7(1))C17(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[17]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[2448 +: RES_LEN]));
	CUBE #(.NO3(2),.NO5(0),.ID5(2),.NO7(1),.ID7(2))C18(.wsize(wsize_dff3),.i_dat(icu[2]),.w_dat(wcu[18]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[2592 +: RES_LEN]));
	CUBE #(.NO3(3),.NO5(0),.ID5(3),.NO7(1),.ID7(3))C19(.wsize(wsize_dff3),.i_dat(icu[3]),.w_dat(wcu[19]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[2736 +: RES_LEN]));
	CUBE #(.NO3(4),.NO5(1),.ID5(0),.NO7(1),.ID7(4))C20(.wsize(wsize_dff3),.i_dat(icu[4]),.w_dat(wcu[20]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[2880 +: RES_LEN]));
	CUBE #(.NO3(5),.NO5(1),.ID5(1),.NO7(1),.ID7(5))C21(.wsize(wsize_dff3),.i_dat(icu[5]),.w_dat(wcu[21]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[3024 +: RES_LEN]));
	CUBE #(.NO3(6),.NO5(1),.ID5(2),.NO7(1),.ID7(6))C22(.wsize(wsize_dff3),.i_dat(icu[6]),.w_dat(wcu[22]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[3168 +: RES_LEN]));
	CUBE #(.NO3(7),.NO5(1),.ID5(3),.NO7(1),.ID7(7))C23(.wsize(wsize_dff3),.i_dat(icu[7]),.w_dat(wcu[23]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[3312 +: RES_LEN]));
	CUBE #(.NO3(0),.NO5(2),.ID5(0),.NO7(1),.ID7(8))C24(.wsize(wsize_dff3),.i_dat(icu[8]),.w_dat(wcu[24]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[3456 +: RES_LEN]));
	CUBE #(.NO3(1),.NO5(2),.ID5(1),.NO7(1),.ID7(9))C25(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[25]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[3600 +: RES_LEN]));
	CUBE #(.NO3(2),.NO5(2),.ID5(2),.NO7(1),.ID7(9))C26(.wsize(wsize_dff3),.i_dat(icu[0]),.w_dat(wcu[26]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[3744 +: RES_LEN]));
	CUBE #(.NO3(3),.NO5(2),.ID5(3),.NO7(1),.ID7(9))C27(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[27]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[3888 +: RES_LEN]));
	CUBE #(.NO3(4),.NO5(3),.ID5(0),.NO7(1),.ID7(9))C28(.wsize(wsize_dff3),.i_dat(icu[0]),.w_dat(wcu[28]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[4032 +: RES_LEN]));
	CUBE #(.NO3(5),.NO5(3),.ID5(1),.NO7(1),.ID7(9))C29(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[29]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[4176 +: RES_LEN]));
	CUBE #(.NO3(6),.NO5(3),.ID5(2),.NO7(1),.ID7(9))C30(.wsize(wsize_dff3),.i_dat(icu[0]),.w_dat(wcu[30]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[4320 +: RES_LEN]));
	CUBE #(.NO3(7),.NO5(3),.ID5(3),.NO7(1),.ID7(9))C31(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[31]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[4464+: RES_LEN]));
	
	CUBE #(.NO3(0),.NO5(0),.ID5(0),.NO7(0),.ID7(0))C32(.wsize(wsize_dff3),.i_dat(icu[0]),.w_dat(wcu[32]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[4608 +: RES_LEN]));
	CUBE #(.NO3(1),.NO5(0),.ID5(1),.NO7(0),.ID7(1))C33(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[33]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[4752 +: RES_LEN]));
	CUBE #(.NO3(2),.NO5(0),.ID5(2),.NO7(0),.ID7(2))C34(.wsize(wsize_dff3),.i_dat(icu[2]),.w_dat(wcu[34]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[4896 +: RES_LEN]));
	CUBE #(.NO3(3),.NO5(0),.ID5(3),.NO7(0),.ID7(3))C35(.wsize(wsize_dff3),.i_dat(icu[3]),.w_dat(wcu[35]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[5040 +: RES_LEN]));
	CUBE #(.NO3(4),.NO5(1),.ID5(0),.NO7(0),.ID7(4))C36(.wsize(wsize_dff3),.i_dat(icu[4]),.w_dat(wcu[36]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[5184 +: RES_LEN]));
	CUBE #(.NO3(5),.NO5(1),.ID5(1),.NO7(0),.ID7(5))C37(.wsize(wsize_dff3),.i_dat(icu[5]),.w_dat(wcu[37]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[5328 +: RES_LEN]));
	CUBE #(.NO3(6),.NO5(1),.ID5(2),.NO7(0),.ID7(6))C38(.wsize(wsize_dff3),.i_dat(icu[6]),.w_dat(wcu[38]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[5472 +: RES_LEN]));
	CUBE #(.NO3(7),.NO5(1),.ID5(3),.NO7(0),.ID7(7))C39(.wsize(wsize_dff3),.i_dat(icu[7]),.w_dat(wcu[39]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[5616 +: RES_LEN]));
	CUBE #(.NO3(0),.NO5(2),.ID5(0),.NO7(0),.ID7(8))C40(.wsize(wsize_dff3),.i_dat(icu[8]),.w_dat(wcu[40]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[5760 +: RES_LEN]));
	CUBE #(.NO3(1),.NO5(2),.ID5(1),.NO7(0),.ID7(9))C41(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[44]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[5904 +: RES_LEN]));
	CUBE #(.NO3(2),.NO5(2),.ID5(2),.NO7(0),.ID7(9))C42(.wsize(wsize_dff3),.i_dat(icu[0]),.w_dat(wcu[42]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[6048 +: RES_LEN]));
	CUBE #(.NO3(3),.NO5(2),.ID5(3),.NO7(0),.ID7(9))C43(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[45]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[6192 +: RES_LEN]));
	CUBE #(.NO3(4),.NO5(3),.ID5(0),.NO7(0),.ID7(9))C44(.wsize(wsize_dff3),.i_dat(icu[0]),.w_dat(wcu[44]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[6336 +: RES_LEN]));
	CUBE #(.NO3(5),.NO5(3),.ID5(1),.NO7(0),.ID7(9))C45(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[45]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[6480 +: RES_LEN]));
	CUBE #(.NO3(6),.NO5(3),.ID5(2),.NO7(0),.ID7(9))C46(.wsize(wsize_dff3),.i_dat(icu[0]),.w_dat(wcu[46]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[6624 +: RES_LEN]));
	CUBE #(.NO3(7),.NO5(3),.ID5(3),.NO7(0),.ID7(9))C47(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[47]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[6768 +: RES_LEN]));
	
	CUBE #(.NO3(0),.NO5(0),.ID5(0),.NO7(1),.ID7(0))C48(.wsize(wsize_dff3),.i_dat(icu[0]),.w_dat(wcu[48]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[6912 +: RES_LEN]));
	CUBE #(.NO3(1),.NO5(0),.ID5(1),.NO7(1),.ID7(1))C49(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[49]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[7056 +: RES_LEN]));
	CUBE #(.NO3(2),.NO5(0),.ID5(2),.NO7(1),.ID7(2))C50(.wsize(wsize_dff3),.i_dat(icu[2]),.w_dat(wcu[50]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[7200 +: RES_LEN]));
	CUBE #(.NO3(3),.NO5(0),.ID5(3),.NO7(1),.ID7(3))C51(.wsize(wsize_dff3),.i_dat(icu[3]),.w_dat(wcu[51]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[7344 +: RES_LEN]));
	CUBE #(.NO3(4),.NO5(1),.ID5(0),.NO7(1),.ID7(4))C52(.wsize(wsize_dff3),.i_dat(icu[4]),.w_dat(wcu[52]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[7488 +: RES_LEN]));
	CUBE #(.NO3(5),.NO5(1),.ID5(1),.NO7(1),.ID7(5))C53(.wsize(wsize_dff3),.i_dat(icu[5]),.w_dat(wcu[53]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[7632 +: RES_LEN]));
	CUBE #(.NO3(6),.NO5(1),.ID5(2),.NO7(1),.ID7(6))C54(.wsize(wsize_dff3),.i_dat(icu[7]),.w_dat(wcu[55]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[7776 +: RES_LEN]));
	CUBE #(.NO3(7),.NO5(1),.ID5(3),.NO7(1),.ID7(7))C55(.wsize(wsize_dff3),.i_dat(icu[7]),.w_dat(wcu[55]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[7920 +: RES_LEN]));
	CUBE #(.NO3(0),.NO5(2),.ID5(0),.NO7(1),.ID7(8))C56(.wsize(wsize_dff3),.i_dat(icu[8]),.w_dat(wcu[56]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[8064 +: RES_LEN]));
	CUBE #(.NO3(1),.NO5(2),.ID5(1),.NO7(1),.ID7(9))C57(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[57]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[8208 +: RES_LEN]));
	CUBE #(.NO3(2),.NO5(2),.ID5(2),.NO7(1),.ID7(9))C58(.wsize(wsize_dff3),.i_dat(icu[0]),.w_dat(wcu[58]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[8352 +: RES_LEN]));
	CUBE #(.NO3(3),.NO5(2),.ID5(3),.NO7(1),.ID7(9))C59(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[59]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[8496 +: RES_LEN]));
	CUBE #(.NO3(4),.NO5(3),.ID5(0),.NO7(1),.ID7(9))C60(.wsize(wsize_dff3),.i_dat(icu[0]),.w_dat(wcu[60]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[8640 +: RES_LEN]));
	CUBE #(.NO3(5),.NO5(3),.ID5(1),.NO7(1),.ID7(9))C61(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[61]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[8784 +: RES_LEN]));
	CUBE #(.NO3(6),.NO5(3),.ID5(2),.NO7(1),.ID7(9))C62(.wsize(wsize_dff3),.i_dat(icu[0]),.w_dat(wcu[62]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[8928 +: RES_LEN]));
	CUBE #(.NO3(7),.NO5(3),.ID5(3),.NO7(1),.ID7(9))C63(.wsize(wsize_dff3),.i_dat(icu[1]),.w_dat(wcu[63]),.rst_n(rst_n),.clk(clk),.stride(stride_dff3),.round(round_dff3),.i_format(i_format_tmp2),.w_format(w_format_tmp2),.result(result[9072 +: RES_LEN]));
	
	/* res_valid : raising after i_data came in 4->12 cycles */
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			res_valid<=0;
			res_valid_tmp<=0;
			res_valid_tmp1<=0;
			res_valid_tmp2<=0;
			res_valid_tmp3<=0;/*
			res_valid_tmp4<=0;
			res_valid_tmp5<=0;
			res_valid_tmp6<=0;
			res_valid_tmp7<=0;
			res_valid_tmp8<=0;
			res_valid_tmp9<=0;
			res_valid_tmp10<=0;*/
			
		end
		else begin
			case(PS)
				WAIT:    res_valid_tmp<=0;
				COMPUTE: res_valid_tmp<=1;
			endcase
			res_valid_tmp1 <= res_valid_tmp;
			res_valid_tmp2 <= res_valid_tmp1;
			res_valid_tmp3 <= res_valid_tmp2;
			res_valid <= res_valid_tmp3;/*
			res_valid_tmp5 <= res_valid_tmp4;
			res_valid_tmp6 <= res_valid_tmp5;
			res_valid_tmp7 <= res_valid_tmp6;
			res_valid_tmp8 <= res_valid_tmp7;
			res_valid_tmp9 <= res_valid_tmp8;
			res_valid_tmp10 <= res_valid_tmp9;
			res_valid <= res_valid_tmp10;*/
		end
	end
	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			i_format_tmp<=0;
			i_format_tmp1<=0;
			
			w_format_tmp<=0;
			w_format_tmp1<=0;
			
			i_format_tmp2<=0;
			w_format_tmp2<=0;
		end
		else begin
			i_format_tmp <= i_format;
			i_format_tmp1 <= i_format_tmp;
			
			w_format_tmp <= w_format;
			w_format_tmp1 <= w_format_tmp;
			
			i_format_tmp2 <= i_format_tmp1;
			w_format_tmp2 <= w_format_tmp1;
		end
	end
	
	
	
	/* FSM */
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			PS<=WAIT;
		end
		else begin
			PS<=NS;
		end
	end
	always@(*)begin
		NS = PS;
		case(PS)
			WAIT:begin
				NS=WAIT;
				if(ctrl==START)begin
					NS=COMPUTE;
				end
			end
			COMPUTE:begin
				NS=COMPUTE;	
				if(ctrl==FINI)begin
					NS=WAIT;
				end	
			end
		endcase
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			wgroup_dff<=0;
		end
		else begin
			wgroup_dff<=wgroup;
		end
	end
	/* get wcu */
	/* version2: wcu is dff*/
	/*
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			wgroup_start<=0;
		end
		else begin	
			case(wgroup)
				0:wgroup_start<= 0;  		  //wgroup1
				1:begin					 	  //wgroup2
					case(Wsize)
						0:wgroup_start<= 576; //9*P1*8
						1:wgroup_start<= 800; //25*P1*4
						2:wgroup_start<= 784; //49*P1*2
					endcase
				end
			endcase
		end
	end*/
	always@(posedge clk_2A or negedge rst_n)begin
		if(!rst_n)begin
			wgroup_start_A<=0;
		end
		else begin	
			case(wgroup)
				0:wgroup_start_A<= 0;  		  //wgroup1
				1:begin					 	  //wgroup2
					case(Wsize)
						0:wgroup_start_A<= 576; //9*P1*8
						1:wgroup_start_A<= 800; //25*P1*4
						2:wgroup_start_A<= 784; //49*P1*2
					endcase
				end
			endcase
		end
	end
	
	always@(posedge clk_2B or negedge rst_n)begin
		if(!rst_n)begin
			wgroup_start_B<=0;
		end
		else begin	
			case(wgroup)
				0:wgroup_start_B<= 0;  		  //wgroup1
				1:begin					 	  //wgroup2
					case(Wsize)
						0:wgroup_start_B<= 576; //9*P1*8
						1:wgroup_start_B<= 800; //25*P1*4
						2:wgroup_start_B<= 784; //49*P1*2
					endcase
				end
			endcase
		end
	end
	
	always@(negedge clk or negedge rst_n)begin
		if(!rst_n)begin
			clk_2B<=1;
		end
		else begin
			clk_2B<=~clk_2B;	
		end
	end
	
	always@(negedge clk or negedge rst_n)begin
		if(!rst_n)begin
			clk_2A<=0;
		end
		else begin
			clk_2A<=~clk_2A;		
		end
	end
	
	always@(posedge clk_2A or negedge rst_n)begin
		if(!rst_n)begin
			wsize_dff1_A<=0;
		end
		else begin
			wsize_dff1_A<=Wsize;
		end
	end
	
	always@(posedge clk_2A or negedge rst_n)begin
		if(!rst_n)begin
			for(idxx=0; idxx<64; idxx=idxx+1)begin 
				wcu_A[idxx]<=0;
			end
		end
		else begin
			case(wsize_dff1_A)
			
				0:begin //2 layer for can syn !!
					for(idx=0; idx<8; idx=idx+1)begin   						// 8 channels
						for(idxx= (idx*8) ; idxx< 8+ (idx*8); idxx=idxx+1)begin // NO3_0 ~ NO3_7
							wcu_A[idxx]<={8'b0,w[(W1*idx)+wgroup_start_A +:W1]};
						end
					end								
				end	
				
			//------------------------------
				1:begin
						//3 layer sys work !!!
					for(idi=0;idi<4;idi=idi+1)begin  							// 4 channels
						for(idx=0;idx<4;idx=idx+1)begin							// NO5_0 ~ NO5_3
							for(idxx=0;idxx<4;idxx=idxx+1)begin					// ID5_0 ~ ID5_3
								case(idxx)
									0:wcu_A[16*idi+4*idx+idxx]<={8'b0,w[(P1*10)+wgroup_start_A+idi*(P1*25) +:D3],w[(P1*5)+wgroup_start_A+idi*(P1*25) +:D3],w[wgroup_start_A+idi*(P1*25) +:D3]};
									1:wcu_A[16*idi+4*idx+idxx]<={8'b0,24'b0,w[(P1*20)+wgroup_start_A+idi*(P1*25) +:D3],w[(P1*15)+wgroup_start_A+idi*(P1*25) +:D3]};
									2:wcu_A[16*idi+4*idx+idxx]<={8'b0,8'b0,w[(P1*13)+wgroup_start_A+idi*(P1*25) +:D2],8'b0,w[(P1*8)+wgroup_start_A+idi*(P1*25) +:D2],8'b0,w[(P1*3)+wgroup_start_A+idi*(P1*25) +:D2]};
									3:wcu_A[16*idi+4*idx+idxx]<={8'b0,24'b0,8'b0,w[(P1*23)+wgroup_start_A+idi*(P1*25) +:D2],8'b0,w[(P1*18)+wgroup_start_A+idi*(P1*25) +:D2]};
								endcase
							end
						end
					end
				end		
			//-----------------------
			
				2:begin
					
					for(idi=0;idi<2;idi=idi+1)begin								// 2 channels
						for(idx=0;idx<2;idx=idx+1)begin							// NO7_0 , NO7_1
							for(idxx=0;idxx<16;idxx=idxx+1)begin				// ID7_0 ~ ID7_8 (ID7_8(1 data))--|
															  //   |----------------------------------------------|
								case(idxx)                    //   V
									0:wcu_A[idi*32+idx*16+idxx]<={w[(P1*48)+wgroup_start_A+idi*(P1*49) +:D1],w[(P1*14)+wgroup_start_A+idi*(P1*49) +:D3],w[(P1*7)+wgroup_start_A+idi*(P1*49) +:D3],w[wgroup_start_A+idi*(P1*49) +:D3]};
									1:wcu_A[idi*32+idx*16+idxx]<={8'b0,w[(P1*35)+wgroup_start_A+idi*(P1*49) +:D3],w[(P1*28)+wgroup_start_A+idi*(P1*49) +:D3],w[(P1*21)+wgroup_start_A+idi*(P1*49) +:D3]};
									2:wcu_A[idi*32+idx*16+idxx]<={8'b0,48'b0,w[(P1*42)+wgroup_start_A+idi*(P1*49) +:D3]};
									3:wcu_A[idi*32+idx*16+idxx]<={8'b0,w[(P1*17)+wgroup_start_A+idi*(P1*49) +:D3],w[(P1*10)+wgroup_start_A+idi*(P1*49) +:D3],w[(P1*3)+wgroup_start_A+idi*(P1*49) +:D3]};
									4:wcu_A[idi*32+idx*16+idxx]<={8'b0,w[(P1*38)+wgroup_start_A+idi*(P1*49) +:D3],w[(P1*31)+wgroup_start_A+idi*(P1*49) +:D3],w[(P1*24)+wgroup_start_A+idi*(P1*49) +:D3]};
									5:wcu_A[idi*32+idx*16+idxx]<={8'b0,48'b0,w[(P1*45)+wgroup_start_A+idi*(P1*49) +:D3]};
									6:wcu_A[idi*32+idx*16+idxx]<={8'b0,16'b0,w[(P1*20)+wgroup_start_A+idi*(P1*49) +:D1],16'b0,w[(P1*13)+wgroup_start_A+idi*(P1*49) +:D1],16'b0,w[(P1*6)+wgroup_start_A+idi*(P1*49) +:D1]};
									7:wcu_A[idi*32+idx*16+idxx]<={8'b0,16'b0,w[(P1*41)+wgroup_start_A+idi*(P1*49) +:D1],16'b0,w[(P1*34)+wgroup_start_A+idi*(P1*49) +:D1],16'b0,w[(P1*27)+wgroup_start_A+idi*(P1*49) +:D1]};
									default:wcu_A[idi*32+idx*16+idxx]<=0; // ID7_9 fills 0
								endcase
							end
						end
					end	
				end
					
				//------------------
			endcase
		end
	end
	
	
	always@(posedge clk_2B or negedge rst_n)begin
		if(!rst_n)begin
			wsize_dff1_B<=0;
		end
		else begin
			wsize_dff1_B<=Wsize;
		end
	end
	
	always@(posedge clk_2B or negedge rst_n)begin
		if(!rst_n)begin
			for(idxx=0; idxx<64; idxx=idxx+1)begin 
				wcu_B[idxx]<=0;
			end
		end
		else begin
			case(wsize_dff1_B)
				0:begin //2 layer for can syn !!
					for(idx=0; idx<8; idx=idx+1)begin   						// 8 channels
						for(idxx= (idx*8) ; idxx< 8+ (idx*8); idxx=idxx+1)begin // NO3_0 ~ NO3_7
							wcu_B[idxx]<={8'b0,w[(W1*idx)+wgroup_start_B +:W1]};
						end
					end								
				end	
			//------------------------------
				1:begin
						//3 layer sys work !!!
					for(idi=0;idi<4;idi=idi+1)begin  							// 4 channels
						for(idx=0;idx<4;idx=idx+1)begin							// NO5_0 ~ NO5_3
							for(idxx=0;idxx<4;idxx=idxx+1)begin					// ID5_0 ~ ID5_3
								case(idxx)
									0:wcu_B[16*idi+4*idx+idxx]<={8'b0,w[(P1*10)+wgroup_start_B+idi*(P1*25) +:D3],w[(P1*5)+wgroup_start_B+idi*(P1*25) +:D3],w[wgroup_start_B+idi*(P1*25) +:D3]};
									1:wcu_B[16*idi+4*idx+idxx]<={8'b0,24'b0,w[(P1*20)+wgroup_start_B+idi*(P1*25) +:D3],w[(P1*15)+wgroup_start_B+idi*(P1*25) +:D3]};
									2:wcu_B[16*idi+4*idx+idxx]<={8'b0,8'b0,w[(P1*13)+wgroup_start_B+idi*(P1*25) +:D2],8'b0,w[(P1*8)+wgroup_start_B+idi*(P1*25) +:D2],8'b0,w[(P1*3)+wgroup_start_B+idi*(P1*25) +:D2]};
									3:wcu_B[16*idi+4*idx+idxx]<={8'b0,24'b0,8'b0,w[(P1*23)+wgroup_start_B+idi*(P1*25) +:D2],8'b0,w[(P1*18)+wgroup_start_B+idi*(P1*25) +:D2]};
								endcase
							end
						end
					end
				end		
			//-----------------------
			
				2:begin
					
					for(idi=0;idi<2;idi=idi+1)begin								// 2 channels
						for(idx=0;idx<2;idx=idx+1)begin							// NO7_0 , NO7_1
							for(idxx=0;idxx<16;idxx=idxx+1)begin				// ID7_0 ~ ID7_8 (ID7_8(1 data))--|
															  //   |----------------------------------------------|
								case(idxx)                    //   V
									0:wcu_B[idi*32+idx*16+idxx]<={w[(P1*48)+wgroup_start_B+idi*(P1*49) +:D1],w[(P1*14)+wgroup_start_B+idi*(P1*49) +:D3],w[(P1*7)+wgroup_start_B+idi*(P1*49) +:D3],w[wgroup_start_B+idi*(P1*49) +:D3]};
									1:wcu_B[idi*32+idx*16+idxx]<={8'b0,w[(P1*35)+wgroup_start_B+idi*(P1*49) +:D3],w[(P1*28)+wgroup_start_B+idi*(P1*49) +:D3],w[(P1*21)+wgroup_start_B+idi*(P1*49) +:D3]};
									2:wcu_B[idi*32+idx*16+idxx]<={8'b0,48'b0,w[(P1*42)+wgroup_start_B+idi*(P1*49) +:D3]};
									3:wcu_B[idi*32+idx*16+idxx]<={8'b0,w[(P1*17)+wgroup_start_B+idi*(P1*49) +:D3],w[(P1*10)+wgroup_start_B+idi*(P1*49) +:D3],w[(P1*3)+wgroup_start_B+idi*(P1*49) +:D3]};
									4:wcu_B[idi*32+idx*16+idxx]<={8'b0,w[(P1*38)+wgroup_start_B+idi*(P1*49) +:D3],w[(P1*31)+wgroup_start_B+idi*(P1*49) +:D3],w[(P1*24)+wgroup_start_B+idi*(P1*49) +:D3]};
									5:wcu_B[idi*32+idx*16+idxx]<={8'b0,48'b0,w[(P1*45)+wgroup_start_B+idi*(P1*49) +:D3]};
									6:wcu_B[idi*32+idx*16+idxx]<={8'b0,16'b0,w[(P1*20)+wgroup_start_B+idi*(P1*49) +:D1],16'b0,w[(P1*13)+wgroup_start_B+idi*(P1*49) +:D1],16'b0,w[(P1*6)+wgroup_start_B+idi*(P1*49) +:D1]};
									7:wcu_B[idi*32+idx*16+idxx]<={8'b0,16'b0,w[(P1*41)+wgroup_start_B+idi*(P1*49) +:D1],16'b0,w[(P1*34)+wgroup_start_B+idi*(P1*49) +:D1],16'b0,w[(P1*27)+wgroup_start_B+idi*(P1*49) +:D1]};
									default:wcu_B[idi*32+idx*16+idxx]<=0; // ID7_9 fills 0
								endcase
							end
						end
					end	
				end
					
				//------------------
			endcase
		end
	end
	
	always@(negedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(idxx=0; idxx<64; idxx=idxx+1)begin 
				wcu[idxx]<=0;
			end
		end
		else begin
			if(clk_2A)begin
				for(idxx=0; idxx<64; idxx=idxx+1)begin 
					wcu[idxx]<=wcu_A[idxx];
				end
			end
			else begin
				for(idxx=0; idxx<64; idxx=idxx+1)begin 
					wcu[idxx]<=wcu_B[idxx];
				end
			end
		end
	end
	
	W_DATA wdata(.clk(clk),.rst_n(rst_n),.ctrl(ctrl),.PS(PS),.Wsize(Wsize),.w_valid(w_valid),.w_data(w_data),.w(w),.cnt7_7_2(cnt7_7_2));
	
	
	/* get round,stride,wsize dff */
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			round_dff1<=0;
			round_dff2<=0;
			wsize_dff1<=0;
			wsize_dff2<=0;
			stride_dff1<=0;
			stride_dff2<=0;
			
			round_dff3<=0;
			wsize_dff3<=0;
			stride_dff3<=0;
		end
		else begin
			round_dff1<=wround;
			round_dff2<=round_dff1;
			wsize_dff1<=Wsize;
			wsize_dff2<=wsize_dff1;
			stride_dff1<=stride;
			stride_dff2<=stride_dff1;
			
			round_dff3<=round_dff2;
			wsize_dff3<=wsize_dff2;
			stride_dff3<=stride_dff2;
		end
	end
	always@(posedge clk  or negedge rst_n)begin 
		if(!rst_n)begin
			for(idx=0;idx<9;idx=idx+1)begin
				icu[idx]<=0;
			end
		end
		else begin
			for(idx=0;idx<9;idx=idx+1)begin
				icu[idx]<=icuu[idx];
			end
		end
	end
	
	/*get icu*/
	always@(posedge clk  or negedge rst_n)begin 
		if(!rst_n)begin
			for(idx=0;idx<9;idx=idx+1)begin
				icuu[idx]<=0;
			end
		end
		else begin	
			case(wsize_dff1) //** change stride -> stride_dff 2020/3
				0:begin										// 3 * 3
					if(stride_dff1 && !wgroup_dff)begin			// B C D
						for(idx=0;idx<9;idx=idx+1)begin
							icuu[idx]<={regb,regc,regd};
						end
					end
					else begin								// A B C
						for(idx=0;idx<9;idx=idx+1)begin
							icuu[idx]<={rega,regb,regc};
						end
					end
				end
				
				1:begin										// 5 * 5
					if(stride_dff1 && !wgroup_dff)begin	  		// B C D E F
						for(idx=0;idx<9;idx=idx+2)begin		// ID5_0  , ID5_2 
							icuu[idx]<={regb,regc,regd};
						end
						for(idx=1;idx<9;idx=idx+2)begin	// ID5_1  , ID5_3 
							icuu[idx]<={rege,regf,64'b0};
						end
					end
					else begin					 			// A B C D E
						for(idx=0;idx<9;idx=idx+2)begin		// ID5_0  , ID5_2 
							icuu[idx]<={rega,regb,regc};
						end
						for(idx=1;idx<9;idx=idx+2)begin		// ID5_1  , ID5_3 
							icuu[idx]<={regd,rege,64'b0};
						end
					end	
				end
				2:begin
					if(stride_dff1 && !wgroup_dff)begin			// B C D E F G H 
						for(idx=0;idx<9;idx=idx+3)begin 	// ID7_0  , ID7_3  , ID7_6
							icuu[idx]<={regb,regc,regd};
						end
						for(idx=1;idx<9;idx=idx+3)begin		// ID7_1  , ID7_4  , ID7_7
							icuu[idx]<={rege,regf,regg};
						end
						for(idx=2;idx<9;idx=idx+3)begin		// ID7_2  , ID7_5  , ID7_8
							icuu[idx]<={regh,128'b0};
						end
					end
					else begin   				  			// A B C D E F G
						for(idx=0;idx<9;idx=idx+3)begin		// ID7_0  , ID7_3  , ID7_6
							icuu[idx]<={rega,regb,regc};
						end
						for(idx=1;idx<9;idx=idx+3)begin		// ID7_1  , ID7_4  , ID7_7
							icuu[idx]<={regd,rege,regf};
						end
						for(idx=2;idx<9;idx=idx+3)begin		// ID7_2  , ID7_5  , ID7_8
							icuu[idx]<={regg,128'b0};
						end
					end	
				end
			endcase	
		end
	end
	
	
	/* get data*/
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			rega<=0;
			regb<=0;
			regc<=0;
			regd<=0;
			rege<=0;
			regf<=0;
			regg<=0;
			regh<=0;	
		end
		else begin
			if(RLPadding == RPadding)begin
				rega<=0;
				regb<=0;
				regc<=0;
				regd<=0;
				rege<=0;
				regf<=0;
				regg<=0;
				regh<=0;
			end
			else if(i_valid || RLPadding == LPadding)begin    
				case(Wsize)
					0:begin		// 3 * 3
						case(stride)
							0:begin
								rega<=regb;
								regb<=regc;
								regc<= (i_valid)? i_data : 0;
							end
							1:begin
								rega<=regb;
								regb<=regc;
								regc<=regd;
								regd<=(i_valid)? i_data : 0;
							end
						endcase
					end
					1:begin		// 5 * 5
						case(stride)
							0:begin
								rega<=regb;
								regb<=regc;
								regc<=regd;
								regd<=rege;
								rege<=(i_valid)? i_data : 0;
							end
							1:begin
								rega<=regb;
								regb<=regc;
								regc<=regd;
								regd<=rege;
								rege<=regf;
								regf<=(i_valid)? i_data : 0;
							end
						endcase
					end
					2:begin		// 7 * 7
						case(stride)
							0:begin
								rega<=regb;
								regb<=regc;
								regc<=regd;
								regd<=rege;
								rege<=regf;
								regf<=regg;
								regg<=(i_valid)? i_data : 0;
							end
							1:begin
								rega<=regb;
								regb<=regc;
								regc<=regd;
								regd<=rege;
								rege<=regf;
								regf<=regg;
								regg<=regh;
								regh<=(i_valid)? i_data : 0;
							end
						endcase
					end
				endcase
			end
			else begin
			end
			
		end
	end
	
	
endmodule	