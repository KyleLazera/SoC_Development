# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\Users\klaze\Desktop\Vitis_intro\FPro_Bus_Hardware\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\Users\klaze\Desktop\Vitis_intro\FPro_Bus_Hardware\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {FPro_Bus_Hardware}\
-hw {C:\Users\klaze\Xilinx_FGPA_Projects\Introductory_Projects\Chapter_11_MMIO\Vanilla_Fpro_Bus\FPro_Bus_Hardware.xsa}\
-out {C:/Users/klaze/Desktop/Vitis_intro}

platform write
domain create -name {standalone_microblaze_I} -display-name {standalone_microblaze_I} -os {standalone} -proc {microblaze_I} -runtime {cpp} -arch {32-bit} -support-app {empty_application}
platform generate -domains 
platform active {FPro_Bus_Hardware}
platform generate -quick
platform generate
platform generate -domains 
platform active {FPro_Bus_Hardware}
platform config -updatehw {C:/Users/klaze/Xilinx_FGPA_Projects/Introductory_Projects/Chapter_11_MMIO/Vanilla_Fpro_Bus/FPro_Vanilla.xsa}
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform active {FPro_Bus_Hardware}
platform config -updatehw {C:/Users/klaze/Xilinx_FGPA_Projects/Introductory_Projects/Chapter_11_MMIO/Vanilla_Fpro_Bus/FPro_Vanilla.xsa}
platform generate -domains 
platform generate -domains 
platform active {FPro_Bus_Hardware}
platform config -updatehw {C:/Users/klaze/Xilinx_FGPA_Projects/Introductory_Projects/Chapter_11_MMIO/Vanilla_Fpro_Bus/FPro_Vanilla.xsa}
platform config -updatehw {C:/Users/klaze/Xilinx_FGPA_Projects/Introductory_Projects/Chapter_11_MMIO/Vanilla_Fpro_Bus/FPro_Vanilla.xsa}
platform generate -domains 
platform generate -domains 
platform config -updatehw {C:/Users/klaze/Xilinx_FGPA_Projects/Introductory_Projects/Chapter_11_MMIO/Vanilla_Fpro_Bus/FPro_Vanilla.xsa}
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform config -updatehw {C:/Users/klaze/Xilinx_FGPA_Projects/Introductory_Projects/Chapter_11_MMIO/Vanilla_Fpro_Bus/FPro_Vanilla.xsa}
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform active {FPro_Bus_Hardware}
platform config -updatehw {C:/Users/klaze/Xilinx_FGPA_Projects/Introductory_Projects/Chapter_11_MMIO/Vanilla_Fpro_Bus/FPro_Vanilla.xsa}
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform active {FPro_Bus_Hardware}
platform config -updatehw {C:/Users/klaze/Xilinx_FGPA_Projects/Introductory_Projects/Chapter_11_MMIO/Vanilla_Fpro_Bus/FPro_Vanilla.xsa}
platform generate -domains 
platform generate -domains 
platform generate -domains 
platform generate -domains 
