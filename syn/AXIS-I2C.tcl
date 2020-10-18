# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir ".."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

# Set the project name
set _xil_proj_name_ "AXIS-I2C"

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
  set _xil_proj_name_ $::user_project_name
}

variable script_file
set script_file "AXIS-I2C.tcl"

# Help information for this script
proc print_help {} {
  variable script_file
  puts "\nDescription:"
  puts "Recreate a Vivado project from this script. The created project will be"
  puts "functionally equivalent to the original project for which this script was"
  puts "generated. The script contains commands for creating a project, filesets,"
  puts "runs, adding/importing sources and setting properties on various objects.\n"
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--origin_dir <path>\]"
  puts "$script_file -tclargs \[--project_name <name>\]"
  puts "$script_file -tclargs \[--help\]\n"
  puts "Usage:"
  puts "Name                   Description"
  puts "-------------------------------------------------------------------------"
  puts "\[--origin_dir <path>\]  Determine source file paths wrt this path. Default"
  puts "                       origin_dir path value is \".\", otherwise, the value"
  puts "                       that was set with the \"-paths_relative_to\" switch"
  puts "                       when this script was generated.\n"
  puts "\[--project_name <name>\] Create project with the specified name. Default"
  puts "                       name is the name of the project from where this"
  puts "                       script was generated.\n"
  puts "\[--help\]               Print help information for this script"
  puts "-------------------------------------------------------------------------\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < $::argc} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--origin_dir"   { incr i; set origin_dir [lindex $::argv $i] }
      "--project_name" { incr i; set _xil_proj_name_ [lindex $::argv $i] }
      "--help"         { print_help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

# Create project
create_project -force ${_xil_proj_name_} ${origin_dir}/syn/${_xil_proj_name_} -part xc7z020clg484-1

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]
set_property -name "board_part" -value "em.avnet.com:zed:part0:1.4" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/${_xil_proj_name_}.cache/ip" -objects $obj
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
set_property -name "platform.board_id" -value "zed" -objects $obj
set_property -name "sim.central_dir" -value "$proj_dir/${_xil_proj_name_}.ip_user_files" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "webtalk.activehdl_export_sim" -value "4" -objects $obj
set_property -name "webtalk.ies_export_sim" -value "4" -objects $obj
set_property -name "webtalk.modelsim_export_sim" -value "4" -objects $obj
set_property -name "webtalk.questa_export_sim" -value "4" -objects $obj
set_property -name "webtalk.riviera_export_sim" -value "4" -objects $obj
set_property -name "webtalk.vcs_export_sim" -value "4" -objects $obj
set_property -name "webtalk.xsim_export_sim" -value "4" -objects $obj


############################################
############# Create File Sets #############
############################################
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set IP repository paths
set sources_1_obj [get_filesets sources_1]
set sim_1_obj [get_filesets sim_1]
set_property "ip_repo_paths" "[file normalize "$origin_dir/src/ip/local_repo"]" $sources_1_obj
# simsets have no such property
#set_property "ip_repo_paths" "[file normalize "$origin_dir/src/ip/local_repo"]" $sim_1_obj
update_ip_catalog -rebuild

set_property -name "top_lib" -value "xil_defaultlib" -objects $sim_1_obj
set_property -name "hbs.configure_design_for_hier_access" -value "1" -objects $sim_1_obj

# Enable UVM
set_property -name {xsim.compile.xvlog.more_options} -value {-L UVM} -objects $sim_1_obj
# set_property include_dirs [list \
#  [file normalize "${origin_dir}/sim/tb/tests" ]\
#  [file normalize "${origin_dir}/sim/tb/i2c_vip_pkg" ]\
#  [file normalize "${origin_dir}/sim/tb/spi_vip_pkg" ]\
# ] $sim_1_obj

##########################################
############# Set File Lists #############
##########################################

