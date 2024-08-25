set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
	
#reset Signal
set_property PACKAGE_PIN U18 [get_ports reset_n]						
	set_property IOSTANDARD LVCMOS33 [get_ports reset_n]
 
# Switches
set_property PACKAGE_PIN V17 [get_ports {sw[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
set_property PACKAGE_PIN V16 [get_ports {sw[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
set_property PACKAGE_PIN W16 [get_ports {sw[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
set_property PACKAGE_PIN W17 [get_ports {sw[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]
set_property PACKAGE_PIN W15 [get_ports {sw[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[4]}]
set_property PACKAGE_PIN V15 [get_ports {sw[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]
set_property PACKAGE_PIN W14 [get_ports {sw[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]
set_property PACKAGE_PIN W13 [get_ports {sw[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]
set_property PACKAGE_PIN V2 [get_ports {sw[8]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[8]}]
set_property PACKAGE_PIN T3 [get_ports {sw[9]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[9]}]
set_property PACKAGE_PIN T2 [get_ports {sw[10]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[10]}]
set_property PACKAGE_PIN R3 [get_ports {sw[11]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[11]}]
set_property PACKAGE_PIN W2 [get_ports {sw[12]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[12]}]
set_property PACKAGE_PIN U1 [get_ports {sw[13]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[13]}]
set_property PACKAGE_PIN T1 [get_ports {sw[14]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[14]}]
set_property PACKAGE_PIN R2 [get_ports {sw[15]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw[15]}]
 

# LEDs
set_property PACKAGE_PIN U16 [get_ports {LED[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]
set_property PACKAGE_PIN E19 [get_ports {LED[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
set_property PACKAGE_PIN U19 [get_ports {LED[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]
set_property PACKAGE_PIN V19 [get_ports {LED[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]
set_property PACKAGE_PIN W18 [get_ports {LED[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]
set_property PACKAGE_PIN U15 [get_ports {LED[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]
set_property PACKAGE_PIN U14 [get_ports {LED[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[6]}]
set_property PACKAGE_PIN V14 [get_ports {LED[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[7]}]
set_property PACKAGE_PIN V13 [get_ports {LED[8]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[8]}]
set_property PACKAGE_PIN V3 [get_ports {LED[9]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[9]}]
set_property PACKAGE_PIN W3 [get_ports {LED[10]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[10]}]
set_property PACKAGE_PIN U3 [get_ports {LED[11]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[11]}]
set_property PACKAGE_PIN P3 [get_ports {LED[12]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[12]}]
set_property PACKAGE_PIN N3 [get_ports {LED[13]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[13]}]
set_property PACKAGE_PIN P1 [get_ports {LED[14]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[14]}]
set_property PACKAGE_PIN L1 [get_ports {LED[15]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[15]}]

#7 segment display
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]
set_property PACKAGE_PIN V7 [get_ports {seg[7]}]							
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[7]}]

set_property PACKAGE_PIN U2 [get_ports {an[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]

##Timer output port
##Sch name = JC1
set_property PACKAGE_PIN K17 [get_ports timer_complete]					
	set_property IOSTANDARD LVCMOS33 [get_ports timer_complete]	
#====================================================================================================
# USB-RS232 Interface
#====================================================================================================
set_property PACKAGE_PIN B18 [get_ports rx]
set_property IOSTANDARD LVCMOS33 [get_ports rx]
set_property PACKAGE_PIN A18 [get_ports tx]
set_property IOSTANDARD LVCMOS33 [get_ports tx]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

#Pmod Header JXADC
#Sch name = XA1_P
set_property PACKAGE_PIN J3 [get_ports {adc_p[0]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {adc_p[0]}]
#Sch name = XA2_P
set_property PACKAGE_PIN L3 [get_ports {adc_p[1]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {adc_p[1]}]
#Sch name = XA3_P
set_property PACKAGE_PIN M2 [get_ports {adc_p[2]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {adc_p[2]}]
#Sch name = XA4_P
set_property PACKAGE_PIN N2 [get_ports {adc_p[3]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {adc_p[3]}]
#Sch name = XA1_N
set_property PACKAGE_PIN K3 [get_ports {adc_n[0]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {adc_n[0]}]
#Sch name = XA2_N
set_property PACKAGE_PIN M3 [get_ports {adc_n[1]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {adc_n[1]}]
#Sch name = XA3_N
set_property PACKAGE_PIN M1 [get_ports {adc_n[2]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {adc_n[2]}]
#Sch name = XA4_N
set_property PACKAGE_PIN N1 [get_ports {adc_n[3]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {adc_n[3]}]


#PWM Output Channels
##Pmod Header JA
##Sch name = JA1
set_property PACKAGE_PIN J1 [get_ports {pwm_out[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pwm_out[0]}]
##Sch name = JA2
set_property PACKAGE_PIN L2 [get_ports {pwm_out[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pwm_out[1]}]
##Sch name = JA3
set_property PACKAGE_PIN J2 [get_ports {pwm_out[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pwm_out[2]}]
##Sch name = JA4
set_property PACKAGE_PIN G2 [get_ports {pwm_out[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pwm_out[3]}]
##Sch name = JA7
set_property PACKAGE_PIN H1 [get_ports {pwm_out[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pwm_out[4]}]
##Sch name = JA8
set_property PACKAGE_PIN K2 [get_ports {pwm_out[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pwm_out[5]}]
	
##SPI Connection Ports
##Sch name = JB1
set_property PACKAGE_PIN A14 [get_ports spi_clk]					
	set_property IOSTANDARD LVCMOS33 [get_ports spi_clk]
##Sch name = JB2
set_property PACKAGE_PIN A16 [get_ports spi_mosi]					
	set_property IOSTANDARD LVCMOS33 [get_ports spi_mosi]
##Sch name = JB3
set_property PACKAGE_PIN B15 [get_ports spi_miso]					
	set_property IOSTANDARD LVCMOS33 [get_ports spi_miso]
##Sch name = JB4
set_property PACKAGE_PIN B16 [get_ports {spi_cs[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {spi_cs[0]}]	
##Sch name = JB7
set_property PACKAGE_PIN A15 [get_ports {spi_cs[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {spi_cs[1]}]
