# 50 MHz clock
set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33} [get_ports clk]

set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports {led[1]}]

set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {btn[0]}]
set_property -dict {PACKAGE_PIN AA1 IOSTANDARD LVCMOS33} [get_ports {btn[1]}]
set_property -dict {PACKAGE_PIN W1 IOSTANDARD LVCMOS33} [get_ports {btn[2]}]

set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports tx]
set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports rx]

