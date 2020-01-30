`define CYCLE      30
`define SDFFILE    "./IPF.sdf"	  
`define End_CYCLE  10000000

`define PAT        "./pattern.dat" 
`define WPA		   "./wpa.dat"   
`define EXP0       "./res.dat"


`define N_PAT      256**2
`define I_Width    8
`define O_Width    9
`define A_Width    16

module IPF_tb;
    
    reg   clk; //give IPF=> reg
	reg   rst;
	reg  [2:0] ctrl;
	reg  [63:0] i_data;
	reg  [63:0] w_data;
	reg  i_valid,w_valid;
	
	
	wire [1151:0] res;				//each res //receive from IPF=>wire
	wire res_valid;
	wire finish;
	
	reg [63:0] i_mem [0:7];
	reg [63:0] w_mem  [0:4];		// 4 W => 9 * 8 bit * 4 / 63 = 4.xx
	reg [1151:0] exp_mem  [0:31];	//31次res

	reg [1151:0] ipf_dbg, exp_dbg;
    reg over;
    integer err, exp_num, i,cnt,i_data_id;
	reg w_data_id;
	
/* 接線 */
`ifdef SDF
    IPF IPF(
`else
    IPF #(.In_Width(`I_Width), .Out_Width(`O_Width), .Addr_Width(`A_Width)) IPF(
`endif
    	.clk(clk),
		.rst(rst),  
        .ctrl(ctrl),
		.i_valid(i_valid),
        .i_data(i_data),
		.w_valid(w_valid),
		.w_data(w_data), 
		.res_valid(res_valid), 
		.res(res), 
		.finish(finish)
	);
			
    ipf_mem u_ipf_mem(
   	    .clk(clk),
   	    .res_valid(res_valid),
   	    .res(res)
   	);
	
	/* read file data */
	initial begin
		$readmemb(`PAT, i_mem);
		$readmemb(`WPA , w_mem);
		$readmemb(`EXP0 , exp_mem);		
		/*
		`ifdef MODE0
			$readmemh(`EXP0 , exp_mem);
		`elsif MODE1
			$readmemh(`EXP1 , exp_mem);
		`else
			$readmemh(`EXP2 , exp_mem);
		`endif
		*/
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
		i_valid=0;
		w_valid=0;
		ctrl='hz;
		
		@(negedge clk)rst=1; 	//wait , when neg clk => active(rst=1)
		#(`CYCLE*2)rst=0; 		//wait 2 cyc =>active(rst=0)
		@(negedge clk);
		
		cnt	 	 = 0;
		i_data_id= 0;
		w_data_id= 0;
		while(finish==0)begin
			if(cnt==0|cnt==2|cnt==4)begin
				if(cnt!=4)begin
					if(cnt==0)begin
						i_valid=1;
						repeat(8)begin
							i_data =i_mem[i_data_id];
							i_data_id = i_data_id + 1;
							@(negedge clk);
						end
					end
					i_valid=0;
					w_valid=1;
					repeat(2)begin
						if(w_data_id==4)w_data_id=0;	// w0 - w3
						w_data =w_mem[w_data_id];
						w_data_id = w_data_id+1;
						@(negedge clk);
					end
					ctrl=1;
				end
				else ctrl=0;
			end
			else begin
				repeat(15)@(negedge clk);
				ctrl=2;
				@(negedge clk);
			end
		
			cnt = cnt +1;
			i_valid=0;
			w_valid=0;
		end	
		
		i_data = 'hz;i_valid=0;
		w_data = 'hz;w_valid=0;
		
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
		for(i=0;i<32;i=i+1)begin
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

module ipf_mem(res_valid, res, clk); 

	input	res_valid;
	input	[1151:0] res;
	input	clk;

	reg [1151:0] ipf_M [0:31];
	integer i,id;
	
	initial begin
		for(i=0;i<31;i=i+1)begin
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
