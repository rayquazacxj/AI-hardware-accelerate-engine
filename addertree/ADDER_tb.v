`define CYCLE      30
`define SDFFILE    "./ADDER.sdf"	  
`define End_CYCLE  10000000

`define PAT        "./add_data_3.dat" 

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
	

	reg [73727:0] data_mem[0:1];
	

    reg over;
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
		$readmemb(`PAT, data_mem);			
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
	
		clk=0;
		rst_n=1;
		wsize=0;
		wround=0;
		stride=0;
		
		@(posedge clk)rst_n=0; 	//wait , when pos clk => active(rst_n=0)
		#(`CYCLE*2)rst_n=1; 		//wait 2 cyc
		@(negedge clk);
		
		MUL_results = data_mem[0];
		MUL_DATA_valid = 1;
		
		@(negedge clk);
		MUL_DATA_valid = 0;
		
/*
//------------------------------------3*3 stride 1
		w_valid=1;
		repeat(18)begin //3 * 3
			w_data =w_mem[w_data_id];
			w_data_id = w_data_id+1;
			@(negedge clk);
		end
		w_valid=0;
		$display("END in W\n");	
		
		i_valid=1;
		repeat(2)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		ctrl=1; // start
		repeat(6)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		$display("END compute  0-7 I ~\n");
		
		i_data_id = 0;
		repeat(8)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		$display("END compute first group \n");	
		
//----------------------------------------------
	
		wgroup=1;
		i_data_id = 0;
		ctrl=2;// hold
		repeat(2)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		ctrl=1; // start
		repeat(6)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		$display("END compute  0-7 I \n");
		
		i_data_id = 0;
		repeat(8)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		$display("END compute second group \n");
		
		i_valid=0;
		
		ctrl=0; // end 
		
		
		$display("END RUN\n");	
*/	
		
	end
	
	/* check ans */
	initial begin
		err=0;
		exp_num=0;
		over=0;
		
		$display("GOGO!!\n");
		#(`CYCLE*3);
		# (`End_CYCLE/3);
		//wait(finish); // wait until (true)
		
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
		
	    #(`CYCLE/2); $finish;
	end
		
endmodule

module ADDER_mem (Psum_valid, Psum, clk);

	input	Psum_valid;
	input	[863:0] Psum;
	input	clk;

	reg [863:0] ADDER_M ;
	integer i;

	initial begin
		ADDER_M = 0;
	end

	always@(negedge clk) 
		if (Psum_valid) ADDER_M <= Psum;

endmodule