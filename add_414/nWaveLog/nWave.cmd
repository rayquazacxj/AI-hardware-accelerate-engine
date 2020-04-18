wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 {/users/student/mr108/hshuang19/add/ADDER_syn.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/ADDER_tb"
wvGetSignalSetScope -win $_nWave1 "/ADDER_tb/ADDER"
wvSetPosition -win $_nWave1 {("G1" 7)}
wvSetPosition -win $_nWave1 {("G1" 7)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/ADDER_tb/ADDER/Ain_valid} \
{/ADDER_tb/ADDER/Avalid} \
{/ADDER_tb/ADDER/Bin_valid} \
{/ADDER_tb/ADDER/Bvalid} \
{/ADDER_tb/ADDER/FSAvalid} \
{/ADDER_tb/ADDER/MUL_DATA_valid_dff} \
{/ADDER_tb/ADDER/MUL_results_dff\[73727:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 2 3 4 5 6 7 )} 
wvSetPosition -win $_nWave1 {("G1" 7)}
wvGetSignalSetScope -win $_nWave1 "/ADDER_tb/ADDER/C0"
wvSetPosition -win $_nWave1 {("G1" 9)}
wvSetPosition -win $_nWave1 {("G1" 9)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/ADDER_tb/ADDER/Ain_valid} \
{/ADDER_tb/ADDER/Avalid} \
{/ADDER_tb/ADDER/Bin_valid} \
{/ADDER_tb/ADDER/Bvalid} \
{/ADDER_tb/ADDER/FSAvalid} \
{/ADDER_tb/ADDER/MUL_DATA_valid_dff} \
{/ADDER_tb/ADDER/MUL_results_dff\[73727:0\]} \
{/ADDER_tb/ADDER/C0/FSAout\[45:0\]} \
{/ADDER_tb/ADDER/C0/FSAvalid} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 8 9 )} 
wvSetPosition -win $_nWave1 {("G1" 9)}
wvGetSignalSetScope -win $_nWave1 \
           "/ADDER_tb/ADDER/@\{\\genblk1\[0\].genblk1\[0\].aa \}"
wvSetPosition -win $_nWave1 {("G1" 11)}
wvSetPosition -win $_nWave1 {("G1" 11)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/ADDER_tb/ADDER/Ain_valid} \
{/ADDER_tb/ADDER/Avalid} \
{/ADDER_tb/ADDER/Bin_valid} \
{/ADDER_tb/ADDER/Bvalid} \
{/ADDER_tb/ADDER/FSAvalid} \
{/ADDER_tb/ADDER/MUL_DATA_valid_dff} \
{/ADDER_tb/ADDER/MUL_results_dff\[73727:0\]} \
{/ADDER_tb/ADDER/C0/FSAout\[45:0\]} \
{/ADDER_tb/ADDER/C0/FSAvalid} \
{/ADDER_tb/ADDER/@\{\\genblk1\[0\].genblk1\[0\].aa \}/Aout\[53:0\]} \
{/ADDER_tb/ADDER/@\{\\genblk1\[0\].genblk1\[0\].aa \}/Avalid} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 10 11 )} 
wvSetPosition -win $_nWave1 {("G1" 11)}
wvGetSignalSetScope -win $_nWave1 \
           "/ADDER_tb/ADDER/@\{\\genblk2\[0\].genblk1\[0\].bb \}"
wvSetPosition -win $_nWave1 {("G1" 13)}
wvSetPosition -win $_nWave1 {("G1" 13)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/ADDER_tb/ADDER/Ain_valid} \
{/ADDER_tb/ADDER/Avalid} \
{/ADDER_tb/ADDER/Bin_valid} \
{/ADDER_tb/ADDER/Bvalid} \
{/ADDER_tb/ADDER/FSAvalid} \
{/ADDER_tb/ADDER/MUL_DATA_valid_dff} \
{/ADDER_tb/ADDER/MUL_results_dff\[73727:0\]} \
{/ADDER_tb/ADDER/C0/FSAout\[45:0\]} \
{/ADDER_tb/ADDER/C0/FSAvalid} \
{/ADDER_tb/ADDER/@\{\\genblk1\[0\].genblk1\[0\].aa \}/Aout\[53:0\]} \
{/ADDER_tb/ADDER/@\{\\genblk1\[0\].genblk1\[0\].aa \}/Avalid} \
{/ADDER_tb/ADDER/@\{\\genblk2\[0\].genblk1\[0\].bb \}/Bout\[53:0\]} \
{/ADDER_tb/ADDER/@\{\\genblk2\[0\].genblk1\[0\].bb \}/Bvalid} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 12 13 )} 
wvSetPosition -win $_nWave1 {("G1" 13)}
wvGetSignalSetScope -win $_nWave1 "/ADDER_tb"
wvSetPosition -win $_nWave1 {("G1" 16)}
wvSetPosition -win $_nWave1 {("G1" 16)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/ADDER_tb/ADDER/Ain_valid} \
{/ADDER_tb/ADDER/Avalid} \
{/ADDER_tb/ADDER/Bin_valid} \
{/ADDER_tb/ADDER/Bvalid} \
{/ADDER_tb/ADDER/FSAvalid} \
{/ADDER_tb/ADDER/MUL_DATA_valid_dff} \
{/ADDER_tb/ADDER/MUL_results_dff\[73727:0\]} \
{/ADDER_tb/ADDER/C0/FSAout\[45:0\]} \
{/ADDER_tb/ADDER/C0/FSAvalid} \
{/ADDER_tb/ADDER/@\{\\genblk1\[0\].genblk1\[0\].aa \}/Aout\[53:0\]} \
{/ADDER_tb/ADDER/@\{\\genblk1\[0\].genblk1\[0\].aa \}/Avalid} \
{/ADDER_tb/ADDER/@\{\\genblk2\[0\].genblk1\[0\].bb \}/Bout\[53:0\]} \
{/ADDER_tb/ADDER/@\{\\genblk2\[0\].genblk1\[0\].bb \}/Bvalid} \
{/ADDER_tb/Psum\[863:0\]} \
{/ADDER_tb/Psum_valid} \
{/ADDER_tb/clk} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 14 15 16 )} 
wvSetPosition -win $_nWave1 {("G1" 16)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSelectGroup -win $_nWave1 {G2}
wvExit
