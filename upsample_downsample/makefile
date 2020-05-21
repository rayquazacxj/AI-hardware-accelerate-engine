HEAD		=header.v

VLOG		=ncverilog

SRC			=UDS_tb.v\
			 UDS.v

SRC_syn 	=UDS_tb.v\
			 UDS_syn.v\
			 -v /theda21_2/yllab/CBDK40_TSMC/CBDK_TSMC40_Arm_f1.0/CIC/Verilog/sc9_cln40g_base_lvt_udp.v\
			 -v /theda21_2/yllab/CBDK40_TSMC/CBDK_TSMC40_Arm_f1.0/CIC/Verilog/sc9_cln40g_base_lvt.v\
			 -v /theda21_2/yllab/CBDK40_TSMC/CBDK_TSMC40_Arm_f1.0/CIC/Verilog/sc9_cln40g_base_lvt_neg.v
			 #-v /theda21_2/CBDK_IC_Contest/cur/Verilog/tsmc13.v

			 		 
SDF			=+define+SDF

VLOGARG		=+access+r

TMPFILE		=*.log\
			 INCA_libs

RM			=-rm -rf 

all :: sim
sim :
		$(VLOG) $(HEAD) $(SRC) $(VLOGARG) 

sim1 :
		$(VLOG) $(HEAD) $(SRC) $(VLOGARG) 

sim2 :
		$(VLOG) $(HEAD) $(SRC) $(VLOGARG) 

syn : 
		$(VLOG) $(HEAD) $(SRC_syn)  $(SDF) $(VLOGARG) 

syn1 :
		$(VLOG) $(HEAD) $(SRC_syn) $(SDF) $(VLOGARG) 

syn2 :
		$(VLOG) $(HEAD) $(SRC_syn) $(SDF) $(VLOGARG) 

check :
		$(VLOG) -c $(SRC)
clean :
		$(RM) $(TMPFILE)
