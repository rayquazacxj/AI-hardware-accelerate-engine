`define CYCLE      30
`define SDFFILE    "./IPF.sdf"	  
`define End_CYCLE  10000000

//`define PAT        "./mul_data_i.dat"  
//`define WPA		   "./mul_data_w_7_7.dat"
//`define WPA		   "./mul_data_w.dat"   //3*3_w_data 
//`define WPA		   "./mul_data_w_5_5.dat"

//random
`define RES		   "./mul_data3_res.dat"
`define PAT        "./mul_data3_i.dat" 
`define WPA		   "./mul_data3_w.dat"   

`define N_PAT      256**2
`define I_Width    8
`define O_Width    9
`define A_Width    16
`define ANS_NUM    128

module IPF_tb;
    
    reg clk;
	reg rst_n;
	reg [1:0]ctrl;			//0: end , 1:start , 2:hold   
	
	reg  [63:0] i_data; 		
	reg  [63:0] w_data;
	reg i_valid,w_valid;
	reg  [1:0] Wsize;
	reg  [3:0] i_format,w_format;
	
	reg  [1:0]RLPadding;
	reg  stride;
	reg  [3:0]wgroup;
	reg  wgroup_tmp;
	reg  [2:0]wround;
	
	wire [9215:0] result;
	wire res_valid;

	
	reg [63:0] i_mem [0:7];
	reg [63:0] w_mem  [0:24];		//3 *3 18 , 5*5 25
	reg [9215:0]exp_mem[0:5];
	
	reg [9215:0]exp_dbg,result_dbg;
	
    reg over;
    integer err, exp_num, i,cnt,i_data_id,w_data_id,f;
	
	
/* 接線 */
`ifdef SDF
    IPF IPF(
`else
    IPF #(.In_Width(`I_Width), .Out_Width(`O_Width), .Addr_Width(`A_Width)) IPF(
`endif
    	.clk(clk),
		.rst_n(rst_n),  
        .ctrl(ctrl),
		.i_valid(i_valid),
        .i_data(i_data),
		.w_valid(w_valid),
		.w_data(w_data), 
		.Wsize(Wsize),
		.i_format(i_format),
		.w_format(w_format),
		.res_valid(res_valid), 
		.result(result), 
	
		
		.RLPadding(RLPadding),
		.stride(stride),
		.wgroup(wgroup),
		.wround(wround)
	);
	
	result_mem u_result_mem(
   	    .clk(clk),
   	    .res_valid(res_valid), 
   	    .result(result) 
   	    
   	    
   	);
	
	/* read file data */
	initial begin
		$readmemb(`PAT, i_mem);
		$readmemb(`WPA , w_mem);
		$readmemb(`RES , exp_mem);		
		f = $fopen("output.txt","w");
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
		rst_n=1;
		i_valid=0;
		w_valid=0;
		ctrl='hz;
		Wsize=0;
		wgroup=0;
		wround=0;
		stride=0;
		RLPadding=0;
		i_format=2;
		w_format=2;
		
		@(posedge clk)rst_n=0; 	//wait , when pos clk => active(rst_n=0)
		#(`CYCLE*2)rst_n=1; 		//wait 2 cyc
		@(negedge clk);
		
		i_data_id= 0;
		w_data_id= 0;
	
		w_valid=1;
		repeat(9)begin //3 * 3
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
		ctrl=2; // fini
		
		$display("END compute  0-7 I ~\n");
		
		
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
		
/*		
	//------------------------------------3*3 stride2
		stride=1;
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
		wgroup_tmp=0;
		repeat(6)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			wgroup=wgroup_tmp;
			@(negedge clk);
			wgroup_tmp=!wgroup_tmp;
			
		end
		$display("END compute 0-7 I\n");	
		
		i_data_id=0;
		wgroup_tmp=0;
		repeat(8)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			wgroup=wgroup_tmp;
			@(negedge clk);
			wgroup_tmp=!wgroup_tmp;
			
		end
		i_valid=0;
		$display("END compute\n");	
		
		ctrl=0; // end 
		
		
		$display("END RUN\n");	
*/	

