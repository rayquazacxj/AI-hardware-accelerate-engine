`timescale 1ns / 1ps
module Pipe_CPU(
        clk_i,
		rst_i
		);
    
/****************************************
*               I/O ports               *
****************************************/
input clk_i;
input rst_i;

/****************************************
*               wires                   *
****************************************/
wire [32-1:0] instr_w;
wire [64-1:0] pc_addr_w;
wire [64-1:0] Imm_Gen_w;
wire [64-1:0] shift_left_w;
wire [64-1:0] mux_alusrc_w;
wire [64-1:0] mux_pc_result_w;
wire [64-1:0] add2_sum_w;
wire [4-1:0]  alu_control_w;
wire [64-1:0] alu_result_w;
wire [64-1:0] dataMem_read_w;
wire [64-1:0] wb_result_w;
wire [64-1:0] rf_rs1_data_w;
wire [64-1:0] rf_rs2_data_w;
wire [64-1:0] add1_result_w;
wire [64-1:0] add1_source_w;
assign add1_source_w = 64'd4;
wire [2-1:0]  ctrl_alu_op_w;
wire ctrl_write_mux_w;        //---seem no use?
wire ctrl_register_write_w;
wire ctrl_branch_w;
wire ctrl_alusrc_mux_w;  //--
//wire and_result_w;    //--
wire alu_zero_w;
wire ctrl_mem_write_w;
wire ctrl_mem_read_w;
wire ctrl_mem_mux_w;  //---
wire PCsrc_w;

//----------------------
wire [64-1:0]ALU_data1,ALU_data2;


//----Forwarding_Unit
wire [1:0]ForwardA;
wire [1:0]ForwardB;

//----Pipe_Reg
wire [31:0]IF_ID_instr;
wire [208:0]ID_EX_o;
wire [134:0]EX_MEM_o,MEM_WB_o;


//-----Pipe_control_Reg
reg [9:0]IDEX_EX_ALUfunc73;
reg [1:0]IDEX_EX_ALUop;
reg IDEX_EX_ALUsrc,IDEX_EX_Branch,IDEX_MEM_MemRead,IDEX_MEM_MemWrite,IDEX_WB_MemtoReg,IDEX_WB_RegWrite;
reg EXMEM_MEM_MemRead,EXMEM_MEM_MemWrite,EXMEM_WB_MemtoReg,EXMEM_WB_RegWrite;
reg MEMWB_WB_MemtoReg,MEMWB_WB_RegWrite;

assign PCsrc_w = ctrl_branch_w & alu_zero_w;


/****************************************
*            Internal signal            *
****************************************/

/**** IF stage ****/
//control signal...


/**** ID stage ****/
//control signal...


/**** EX stage ****/
//control signal...
always @(posedge clk_i or negedge  rst_i) begin
	if( rst_i == 0)begin
		IDEX_EX_ALUop 	 	<= 0;
		IDEX_EX_Branch	 	<= 0;
		IDEX_EX_ALUfunc73	<= 0;
		IDEX_EX_ALUsrc		<= ctrl_alusrc_mux_w;
		
		IDEX_MEM_MemWrite 	<= 0;
		IDEX_MEM_MemRead	<= 0;
		
		IDEX_WB_MemtoReg	<= 0;
		IDEX_WB_RegWrite  	<= 0;
	end
    else begin
		IDEX_EX_ALUop 	 	<= ctrl_alu_op_w;
		IDEX_EX_Branch	 	<= ctrl_branch_w;
		IDEX_EX_ALUsrc		<= ctrl_alusrc_mux_w;
		IDEX_EX_ALUfunc73	<= {IF_ID_instr[30],IF_ID_instr[14:12]};
		
		IDEX_MEM_MemWrite 	<= ctrl_mem_write_w;
		IDEX_MEM_MemRead	<= ctrl_mem_read_w;
		
		IDEX_WB_MemtoReg	<= ctrl_mem_mux_w;
		IDEX_WB_RegWrite	<= ctrl_register_write_w;
	end
end

/**** MEM stage ****/
//control signal...

always @(posedge clk_i or negedge  rst_i) begin
	if( rst_i == 0)begin	
		EXMEM_MEM_MemWrite 	<= 0;
		EXMEM_MEM_MemRead	<= 0;
		
		EXMEM_WB_MemtoReg	<= 0;
		EXMEM_WB_RegWrite  	<= 0;
	end
    else begin
		EXMEM_MEM_MemWrite 	<= IDEX_MEM_MemWrite;
		EXMEM_MEM_MemRead	<= IDEX_MEM_MemRead;
		
		EXMEM_WB_MemtoReg	<= IDEX_WB_MemtoReg;
		EXMEM_WB_RegWrite  	<= IDEX_WB_RegWrite;
	end
end

/**** WB stage ****/
//control signal...

always @(posedge clk_i or negedge  rst_i) begin
	if( rst_i == 0)begin
		MEMWB_WB_MemtoReg	<= 0;
		MEMWB_WB_RegWrite  	<= 0;
	end
    else begin
		MEMWB_WB_MemtoReg	<= EXMEM_WB_MemtoReg;
		MEMWB_WB_RegWrite  	<= EXMEM_WB_RegWrite;
	end
end


/**** Data hazard ****/
//control signal...

Forwarding_Unit FU(
	.EX_MEMRegWrite(EXMEM_WB_RegWrite),
	.MEM_WBRegWrite(MEMWB_WB_RegWrite),
	.EX_MEMRegisterRd(EX_MEM_o[6:2]),
	.MEM_WBRegisterRd(MEM_WB_o[6:2]),
	.ID_EXRegisterRs1(ID_EX_o[21:17]),
	.ID_EXRegisterRs2(ID_EX_o[26:22]),
	.ID_EXop(ID_EX_o[1:0]),
	.EX_MEMop(EX_MEM_o[1:0]),
	.MEM_WBop(MEM_WB_o[1:0]),
	
	.ForwardA(ForwardA),
	.ForwardB(ForwardB)
	);

/****************************************
*          Instantiate modules          *
****************************************/
//Instantiate the components in IF stage
Program_Counter PC(
	.clk_i(clk_i),      
	.rst_i (rst_i),     
	.pc_in_i(mux_pc_result_w) ,   
	.pc_out_o(pc_addr_w) 
	);
		
MUX_2to1 #(.size(64)) Mux_PC_Source(
	.data0_i(add1_result_w),
	.data1_i(add2_sum_w),
	.select_i(1'b0), 			//assume branch always not taken
	.data_o(mux_pc_result_w)
	);	

Instr_Mem IM(
	.pc_addr_i(pc_addr_w),  
	.instr_o(instr_w)  
	);
			
Adder Add_pc(
	.src1_i(pc_addr_w),
	.src2_i(add1_source_w),     
	.sum_o(add1_result_w)   
	);

//You need to instantiate many pipe_reg
Pipe_Reg #(.size(32)) IF_ID(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(instr_w), 
	.data_o(IF_ID_instr)
	);
		
//Instantiate the components in ID stage
Reg_File RF(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.RS1addr_i(IF_ID_instr[19:15]) ,
	.RS2addr_i(IF_ID_instr[24:20]) ,
	.RDaddr_i(IF_ID_instr[11:7]) ,
	.RDdata_i(wb_result_w[64-1:0]),
	.RegWrite_i(MEMWB_WB_RegWrite),
	.RS1data_o(rf_rs1_data_w) ,
	.RS2data_o(rf_rs2_data_w)
	);

Control Control(
	.instr_op_i(IF_ID_instr[6:0]),
	.Branch_o(ctrl_branch_w),
	.MemRead_o(ctrl_mem_read_w),
	.MemtoReg_o(ctrl_mem_mux_w),
	.ALU_op_o(ctrl_alu_op_w),
	.MemWrite_o(ctrl_mem_write_w),
	.ALUSrc_o(ctrl_alusrc_mux_w),
	.RegWrite_o(ctrl_register_write_w)
	);

Imm_Gen IG(
	.data_i(IF_ID_instr),
	.data_o(Imm_Gen_w)
	);	

//You need to instantiate many pipe_reg
Pipe_Reg #(.size(209)) ID_EX(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i({rf_rs1_data_w,rf_rs2_data_w,Imm_Gen_w,IF_ID_instr[24:20],IF_ID_instr[19:15],IF_ID_instr[11:7],IF_ID_instr[5:4]}), //r2,r1,rd
	// 208:145,144:81,80:17,16:12, 11:7, 6:2,1:0
	.data_o(ID_EX_o)
	);
				
//Instantiate the components in EX stage	   
ALU ALU(
	.src1_i(ALU_data1),
	.src2_i(ALU_data2),
	.ctrl_i(alu_control_w),
	.result_o(alu_result_w),
	.zero_o(alu_zero_w)
	);
		
MUX_3to1 #(.size(64 )) Mux3_1(
	.data0_i(ID_EX_o[208:145]),
	.data1_i(EX_MEM_o[70:7]),
	.data2_i(wb_result_w),
	.select_i(ForwardA),
	.data_o(ALU_data1)
    );
		
MUX_3to1 #(.size(64 )) Mux3_2(
	.data0_i(mux_alusrc_w),
	.data1_i(EX_MEM_o[70:7]), 
	.data2_i(wb_result_w),
	.select_i(ForwardB),
	.data_o(ALU_data2)
    );
		
ALU_Ctrl AC(
	.funct_i(IDEX_EX_ALUfunc73),   
	.ALUOp_i(IDEX_EX_ALUop),   
	.ALUCtrl_o(alu_control_w)
	);

MUX_2to1 #(.size( 64)) Mux1(
	.data0_i(ID_EX_o[144:81] ), // rf_rs2_data_w
	.data1_i(ID_EX_o[80:17] ),	 // Imm_Gen_w
	.select_i(IDEX_EX_ALUsrc),
	.data_o(mux_alusrc_w)
    );
				
Shift_Left_One_64 Shifter(
	.data_i(ID_EX_o[80:17]),
	.data_o(shift_left_w)
	); 	
		
Adder Add_pc2(
	.src1_i(pc_addr_w),     
	.src2_i(shift_left_w),     
	.sum_o(add2_sum_w)    
	);

//You need to instantiate many pipe_reg
Pipe_Reg #(.size(135)) EX_MEM(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i({ALU_data2,alu_result_w,ID_EX_o[6:0]}), //rd
	.data_o(EX_MEM_o)
	);	

//Instantiate the components in MEM stage
Data_Mem DM(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.addr_i(EX_MEM_o[68:5]),
	.data_i(EX_MEM_o[132:69]),
	.MemRead_i(EXMEM_MEM_MemRead),
	.MemWrite_i(EXMEM_MEM_MemWrite),
	.data_o(dataMem_read_w)
	);

Pipe_Reg #(.size( 135 )) MEM_WB(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i({dataMem_read_w,EX_MEM_o[70:0]}), 
	.data_o(MEM_WB_o)
	);

//Instantiate the components in WB stage
MUX_2to1 #(.size(64)) Mux2(
	.data0_i(MEM_WB_o[70:7]),
	.data1_i(MEM_WB_o[134:71]),
	.select_i(MEMWB_WB_MemtoReg),
	.data_o(wb_result_w)
    );

/****************************************
*           Signal assignment           *
****************************************/
	
endmodule

