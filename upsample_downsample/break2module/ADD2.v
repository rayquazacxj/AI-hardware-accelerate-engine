module ADD2(
	input[31:0]a;
	input[31:0]b;
	//input active; 
	output reg[31:0]ADD2_res;
);
	
	always@(*)begin
		ADD2_res = (a + b)>>1;
	/*
		case(active)
			1'b0 : ADD2_res = 32'd0;
			1'b1 : ADD2_res = (a + b)>>1;
		endcase*/
	end

endmodule