set srcFiles [list \
 [file normalize "${origin_dir}/src/ip/AXIS_I2C_Master_0/AXIS_I2C_Master_0.xci" ]\
 [file normalize "${origin_dir}/src/rtl/interfaces/axistream_intf.sv" ]\
 [file normalize "${origin_dir}/src/rtl/interfaces/i2c_intf.sv" ]\
 [file normalize "${origin_dir}/src/rtl/interfaces/spi_intf.sv" ]\
 [file normalize "${origin_dir}/src/rtl/interfaces/axilite_intf.sv" ]\
 [file normalize "${origin_dir}/src/rtl/fpga_top.sv" ]\
]
set simFiles [list \
 [file normalize "${origin_dir}/src/ip/axis_master_0/axis_master_0.xci" ]\
 [file normalize "${origin_dir}/src/ip/axis_slave_0/axis_slave_0.xci" ]\
 [file normalize "${origin_dir}/src/ip/axi4_master_0/axi4_master_0.xci" ]\
 [file normalize "${origin_dir}/sim/tb/i2c_vip_pkg/i2c_vip_pkg.sv" ]\
 [file normalize "${origin_dir}/sim/tb/spi_vip_pkg/spi_vip_pkg.sv" ]\
 [file normalize "${origin_dir}/sim/tb/axi4stream_uvm/axi4stream_uvm_pkg.sv" ]\
 [file normalize "${origin_dir}/sim/tb/generic_components/generic_components_pkg.sv" ]\
 [file normalize "${origin_dir}/sim/tb/axis_i2c_master/axis_i2c_master_pkg.sv" ]\
 [file normalize "${origin_dir}/sim/tb/tb_pkg.sv" ]\
 [file normalize "${origin_dir}/sim/tb/tb_top.sv" ]\
 [file normalize "${origin_dir}/sim/tb/tb_top_deserialized.sv" ]\
]
add_files -fileset sources_1 $srcFiles
add_files -fileset sim_1 $simFiles

###############################################
############# Set File Properties #############
###############################################

proc setSystemVerilog {file sourceset} {
  set file_obj [get_files -of_objects $sourceset [list "*$file"]]
  puts $file_obj
  set_property -name "file_type" -value "SystemVerilog" -objects $file_obj
}
setSystemVerilog "src/rtl/interfaces/axistream_intf.sv" $sources_1_obj
setSystemVerilog "src/rtl/interfaces/i2c_intf.sv" $sources_1_obj
setSystemVerilog "src/rtl/interfaces/spi_intf.sv" $sources_1_obj
setSystemVerilog "src/rtl/interfaces/axilite_intf.sv" $sources_1_obj
setSystemVerilog "src/rtl/fpga_top.sv" $sources_1_obj

setSystemVerilog "sim/tb/tb_top.sv" $sim_1_obj
setSystemVerilog "sim/tb/tb_top_deserialized.sv" $sim_1_obj
setSystemVerilog "sim/tb/i2c_vip_pkg/i2c_vip_pkg.sv" $sim_1_obj
setSystemVerilog "sim/tb/spi_vip_pkg/spi_vip_pkg.sv" $sim_1_obj
setSystemVerilog "sim/tb/generic_components/generic_components_pkg.sv" $sim_1_obj
setSystemVerilog "sim/tb/tb_pkg.sv" $sim_1_obj

####################################
############# Set Tops #############
####################################

set_property -name "top" -value "fpga_top" -objects $sources_1_obj
set_property -name "top" -value "tb_top" -objects $sim_1_obj

# already exists by default
#create_run -name synth_1 -part xc7z020clg484-1 -flow {Vivado Synthesis 2020} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
set synth_1_obj [get_runs synth_1]
set_property set_report_strategy_name 1 $synth_1_obj
set_property report_strategy {Vivado Synthesis Default Reports} $synth_1_obj
set_property set_report_strategy_name 0 $synth_1_obj

# already exists by default
#create_report_config -report_name synth_1_synth_report_utilization_0 -report_type report_utilization:1.0 -steps synth_design -runs synth_1
set synth_report_utlization_obj [get_report_configs -of_objects [get_runs synth_1] synth_1_synth_report_utilization_0]
# set the current synth run
current_run -synthesis $synth_1_obj

