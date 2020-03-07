read_file -format verilog {ADDER.v}

analyze -library WORK -format verilog {ADDER.v}

elaborate ADDER -architecture verilog -library WORK

create_clock -name "clk" -period 30 -waveform {0 15}  {clk}
compile -exact_map

write_sdf -version 1.0 -context verilog ADDER.sdf

write -hierarchy -format verilog -output ADDER_syn.v

uplevel #0 { report_area }
uplevel #0 { report_timing -path full -delay max -nworst 1 -max_paths 1 -significant_digits 2 -sort_by group }