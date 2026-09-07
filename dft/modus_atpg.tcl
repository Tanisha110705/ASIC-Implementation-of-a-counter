# =========================================================
# Cadence Modus ATPG Script
# Run command: modus -files modus_atpg.tcl
# =========================================================

# 1. Build ATPG Logic Model from DFT Netlist
build_model \
  -design counter \
  -verilog counter_dft_netlist.v \
  -lib_verilog ./lib/verilog/basicCells.v

# 2. Perform Test Rule Checks (TRC)
run_test_rule_check

# 3. Create Stuck-at Fault Model & Generate ATPG Patterns
create_fault_model -fault_type stuck_at
create_test_vectors

# 4. Export Test Pattern Deliverables
write_vectors -format stil -output outputs/patterns.stil
write_vectors -format verilog -output outputs/patterns_tb.v
report_atpg_summary > report_atpg.rpt
