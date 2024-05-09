`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2024 11:20:45 AM
// Design Name: 
// Module Name: co_decoder
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


module co_decoder import cvxif_pkg::*;
(
    input  logic             clk_i,
    input  logic             issue_valid_i,
    input  x_issue_req_t     issue_req_i,
    output x_issue_resp_t    issue_resp_o,
    output cntr              controls,
    output convolution       data
    );
    parameter Custom_OPCODE = 7'b0001011 ;
//    parameter x_issue_resp_t nowb = '{
//              accept : 1'b1,
//              writeback : 1'b0,
//              dualwrite : 1'b0,
//              dualread : 1'b0,
//              loadstore : 1'b0,
//              ecswrite : 1'b0,
//              exc : 1'b0
//          };
//    variables
//    opCode selection

always_comb 
begin
    // Default assignments
    issue_resp_o.accept    = '0;
    issue_resp_o.writeback = '0;
    issue_resp_o.dualwrite = '0;
    issue_resp_o.dualread  = '0;
    issue_resp_o.loadstore = '0;
    issue_resp_o.ecswrite  = '0;
    issue_resp_o.exc       = '0;
    unique case (issue_req_i.instr[6:0])
      Custom_OPCODE: begin // Custom opcode
      if (issue_valid_i) begin
            issue_resp_o.accept     = '1;
//            issue_resp_o.writeback  = '1;
            issue_resp_o.writeback  = issue_req_i.instr[12] && issue_req_i.instr[13];
            issue_resp_o.dualwrite  = '0;
            issue_resp_o.dualread   = '0;
            issue_resp_o.loadstore  = '0;
            issue_resp_o.ecswrite   = '0;
            issue_resp_o.exc        = '0;
            controls.result_valid_d = '1; 
            unique case (issue_req_i.instr[14:12])   
                3'b000:begin
                    data.W_addr            = issue_req_i.rs[0];
                    data.I_addr            = issue_req_i.rs[1];
                end
                3'b001:begin
                    data.I_height          = issue_req_i.rs[1]; //register operand 1
                    data.I_width           = issue_req_i.rs[0]; //register operand 2
                    data.I_channels        = issue_req_i.instr[11:7] ;
                end
                3'b010:begin
                    data.W_height          = issue_req_i.rs[1]; //register operand 1
                    data.W_width           = issue_req_i.rs[0]; //register operand 2
                    data.W_channels        = issue_req_i.instr[11:7] ;
                    data.Padding           = issue_req_i.instr[27:26] ;
                    data.Stride            = issue_req_i.instr[25] ;
                end
                3'b011:begin
                    data.R_addr            = issue_req_i.rs[0];
                end
            endcase
      end
      end
  endcase
  end
endmodule