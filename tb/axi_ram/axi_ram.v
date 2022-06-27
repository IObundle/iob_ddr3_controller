`timescale 1ns / 1ps

module axi_ram
  #(
    parameter DDR_CLK_PER = 20
    )
   (
    // Inputs
    input clk
    ,input rst
	  
    ,input s_axi_awvalid
    ,input [31:0] s_axi_awaddr
    ,input [2:0] s_axi_awsize
    ,input s_axi_awlock
    ,input [2:0] s_axi_awprot
    ,input [3:0] s_axi_awcache
    ,input [3:0] s_axi_awid
    ,input [7:0] s_axi_awlen
    ,input [1:0] s_axi_awburst
    ,input s_axi_wvalid
    ,input [31:0] s_axi_wdata
    ,input [3:0] s_axi_wstrb
    ,input s_axi_wlast
    ,input s_axi_bready
    ,input s_axi_arvalid
    ,input [31:0] s_axi_araddr
    ,input [2:0] s_axi_arsize
    ,input s_axi_arlock
    ,input [3:0] s_axi_arcache
    ,input [2:0] s_axi_arprot
    ,input [3:0] s_axi_arid
    ,input [7:0] s_axi_arlen
    ,input [1:0] s_axi_arburst
    ,input s_axi_rready
    
    // Outputs
    ,output s_axi_awready
    ,output s_axi_wready
    ,output s_axi_bvalid
    ,output [1:0] s_axi_bresp
    ,output [3:0] s_axi_bid
    ,output s_axi_arready
    ,output s_axi_rvalid
    ,output [31:0] s_axi_rdata
    ,output [1:0] s_axi_rresp
    ,output [3:0] s_axi_rid
    ,output s_axi_rlast
    );

   //-----------------------------------------------------------------
   // DDR Controller
   //-----------------------------------------------------------------
   wire [ 14:0]  dfi_address_w;
   wire [  2:0]  dfi_bank_w;
   wire 	 dfi_cas_n_w;
   wire 	 dfi_cke_w;
   wire 	 dfi_cs_n_w;
   wire 	 dfi_odt_w;
   wire 	 dfi_ras_n_w;
   wire 	 dfi_reset_n_w;
   wire 	 dfi_we_n_w;
   wire [ 31:0]  dfi_wrdata_w;
   wire 	 dfi_wrdata_en_w;
   wire [  3:0]  dfi_wrdata_mask_w;
   wire 	 dfi_rddata_en_w;
   wire [ 31:0]  dfi_rddata_w;
   wire 	 dfi_rddata_valid_w;
   wire [  1:0]  dfi_rddata_dnv_w;

  

   localparam READ_LAT=3;
   
   ddr3_axi
     #(
       .DDR_WRITE_LATENCY(4)
       ,.DDR_READ_LATENCY(READ_LAT)
       ,.DDR_MHZ(50)
       )
   u_ddr
     (
      // Inputs
      .clk_i(clk)
      ,.rst_i(rst)

      ,.inport_awvalid_i(s_axi_awvalid)
      ,.inport_awaddr_i(s_axi_awaddr)
      ,.inport_awid_i(s_axi_awid)
      ,.inport_awlen_i(s_axi_awlen)
      ,.inport_awburst_i(s_axi_awburst)
      ,.inport_wvalid_i(s_axi_wvalid)
      ,.inport_wdata_i(s_axi_wdata)
      ,.inport_wstrb_i(s_axi_wstrb)
      ,.inport_wlast_i(s_axi_wlast)
      ,.inport_bready_i(s_axi_bready)
      ,.inport_arvalid_i(s_axi_arvalid)
      ,.inport_araddr_i(s_axi_araddr)
      ,.inport_arid_i(s_axi_arid)
      ,.inport_arlen_i(s_axi_arlen)
      ,.inport_arburst_i(s_axi_arburst)
      ,.inport_rready_i(s_axi_rready)
      ,.dfi_rddata_i(dfi_rddata_w)
      ,.dfi_rddata_valid_i(dfi_rddata_valid_w)
      ,.dfi_rddata_dnv_i(dfi_rddata_dnv_w)

      // Outputs
      ,.inport_awready_o(s_axi_awready)
      ,.inport_wready_o(s_axi_wready)
      ,.inport_bvalid_o(s_axi_bvalid)
      ,.inport_bresp_o(s_axi_bresp)
      ,.inport_bid_o(s_axi_bid)
      ,.inport_arready_o(s_axi_arready)
      ,.inport_rvalid_o(s_axi_rvalid)
      ,.inport_rdata_o(s_axi_rdata)
      ,.inport_rresp_o(s_axi_rresp)
      ,.inport_rid_o(s_axi_rid)
      ,.inport_rlast_o(s_axi_rlast)
      ,.dfi_address_o(dfi_address_w)
      ,.dfi_bank_o(dfi_bank_w)
      ,.dfi_cas_n_o(dfi_cas_n_w)
      ,.dfi_cke_o(dfi_cke_w)
      ,.dfi_cs_n_o(dfi_cs_n_w)
      ,.dfi_odt_o(dfi_odt_w)
      ,.dfi_ras_n_o(dfi_ras_n_w)
      ,.dfi_reset_n_o(dfi_reset_n_w)
      ,.dfi_we_n_o(dfi_we_n_w)
      ,.dfi_wrdata_o(dfi_wrdata_w)
      ,.dfi_wrdata_en_o(dfi_wrdata_en_w)
      ,.dfi_wrdata_mask_o(dfi_wrdata_mask_w)
      ,.dfi_rddata_en_o(dfi_rddata_en_w)
      );

   //-----------------------------------------------------------------
   // PHY
   //-----------------------------------------------------------------

   wire 	 clk_ddr_w = clk;
   wire 	 clk_ddr90_w;
   assign  #(DDR_CLK_PER/4) clk_ddr90_w = clk;

   wire [13:0] ddr3b_a; //SSTL15  //Address
   wire [2:0]  ddr3b_ba; //SSTL15  //Bank Address
   wire        ddr3b_rasn; //SSTL15  //Row Address Strobe
   wire        ddr3b_casn; //SSTL15  //Column Address Strobe
   wire        ddr3b_wen; //SSTL15  //Write Enable
   wire [1:0]  ddr3b_dm; //SSTL15  //Data Write Mask
   wire [15:0] ddr3b_dq; //SSTL15  //Data Bus
   wire        ddr3b_clk_n; //SSTL15  //Diff Clock - Neg
   wire        ddr3b_clk_p; //SSTL15  //Diff Clock - Pos
   wire        ddr3b_cke; //SSTL15  //Clock Enable
   wire        ddr3b_csn; //SSTL15  //Chip Select
   wire [1:0]  ddr3b_dqs_n; //SSTL15  //Diff Data Strobe - Neg
   wire [1:0]  ddr3b_dqs_p; //SSTL15  //Diff Data Strobe - Pos
   wire        ddr3b_odt; //SSTL15  //On-Die Termination Enable
   wire        ddr3b_resetn; //SSTL15  //Reset

   
   ddr3_dfi_phy
     u_phy
       (
	.clk_i(clk_ddr_w)
	,.clk90_i(clk_ddr90_w)
	,.rst_i(rst)


	,.dfi_address_i(dfi_address_w)
	,.dfi_bank_i(dfi_bank_w)
	,.dfi_cas_n_i(dfi_cas_n_w)
	,.dfi_cke_i(dfi_cke_w)
	,.dfi_cs_n_i(dfi_cs_n_w)
	,.dfi_odt_i(dfi_odt_w)
	,.dfi_ras_n_i(dfi_ras_n_w)
	,.dfi_reset_n_i(dfi_reset_n_w)
	,.dfi_we_n_i(dfi_we_n_w)
	,.dfi_wrdata_i(dfi_wrdata_w)
	,.dfi_wrdata_en_i(dfi_wrdata_en_w)
	,.dfi_wrdata_mask_i(dfi_wrdata_mask_w)
	,.dfi_rddata_en_i(dfi_rddata_en_w)

	,.dfi_rddata_o(dfi_rddata_w)
	,.dfi_rddata_valid_o(dfi_rddata_valid_w)
	,.dfi_rddata_dnv_o(dfi_rddata_dnv_w)

	,.ddr3_addr_o(ddr3b_a)
	,.ddr3_ba_o(ddr3b_ba)
	,.ddr3_ras_n_o(ddr3b_rasn)
	,.ddr3_cas_n_o(ddr3b_casn)
	,.ddr3_we_n_o(ddr3b_wen)
	,.ddr3_dm_o(ddr3b_dm)
	,.ddr3_dq_io(ddr3b_dq)
	,.ddr3_ck_p_o(ddr3b_clk_p)
	,.ddr3_ck_n_o(ddr3b_clk_n)
	,.ddr3_cke_o(ddr3b_cke)
	,.ddr3_reset_n_o(ddr3b_resetn)
	,.ddr3_cs_n_o(ddr3b_csn)
	,.ddr3_odt_o(ddr3b_odt)
	,.ddr3_dqs_p_io(ddr3b_dqs_p)
	,.ddr3_dqs_n_io(ddr3b_dqs_n)
	);

   //-----------------------------------------------------------------
   // DDR model
   //-----------------------------------------------------------------

   ddr3
     u_ram
       (
	.rst_n(ddr3b_resetn)
	,.ck(ddr3b_clk_p)
	,.ck_n(ddr3b_clk_n)
	,.cke(ddr3b_cke)
	,.cs_n(ddr3b_csn)
	,.ras_n(ddr3b_rasn)
	,.cas_n(ddr3b_casn)
	,.we_n(ddr3b_wen)
	,.dm_tdqs(ddr3b_dm)
	,.ba(ddr3b_ba)
	,.addr(ddr3b_a)
	,.dq(ddr3b_dq)
	,.dqs(ddr3b_dqs_p)
	,.dqs_n(ddr3b_dqs_n)
	,.tdqs_n()
	,.odt(ddr3b_odt)
	);

endmodule
