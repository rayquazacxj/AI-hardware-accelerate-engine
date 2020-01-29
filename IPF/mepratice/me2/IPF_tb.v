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
	reg  [7:0] i_data;
	reg  [3:0] w_data;
	reg ready,endinput;
	
	wire [31:0] res;//each res //receive from IPF=>wire
	wire res_valid;
	wire finish;
	
	
	reg [7:0] i_mem [0:5];
	reg [3:0] w_mem  [0:1];
	reg [31:0] exp_mem  [0:11];//12次res

	reg [31:0] ipf_dbg, exp_dbg;
    reg over;
    integer err, exp_num, i,cnt,c_cnt,i_cnt,i_data_id,w_data_id;
	
/* 接線 */
`ifdef SDF
    IPF IPF(
`else
    IPF #(.In_Width(`I_Width), .Out_Width(`O_Width), .Addr_Width(`A_Width)) IPF(
`endif
    	.clk(clk),
		.rst(rst),  
        .ready(ready),
		.endinput(endinput),
        .i_data(i_data), 
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
		endinput=0;
		
		@(negedge clk)rst=1; //wait , when neg clk => active(rst=1)
		#(`CYCLE*2)rst=0; //wait 2 cyc =>active(rst=0)
		@(negedge clk)ready=1;
		@(negedge clk);
		
		cnt=0;
		i_data_id=0;
		w_data_id=0;
		i_cnt=0;
		c_cnt=0;
		while(finish == 0)begin
			if(cnt== 0 | cnt== 5)begin //give i
				i_data = i_mem[i_data_id];
				i_data_id = i_data_id+1;
				i_cnt = i_cnt+1;
				if(i_cnt==3)begin
					i_cnt=0;
					cnt = cnt+1;
				end
			end
			else if (cnt==1 | cnt==3 |cnt==6 |cnt==8)begin //give w
				w_data = w_mem[w_data_id];
				if(w_data_id)w_data_id=0;
				else w_data_id=1;
				cnt = cnt+1;
			end
			else if (cnt==2 | cnt==4 |cnt==7 |cnt==9)begin //compute
				c_cnt = c_cnt+1;
				if(c_cnt==3)begin
					if(cnt==9)endinput=1;
					c_cnt=0;
					cnt = cnt+1;
				end
			end
			else begin
				i_data = 'hz;
				w_data = 'hz;
			end
			
			@(negedge clk);
		end
		
		ready=0;i_data = 'hz;w_data = 'hz;
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
		for(i=0;i<12;i=i+1)begin
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
	input	[31:0] res;
	input	clk;

	reg [31:0] ipf_M [0:11];
	integer i,id;
	
	initial begin
		for(i=0;i<`N_PAT;i=i+1)begin
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
