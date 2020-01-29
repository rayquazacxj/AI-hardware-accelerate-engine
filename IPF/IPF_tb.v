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
    
    reg   clk;
	reg   rst;
	reg   [1:0] mode;

	reg [`I_Width-1:0] gray_mem [0:`N_PAT-1];
	reg [`O_Width-1:0] exp_mem  [0:`N_PAT-1];

	reg [`O_Width-1:0] ipf_dbg, exp_dbg;
	
	wire [`A_Width-1:0] gray_addr, ipf_addr;
	reg  [`I_Width-1:0] gray_data;
	wire [`O_Width-1:0] ipf_data;

    reg gray_ready, over;
    
    integer err, exp_num, i;
    
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

	initial	begin
	    $readmemh (`PAT, gray_mem);
		`ifdef MODE0
			$readmemh (`EXP0, exp_mem);
		`elsif MODE1
            $readmemh (`EXP1, exp_mem);
		`else
			$readmemh (`EXP2, exp_mem);
		`endif
	end

	always begin #(`CYCLE/2) clk = ~clk; end

	initial begin

		`ifdef SDF
			$sdf_annotate(`SDFFILE, IPF); //check time violation
			$fsdbDumpfile("IPF_syn.fsdb"); //generate nWave
			$fsdbDumpvars("+mda");
		`else
			$fsdbDumpfile("IPF.fsdb");
			$fsdbDumpvars("+mda");
		`endif

	end

	initial begin
		clk = 0;
		rst = 0;
		@(negedge clk)  rst = 1'b1; 
		#(`CYCLE*2);    rst = 1'b0; 
		@(negedge clk)  gray_ready = 1'b1; 

		mode = 2'd0;
		
		`ifdef MODE1
			mode = 2'd1;
		`elsif MODE2
			mode = 2'd2;
		`endif

	    while (finish == 0) begin             
	      if(gray_req) begin
	         gray_data = gray_mem[gray_addr];  
	      end else begin
	         gray_data = 'hz;  
	      end                    
	      @(negedge clk); 
	    end     
	    gray_ready = 0; gray_data='hz;
	end



	initial begin
	    exp_num = 0;
		err = 0;
		over = 0;

		$display("START!!! Simulation Start .....\n");
	 	#(`CYCLE*3); 
		
		wait(finish) ;
		@(posedge clk); 
		@(posedge clk);
		for (i=0; i <`N_PAT ; i=i+1) begin
				exp_dbg = exp_mem[i]; ipf_dbg = u_ipf_mem.ipf_M[i];
				if (exp_mem[i] == u_ipf_mem.ipf_M[i]) begin
					err = err;
				end else begin 
					err = err + 1;
					if (err <= 10) $display("Output pixel %d are wrong!", i);
					if (err == 11) begin $display("Find the wrong pixel reached a total of more than 10 !, Please check the code .....\n");  end
				end					
				exp_num = exp_num + 1;
		end
		over = 1;
	end


    initial  begin
	    #`End_CYCLE ;
	    $display("-------------------------FAIL------------------------\n");
	 	$display("     Error!!! Somethings' wrong with your code ...!  \n");
	 	$display("-----------------------------------------------------\n");
	 	$finish;
	end

	initial begin
        @(posedge over)      
        if((over) && (exp_num!='d0)) begin
            if (err == 0)  begin
                $display("-------------------------PASS------------------------------\n");
                $display("Congratulations! All data have been generated successfully!\n");
            end else begin
                $display("-------------------------ERROR-----------------------------\n");
                $display("There are %d errors!\n", err);
            end
            $display("-----------------------------------------------------------\n");
        end
	    #(`CYCLE/2); $finish;
	end
   
endmodule


module ipf_mem (ipf_valid, ipf_data, ipf_addr, clk);

	input	ipf_valid;
	input	[`A_Width-1:0] ipf_addr;
	input	[`O_Width-1:0] ipf_data;
	input	clk;

	reg [`O_Width-1:0] ipf_M [0:`N_PAT];
	integer i;

	initial begin
		for (i=0; i<=`N_PAT; i=i+1) ipf_M[i] = 0;
	end

	always@(negedge clk) 
		if (ipf_valid) ipf_M[ipf_addr] <= ipf_data;

endmodule





