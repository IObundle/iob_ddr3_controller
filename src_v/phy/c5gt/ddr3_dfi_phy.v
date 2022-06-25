//-----------------------------------------------------------------
//              Lightweight DDR3 Memory Controller
//                            V0.5
//                     Ultra-Embedded.com
//                     Copyright 2020-21
//
//                   admin@ultra-embedded.com
//
//                     License: Apache 2.0
//-----------------------------------------------------------------
// Copyright 2020-21 Ultra-Embedded.com
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//-----------------------------------------------------------------

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
     input           clk_i
    ,input           clk_ddr_i   // 90 degree phase shifted version of clk_i
    ,input           rst_i
    ,input           cfg_valid_i
    ,input  [ 31:0]  cfg_i
    ,input  [ 14:0]  dfi_address_i
    ,input  [  2:0]  dfi_bank_i
    ,input           dfi_cas_n_i
    ,input           dfi_cke_i
    ,input           dfi_cs_n_i
    ,input           dfi_odt_i
    ,input           dfi_ras_n_i
    ,input           dfi_reset_n_i
    ,input           dfi_we_n_i
    ,input  [ 31:0]  dfi_wrdata_i
    ,input           dfi_wrdata_en_i
    ,input  [  3:0]  dfi_wrdata_mask_i
    ,input           dfi_rddata_en_i

    // Outputs
    ,output [ 31:0]  dfi_rddata_o
    ,output          dfi_rddata_valid_o
    ,output [  1:0]  dfi_rddata_dnv_o
    ,output          ddr3_ck_p_o
    ,output          ddr3_cke_o
    ,output          ddr3_reset_n_o
    ,output          ddr3_ras_n_o
    ,output          ddr3_cas_n_o
    ,output          ddr3_we_n_o
    ,output          ddr3_cs_n_o
    ,output [  2:0]  ddr3_ba_o
    ,output [ 14:0]  ddr3_addr_o
    ,output          ddr3_odt_o
    ,output [  1:0]  ddr3_dm_o
    ,inout [  1:0]  ddr3_dqs_p_io
    ,inout [ 15:0]  ddr3_dq_io
);



//-----------------------------------------------------------------
// Configuration
//-----------------------------------------------------------------
`define DDR_PHY_CFG_RDLAT_R         11:8

reg [3:0] rd_lat_q;

always @ (posedge clk_i )
if (rst_i)
    rd_lat_q <= TPHY_RDLAT;
else if (cfg_valid_i)
    rd_lat_q <= cfg_i[`DDR_PHY_CFG_RDLAT_R];

//-----------------------------------------------------------------
// DDR Clock
//-----------------------------------------------------------------
// ddr3_ck_p_o = ~clk_i

altddio_out
  #(
    .WIDTH(1)
    )
u_pad_ck
(
     .outclock(clk_i)
    ,.datain_l(0)
    ,.datain_h(1)
    ,.dataout(ddr3_ck_p_o)
);


reg        cke_q;
always @ (posedge clk_i )
if (rst_i)
    cke_q <= 1'b0;
else
    cke_q <= dfi_cke_i;
assign ddr3_cke_o       = cke_q;

reg        reset_n_q;
always @ (posedge clk_i )
if (rst_i)
    reset_n_q <= 1'b0;
else
    reset_n_q <= dfi_reset_n_i;
assign ddr3_reset_n_o   = reset_n_q;

reg        ras_n_q;
always @ (posedge clk_i )
if (rst_i)
    ras_n_q <= 1'b0;
else
    ras_n_q <= dfi_ras_n_i;
assign ddr3_ras_n_o     = ras_n_q;

reg        cas_n_q;
always @ (posedge clk_i )
if (rst_i)
    cas_n_q <= 1'b0;
else
    cas_n_q <= dfi_cas_n_i;
assign ddr3_cas_n_o     = cas_n_q;

