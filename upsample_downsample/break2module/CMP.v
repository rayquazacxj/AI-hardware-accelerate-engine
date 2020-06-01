module CMP(
	input[31:0]cmp1;
	input[31:0]cmp2;
	input[31:0]cmp3;
	input [1:0]active; // 00: inactive , 10 : cmp2 , 11 :cmp3
	output reg[31:0]cmp_res;
);
	wire cmp2_res;
	
	assign cmp2_res = (cmp1 > cmp2)? cmp1 : cmp2;
	
	always@(*)begin
		case(active)
			2'b00 : cmp_res = 32'd0;
			2'b01 : cmp_res = cmp2_res;
			2'b11 : cmp_res = (cmp2_res > cmp3) ? cmp2_res : cmp3 ;
		endcase
	end

endmodule
	
			
			
	