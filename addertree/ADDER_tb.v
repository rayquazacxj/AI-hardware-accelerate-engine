`define CYCLE      30
`define SDFFILE    "./ADDER.sdf"	  
`define End_CYCLE  10000000

`define PAT3        "./add_data_33.dat"
`define PAT5        "./add_data_5.dat" 
`define PAT7        "./add_data_7.dat" 

module ADDER_tb;
  
    reg	clk;
	reg rst_n;
	reg stride;
	reg [2:0]wround;
	reg [73727:0]MUL_results;
	reg MUL_DATA_valid;
	reg [3:0] wsize;
	
	wire Psum_valid;
	wire [863:0]Psum;
	

	reg [73727:0] data_mem3[0:1];
	reg [73727:0] data_mem5[0:1];
	reg [73727:0] data_mem7[0:1];
	
	

    reg over,fin;
    integer err, exp_num, i,cnt,i_data_id,w_data_id;
	
	
/* 接線 */
`ifdef SDF
    ADDER ADDER(
`else
    ADDER ADDER(
`endif
    	.clk(clk),
		.rst_n(rst_n),  
		.wsize(wsize),
		.stride(stride),
		.wround(wround),
		.MUL_results(MUL_results),
		.MUL_DATA_valid(MUL_DATA_valid),
		.Psum_valid(Psum_valid),
		.Psum(Psum)

	);
	ADDER_mem u_ADDER_mem(
   	    .clk(clk),
   	    .Psum_valid(Psum_valid), 
   	    .Psum(Psum)
   	);
	
	/* read file data */
	initial begin
		$readmemb(`PAT3, data_mem3);
		$readmemb(`PAT5, data_mem5);
		$readmemb(`PAT7, data_mem7);
	end
	
	/* set clk */
	always begin #(`CYCLE/2) clk = ~clk;end
	
	/* create nWave & time violation detect */
	initial begin
		`ifdef SDF //syn
			$sdf_annotate(`SDFFILE,IPF); //time violation
			$fsdbDumpfile("ADDER_syn.fsdb"); //nWave
			$fsdbDumpvars("+mda");
		`else
			$fsdbDumpfile("ADDER.fsdb");
			$fsdbDumpvars("+mda");
		`endif
	end

	/* init val & give data */ 
	initial begin 
		fin=0;
		clk=0;
		rst_n=1;
		wsize=0;
		wround=0;
		stride=0;
		MUL_results=0;
		MUL_DATA_valid = 0;
		
		@(posedge clk)rst_n=0; 	//wait , when pos clk => active(rst_n=0)
		#(`CYCLE*2)rst_n=1; 		//wait 2 cyc
		@(negedge clk);
		
		MUL_results = data_mem3[0];
		MUL_DATA_valid = 1;
		
		@(negedge clk);
		MUL_DATA_valid = 0;

		/*
		@(negedge clk);
		MUL_results = data_mem5[0]; 	//stride 1
		MUL_DATA_valid = 1;
		wsize=1;
		wround = 0;
		
		@(negedge clk);
		wround = 1;
		
		@(negedge clk);
		MUL_DATA_valid = 0;
		*/
		
		@(negedge clk);
		MUL_results = data_mem7[0]; 	//stride 1
		MUL_DATA_valid = 1;
		wsize=2;
		wround = 0;
		
		@(negedge clk);
		wround = 1;
		
		@(negedge clk);
		wround = 2;
		
		@(negedge clk);
		wround = 3;
		
		@(negedge clk);
		MUL_DATA_valid = 0;
		
		repeat(30)@(negedge clk);
		fin=1;
		$display("END RUN~~\n");	

		
	end
	
	/* check ans */
	initial begin
		err=0;
		exp_num=0;
		over=0;
		
		$display("GOGO!!\n");
		
		wait(fin);
		
		@(posedge clk);
		@(posedge clk);
		$display("finish\n");
		
		over=1;
	end
	
	/* stop program brutally*/
	initial  begin
	    #`End_CYCLE ;
	    $display("-------------------------FAIL------------------------\n");
	 	$display("     Error!!! Somethings' wrong with your code !  \n");
	 	$display("-----------------------------------------------------\n");
	 	$finish;
	end
	
	/* end test */
	initial begin
		@(posedge over)
		$finish;
	    //#(`CYCLE/2); $finish;
	end
		
endmodule

module ADDER_mem (Psum_valid, Psum, clk);

	input	Psum_valid;
	input	[863:0] Psum;
	input	clk;

	reg [863:0] ADDER_M[0:2];
	integer i;

	initial begin
		for(i=0;i<3;i=i+1)begin
			ADDER_M[i] = 0;
		end
		i=0;
	end

	always@(negedge clk)begin 
		if (Psum_valid)begin
			ADDER_M[i] <= Psum;
			i <= i + 1;
		end
	end
	
endmodule