reg        we_n_q;
always @ (posedge clk_i )
if (rst_i)
    we_n_q <= 1'b0;
else
    we_n_q <= dfi_we_n_i;
assign ddr3_we_n_o      = we_n_q;

reg        cs_n_q;
always @ (posedge clk_i )
if (rst_i)
    cs_n_q <= 1'b0;
else
    cs_n_q <= dfi_cs_n_i;
assign ddr3_cs_n_o      = cs_n_q;

reg [2:0]  ba_q;
always @ (posedge clk_i )
if (rst_i)
    ba_q <= 3'b0;
else
    ba_q <= dfi_bank_i;
assign ddr3_ba_o        = ba_q;

reg [14:0] addr_q;
always @ (posedge clk_i )
if (rst_i)
    addr_q <= 15'b0;
else
    addr_q <= dfi_address_i;
assign ddr3_addr_o      = addr_q;

reg        odt_q;
always @ (posedge clk_i )
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
else if (wr_valid_q1)
    dqs_out_en_n_q <= 1'b0;
else if (!wr_valid_q2)
    dqs_out_en_n_q <= 1'b1;

//-----------------------------------------------------------------
// DQS I/O Buffers
//-----------------------------------------------------------------
wire [1:0] dqs_out_en_n_w = {dqs_out_en_n_q, dqs_out_en_n_q};
wire [1:0] dqs_out_w;
wire [1:0] dqs_in_w;

//alt_iobuf my_iobuf 
   // (.i(internal_sig1), 
   // .oe(enable_sig),
   // .o(internal_sig2), 
   // .io(bidir)); //bidir must be declared as an inout pin



alt_iobuf
u_pad_dqs0
(
     .i(dqs_out_w[0])
    ,.o(dqs_in_w[0])
    ,.oe(~dqs_out_en_n_w[0])
    ,.io(ddr3_dqs_p_io[0])
);

alt_iobuf
u_pad_dqs1
(
     .i(dqs_out_w[1])
    ,.o(dqs_in_w[1])
    ,.oe(~dqs_out_en_n_w[1])
    ,.io(ddr3_dqs_p_io[1])
);

//-----------------------------------------------------------------
// Write Data Strobe (DQS)
//-----------------------------------------------------------------

// 90 degrees delayed version of clk_i
assign dqs_out_w[0] = clk_ddr_i;
assign dqs_out_w[1] = clk_ddr_i;

//-----------------------------------------------------------------
// Write Data (DQ)
//-----------------------------------------------------------------
reg [31:0] dfi_wrdata_q;

always @ (posedge clk_i )
if (rst_i)
    dfi_wrdata_q <= 32'b0;
else
    dfi_wrdata_q <= dfi_wrdata_i;

wire [15:0] dq_in_w;
wire [15:0] dq_out_w;
wire [15:0] dq_out_en_n_w;


altddio_out
  #(
    .WIDTH(1)
    )
u_dq0_out
(
     .outclock(clk_i)
    ,.datain_l(dfi_wrdata_q[0+0])
    ,.datain_h(dfi_wrdata_q[0+16])
    ,.dataout(dq_out_w[0])
);

assign dq_out_en_n_w[0] = dqs_out_en_n_q;

alt_iobuf
u_pad_dq0
(
     .i(dq_out_w[0])
    ,.o(dq_in_w[0])
    ,.oe(~dq_out_en_n_w[0])
    ,.io(ddr3_dq_io[0])
);


altddio_out
  #(
    .WIDTH(1)
    )
u_dq1_ououtclock     
(
     .outclock(clk_i)
    ,.datain_l(dfi_wrdata_q[1+0])
    ,.datain_h(dfi_wrdata_q[1+16])
    ,.dataout(dq_out_w[1])
);

assign dq_out_en_n_w[1] = dqs_out_en_n_q;

