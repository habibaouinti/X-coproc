/*
 Copyright 2021 TU Wien

 This file, and derivatives thereof are licensed under the
 Solderpad License, Version 2.0 (the "License");
 Use of this file means you agree to the terms and conditions
 of the license and are in full compliance with the License.
 You may obtain a copy of the License at

 https://solderpad.org/licenses/SHL-2.0/

 Unless required by applicable law or agreed to in writing, software
 and hardware implementations thereof
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESSED OR IMPLIED.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

////////////////////////////////////////////////////////////////////////////////
// Engineer:       Michael Platzer - michael.platzer@tuwien.ac.at             //
//                                                                            //
// Design Name:    CORE-V XIF eXtension Interface                             //
// Project Name:   RI5CY                                                      //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Definition of the CORE-V XIF eXtension Interface.          //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface cv32e40x_if_xif
import cvxif_pkg::*;

#(
  parameter int unsigned X_NUM_RS        =  2,  // Number of register file read ports that can be used by the eXtension interface
  parameter int unsigned X_ID_WIDTH      =  4,  // Width of ID field.
  parameter int unsigned X_MEM_WIDTH     =  32, // Memory access width for loads/stores via the eXtension interface
  parameter int unsigned X_RFR_WIDTH     =  32, // Register file read access width for the eXtension interface
  parameter int unsigned X_RFW_WIDTH     =  32, // Register file write access width for the eXtension interface
  parameter logic [31:0] X_MISA          =  '0, // MISA extensions implemented on the eXtension interface
  parameter logic [ 1:0] X_ECS_XS        =  '0  // Default value for mstatus.XS
);

  localparam int XLEN = 32;
  localparam int FLEN = 32;

  // Compressed interface
  logic               compressed_valid;
  logic               compressed_ready;
  x_compressed_req_t  compressed_req;
  x_compressed_resp_t compressed_resp;

  // Issue interface
  logic               issue_valid;
  logic               issue_ready;
  x_issue_req_t       issue_req;
  x_issue_resp_t      issue_resp;

  // Commit interface
  logic               commit_valid;
  x_commit_t          commit;

  // Memory (request/response) interface
  logic               mem_valid;
  logic               mem_ready;
  x_mem_req_t         mem_req;
  x_mem_resp_t        mem_resp;

  // Memory result interface
  logic               mem_result_valid;
  x_mem_result_t      mem_result;

  // Result interface
  logic               result_valid;
  logic               result_ready;
  x_result_t          result;

  // Port directions for host CPU
  modport cpu_compressed (
    output compressed_valid,
    input  compressed_ready,
    output compressed_req,
    input  compressed_resp
  );
  modport cpu_issue (
    output issue_valid,
    input  issue_ready,
    output issue_req,
    input  issue_resp
  );
  modport cpu_commit (
    output commit_valid,
    output commit
  );
  modport cpu_mem (
    input  mem_valid,
    output mem_ready,
    input  mem_req,
    output mem_resp
  );
  modport cpu_mem_result (
    output mem_result_valid,
    output mem_result
  );
  modport cpu_result (
    input  result_valid,
    output result_ready,
    input  result
  );

  // Port directions for extension
  modport coproc_compressed (
    input  compressed_valid,
    output compressed_ready,
    input  compressed_req,
    output compressed_resp
  );
  modport coproc_issue (
    input  issue_valid,
    output issue_ready,
    input  issue_req,
    output issue_resp
  );
  modport coproc_commit (
    input  commit_valid,
    input  commit
  );
  modport coproc_mem (
    output mem_valid,
    input  mem_ready,
    output mem_req,
    input  mem_resp
  );
  modport coproc_mem_result (
    input  mem_result_valid,
    input  mem_result
  );
  modport coproc_result (
    output result_valid,
    input  result_ready,
    output result
  );

  // Monitor port directions
  modport monitor_compressed (
    input  compressed_valid,
    input  compressed_ready,
    input  compressed_req,
    input  compressed_resp
  );
  modport monitor_issue (
    input  issue_valid,
    input  issue_ready,
    input  issue_req,
    input  issue_resp
  );
  modport monitor_commit (
    input  commit_valid,
    input  commit
  );
  modport monitor_mem (
    input  mem_valid,
    input  mem_ready,
    input  mem_req,
    input  mem_resp
  );
  modport monitor_mem_result (
    input  mem_result_valid,
    input  mem_result
  );
  modport monitor_result (
    input  result_valid,
    input  result_ready,
    input  result
  );

endinterface : cv32e40x_if_xif