# already exists by default
#create_run -name impl_1 -part xc7z020clg484-1 -flow {Vivado Implementation 2020} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
set impl_1_obj [get_runs impl_1]
set_property set_report_strategy_name 1 $impl_1_obj
set_property report_strategy {Vivado Implementation Default Reports} $impl_1_obj
set_property set_report_strategy_name 0 $impl_1_obj

# Create 'impl_1_init_report_timing_summary_0' report (if not found)
set impl_report_init_timing_obj [get_report_configs -of_objects $impl_1_obj impl_1_init_report_timing_summary_0]
if { [string equal $impl_report_init_timing_obj "" ] } {
  set impl_report_init_timing_obj [create_report_config -report_name impl_1_init_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps init_design -runs impl_1]
}
set_property -name "is_enabled" -value "0" -objects $impl_report_init_timing_obj
set_property -name "options.max_paths" -value "10" -objects $impl_report_init_timing_obj

# Create 'impl_1_opt_report_drc_0' report (if not found)
set impl_report_drc_obj [get_report_configs -of_objects [get_runs $impl_1_obj] impl_1_opt_report_drc_0]
if { [string equal $ "" ] } {
  set impl_report_drc_obj [create_report_config -report_name impl_1_opt_report_drc_0 -report_type report_drc:1.0 -steps opt_design -runs impl_1]
}

# Create 'impl_1_opt_report_timing_summary_0' report (if not found)
set impl_report_opt_timing_obj [get_report_configs -of_objects $impl_1_obj impl_1_opt_report_timing_summary_0]
if { [string equal $impl_report_opt_timing_obj "" ] } {
  set impl_report_opt_timing_obj [create_report_config -report_name impl_1_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps opt_design -runs impl_1]
}
set_property -name "is_enabled" -value "0" -objects $impl_report_opt_timing_obj
set_property -name "options.max_paths" -value "10" -objects $impl_report_opt_timing_obj

# Create 'impl_1_power_opt_report_timing_summary_0' report (if not found)
set impl_report_power_opt_timing_obj [get_report_configs -of_objects $impl_1_obj impl_1_power_opt_report_timing_summary_0]
if { [string equal $impl_report_power_opt_timing_obj "" ] } {
  set impl_report_power_opt_timing_obj [create_report_config -report_name impl_1_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps power_opt_design -runs impl_1]
}
set_property -name "is_enabled" -value "0" -objects $impl_report_power_opt_timing_obj
set_property -name "options.max_paths" -value "10" -objects $impl_report_power_opt_timing_obj

# Create 'impl_1_place_report_io_0' report (if not found)
set impl_report_place_io_obj [get_report_configs -of_objects $impl_1_obj impl_1_place_report_io_0]
if { [string equal $impl_report_place_io_obj "" ] } {
  set impl_report_place_io_obj [create_report_config -report_name impl_1_place_report_io_0 -report_type report_io:1.0 -steps place_design -runs impl_1]
}

# Create 'impl_1_place_report_utilization_0' report (if not found)
set impl_report_place_utilization_obj [get_report_configs -of_objects $impl_1_obj impl_1_place_report_utilization_0]
if { [string equal $impl_report_place_utilization_obj "" ] } {
  set impl_report_place_utilization_obj [create_report_config -report_name impl_1_place_report_utilization_0 -report_type report_utilization:1.0 -steps place_design -runs impl_1]
}

# Create 'impl_1_place_report_control_sets_0' report (if not found)
set impl_report_place_control_sets_obj [get_report_configs -of_objects $impl_1_obj impl_1_place_report_control_sets_0]
if { [string equal $impl_report_place_control_sets_obj "" ] } {
  set impl_report_place_control_sets_obj [create_report_config -report_name impl_1_place_report_control_sets_0 -report_type report_control_sets:1.0 -steps place_design -runs impl_1]
}
set_property -name "options.verbose" -value "1" -objects $impl_report_place_control_sets_obj

