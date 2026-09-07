# =========================================================
# 1. Search Paths & Target Libraries
# =========================================================
set_db init_lib_search_path ./lib/timing
set_db init_hdl_search_path .

read_libs { \
  fast_vdd1v0_basicCells_hvt.lib slow_vdd1v0_basicCells_hvt.lib \
  fast_vdd1v0_basicCells.lib     slow_vdd1v0_basicCells.lib     \
  fast_vdd1v0_basicCells_lvt.lib slow_vdd1v0_basicCells_lvt.lib \
  fast_vdd1v2_basicCells_hvt.lib slow_vdd1v2_basicCells_hvt.lib \
  fast_vdd1v2_basicCells.lib     slow_vdd1v2_basicCells.lib     \
  fast_vdd1v2_basicCells_lvt.lib slow_vdd1v2_basicCells_lvt.lib \
}

# =========================================================
# 2. Read RTL & Elaborate Top Module
# =========================================================
read_hdl "counter.v"
elaborate counter

# =========================================================
# 3. Apply Design, Timing & DRC Constraints
# =========================================================
set PERIOD 0.404
set INPUT_DELAY 0.1
set OUTPUT_DELAY 0.25
set CLOCK_LATENCY 0.25
set SOURCE_LATENCY 0.25
set UNCERTAINTY 0.1
set MAX_TRANSITION 0.2
set MIN_CLOCK_LATENCY 0.05
set MIN_SOURCE_LATENCY 0.05
set MIN_IO_DELAY 0.1

create_clock -name "clock" -period $PERIOD [get_ports clk]
set_clock_latency $CLOCK_LATENCY [get_clocks clock]
set_clock_latency -min $MIN_CLOCK_LATENCY [get_clocks clock]
set_clock_latency -source $SOURCE_LATENCY [get_clocks clock]
set_clock_latency -source -min $MIN_SOURCE_LATENCY [get_clocks clock]
set_clock_uncertainty -setup $UNCERTAINTY [get_clocks clock]
set_clock_uncertainty -hold $UNCERTAINTY [get_clocks clock]
set_clock_transition 0.1 [get_clocks clock]

group_path -name CLOCK   -to clock -weight 1
group_path -name INPUTS  -through [all_inputs] -weight 1
group_path -name OUTPUTS -to [all_outputs] -weight 1
group_path -name COMBO   -from [all_inputs] -to [all_outputs] -weight 1

set INPUTPORTS [remove_from_collection [all_inputs] [get_ports clk]]
set OUTPUTPORTS [all_outputs]

set_input_delay  -clock "clock" -max $INPUT_DELAY $INPUTPORTS 
set_output_delay -clock "clock" -max $OUTPUT_DELAY $OUTPUTPORTS
set_input_delay  -clock "clock" -min $MIN_IO_DELAY $INPUTPORTS 
set_output_delay -clock "clock" -min $MIN_IO_DELAY $OUTPUTPORTS

set_max_transition $MAX_TRANSITION [current_design]
set_max_fanout 30 [current_design]
set_max_capacitance 80 [current_design]

# =========================================================
# 4. Power Directives & Optimization Effort
# =========================================================
set_db lp_insert_clock_gating true
set_db / .lp_power_analysis_effort high 
set_db / .leakage_power_effort medium 

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

# =========================================================
# 5. Synthesis Steps
# =========================================================
syn_generic
syn_map
syn_opt

# =========================================================
# 6. Generate Reports & Deliverables
# =========================================================
report_timing > ./report_timing.rpt
report_power  > ./report_power.rpt
report_area   > ./report_area.rpt
report_qor    > ./report_qor.rpt

write_hdl > ./counter_netlist.v
write_sdc > ./counter_sdc.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > outputs/delays.sdf
write_do_lec -golden_design rtl -revised_design counter_netlist.v > rtl_to_final.tcl