alt_iobuf
u_pad_dq1
(
     .i(dq_out_w[1])
    ,.o(dq_in_w[1])
    ,.oe(~dq_out_en_n_w[1])
    ,.io(ddr3_dq_io[1])
);


altddio_out
  #(
    .WIDTH(1)
    )
u_dq2_out
(
     .outclock(clk_i)
    ,.datain_l(dfi_wrdata_q[2+0])
    ,.datain_h(dfi_wrdata_q[2+16])
    ,.dataout(dq_out_w[2])
);

assign dq_out_en_n_w[2] = dqs_out_en_n_q;

alt_iobuf
u_pad_dq2
(
     .i(dq_out_w[2])
    ,.o(dq_in_w[2])
    ,.oe(~dq_out_en_n_w[2])
    ,.io(ddr3_dq_io[2])
);


altddio_out
  #(
    .WIDTH(1)
    )
u_dq3_out
(
     .outclock(clk_i)
    ,.datain_l(dfi_wrdata_q[3+0])
    ,.datain_h(dfi_wrdata_q[3+16])
    ,.dataout(dq_out_w[3])
);

assign dq_out_en_n_w[3] = dqs_out_en_n_q;

alt_iobuf
u_pad_dq3
(
     .i(dq_out_w[3])
    ,.o(dq_in_w[3])
    ,.oe(~dq_out_en_n_w[3])
    ,.io(ddr3_dq_io[3])
);


altddio_out
  #(
    .WIDTH(1)
    )
u_dq4_out
(
     .outclock(clk_i)
    ,.datain_l(dfi_wrdata_q[4+0])
    ,.datain_h(dfi_wrdata_q[4+16])
    ,.dataout(dq_out_w[4])
);

assign dq_out_en_n_w[4] = dqs_out_en_n_q;

alt_iobuf
u_pad_dq4
(
     .i(dq_out_w[4])
    ,.o(dq_in_w[4])
    ,.oe(~dq_out_en_n_w[4])
    ,.io(ddr3_dq_io[4])
);


altddio_out
  #(
    .WIDTH(1)
    )
u_dq5_out
  (
   .outclock(clk_i)
    ,.datain_l(dfi_wrdata_q[5+0])
    ,.datain_h(dfi_wrdata_q[5+16])
    ,.dataout(dq_out_w[5])
);

assign dq_out_en_n_w[5] = dqs_out_en_n_q;

alt_iobuf
u_pad_dq5
(
     .i(dq_out_w[5])
    ,.o(dq_in_w[5])
    ,.oe(~dq_out_en_n_w[5])
    ,.io(ddr3_dq_io[5])
);


altddio_out
  #(
    .WIDTH(1)
    )
u_dq6_out
(
    .outclock(clk_i)
    ,.datain_l(dfi_wrdata_q[6+0])
    ,.datain_h(dfi_wrdata_q[6+16])
    ,.dataout(dq_out_w[6])
);

assign dq_out_en_n_w[6] = dqs_out_en_n_q;

alt_iobuf
u_pad_dq6
(
     .i(dq_out_w[6])
    ,.o(dq_in_w[6])
    ,.oe(~dq_out_en_n_w[6])
    ,.io(ddr3_dq_io[6])
);


altddio_out
  #(
    .WIDTH(1)
    )
u_dq7_out
(
     .outclock(clk_i)
    ,.datain_l(dfi_wrdata_q[7+0])
    ,.datain_h(dfi_wrdata_q[7+16])
    ,.dataout(dq_out_w[7])
);

assign dq_out_en_n_w[7] = dqs_out_en_n_q;

alt_iobuf
u_pad_dq7
(
     .i(dq_out_w[7])
    ,.o(dq_in_w[7])
    ,.oe(~dq_out_en_n_w[7])
    ,.io(ddr3_dq_io[7])
);

   
altddio_out
  #(
    .WIDTH(1)
    )
u_dq8_out
(
    .outclock(clk_i)
    ,.datain_l(dfi_wrdata_q[8+0])
    ,.datain_h(dfi_wrdata_q[8+16])
    ,.dataout(dq_out_w[8])
);

assign dq_out_en_n_w[8] = dqs_out_en_n_q;

alt_iobuf
u_pad_dq8
(
     .i(dq_out_w[8])
    ,.o(dq_in_w[8])
    ,.oe(~dq_out_en_n_w[8])
    ,.io(ddr3_dq_io[8])
);


altddio_out
  #(
    .WIDTH(1)
    )
u_dq9_out
(
     .outclock(clk_i)
    ,.datain_l(dfi_wrdata_q[9+0])
    ,.datain_h(dfi_wrdata_q[9+16])
    ,.dataout(dq_out_w[9])
);

assign dq_out_en_n_w[9] = dqs_out_en_n_q;

alt_iobuf
u_pad_dq9
(
     .i(dq_out_w[9])
    ,.o(dq_in_w[9])
    ,.oe(~dq_out_en_n_w[9])
    ,.io(ddr3_dq_io[9])
);


altddio_out
  #(
    .WIDTH(1)
    )
u_dq10_out 
(
     .outclock(clk_i)
    ,.datain_l(dfi_wrdata_q[10+0])
    ,.datain_h(dfi_wrdata_q[10+16])
    ,.dataout(dq_out_w[10])
);

assign dq_out_en_n_w[10] = dqs_out_en_n_q;

alt_iobuf
u_pad_dq10
(
     .i(dq_out_w[10])
    ,.o(dq_in_w[10])
    ,.oe(~dq_out_en_n_w[10])
    ,.io(ddr3_dq_io[10])
);


altddio_out
  #(
    .WIDTH(1)
    )
u_dq11_out
(
    .outclock(clk_i)
    ,.datain_l(dfi_wrdata_q[11+0])
    ,.datain_h(dfi_wrdata_q[11+16])
    ,.dataout(dq_out_w[11])
);

assign dq_out_en_n_w[11] = dqs_out_en_n_q;

alt_iobuf
u_pad_dq11
(
     .i(dq_out_w[11])
    ,.o(dq_in_w[11])
    ,.oe(~dq_out_en_n_w[11])
    ,.io(ddr3_dq_io[11])
);


altddio_out
  #(
    .WIDTH(1)
    )
u_dq12_out
  (
     .outclock(clk_i)
    ,.datain_l(dfi_wrdata_q[12+0])
    ,.datain_h(dfi_wrdata_q[12+16])
    ,.dataout(dq_out_w[12])
);

assign dq_out_en_n_w[12] = dqs_out_en_n_q;

alt_iobuf
u_pad_dq12
(
     .i(dq_out_w[12])
    ,.o(dq_in_w[12])
    ,.oe(~dq_out_en_n_w[12])
    ,.io(ddr3_dq_io[12])
);


altddio_out
  #(
    .WIDTH(1)
    )
u_dq13_out
(
    .outclock(clk_i)
    ,.datain_l(dfi_wrdata_q[13+0])
    ,.datain_h(dfi_wrdata_q[13+16])
    ,.dataout(dq_out_w[13])
);

assign dq_out_en_n_w[13] = dqs_out_en_n_q;

alt_iobuf
u_pad_dq13
(
     .i(dq_out_w[13])
    ,.o(dq_in_w[13])
    ,.oe(~dq_out_en_n_w[13])
    ,.io(ddr3_dq_io[13])
);


altddio_out
  #(
    .WIDTH(1)
    )
u_dq14_out
(
     .outclock(clk_i)
    ,.datain_l(dfi_wrdata_q[14+0])
    ,.datain_h(dfi_wrdata_q[14+16])
    ,.dataout(dq_out_w[14])
);

assign dq_out_en_n_w[14] = dqs_out_en_n_q;

alt_iobuf
u_pad_dq14
(
     .i(dq_out_w[14])
    ,.o(dq_in_w[14])
    ,.oe(~dq_out_en_n_w[14])
    ,.io(ddr3_dq_io[14])
);


altddio_out
  #(
    .WIDTH(1)
    )
u_dq15_out
(
     .outclock(clk_i)
    ,.datain_l(dfi_wrdata_q[15+0])
    ,.datain_h(dfi_wrdata_q[15+16])
    ,.dataout(dq_out_w[15])
);

assign dq_out_en_n_w[15] = dqs_out_en_n_q;

alt_iobuf
u_pad_dq15
(
     .i(dq_out_w[15])
    ,.o(dq_in_w[15])
    ,.oe(~dq_out_en_n_w[15])
    ,.io(ddr3_dq_io[15])
);


//-----------------------------------------------------------------
// Data Mask (DM)
//-----------------------------------------------------------------
wire [1:0] dm_out_w;
reg [3:0]  dfi_wr_mask_q;

always @ (posedge clk_i )
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
    ,.datain_l(dfi_wr_mask_q[0+0])
    ,.datain_h(dfi_wr_mask_q[0+2])
    ,.dataout(dm_out_w[0])
);


altddio_out
  #(
    .WIDTH(1)
    )
u_dm1_out
(
     .outclock(clk_i)
    ,.datain_l(dfi_wr_mask_q[1+0])
    ,.datain_h(dfi_wr_mask_q[1+2])
    ,.dataout(dm_out_w[1])
);


assign ddr3_dm_o   = dm_out_w;

//-----------------------------------------------------------------
// Read capture
//-----------------------------------------------------------------
wire [31:0] rd_data_w;
wire [15:0] dq_in_delayed_w;

DELAYG 
#(
     .DEL_MODE("USER_DEFINED")
    ,.DEL_VALUE(DQ_IN_DELAY_INIT)
)
u_dq_delay0
(
     .A(dq_in_w[0])
    ,.Z(dq_in_delayed_w[0])
);

altddio_in
  #(
    .WIDTH(1)
    )
u_dq_in0
(
     .inclock(clk_i)
    ,.datain(dq_in_delayed_w[0])
    ,.dataout_l(rd_data_w[0])
    ,.dataout_h(rd_data_w[0+16])
);

DELAYG 
#(
     .DEL_MODE("USER_DEFINED")
    ,.DEL_VALUE(DQ_IN_DELAY_INIT)
)
u_dq_delay1
(
     .A(dq_in_w[1])
    ,.Z(dq_in_delayed_w[1])
);

altddio_in
  #(
    .WIDTH(1)
    )
u_dq_in1
(
     .inclock(clk_i)
    ,.datain(dq_in_delayed_w[1])
    ,.dataout_l(rd_data_w[1])
    ,.dataout_h(rd_data_w[1+16])
);

DELAYG 
#(
     .DEL_MODE("USER_DEFINED")
    ,.DEL_VALUE(DQ_IN_DELAY_INIT)
)
u_dq_delay2
(
     .A(dq_in_w[2])
    ,.Z(dq_in_delayed_w[2])
);

altddio_in
  #(
    .WIDTH(1)
    )
u_dq_in2
(
     .inclock(clk_i)
    ,.datain(dq_in_delayed_w[2])
    ,.dataout_l(rd_data_w[2])
    ,.dataout_h(rd_data_w[2+16])
);

DELAYG 
#(
     .DEL_MODE("USER_DEFINED")
    ,.DEL_VALUE(DQ_IN_DELAY_INIT)
)
u_dq_delay3
(
     .A(dq_in_w[3])
    ,.Z(dq_in_delayed_w[3])
);

altddio_in
  #(
    .WIDTH(1)
    )
u_dq_in3
(
     .inclock(clk_i)
    ,.datain(dq_in_delayed_w[3])
    ,.dataout_l(rd_data_w[3])
    ,.dataout_h(rd_data_w[3+16])
);

DELAYG 
#(
     .DEL_MODE("USER_DEFINED")
    ,.DEL_VALUE(DQ_IN_DELAY_INIT)
)
u_dq_delay4
(
     .A(dq_in_w[4])
    ,.Z(dq_in_delayed_w[4])
);

altddio_in
  #(
    .WIDTH(1)
    )
u_dq_in4
(
     .inclock(clk_i)
    ,.datain(dq_in_delayed_w[4])
    ,.dataout_l(rd_data_w[4])
    ,.dataout_h(rd_data_w[4+16])
);

DELAYG 
#(
     .DEL_MODE("USER_DEFINED")
    ,.DEL_VALUE(DQ_IN_DELAY_INIT)
)
u_dq_delay5
(
     .A(dq_in_w[5])
    ,.Z(dq_in_delayed_w[5])
);

altddio_in
  #(
    .WIDTH(1)
    )
u_dq_in5
(
     .inclock(clk_i)
    ,.datain(dq_in_delayed_w[5])
    ,.dataout_l(rd_data_w[5])
    ,.dataout_h(rd_data_w[5+16])
);

DELAYG 
#(
     .DEL_MODE("USER_DEFINED")
    ,.DEL_VALUE(DQ_IN_DELAY_INIT)
)
u_dq_delay6
(
     .A(dq_in_w[6])
    ,.Z(dq_in_delayed_w[6])
);

altddio_in
  #(
    .WIDTH(1)
    )
u_dq_in6
(
     .inclock(clk_i)
    ,.datain(dq_in_delayed_w[6])
    ,.dataout_l(rd_data_w[6])
    ,.dataout_h(rd_data_w[6+16])
);

DELAYG 
#(
     .DEL_MODE("USER_DEFINED")
    ,.DEL_VALUE(DQ_IN_DELAY_INIT)
)
u_dq_delay7
(
     .A(dq_in_w[7])
    ,.Z(dq_in_delayed_w[7])
);

altddio_in
  #(
    .WIDTH(1)
    )
u_dq_in7
(
     .inclock(clk_i)
    ,.datain(dq_in_delayed_w[7])
    ,.dataout_l(rd_data_w[7])
    ,.dataout_h(rd_data_w[7+16])
);

DELAYG 
#(
     .DEL_MODE("USER_DEFINED")
    ,.DEL_VALUE(DQ_IN_DELAY_INIT)
)
u_dq_delay8
(
     .A(dq_in_w[8])
    ,.Z(dq_in_delayed_w[8])
);

altddio_in
  #(
    .WIDTH(1)
    )
u_dq_in8
(
     .inclock(clk_i)
    ,.datain(dq_in_delayed_w[8])
    ,.dataout_l(rd_data_w[8])
    ,.dataout_h(rd_data_w[8+16])
);

DELAYG 
#(
     .DEL_MODE("USER_DEFINED")
    ,.DEL_VALUE(DQ_IN_DELAY_INIT)
)
u_dq_delay9
(
     .A(dq_in_w[9])
    ,.Z(dq_in_delayed_w[9])
);

altddio_in
  #(
    .WIDTH(1)
    )
u_dq_in9
(
     .inclock(clk_i)
    ,.datain(dq_in_delayed_w[9])
    ,.dataout_l(rd_data_w[9])
    ,.dataout_h(rd_data_w[9+16])
);

DELAYG 
#(
     .DEL_MODE("USER_DEFINED")
    ,.DEL_VALUE(DQ_IN_DELAY_INIT)
)
u_dq_delay10
(
     .A(dq_in_w[10])
    ,.Z(dq_in_delayed_w[10])
);

altddio_in
  #(
    .WIDTH(1)
    )
u_dq_in10
(
     .inclock(clk_i)
    ,.datain(dq_in_delayed_w[10])
    ,.dataout_l(rd_data_w[10])
    ,.dataout_h(rd_data_w[10+16])
);