/*
	//---------------------------------5*5 stride1
		Wsize=1;
		w_valid=1;
		repeat(25)begin //5 * 5
			w_data =w_mem[w_data_id];
			w_data_id = w_data_id+1;
			@(negedge clk);
		end
		w_valid=0;
		$display("END in 5*5 W\n");	
		
		i_valid=1;
		repeat(4)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		ctrl=1; // start
		repeat(4)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		i_data_id=0;
		repeat(8)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		$display("END compute first round(16i) \n");
		
		i_data_id=0;
		ctrl=2; 	// hold
		repeat(4)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		wround=1;	// round 2
		ctrl=1; 	// start	
		repeat(4)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		$display("END compute second round \n");
		
		i_data_id=0;
		ctrl=2; 	// hold
		repeat(4)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		wround=0;	// round 1
		ctrl=1; 	// start	
		repeat(4)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		$display("END compute third \n");
		
		i_data_id=0;
		ctrl=2; 	// hold
		repeat(4)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		wround=1;	// round 2
		ctrl=1; 	// start	
		repeat(4)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		$display("END compute third-round2~ \n");
		
		i_valid=0;
		ctrl=0;		// end
		//$display("END compute second round & first group~\n");
			
		//-------------------------------------
*/
/*
	//---------------------------------------5*5stride2	
		Wsize=1;
		stride=1;
		w_valid=1;
		repeat(25)begin //5 * 5
			w_data =w_mem[w_data_id];
			w_data_id = w_data_id+1;
			@(negedge clk);
		end
		w_valid=0;
		$display("END in 5*5 W\n");	
		
		i_valid=1;
		repeat(4)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		ctrl=1; // start
		wgroup_tmp=0;
		repeat(4)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			wgroup=wgroup_tmp;
			@(negedge clk);
			wgroup_tmp=!wgroup_tmp;
		end
		$display("END compute 0-7i \n");
		
		i_data_id=0;	
		repeat(8)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			wgroup=wgroup_tmp;
			@(negedge clk);
			wgroup_tmp=!wgroup_tmp;
		end
		i_valid=0;	
		$display("END compute 8-15i~ \n");
		
		ctrl=2;
		repeat(10)@(negedge clk);
		
		
		ctrl=0; // end 
		$display("END compute 5*5stride2~ \n");
		
	//-------------------------------------------------
*/
/*
	//---------------------------------------7*7 stride1
		Wsize=2;
		w_valid=1;
		repeat(25)begin //7 * 7
			w_data =w_mem[w_data_id];
			w_data_id = w_data_id+1;
			@(negedge clk);
		end
		w_valid=0;
		$display("END in 7*7 W\n");	
		
		i_valid=1;
		repeat(6)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		ctrl=1; 	// start
		repeat(2)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		i_data_id=0;
		repeat(8)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		$display("END compute first round(16i) , 7*7 1st round \n");
		
		ctrl=2;		//hold
		i_data_id=0;	
		repeat(6)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		wround=1;
		ctrl=1; // start
		repeat(2)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		$display("END compute second round(8i) \n");
		
		ctrl=2;		//hold
		i_data_id=0;	
		repeat(6)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		wround=2;
		ctrl=1; // start
		repeat(2)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		$display("END compute 3 round(8i) \n");
		
		ctrl=2;		//hold
		i_data_id=0;	
		repeat(6)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		wround=3;
		ctrl=1; // start
		repeat(2)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		$display("END compute 4 round(8i)~ \n");
		
		ctrl=2;
		repeat(10)@(negedge clk);
		
		i_valid=0;
		ctrl=0;		// end
		$display("END compute~\n");
		
	//----------------------------------------------------------------
*/
/*
	//-------------------------------------7*7 stride2
		Wsize=2;
		w_valid=1;
		stride=1;
		
		repeat(25)begin //7 * 7
			w_data =w_mem[w_data_id];
			w_data_id = w_data_id+1;
			@(negedge clk);
		end
		w_valid=0;
		$display("END in 7*7 W\n");	
		
		i_valid=1;
		repeat(6)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		
		ctrl=1; 	// start
		wgroup_tmp=0;
		repeat(2)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			wgroup=wgroup_tmp;
			@(negedge clk);
			wgroup_tmp=!wgroup_tmp;		
		end
		i_data_id=0;
		repeat(8)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			wgroup=wgroup_tmp;
			@(negedge clk);
			wgroup_tmp=!wgroup_tmp;
		end
		ctrl=2;		// hold
		$display("END compute first round(16i) , 7*7 1st round~ \n");
		
		i_data_id=0;
		repeat(6)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		wround=1;
		ctrl=1; 	// start
		wgroup_tmp=0;
		repeat(2)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			wgroup=wgroup_tmp;
			@(negedge clk);
			wgroup_tmp=!wgroup_tmp;		
		end
		$display("END compute first round(8i) , 7*7 2nd round~ \n");
		
		wgroup_tmp=0;
		i_data_id=0;
		repeat(8)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			wgroup=wgroup_tmp;
			@(negedge clk);
			wgroup_tmp=!wgroup_tmp;
		end
		ctrl=2;		// hold
		
		repeat(10)@(negedge clk);
		
		i_valid=0;
		ctrl=0;		// end
		$display("END compute~\n");
	//-------------------------------------------------------------
*/	
/*	
	//----------------------------------------3*3 stride1 padding
		w_valid=1;
		repeat(18)begin //3 * 3
			w_data =w_mem[w_data_id];
			w_data_id = w_data_id+1;
			@(negedge clk);
		end
		w_valid=0;
		$display("END in W\n");	
		
		RLPadding=1;
		@(negedge clk);
		RLPadding=0;
		
		i_valid=1;
		ctrl=1; // start  padding	
		repeat(8)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);		
		end
		i_valid=0;
		RLPadding=2;
		repeat(2)@(negedge clk);	
		
		RLPadding=1;
		ctrl=2;
		
		@(negedge clk);
		
		ctrl=1; // start  padding	
		RLPadding=0;
		i_valid=1;
		i_data_id = 0;		
		repeat(8)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		i_valid=0;
		RLPadding=2;
		repeat(2)@(negedge clk);
		
		
		$display("END compute padding~\n");
		
		RLPadding=0;
		ctrl=2;		// hold
		repeat(10)@(negedge clk);
		
		
		ctrl=0;		// end
		$display("END compute~\n");
		
	//-----------------------------------------------	
*/		
/*		
	//--------------------------------------3*3 stride2 padding
		stride=1;
		w_valid=1;
		repeat(18)begin //3 * 3
			w_data =w_mem[w_data_id];
			w_data_id = w_data_id+1;
			@(negedge clk);
		end
		w_valid=0;
		$display("END in W\n");	
		
		RLPadding=1;
		@(negedge clk);
		RLPadding=0;
		
		i_valid=1;
		ctrl=1; // start
		wgroup_tmp=0;
		repeat(8)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			wgroup=wgroup_tmp;
			@(negedge clk);
			wgroup_tmp=!wgroup_tmp;
			
		end
		$display("END compute 0-7 I\n");

		i_valid=0;
		RLPadding=2;
		repeat(2)begin
			wgroup=wgroup_tmp;
			@(negedge clk);
			wgroup_tmp=!wgroup_tmp;
		end
	//-----
		ctrl=2;
		RLPadding=1;
		i_valid=0;
		
		@(negedge clk);
		
		RLPadding=0;
		i_valid=1;
		ctrl=1; // start
		wgroup_tmp=0;
		i_data_id =0;
		repeat(8)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			wgroup=wgroup_tmp;
			@(negedge clk);
			wgroup_tmp=!wgroup_tmp;
			
		end
		i_valid=0;
		$display("END compute padding\n");
			
		ctrl=2;		// hold
		repeat(10)@(negedge clk);
		$display("END compute\n");	
		ctrl=0; // end 
		
		$display("END RUN\n");
	//---------------------------------------------
*/		

