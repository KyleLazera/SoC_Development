# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\Users\klaze\Desktop\Vitis_intro\microblaze_init\mcs_top_vanilla\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\Users\klaze\Desktop\Vitis_intro\microblaze_init\mcs_top_vanilla\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {mcs_top_vanilla}\
-hw {C:\Users\klaze\Xilinx_FGPA_Projects\Introductory_Projects\Chapter_10_Bare_Metal\example_project\mcs_top_vanilla.xsa}\
-out {C:/Users/klaze/Desktop/Vitis_intro/microblaze_init}

platform write
domain create -name {standalone_microblaze_I} -display-name {standalone_microblaze_I} -os {standalone} -proc {microblaze_I} -runtime {cpp} -arch {32-bit} -support-app {empty_application}
platform generate -domains 
platform active {mcs_top_vanilla}
platform generate -quick
platform generate
platform generate -domains 
platform generate -domains 
platform generate -domains 
