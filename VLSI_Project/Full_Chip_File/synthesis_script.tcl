set_db init_lib_search_path "pdk/stdcell pdk/iopad"
set_db library "slow_vdd1v2_basicCells.lib pads_SS_s1vg.lib"
set_db lef_library "pdk/stdcell/gsclib045_tech.lef pdk/stdcell/gsclib045_macro.lef 
 pdk/iopad/giolib045.lef"
set_db hdl_search_path input_files
read_hdl usb_controller_wpad.v
elaborate
set_top_module usb_controller_wpad
current_design usb_controller_wpad
write_hdl > usb_controller_wpad_elaborated.v
############### constraints ###############
create_clock -name clk -period 4.87 [get_ports PAD_clk]
set_clock_uncertainty -setup 0.5 [get_clocks clk]
set_clock_uncertainty -hold 0.5 [get_clocks clk]
set_max_transition 0.9 [get_ports PAD_clk]
set_clock_transition -min -fall 0.5 [get_clocks clk]
set_clock_transition -min -rise 0.5 [get_clocks clk]
set_clock_transition -max -fall 0.5 [get_clocks clk]
set_clock_transition -max -rise 0.5 [get_clocks clk]
set_clock_groups -name original -group [list [get_clocks clk]]
set DRIVING_CELL BUFX8
set DRIVE_PIN {Y}
set_driving_cell -lib_cell $DRIVING_CELL -pin $DRIVE_PIN [all_inputs]
set_max_fanout 8 [current_design]
set_load 0.5 [all_outputs]
set_operating_conditions PVT_1P08V_125C
set_input_delay -max 1.86 [all_inputs]
set_output_delay -max 2.23 [all_outputs]
set_dont_use SDFFQX*
###########################################
remove_assign -buffer_or_inverter BUFX16 -design [current_design]
syn_gen
write_hdl > usb_controller_wpad_generic.v
syn_map
write_hdl > usb_controller_wpad_post_synthesis.v
set_remove_assign_options -buffer_or_inverter BUFX12 -verbose
remove_assigns_without_opt -buffer_or_inverter BUFX12 -verbose
syn_opt
write -mapped > usb_controller_wpad_mapped.v
write_sdc > usb_controller_wpad.sdc
