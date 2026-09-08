// Set Log File
set log file lec.log -replace

// Read Technology Libraries
read library ./lib/verilog/slow_vdd1v0_basicCells.v ./lib/verilog/slow_vdd1v0_basicCells_lvt.v ./lib/verilog/slow_vdd1v0_basicCells_hvt.v -verilog -b

// Read Golden Design (RTL) and Elaborate
read design -verilog -golden -lastmod -noelab counter.v
elaborate design -golden -root counter

// Read Revised Design (Synthesized Netlist) and Elaborate
read design -verilog -revised -lastmod -noelab counter_netlist.v
elaborate design -revised -root counter

// Flatten Model Options
set flatten model -seq_constant
set flatten model -seq_constant_x_to 0
set flatten model -nodff_to_dlat_zero
set flatten model -nodff_to_dlat_feedback
set flatten model -hier_seq_merge
set flatten model -gated_clock

// Switch System Mode to LEC & Check Unmapped Points
set system mode lec
report unmapped points -summary
report unmapped points -notmapped

// Add Compare Points & Execute Comparison
add compare points -all
compare

// Report Equivalence & Verification Results
report compare data -class nonequivalent -class abort -class notcompared
report verification -verbose