/*	
	//------------------------------------------3*3 format
		i_format=2;
		w_format=3;
		
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
		repeat(4)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		i_format=2;
		w_format=1;
		repeat(2)begin
			i_data =i_mem[i_data_id];
			i_data_id = i_data_id + 1;
			@(negedge clk);
		end
		
		ctrl=2;		// hold
		repeat(10)@(negedge clk);
		
		$display("END compute~\n");	
		ctrl=0; // end 
		
	//--------------------------------------------------	
*/	
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
		//# (`End_CYCLE/2);
		//wait(finish); // wait until (true)
		
		repeat(50)@(posedge clk);
		
		for (i=0; i <6 ; i=i+1) begin
				exp_dbg = exp_mem[i]; result_dbg = u_result_mem.result_M[i];
				if (exp_mem[i] == u_result_mem.result_M[i]) begin
					err = err;
				end else begin 
					err = err + 1;
					if (err <= 10) $display("Output pixel %d are wrong! \n %h \n %h", i,exp_mem[i],u_result_mem.result_M[i]);
					if (err == 11) begin $display("Find the wrong pixel reached a total of more than 10 !, Please check the code .....\n");  end
				end					
				exp_num = exp_num + 1;
		end
		if(err==0)$display("AC!\n");
		$display("finish~\n");
		
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
		
	    repeat(20)@(posedge clk) ; $fclose(f);  $finish;
	end
		
endmodule

module result_mem (res_valid, result, clk);

	input	res_valid;
	input	[9215:0] result;
	input	clk;

	reg [9215:0] result_M [0:5];
	integer i,id;

	initial begin
		for (i=0; i<=6; i=i+1) result_M[i] = 0;
		id = 0;
	end

	always@(negedge clk) 
		if (res_valid)begin
			result_M[id] <= result;
			if(id==5)$fwrite(f,"%b\n",result);
			id<= id +1;
		end

endmodule