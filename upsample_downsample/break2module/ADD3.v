module ADD2(
	input[31:0]a;
	input[31:0]b;
	input[31:0]c;
	//input active; 
	output reg[31:0]ADD3_res;
);
	
	always@(*)begin
		ADD3_res = a + b + c;
	/*
		case(active)
			1'b0 : ADD3_res = 32'd0;
			1'b1 : ADD3_res = a + b+ c;
		endcase*/
	end

endmodule