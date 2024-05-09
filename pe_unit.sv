`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2024 02:17:42 PM
// Design Name: 
// Module Name: pe_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pe_unit import cvxif_pkg::*;
(
    input  logic             clk_i,
    input  cntr              controls,
    input convolution        data,
    output logic [31:0]      result_o,
    output logic             pe_finished
);
/*wire signed [31:0] p;
reg signed [15:0] a_ext;
reg signed [15:0] b_ext;
reg signed [31:0] c_ext;
dsp_macro_0 dsp(//pre synthesized DSP macro in modes: P = (A+D)*B  or P = A+B; delay = 1 clk
    .CLK(clk),
    .A(a_ext),
    .B(b_ext),
    .C(c_ext),
    .P(p)
);
always_comb begin
        a_ext = data.I_height;
        b_ext = data.I_width;
        c_ext = 10;
end*/
assign result_o    = controls.result_valid_d  ? (data.I_height+data.I_width)*10 : 10 ;
assign pe_finished = '1;

endmodule