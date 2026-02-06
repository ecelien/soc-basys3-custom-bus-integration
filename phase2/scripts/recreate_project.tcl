
# Define project name and paths
set project_name "task_2"
set origin_dir "."
set output_dir "../hw/vivado"
set part_name "xc7a35tcpg236-1"
set ip_repo_dir [file normalize "$origin_dir/../hw/ip_repo"]
set design_name "design_2"

# Set board repo path GLOBAL parameter to ensure it is picked up before project creation
set_param board.repoPaths [file normalize "$origin_dir/../hw/board_files"]

# Create the project
create_project $project_name $output_dir -part $part_name -force

# (Optional) Add board files if you have them in the repo
set_property board_part_repo_paths [file normalize "$origin_dir/../hw/board_files"] [current_project]
# Refresh catalog to ensure the board_part_repo_paths is picked up and warnings are suppressed
update_ip_catalog
set_property board_part digilentinc.com:basys3:part0:1.2 [current_project]

set_property target_language VHDL [current_project]

set_property ip_repo_paths $ip_repo_dir [current_project]
update_ip_catalog

# Reconstruct the Block Design
source $origin_dir/../hw/src/bd/design_2.bd.tcl
regenerate_bd_layout
save_bd_design

# Create and add the wrapper
open_bd_design $design_name.bd

make_wrapper -files [get_files $design_name.bd] -top
add_files -norecurse [file normalize $output_dir/$project_name.gen/sources_1/bd/$design_name/hdl/${design_name}_wrapper.vhd]
update_compile_order -fileset sources_1

validate_bd_design
save_bd_design

puts "Project created successfully."
