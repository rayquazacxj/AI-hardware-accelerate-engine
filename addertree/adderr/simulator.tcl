# change your timing constraint here
set CYCLE 2        ;  #clock period defined by designer.
set t_in_max  0.1  ;  #input  delay defined by designer. 
set t_in_min  0    ;  #input  delay defined by designer.
set t_out_max 0.1  ;  #output delay defined by designer. 
set t_out_min 0    ;  #output delay defined by designer. 
set clock_skew 0.3 ;  #Using 0.1-0.3, based on your design. if gate count is large using 0.3 
set clock_lat  1   ;  #don't touch  
set input_tran 0.5 ;  #don't touch
set clock_tran 0.1 ;  #don't touch


read_file -format verilog {/users/student/mr108/hshuang19/addertree/ADDER.v}
analyze -library WORK -format verilog {/users/student/mr108/hshuang19/addertree/ADDER.v}
elaborate ADDER -architecture verilog -library WORK

# Setting wireload model
# set_wire_load_model -name xxx -library xxx

# Setting Timing Constraints
create_clock -name "clk" -period $CYCLE  -waveform { 0 1 }  { clk }
set_dont_touch_network  [ find clock clk ]
set_fix_hold  [ find clock clk]
set_clock_uncertainty $clock_skew  [get_clocks clk]
set_clock_latency     $clock_lat   [get_clocks clk]
set_clock_transition  $clock_tran  [all_clocks]
set_input_transition  $input_tran  [all_inputs]

# I/O delay should depend on the real enironment.
set_input_delay -clock clk -max $t_in_max [remove_from_collection [all_inputs] [get_ports clk]] 
set_input_delay -clock clk -min $t_in_min   [remove_from_collection [all_inputs] [get_ports clk]] 
set_output_delay -clock clk -max $t_out_max [all_outputs]
set_output_delay -clock clk -min $t_out_min [all_outputs]

# Input/Output Driving if connect to Buffer
# set_driving_cell -library xxx -lib_cell xxx -pin { x }  [all_inputs]
# set_load [load_of "xxx/DFFX1/D"] [all_outputs]
set_load         0.5     [all_outputs]
set_drive        1     [all_inputs]
#set_load   [load_of "PTC_DRAM_25nm_FF_3sigma_1V32_m40C/SR12DFFQRBX1/DATA"]       [all_outputs] 
#set_load   [load_of "PTC_DRAM_25nm_LVT_FF_3sigma_1V32_m40C/SL12DFFQRBX1/DATA"]       [all_outputs] 
#set_max_fanout 20 [all_inputs]
set_structure -timing true
set_ideal_network [get_ports clk]
set_ideal_network [get_ports rst]

compile -exact_map
write_sdf -version 1.0 -context verilog ADDER.sdf
write -hierarchy -format verilog -output ADDER_syn.v
uplevel #0 { report_area }
uplevel #0 { report_power -analysis_effort low }
uplevel #0 { report_timing -path full -delay max -nworst 1 -max_paths 1 -significant_digits 2 -sort_by group }
