set_property PACKAGE_PIN V18 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property -dict { PACKAGE_PIN F15   IOSTANDARD LVCMOS33 } [get_ports {rxd}]
set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33 } [get_ports {txd}]

set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN C13   IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN B13   IOSTANDARD LVCMOS33 } [get_ports {led[3]}]
set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33 } [get_ports {led[4]}]
set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33 } [get_ports {led[5]}]
set_property -dict { PACKAGE_PIN A13   IOSTANDARD LVCMOS33 } [get_ports {led[6]}]
set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33 } [get_ports {led[7]}]

set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]
set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33 } [get_ports {sw[3]}]
set_property -dict { PACKAGE_PIN C18   IOSTANDARD LVCMOS33 } [get_ports {sw[4]}]
set_property -dict { PACKAGE_PIN C19   IOSTANDARD LVCMOS33 } [get_ports {sw[5]}]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports {sw[6]}]
set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports {sw[7]}]

set_property PACKAGE_PIN F20 [get_ports btn]
set_property IOSTANDARD LVCMOS33 [get_ports btn]
 
set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports {d[0]}]
set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports {d[1]}]
set_property -dict { PACKAGE_PIN B20   IOSTANDARD LVCMOS33 } [get_ports {d[2]}]
set_property -dict { PACKAGE_PIN A20   IOSTANDARD LVCMOS33 } [get_ports {d[3]}]


set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports {an[0]}]
set_property -dict { PACKAGE_PIN A19   IOSTANDARD LVCMOS33 } [get_ports {an[1]}]
set_property -dict { PACKAGE_PIN F19   IOSTANDARD LVCMOS33 } [get_ports {an[2]}]

