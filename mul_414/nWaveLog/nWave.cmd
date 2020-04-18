wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 {/users/student/mr108/hshuang19/multestt/IPF_syn.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/IPF_tb"
wvGetSignalSetScope -win $_nWave1 "/IPF_tb/IPF"
wvSetPosition -win $_nWave1 {("G1" 15)}
wvSetPosition -win $_nWave1 {("G1" 15)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/IPF_tb/IPF/clk} \
{/IPF_tb/IPF/i_valid} \
{/IPF_tb/IPF/rega\[63:0\]} \
{/IPF_tb/IPF/regb\[63:0\]} \
{/IPF_tb/IPF/regc\[63:0\]} \
{/IPF_tb/IPF/regd\[63:0\]} \
{/IPF_tb/IPF/rege\[63:0\]} \
{/IPF_tb/IPF/regf\[63:0\]} \
{/IPF_tb/IPF/regg\[63:0\]} \
{/IPF_tb/IPF/regh\[63:0\]} \
{/IPF_tb/IPF/res_valid} \
{/IPF_tb/IPF/rst_n} \
{/IPF_tb/IPF/w\[1599:0\]} \
{/IPF_tb/IPF/w_valid} \
{/IPF_tb/IPF/widcnt\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 )} 
wvSetPosition -win $_nWave1 {("G1" 15)}
wvSetPosition -win $_nWave1 {("G1" 18)}
wvSetPosition -win $_nWave1 {("G1" 18)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/IPF_tb/IPF/clk} \
{/IPF_tb/IPF/i_valid} \
{/IPF_tb/IPF/rega\[63:0\]} \
{/IPF_tb/IPF/regb\[63:0\]} \
{/IPF_tb/IPF/regc\[63:0\]} \
{/IPF_tb/IPF/regd\[63:0\]} \
{/IPF_tb/IPF/rege\[63:0\]} \
{/IPF_tb/IPF/regf\[63:0\]} \
{/IPF_tb/IPF/regg\[63:0\]} \
{/IPF_tb/IPF/regh\[63:0\]} \
{/IPF_tb/IPF/res_valid} \
{/IPF_tb/IPF/rst_n} \
{/IPF_tb/IPF/w\[1599:0\]} \
{/IPF_tb/IPF/w_valid} \
{/IPF_tb/IPF/widcnt\[31:0\]} \
{/IPF_tb/IPF/C0/locali\[71:0\]} \
{/IPF_tb/IPF/C0/localw_dff2\[71:0\]} \
{/IPF_tb/IPF/C0/mul_result\[143:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 16 17 18 )} 
wvSetPosition -win $_nWave1 {("G1" 18)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 97165.423729 -snap {("G2" 0)}
wvSetCursor -win $_nWave1 79298.228043 -snap {("G1" 11)}
wvSelectGroup -win $_nWave1 {G2}
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvExit
