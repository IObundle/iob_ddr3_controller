`timescale 1ns / 1ps


module ddr3_dfi_phy
  //-----------------------------------------------------------------
  // Params
  //-----------------------------------------------------------------
  #(
    parameter DQ_IN_DELAY_INIT = 64
    ,parameter TPHY_RDLAT       = 4
    ,parameter TPHY_WRLAT       = 3
    ,parameter TPHY_WRDATA      = 0
    )
   //-----------------------------------------------------------------
   // Ports
   //-----------------------------------------------------------------
   (
    // Inputs
    input clk_i
    ,input clk90_i
    ,input rst_i
      
      
    ,input [14:0] dfi_address_i
    ,input [2:0] dfi_bank_i
    ,input dfi_cas_n_i
    ,input dfi_cke_i
    ,input dfi_cs_n_i
    ,input dfi_odt_i
    ,input dfi_ras_n_i
    ,input dfi_reset_n_i
    ,input dfi_we_n_i
    ,input [31:0] dfi_wrdata_i
    ,input dfi_wrdata_en_i
    ,input [3:0] dfi_wrdata_mask_i
    ,input dfi_rddata_en_i
      
    // Outputs
    ,output [31:0] dfi_rddata_o
    ,output dfi_rddata_valid_o
    ,output [1:0] dfi_rddata_dnv_o
      
    ,output [13:0] ddr3_addr_o
    ,output [2:0] ddr3_ba_o
    ,output ddr3_ras_n_o
    ,output ddr3_cas_n_o
    ,output ddr3_we_n_o
    ,output [1:0] ddr3_dm_o
    ,output ddr3_ck_n_o
    ,output ddr3_ck_p_o
    ,output ddr3_cke_o
    ,output ddr3_reset_n_o
    ,output ddr3_cs_n_o
    ,output ddr3_odt_o
    ,inout [1:0] ddr3_dqs_p_io
    ,inout [1:0] ddr3_dqs_n_io
    ,inout [15:0] ddr3_dq_io
    );


   //-----------------------------------------------------------------
   // DDR Clock
   //-----------------------------------------------------------------

   //clock 
   altddio_out
     #(
       .WIDTH(1)
       )
   u_pad_ck_p
     (
      .outclock(clk_i)
      ,.datain_l(1'b0)
      ,.datain_h(1'b1)
      ,.dataout(ddr3_ck_p_o)
      );

   altddio_out
     #(
       .WIDTH(1)
       )
   u_pad_ck_n
     (
      .outclock(clk_i)
      ,.datain_l(1'b1)
      ,.datain_h(1'b0)
      ,.dataout(ddr3_ck_n_o)
      );


   //clock enable
   reg cke_q;
   always @ (posedge clk_i, posedge rst_i )
     if (rst_i)
       cke_q <= 1'b0;
     else
       cke_q <= dfi_cke_i;
   assign #(0.4) ddr3_cke_o       = cke_q;

   //reset 
   reg reset_n_q;
   always @ (posedge clk_i, posedge rst_i )
     if (rst_i)
       reset_n_q <= 1'b0;
     else
       reset_n_q <= dfi_reset_n_i;
   assign ddr3_reset_n_o   = reset_n_q;

   //ras
   reg 	  ras_n_q;
   always @ (posedge clk_i, posedge rst_i )
     if (rst_i)
       ras_n_q <= 1'b0;
     else
       ras_n_q <= dfi_ras_n_i;
   assign  #(0.4) ddr3_ras_n_o     = ras_n_q;

   //cas
   reg 	  cas_n_q;
   always @ (posedge clk_i, posedge rst_i )
     if (rst_i)
       cas_n_q <= 1'b0;
     else
       cas_n_q <= dfi_cas_n_i;
   assign #(0.4) ddr3_cas_n_o     = cas_n_q;

   //write enable
   reg 	  we_n_q;
   always @ (posedge clk_i, posedge rst_i )
     if (rst_i)
       we_n_q <= 1'b0;
     else
       we_n_q <= dfi_we_n_i;
   assign #(0.4) ddr3_we_n_o      = we_n_q;

   //chip select
   reg 	  cs_n_q;
   always @ (posedge clk_i, posedge rst_i )
     if (rst_i)
       cs_n_q <= 1'b0;
     else
       cs_n_q <= dfi_cs_n_i;
   assign ddr3_cs_n_o      = cs_n_q;

   //block address 
   reg [2:0] ba_q;
   always @ (posedge clk_i, posedge rst_i )
     if (rst_i)
       ba_q <= 3'b0;
     else
       ba_q <= dfi_bank_i;
   assign #(0.4) ddr3_ba_o        = ba_q;

   //address
   reg [13:0] addr_q;
   always @ (posedge clk_i, posedge rst_i )
     if (rst_i)
       addr_q <= 14'b0;
     else
       addr_q <= dfi_address_i[13:0];
   assign #(0.4) ddr3_addr_o      = addr_q;

   //on-die termination
   reg        odt_q;
   always @ (posedge clk_i, posedge rst_i )
     if (rst_i)
       odt_q <= 1'b0;
     else
       odt_q <= dfi_odt_i;
   assign ddr3_odt_o       = odt_q;

//-----------------------------------------------------------------
// Write Output Enable
//-----------------------------------------------------------------
reg wr_valid_q0;
always @ (posedge clk_i )
if (rst_i)
    wr_valid_q0 <= 1'b0;
else
    wr_valid_q0 <= dfi_wrdata_en_i;

reg wr_valid_q1;
always @ (posedge clk_i )
if (rst_i)
    wr_valid_q1 <= 1'b0;
else
    wr_valid_q1 <= wr_valid_q0;

reg wr_valid_q2;
always @ (posedge clk_i )
if (rst_i)
    wr_valid_q2 <= 1'b0;
else
    wr_valid_q2 <= wr_valid_q1;    

reg dqs_out_en_n_q;
always @ (posedge clk_i )
if (rst_i)
    dqs_out_en_n_q <= 1'b1;
else if (wr_valid_q1 && !wr_valid_q2)
    dqs_out_en_n_q <= 1'b0;
else
    dqs_out_en_n_q <= 1'b1;


   //-----------------------------------------------------------------
   // Data Strobe (DQS) IO Buffers
   //-----------------------------------------------------------------

   wire [1:0] dqs_in_w;

   alt_iobuf
     u_pad_dqs0_p
       (
	.i(clk90_i)
	,.o(dqs_in_w[0])
	,.oe(~dqs_out_en_n_q)
	,.io(ddr3_dqs_p_io[0])
	);

   alt_iobuf
     u_pad_dqs0_n
       (
	.i(~clk90_i)
	,.o(dqs_in_w[0])
	,.oe(~dqs_out_en_n_q)
	,.io(ddr3_dqs_n_io[0])
	);

   alt_iobuf
     u_pad_dqs1_p
       (
	.i(clk90_i)
	,.o(dqs_in_w[1])
	,.oe(~dqs_out_en_n_q)
	,.io(ddr3_dqs_p_io[1])
	);

   alt_iobuf
     u_pad_dqs1_n
       (
	.i(~clk90_i)
	,.o(dqs_in_w[1])
	,.oe(~dqs_out_en_n_q)
	,.io(ddr3_dqs_n_io[1])
	);

   //-----------------------------------------------------------------
   // Write Data (DQ) DDR Buffers
   //-----------------------------------------------------------------
   reg [31:0] dfi_wrdata_q;

   always @ (posedge clk_i, posedge rst_i )
     if (rst_i)
       dfi_wrdata_q <= 32'b0;
     else
       dfi_wrdata_q <= dfi_wrdata_i;

   wire [15:0] dq_out_w, dq_in_w;
   

   altddio_out
     #(
       .WIDTH(16)
       )
   u_dq0_out
     (
      .outclock(clk_i)
      ,.datain_l(dfi_wrdata_q[15:0])
      ,.datain_h(dfi_wrdata_q[31:16])
      ,.dataout(dq_out_w)
      );


   //-----------------------------------------------------------------
   // Data (DQ) IO Buffers
   //-----------------------------------------------------------------

   genvar     i;
   generate 
      for (i=0; i<16; i=i+1) begin : data_out_buf
	 alt_iobuf u_pad_dq0
	     (
	      .i(dq_out_w[i]),
	      .o(dq_in_w[i]),
	      .oe(~dqs_out_en_n_q),
	      .io(ddr3_dq_io[i])
	      );
      end
   endgenerate

   //-----------------------------------------------------------------
   // Data Write Mask (DM)
   //-----------------------------------------------------------------
   wire [1:0]  dm_out_w;
   reg [3:0]   dfi_wr_mask_q;

   always @ (posedge clk_i, posedge rst_i )
     if (rst_i)
       dfi_wr_mask_q <= 4'b0;
     else
       dfi_wr_mask_q <= dfi_wrdata_mask_i;


   altddio_out
     #(
       .WIDTH(1)
       )
   u_dm0_out
     (
      .outclock(clk_i)
      ,.datain_l(dfi_wr_mask_q[0])
      ,.datain_h(dfi_wr_mask_q[2])
      ,.dataout(dm_out_w[0])
      );


   altddio_out
     #(
       .WIDTH(1)
       )
   u_dm1_out
     (
      .outclock(clk_i)
      ,.datain_l(dfi_wr_mask_q[1])
      ,.datain_h(dfi_wr_mask_q[3])
      ,.dataout(dm_out_w[1])
      );


   assign ddr3_dm_o   = dm_out_w;

   //-----------------------------------------------------------------
   // Read capture
   //-----------------------------------------------------------------
   wire [31:0] rd_data_w;

   altddio_in
     #(
       .WIDTH(16)
       )
   u_dq_in0
     (
      .inclock(clk_i)
      ,.datain(dq_in_w)
      ,.dataout_l(rd_data_w[15:0])
      ,.dataout_h(rd_data_w[31:16])
      );


   assign dfi_rddata_o       = rd_data_w;
   assign dfi_rddata_dnv_o   = 2'b0;

   //-----------------------------------------------------------------
   // Read Valid
   //-----------------------------------------------------------------
   reg rd_en_q;

   always @ (posedge clk_i, posedge rst_i ) begin
     if (rst_i)
       rd_en_q <= 1'b0;
     else
       rd_en_q <= dfi_rddata_en_i;
  end

     assign dfi_rddata_valid_o = rd_en_q;

endmodule
