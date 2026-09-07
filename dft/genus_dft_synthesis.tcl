# =========================================================
# 1. Search Paths & Libraries
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
# 2. Read RTL & Elaborate
# =========================================================
read_hdl "counter.v"
elaborate counter

# =========================================================
# 3. Apply Constraints
# =========================================================
set PERIOD 0.404
create_clock -name "clock" -period $PERIOD [get_ports clk]

set INPUTPORTS [remove_from_collection [all_inputs] [get_ports clk]]
set OUTPUTPORTS [all_outputs]
set_input_delay -clock "clock" -max 0.1 $INPUTPORTS
set_output_delay -clock "clock" -max 0.25 $OUTPUTPORTS

# =========================================================
# 4. DFT Setup & Rule Check
# =========================================================
set_db dft_scan_style muxed_scan
define_dft shift_enable -name SE -active high [get_ports scan_en]

check_dft_rules

# =========================================================
# 5. Mapping & Scan Chain Insertion
# =========================================================
set_db syn_generic_effort medium
set_db syn_map_effort medium
syn_generic
syn_map

define_dft scan_chain -name top_chain -sdomain default -scan_in scan_in -scan_out scan_out
connect_scan_chains

# =========================================================
# 6. Incremental Optimization & Output Files
# =========================================================
set_db syn_opt_effort medium
syn_opt -incremental

report_dft_chains > ./report_dft_chains.rpt
report_dft_registers > ./report_dft_registers.rpt
report_timing > ./report_dft_timing.rpt
report_area > ./report_dft_area.rpt

write_hdl > ./counter_dft_netlist.v
write_sdc > ./counter_dft.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > outputs/dft_delays.sdf