# Create 'impl_1_place_report_incremental_reuse_0' report (if not found)
set impl_report_reuse_0_obj [get_report_configs -of_objects $impl_1_obj impl_1_place_report_incremental_reuse_0]
if { [string equal $impl_report_reuse_0_obj "" ] } {
  set impl_report_reuse_0_obj [create_report_config -report_name impl_1_place_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps place_design -runs impl_1]
}
set_property -name "is_enabled" -value "0" -objects $impl_report_reuse_0_obj

# Create 'impl_1_place_report_incremental_reuse_1' report (if not found)
set impl_report_reuse_1_obj [get_report_configs -of_objects $impl_1_obj impl_1_place_report_incremental_reuse_1]
if { [string equal $impl_report_reuse_1_obj "" ] } {
  set impl_report_reuse_1_obj [create_report_config -report_name impl_1_place_report_incremental_reuse_1 -report_type report_incremental_reuse:1.0 -steps place_design -runs impl_1]
}
set_property -name "is_enabled" -value "0" -objects $impl_report_reuse_1_obj

# Create 'impl_1_place_report_timing_summary_0' report (if not found)
set impl_report_place_utilization_obj [get_report_configs -of_objects $impl_1_obj impl_1_place_report_timing_summary_0]
if { [string equal $impl_report_place_utilization_obj "" ] } {
  set impl_report_place_utilization_obj [create_report_config -report_name impl_1_place_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps place_design -runs impl_1]
}
set_property -name "is_enabled" -value "0" -objects $impl_report_place_utilization_obj
set_property -name "options.max_paths" -value "10" -objects $impl_report_place_utilization_obj

# Create 'impl_1_post_place_power_opt_report_timing_summary_0' report (if not found)
set impl_report_place_power_opt_timing_obj [get_report_configs -of_objects $impl_1_obj impl_1_post_place_power_opt_report_timing_summary_0]
if { [string equal $impl_report_place_power_opt_timing_obj "" ] } {
  set impl_report_place_power_opt_timing_obj [create_report_config -report_name impl_1_post_place_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_place_power_opt_design -runs impl_1]
}
set_property -name "is_enabled" -value "0" -objects $impl_report_place_power_opt_timing_obj
set_property -name "options.max_paths" -value "10" -objects $impl_report_place_power_opt_timing_obj

# Create 'impl_1_phys_opt_report_timing_summary_0' report (if not found)
set impl_report_phys_opt_timing_obj [get_report_configs -of_objects $impl_1_obj impl_1_phys_opt_report_timing_summary_0]
if { [string equal $impl_report_phys_opt_timing_obj "" ] } {
  set impl_report_phys_opt_timing_obj [create_report_config -report_name impl_1_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps phys_opt_design -runs impl_1]
}
set_property -name "is_enabled" -value "0" -objects $impl_report_phys_opt_timing_obj
set_property -name "options.max_paths" -value "10" -objects $impl_report_phys_opt_timing_obj

# Create 'impl_1_route_report_drc_0' report (if not found)
set impl_report_route_drc_obj [get_report_configs -of_objects $impl_1_obj impl_1_route_report_drc_0]
if { [string equal $impl_report_route_drc_obj "" ] } {
  set impl_report_route_drc_obj [create_report_config -report_name impl_1_route_report_drc_0 -report_type report_drc:1.0 -steps route_design -runs impl_1]
}

# Create 'impl_1_route_report_methodology_0' report (if not found)
if { [ string equal [get_report_configs -of_objects $impl_1_obj impl_1_route_report_methodology_0] "" ] } {
  create_report_config -report_name impl_1_route_report_methodology_0 -report_type report_methodology:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects $impl_1_obj impl_1_route_report_methodology_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_power_0' report (if not found)
if { [ string equal [get_report_configs -of_objects $impl_1_obj impl_1_route_report_power_0] "" ] } {
  create_report_config -report_name impl_1_route_report_power_0 -report_type report_power:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects $impl_1_obj impl_1_route_report_power_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_route_status_0' report (if not found)
if { [ string equal [get_report_configs -of_objects $impl_1_obj impl_1_route_report_route_status_0] "" ] } {
  create_report_config -report_name impl_1_route_report_route_status_0 -report_type report_route_status:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects $impl_1_obj impl_1_route_report_route_status_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects $impl_1_obj impl_1_route_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_route_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects $impl_1_obj impl_1_route_report_timing_summary_0]
if { $obj != "" } {
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_route_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects $impl_1_obj impl_1_route_report_incremental_reuse_0] "" ] } {
  create_report_config -report_name impl_1_route_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects $impl_1_obj impl_1_route_report_incremental_reuse_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_clock_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects $impl_1_obj impl_1_route_report_clock_utilization_0] "" ] } {
  create_report_config -report_name impl_1_route_report_clock_utilization_0 -report_type report_clock_utilization:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects $impl_1_obj impl_1_route_report_clock_utilization_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects $impl_1_obj impl_1_route_report_bus_skew_0] "" ] } {
  create_report_config -report_name impl_1_route_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects $impl_1_obj impl_1_route_report_bus_skew_0]
