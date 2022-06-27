INCLUDE+=$(incdir)$(DDR3_DIR)/tb/ddr3_core_xc7

VHDR+=$(DDR3_DIR)/tb/ddr3_core_xc7/2048Mb_ddr3_parameters.vh

VSRC+=$(DDR3_DIR)/tb/axi_ram/axi_ram.v
VSRC+=$(DDR3_DIR)/src_v/ddr3_axi.v
VSRC+=$(DDR3_DIR)/src_v/phy/c5gt/ddr3_dfi_phy.v
VSRC+=$(DDR3_DIR)/src_v/ddr3_axi_retime.v
VSRC+=$(DDR3_DIR)/src_v/ddr3_axi_pmem.v
VSRC+=$(DDR3_DIR)/src_v/ddr3_core.v
VSRC+=$(DDR3_DIR)/src_v/ddr3_dfi_seq.v
#VSRC+=$(DDR3_DIR)/src_v/ddr3_axi_retime.v
VSRC+=$(DDR3_DIR)/tb/ddr3_core_xc7/ddr3.v

