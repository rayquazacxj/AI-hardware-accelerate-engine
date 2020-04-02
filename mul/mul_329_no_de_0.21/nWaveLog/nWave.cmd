wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 {/users/student/mr108/hshuang19/multest/IPF_syn.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/IPF_tb"
wvGetSignalSetScope -win $_nWave1 "/IPF_tb/IPF"
wvSetPosition -win $_nWave1 {("G1" 35)}
wvSetPosition -win $_nWave1 {("G1" 35)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/IPF_tb/IPF/PS\[2:0\]} \
{/IPF_tb/IPF/RLPadding\[1:0\]} \
{/IPF_tb/IPF/Wsize\[1:0\]} \
{/IPF_tb/IPF/add_format\[3:0\]} \
{/IPF_tb/IPF/add_format_dff\[3:0\]} \
{/IPF_tb/IPF/clk} \
{/IPF_tb/IPF/ctrl\[1:0\]} \
{/IPF_tb/IPF/format\[4:0\]} \
{/IPF_tb/IPF/format_dff\[4:0\]} \
{/IPF_tb/IPF/i_data\[63:0\]} \
{/IPF_tb/IPF/i_format\[3:0\]} \
{/IPF_tb/IPF/i_valid} \
{/IPF_tb/IPF/res_valid} \
{/IPF_tb/IPF/res_valid_tmp} \
{/IPF_tb/IPF/res_valid_tmp1} \
{/IPF_tb/IPF/result\[9215:0\]} \
{/IPF_tb/IPF/round_dff1\[2:0\]} \
{/IPF_tb/IPF/round_dff2\[2:0\]} \
{/IPF_tb/IPF/round_dff3\[2:0\]} \
{/IPF_tb/IPF/rst_n} \
{/IPF_tb/IPF/shift_direction} \
{/IPF_tb/IPF/shift_direction_dff} \
{/IPF_tb/IPF/stride} \
{/IPF_tb/IPF/stride_dff1} \
{/IPF_tb/IPF/stride_dff2} \
{/IPF_tb/IPF/stride_dff3} \
{/IPF_tb/IPF/w\[1599:0\]} \
{/IPF_tb/IPF/w_data\[63:0\]} \
{/IPF_tb/IPF/w_format\[3:0\]} \
{/IPF_tb/IPF/w_format_dff\[3:0\]} \
{/IPF_tb/IPF/w_valid} \
{/IPF_tb/IPF/wgroup\[3:0\]} \
{/IPF_tb/IPF/wround\[2:0\]} \
{/IPF_tb/IPF/wsize_dff2\[1:0\]} \
{/IPF_tb/IPF/wsize_dff3\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 )} 
wvSetPosition -win $_nWave1 {("G1" 35)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 59)}
wvSetPosition -win $_nWave1 {("G1" 59)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/IPF_tb/IPF/PS\[2:0\]} \
{/IPF_tb/IPF/RLPadding\[1:0\]} \
{/IPF_tb/IPF/Wsize\[1:0\]} \
{/IPF_tb/IPF/add_format\[3:0\]} \
{/IPF_tb/IPF/add_format_dff\[3:0\]} \
{/IPF_tb/IPF/clk} \
{/IPF_tb/IPF/ctrl\[1:0\]} \
{/IPF_tb/IPF/format\[4:0\]} \
{/IPF_tb/IPF/format_dff\[4:0\]} \
{/IPF_tb/IPF/i_data\[63:0\]} \
{/IPF_tb/IPF/i_format\[3:0\]} \
{/IPF_tb/IPF/i_valid} \
{/IPF_tb/IPF/res_valid} \
{/IPF_tb/IPF/res_valid_tmp} \
{/IPF_tb/IPF/res_valid_tmp1} \
{/IPF_tb/IPF/result\[9215:0\]} \
{/IPF_tb/IPF/round_dff1\[2:0\]} \
{/IPF_tb/IPF/round_dff2\[2:0\]} \
{/IPF_tb/IPF/round_dff3\[2:0\]} \
{/IPF_tb/IPF/rst_n} \
{/IPF_tb/IPF/shift_direction} \
{/IPF_tb/IPF/shift_direction_dff} \
{/IPF_tb/IPF/stride} \
{/IPF_tb/IPF/stride_dff1} \
{/IPF_tb/IPF/stride_dff2} \
{/IPF_tb/IPF/stride_dff3} \
{/IPF_tb/IPF/w\[1599:0\]} \
{/IPF_tb/IPF/w_data\[63:0\]} \
{/IPF_tb/IPF/w_format\[3:0\]} \
{/IPF_tb/IPF/w_format_dff\[3:0\]} \
{/IPF_tb/IPF/w_valid} \
{/IPF_tb/IPF/wgroup\[3:0\]} \
{/IPF_tb/IPF/wround\[2:0\]} \
{/IPF_tb/IPF/wsize_dff2\[1:0\]} \
{/IPF_tb/IPF/wsize_dff3\[1:0\]} \
{/IPF_tb/IPF/C0/clk} \
{/IPF_tb/IPF/C0/format\[4:0\]} \
{/IPF_tb/IPF/C0/format_dff\[4:0\]} \
{/IPF_tb/IPF/C0/i_dat\[191:0\]} \
{/IPF_tb/IPF/C0/locali\[71:0\]} \
{/IPF_tb/IPF/C0/locali_3\[71:0\]} \
{/IPF_tb/IPF/C0/locali_3_dff1\[71:0\]} \
{/IPF_tb/IPF/C0/locali_3_dff2\[71:0\]} \
{/IPF_tb/IPF/C0/locali_3_dff3\[71:0\]} \
{/IPF_tb/IPF/C0/locali_5_s0r0\[71:0\]} \
{/IPF_tb/IPF/C0/locali_5_s0r1_id0\[71:0\]} \
{/IPF_tb/IPF/C0/locali_5_s1\[71:0\]} \
{/IPF_tb/IPF/C0/locali_5_s1_id0\[71:0\]} \
{/IPF_tb/IPF/C0/mul_result\[143:0\]} \
{/IPF_tb/IPF/C0/result\[143:0\]} \
{/IPF_tb/IPF/C0/round\[2:0\]} \
{/IPF_tb/IPF/C0/rst_n} \
{/IPF_tb/IPF/C0/shift_direction} \
{/IPF_tb/IPF/C0/shift_direction_dff} \
{/IPF_tb/IPF/C0/stride} \
{/IPF_tb/IPF/C0/stride_dff} \
{/IPF_tb/IPF/C0/w_dat\[79:0\]} \
{/IPF_tb/IPF/C0/wsize\[1:0\]} \
{/IPF_tb/IPF/C0/wsize_dff\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 36 37 38 39 40 41 42 43 44 45 46 47 48 49 \
           50 51 52 53 54 55 56 57 58 59 )} 
wvSetPosition -win $_nWave1 {("G1" 59)}
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvExit
