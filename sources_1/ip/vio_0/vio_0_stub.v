// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Wed Dec 31 10:48:48 2025
// Host        : DESKTOP-RR3HL5V running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/usually_used/ic/Vivado/HLx/DiP_Systolic_Array/DiP_Systolic_Array_3/DiP_Systolic_Array_3.srcs/sources_1/ip/vio_0/vio_0_stub.v
// Design      : vio_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "vio,Vivado 2018.3" *)
module vio_0(clk, probe_out0, probe_out1, probe_out2, 
  probe_out3, probe_out4, probe_out5)
/* synthesis syn_black_box black_box_pad_pin="clk,probe_out0[3:0],probe_out1[3:0],probe_out2[3:0],probe_out3[9:0],probe_out4[9:0],probe_out5[9:0]" */;
  input clk;
  output [3:0]probe_out0;
  output [3:0]probe_out1;
  output [3:0]probe_out2;
  output [9:0]probe_out3;
  output [9:0]probe_out4;
  output [9:0]probe_out5;
endmodule
