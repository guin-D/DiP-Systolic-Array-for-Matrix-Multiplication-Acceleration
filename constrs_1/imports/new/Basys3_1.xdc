## Clock signal
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports done]
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports start]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports rst_n]
