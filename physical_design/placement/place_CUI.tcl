#read_db DBS/init.dat


set_db place_global_place_io_pins false
set_db opt_useful_skew true
set_db opt_fix_fanout_load true

place_opt_design

set_db add_tieoffs_cells {TIELO TIEHI}

get_db base_cells TIE* 
set_db [get_db base_cells TIE*] .dont_use true

add_tieoffs
set_db [get_db base_cells TIE*] .dont_use false

write_db DBS/place.dat

report_timing

set_db timing_analysis_check_type hold

report_timing -check_type hold