if { $obj != "" } {
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
# Create 'impl_1_post_route_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects $impl_1_obj impl_1_post_route_phys_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_post_route_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_route_phys_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects $impl_1_obj impl_1_post_route_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
# Create 'impl_1_post_route_phys_opt_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects $impl_1_obj impl_1_post_route_phys_opt_report_bus_skew_0] "" ] } {
  create_report_config -report_name impl_1_post_route_phys_opt_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps post_route_phys_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects $impl_1_obj impl_1_post_route_phys_opt_report_bus_skew_0]
if { $obj != "" } {
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
set obj $impl_1_obj
set_property -name "strategy" -value "Vivado Implementation Defaults" -objects $obj
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj

# set the current impl run
current_run -implementation $impl_1_obj

puts "INFO: Project created:${_xil_proj_name_}"
# Create 'drc_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "drc_1" ] ] ""]} {
create_dashboard_gadget -name {drc_1} -type drc
}
set obj [get_dashboard_gadgets [ list "drc_1" ] ]
set_property -name "reports" -value "impl_1#impl_1_route_report_drc_0" -objects $obj

# Create 'methodology_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "methodology_1" ] ] ""]} {
create_dashboard_gadget -name {methodology_1} -type methodology
}
set obj [get_dashboard_gadgets [ list "methodology_1" ] ]
set_property -name "reports" -value "impl_1#impl_1_route_report_methodology_0" -objects $obj

# Create 'power_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "power_1" ] ] ""]} {
create_dashboard_gadget -name {power_1} -type power
}
set obj [get_dashboard_gadgets [ list "power_1" ] ]
set_property -name "reports" -value "impl_1#impl_1_route_report_power_0" -objects $obj

# Create 'timing_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "timing_1" ] ] ""]} {
create_dashboard_gadget -name {timing_1} -type timing
}
set obj [get_dashboard_gadgets [ list "timing_1" ] ]
set_property -name "reports" -value "impl_1#impl_1_route_report_timing_summary_0" -objects $obj

# Create 'utilization_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "utilization_1" ] ] ""]} {
create_dashboard_gadget -name {utilization_1} -type utilization
}
set obj [get_dashboard_gadgets [ list "utilization_1" ] ]
set_property -name "reports" -value "synth_1#synth_1_synth_report_utilization_0" -objects $obj
set_property -name "run.step" -value "synth_design" -objects $obj
set_property -name "run.type" -value "synthesis" -objects $obj

# Create 'utilization_2' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "utilization_2" ] ] ""]} {
create_dashboard_gadget -name {utilization_2} -type utilization
}
set obj [get_dashboard_gadgets [ list "utilization_2" ] ]
set_property -name "reports" -value "impl_1#impl_1_place_report_utilization_0" -objects $obj

move_dashboard_gadget -name {utilization_1} -row 0 -col 0
move_dashboard_gadget -name {power_1} -row 1 -col 0
move_dashboard_gadget -name {drc_1} -row 2 -col 0
move_dashboard_gadget -name {timing_1} -row 0 -col 1
move_dashboard_gadget -name {utilization_2} -row 1 -col 1
move_dashboard_gadget -name {methodology_1} -row 2 -col 1
