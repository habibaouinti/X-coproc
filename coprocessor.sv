`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2024 10:23:11 AM
// Design Name: 
// Module Name: coprocessor
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


module coprocessor import cvxif_pkg::*;
(
        input logic              clk_i,
        input logic              rst_ni,

        cv32e40x_if_xif.coproc_compressed xif_compressed,
        cv32e40x_if_xif.coproc_issue      xif_issue,
        cv32e40x_if_xif.coproc_commit     xif_commit,
        cv32e40x_if_xif.coproc_mem        xif_mem,
        cv32e40x_if_xif.coproc_mem_result xif_mem_result,
        cv32e40x_if_xif.coproc_result     xif_result
    );
    //Declarations

    wire   [4:0] rd,id;
    //Decoder outputs
    convolution         data ;
    cntr                controls;
    logic               pe_finished;
    logic [31:0]        result_o ;
//  PE 
    logic               pe_valid;
    wire                results_valid;
    //ISSUE INTERFACE
    x_issue_req_t       issue_req_i;
    x_issue_resp_t      issue_resp_o;
    logic               issue_valid_i;
    logic               issue_ready_o;


  //Result interface
  logic               result_valid_d;
  logic               result_valid_o;

    //the x interface
   
    //COMPRESSED INTERFACE - NOT USED
    assign xif_compressed.compressed_ready = '0;
    assign xif_compressed.compressed_resp  = '0;

    //ISSUE INTERFACE
    assign issue_req_i           = xif_issue.issue_req;
    assign xif_issue.issue_resp  = issue_resp_o;
    assign issue_valid_i         = xif_issue.issue_valid;
    assign rd                    = issue_req_i.instr[11:7];
    assign xif_issue.issue_ready = '1;

//    assign xif_issue.issue_ready = apu_gnt; 


  /////////////////////////////////////////////////////

  /////////////////////////////////////////////////////
    
co_decoder decoder (
      .clk_i           (clk_i),
      .issue_valid_i   (issue_valid_i),
      .issue_req_i     (issue_req_i),
      .issue_resp_o    (issue_resp_o),
      .controls        (controls),
      .data            (data)
);



    //Memory INTERFACE
    assign xif_mem.mem_valid               = '0;
    assign xif_mem.mem_req                 = '0;
    
    //Execution phase 
  /////////////////////////////////////////////////////

  /////////////////////////////////////////////////////
pe_unit pe(
      .clk_i           (clk_i),
      .controls        (controls),
      .data            (data),
      .result_o        (result_o),
      .pe_finished     (pe_finished)
);
    //RESULT INTERFACE
   always_comb begin
//    result_valid_o   = 1;
    xif_result.result_valid   = pe_finished;
    xif_result.result.id      = issue_req_i.id;
    xif_result.result.data    = result_o ;
    xif_result.result.rd      = rd;
    xif_result.result.we      = '1;
    xif_result.result.exc     = '0;
    xif_result.result.exccode = '0;
  end
endmodule