DELAYG 
#(
     .DEL_MODE("USER_DEFINED")
    ,.DEL_VALUE(DQ_IN_DELAY_INIT)
)
u_dq_delay11
(
     .A(dq_in_w[11])
    ,.Z(dq_in_delayed_w[11])
);

altddio_in
  #(
    .WIDTH(1)
    )
u_dq_in11
(
     .inclock(clk_i)
    ,.datain(dq_in_delayed_w[11])
    ,.dataout_l(rd_data_w[11])
    ,.dataout_h(rd_data_w[11+16])
);

DELAYG 
#(
     .DEL_MODE("USER_DEFINED")
    ,.DEL_VALUE(DQ_IN_DELAY_INIT)
)
u_dq_delay12
(
     .A(dq_in_w[12])
    ,.Z(dq_in_delayed_w[12])
);

altddio_in
  #(
    .WIDTH(1)
    )
u_dq_in12
(
     .inclock(clk_i)
    ,.datain(dq_in_delayed_w[12])
    ,.dataout_l(rd_data_w[12])
    ,.dataout_h(rd_data_w[12+16])
);

DELAYG 
#(
     .DEL_MODE("USER_DEFINED")
    ,.DEL_VALUE(DQ_IN_DELAY_INIT)
)
u_dq_delay13
(
     .A(dq_in_w[13])
    ,.Z(dq_in_delayed_w[13])
);

altddio_in
  #(
    .WIDTH(1)
    )
u_dq_in13
(
     .inclock(clk_i)
    ,.datain(dq_in_delayed_w[13])
    ,.dataout_l(rd_data_w[13])
    ,.dataout_h(rd_data_w[13+16])
);

DELAYG 
#(
     .DEL_MODE("USER_DEFINED")
    ,.DEL_VALUE(DQ_IN_DELAY_INIT)
)
u_dq_delay14
(
     .A(dq_in_w[14])
    ,.Z(dq_in_delayed_w[14])
);

altddio_in
  #(
    .WIDTH(1)
    )
u_dq_in14
(
     .inclock(clk_i)
    ,.datain(dq_in_delayed_w[14])
    ,.dataout_l(rd_data_w[14])
    ,.dataout_h(rd_data_w[14+16])
);

DELAYG 
#(
     .DEL_MODE("USER_DEFINED")
    ,.DEL_VALUE(DQ_IN_DELAY_INIT)
)
u_dq_delay15
(
     .A(dq_in_w[15])
    ,.Z(dq_in_delayed_w[15])
);

altddio_in
  #(
    .WIDTH(1)
    )
u_dq_in15
(
     .inclock(clk_i)
    ,.datain(dq_in_delayed_w[15])
    ,.dataout_l(rd_data_w[15])
    ,.dataout_h(rd_data_w[15+16])
);

assign dfi_rddata_o       = rd_data_w;
assign dfi_rddata_dnv_o   = 2'b0;

//-----------------------------------------------------------------
// Read Valid
//-----------------------------------------------------------------
localparam RD_SHIFT_W = 12;
reg [RD_SHIFT_W-1:0] rd_en_q;
reg [RD_SHIFT_W-1:0] rd_en_r;

always @ *
begin
    rd_en_r = {1'b0, rd_en_q[RD_SHIFT_W-1:1]};
    rd_en_r[rd_lat_q] = dfi_rddata_en_i;
end

always @ (posedge clk_i )
if (rst_i)
    rd_en_q <= {(RD_SHIFT_W){1'b0}};
else
    rd_en_q <= rd_en_r;

assign dfi_rddata_valid_o = rd_en_q[0];


endmodule


module DELAYG
  #(
    DEL_MODE ="USER_DEFINED",
    DEL_VALUE=0
    )
  (
   input  A,
   output Z
   );
   assign Z = A;  
endmodule
