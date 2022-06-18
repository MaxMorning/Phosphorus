
## Clock signal
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]

##BTC

set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports reset]

# GPU
set_property IOSTANDARD LVCMOS33 [get_ports {oBlue[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {oBlue[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {oBlue[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {oBlue[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {oGreen[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {oGreen[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {oGreen[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {oGreen[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports oHs]
set_property IOSTANDARD LVCMOS33 [get_ports {oRed[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {oRed[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {oRed[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {oRed[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports oVs]

set_property PACKAGE_PIN D8 [get_ports {oBlue[3]}]
set_property PACKAGE_PIN D7 [get_ports {oBlue[2]}]
set_property PACKAGE_PIN C7 [get_ports {oBlue[1]}]
set_property PACKAGE_PIN B7 [get_ports {oBlue[0]}]
set_property PACKAGE_PIN A6 [get_ports {oGreen[3]}]
set_property PACKAGE_PIN B6 [get_ports {oGreen[2]}]
set_property PACKAGE_PIN A5 [get_ports {oGreen[1]}]
set_property PACKAGE_PIN C6 [get_ports {oGreen[0]}]
set_property PACKAGE_PIN A4 [get_ports {oRed[3]}]
set_property PACKAGE_PIN C5 [get_ports {oRed[2]}]
set_property PACKAGE_PIN B4 [get_ports {oRed[1]}]
set_property PACKAGE_PIN A3 [get_ports {oRed[0]}]

set_property PACKAGE_PIN B11 [get_ports oHs]
set_property PACKAGE_PIN B12 [get_ports oVs]

##Quad SPI Flash

set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports sdo]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports sdi]
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports wp_n]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports hld_n]
set_property -dict {PACKAGE_PIN L13 IOSTANDARD LVCMOS33} [get_ports cs_n]