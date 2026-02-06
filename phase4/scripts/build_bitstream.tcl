
# Define project name and paths
set project_name "task_4"
set origin_dir "."
set output_dir "../hw/vivado"

# Open the existing project
open_project "$output_dir/$project_name.xpr"

# 1. Run Synthesis
launch_runs synth_1 -jobs 8
wait_on_run synth_1

# 2. Run Implementation 
launch_runs impl_1 -jobs 8
wait_on_run impl_1

# 3. Generate Bitstream
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

# Export the XSA including the bitstream
write_hw_platform -fixed -include_bit -force -file "$origin_dir/../hw/export/system_wrapper.xsa"

puts "Bitstream generated and XSA exported successfully."
