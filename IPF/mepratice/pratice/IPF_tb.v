`define CYCLE      30
`define SDFFILE    "./IPF.sdf"	  
`define End_CYCLE  10000000

`define PAT        "./pattern.dat"    
`define EXP0       "./golden0.dat"
`define EXP1       "./golden1.dat"
`define EXP2       "./golden2.dat"

`define N_PAT      256**2
`define I_Width    8
`define O_Width    9
`define A_Width    16

module IPF_tb;
    
    reg   clk; //give IPF=> reg
	reg   rst;
	reg   [1:0] mode;

	reg [`I_Width-1:0] gray_mem [0:`N_PAT-1];
	reg [`O_Width-1:0] exp_mem  [0:`N_PAT-1];

	reg [`O_Width-1:0] ipf_dbg, exp_dbg;
	
	wire [`A_Width-1:0] gray_addr, ipf_addr; //receive from IPF=>wire
	reg  [`I_Width-1:0] gray_data;
	wire [`O_Width-1:0] ipf_data;
	wire ipf_valid;

    reg gray_ready, over;
    
    integer err, exp_num, i;
	
/* 接線 */
`ifdef SDF
    IPF IPF(
`else
    IPF #(.In_Width(`I_Width), .Out_Width(`O_Width), .Addr_Width(`A_Width)) IPF(
`endif
    	.clk(clk),
		.rst(rst), 
		.mode(mode), 
        .gray_addr(gray_addr), 
        .gray_req(gray_req), 
        .gray_ready(gray_ready), 
        .gray_data(gray_data), 
		.ipf_addr(ipf_addr), 
		.ipf_valid(ipf_valid), 
		.ipf_data(ipf_data), 
		.finish(finish)
	);
			
    ipf_mem u_ipf_mem(
   	    .clk(clk),
   	    .ipf_valid(ipf_valid), 
   	    .ipf_data(ipf_data), 
   	    .ipf_addr(ipf_addr)
   	    
   	);
	
	/* read file data */
	initial begin
		$readmemh(`PAT, gray_mem);
		`ifdef MODE0
			$readmemh(`EXP0 , exp_mem);
		`elsif MODE1
			$readmemh(`EXP1 , exp_mem);
		`else
			$readmemh(`EXP2 , exp_mem);
		`endif
	end
	
	/* set clk */
	always begin #(`CYCLE/2) clk = ~clk;end
	
	/* create nWave & time violation detect */
	initial begin
		`ifdef SDF //syn
			$sdf_annotate(`SDFFILE,IPF); //time violation
			$fsdbDumpfile("IPF_syn.fsdb"); //nWave
			$fsdbDumpvars("+mda");
		`else
			$fsdbDumpfile("IPF.fsdb");
			$fsdbDumpvars("+mda");
		`endif
	end

	/* init val & give data */ 
	initial begin 
		clk=0;
		rst=0;
		@(negedge clk)rst=1; //wait , when neg clk => active(rst=1)
		#(`CYCLE*2)rst=0; //wait 2 cyc =>active(rst=0)
		@(negedge clk)gray_ready=1;
		
		mode=0;
		`ifdef MODE1
			mode=1;
		`elsif MODE2
			mode=2;
		`endif
		
		while(finish == 0)begin
			if(gray_req)begin
				gray_data = gray_mem[gray_addr];
			end else begin
				gray_data = 'hz;
			end
			@(negedge clk);
		end
		
		gray_ready=0;gray_data='hz;
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
		for(i=0;i<`N_PAT;i=i+1)begin
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
		end
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
		if((over) && (exp_num!='d0)) begin
            if (err == 0)  begin
                $display("-------------------------PASS------------------------------\n");
                $display("Congratulations!!\n");
            end else begin
                $display("-------------------------ERROR-----------------------------\n");
                $display("There are %d errors!\n", err);
            end
            $display("-----------------------------------------------------------\n");
        end
	    #(`CYCLE/2); $finish;
	end
		
endmodule

module ipf_mem(ipf_valid, ipf_data, ipf_addr, clk); 

	input	ipf_valid;
	input	[`A_Width-1:0] ipf_addr;
	input	[`O_Width-1:0] ipf_data;
	input	clk;

	reg [`O_Width-1:0] ipf_M [0:`N_PAT];
	integer i;
	
	initial begin
		for(i=0;i<`N_PAT;i=i+1)begin
			ipf_M[i]=0;
		end
	end
	
	always@(negedge clk)begin
		if(ipf_valid)ipf_M[ipf_addr]<=ipf_data;
	end
	
endmodule
