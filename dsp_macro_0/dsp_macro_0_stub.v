// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
// Date        : Fri Apr  5 15:11:57 2024
// Host        : seat40 running 64-bit Ubuntu 22.04.3 LTS
// Command     : write_verilog -force -mode synth_stub -rename_top dsp_macro_0 -prefix
//               dsp_macro_0_ dsp_macro_0_stub.v
// Design      : dsp_macro_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dsp_macro_v1_0_2,Vivado 2022.2" *)
module dsp_macro_0(CLK, A, B, C, P)
/* synthesis syn_black_box black_box_pad_pin="CLK,A[15:0],B[15:0],C[31:0],P[31:0]" */;
  input CLK;
  input [15:0]A;
  input [15:0]B;
  input [31:0]C;
  output [31:0]P;
endmodule
