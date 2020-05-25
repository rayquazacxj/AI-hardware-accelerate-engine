`define CYCLE      30
`define SDFFILE    "./UDS.sdf"	  
`define End_CYCLE  10000000


`define PAT        "./uds_downsample2_input.dat" 
`define ANS        "./uds_downsample2_ans.dat" 
 

module UDS_tb;
    localparam A = 7'd64;
	
	reg clk;
	reg rst_n;
	reg active;
	reg [A*32-1:0]idata;
 	reg idata_valid;
	reg [1:0]scale_factor;
	reg [1:0]function_mode;
	
	wire [2*(A-8)*32-1:0]odata; //2A
	wire odata_valid;
	
	wire finish;
	
	
	reg [A*32-1:0] idata_mem [0:5];
	//reg [2*(A-8)*32-1:0]odata_mem[0:2];
	
    reg over;
    integer err, exp_num, i;
	
	
/* 接線 */

    UDS  #(.A(A))UDS (

    	.clk(clk),
		.rst_n(rst_n),  
        .active(active),
		.idata(idata),
		.idata_valid(idata_valid),
		.scale_factor(scale_factor),
		.function_mode(function_mode),
		
		.odata(odata),
		.odata_valid(odata_valid)
			
	);
	
	/*		
    ipf_mem u_ipf_mem(
   	    .clk(clk),
   	    .res_valid(res_valid),
   	    .res(re)
   	);*/
	
	/* read file data */
	initial begin
	
		$readmemb(`PAT, idata_mem);
		//$readmemb(`ANS , odata_mem);
	
				
		
	end
	
	/* set clk */
	always begin #(`CYCLE/2) clk = ~clk;end
	
	/* create nWave & time violation detect */
	initial begin
		`ifdef SDF //syn
			$sdf_annotate(`SDFFILE,IPF); 	//time violation 
			$fsdbDumpfile("UDS_syn.fsdb"); 	//nWave
			$fsdbDumpvars("+mda");
		`else
			$fsdbDumpfile("UDS.fsdb");
			$fsdbDumpvars("+mda");
		`endif
	end

	/* init val & give data */ 
	initial begin 
		i=0;
		
		clk=0;
		rst_n=1;
		active=0;
		idata_valid=0;
		
	//----
	//  downsample2_max
		scale_factor =	0;
		function_mode = 0;
	//----
	
		@(posedge clk)rst_n=0; 		//wait , when pos clk => active(rst=0)
		#(`CYCLE*2)rst_n=1; 		//wait 2 cyc
		@(negedge clk);
		
	//----------------------------------A,B
		idata = idata_mem[i];
		idata_valid = 1;
		active = 0;
		i=i+1;
		@(negedge clk);
		
		idata = idata_mem[i];
		idata_valid = 1;
		active = 1;
		i=i+1;
		@(negedge clk);
	//----------------------------------
		idata_valid = 0;
		active = 0;
		@(negedge clk);
	//---------------------------------------------------------
	//----------------------------------C,D
		idata = idata_mem[i];
		idata_valid = 1;
		active = 0;
		i=i+1;
		@(negedge clk);
		
		idata = idata_mem[i];
		idata_valid = 1;
		active = 1;
		i=i+1;
		@(negedge clk);
	//----------------------------------
		idata_valid = 0;
		active = 0;
		@(negedge clk);
	//---------------------------------------------------------
		//----------------------------------E,F
		idata = idata_mem[i];
		idata_valid = 1;
		active = 0;
		i=i+1;
		@(negedge clk);
		
		idata = idata_mem[i];
		idata_valid = 1;
		active = 1;
		i=i+1;
		@(negedge clk);
	//----------------------------------
		idata_valid = 0;
		active = 0;
		@(negedge clk);
	//---------------------------------------------------------
		repeat(10)@(negedge clk);
		$display("END RUN\n");	
		over=1;
		

		
	end
	
	/* check ans */
	initial begin
		err=0;
		exp_num=0;
		over=0;
		
		$display("GOGO!!\n");
		#(`CYCLE*3);
		
		wait(finish); // wait until (true)
		
		@(posedge clk);
		@(posedge clk);
		$display("finish\n");
		
		/*
		for(i=0;i<`ANS_NUM;i=i+1)begin
			exp_dbg=exp_mem[i]; ipf_dbg= u_ipf_mem.ipf_M[i];
			if(exp_dbg == ipf_dbg)begin
				err = err;
			end
			else begin
				err=err+1;
				if (err<=10)$display("output pixel %d is wrong!\n",i);
				else $display("err_num > 11\n");
			end
			exp_num = exp_num+1;
		end*/
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
		/*
		if((over) && (exp_num!='d0)) begin
            if (err == 0)  begin
                $display("-------------------------PASS------------------------------\n");
                $display("Congratulations!!\n");
            end else begin
                $display("-------------------------ERROR-----------------------------\n");
                $display("There are %d errors!\n", err);
            end
            $display("-----------------------------------------------------------\n");
        end*/
	    #(`CYCLE/2); $finish;
	end
		
endmodule
/*
module ipf_mem(res_valid, res, clk); 

	input	res_valid;
	input	[1151:0] res;
	input	clk;

	reg [1151:0] ipf_M [0:`ANS_NUM];
	integer i,id;
	
	initial begin
		for(i=0;i<`ANS_NUM;i=i+1)begin
			ipf_M[i]=0;
		end
		id=0;
	end
	
	always@(negedge clk)begin
		if(res_valid)begin
			ipf_M[id]<=res;
			id=id+1;
		end
	end
	
endmodule
*/