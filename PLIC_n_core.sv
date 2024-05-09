`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.01.2019 13:46:51
// Design Name: 
// Module Name: plic
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

module PLIC_n_core
#(
    parameter num_targets = 2,
    parameter num_sources = 2
)
(
    input  logic       aclk,
    input  logic       aresetn,
    
    input logic  [31:0]PLIC_AXI_0_araddr,
    input logic   [2:0]PLIC_AXI_0_arprot,
    output logic  [0:0]PLIC_AXI_0_arready,
    input logic   [0:0]PLIC_AXI_0_arvalid,
    input wire [7 : 0]PLIC_AXI_0_arlen,
    input wire [2 : 0]PLIC_AXI_0_arsize,
    input wire [1 : 0]PLIC_AXI_0_arburst,
    
    input logic  [31:0]PLIC_AXI_0_awaddr,
    input logic   [2:0]PLIC_AXI_0_awprot,
    output logic  [0:0]PLIC_AXI_0_awready,
    input logic   [0:0]PLIC_AXI_0_awvalid,
    
    input logic   [0:0]PLIC_AXI_0_bready,
    output logic  [1:0]PLIC_AXI_0_bresp,
    output logic  [0:0]PLIC_AXI_0_bvalid,
    output logic [31:0]PLIC_AXI_0_rdata,
    input logic   [0:0]PLIC_AXI_0_rready,
    output logic  [1:0]PLIC_AXI_0_rresp,
    output logic  [0:0]PLIC_AXI_0_rvalid,
    
    input logic  [31:0]PLIC_AXI_0_wdata,
    output logic  [0:0]PLIC_AXI_0_wready,
    input logic   [3:0]PLIC_AXI_0_wstrb,
    input logic   [0:0]PLIC_AXI_0_wvalid,
    
    output  logic [num_targets-1:0]      intr_irq,
    input   logic [num_targets-1:0]      intr_irq_ack,
    input   logic [num_targets-1:0][4:0] intr_irq_ack_id,
    output  logic [num_targets-1:0][4:0] intr_irq_id,
    output  logic [num_targets-1:0]      intr_sec,
    input   logic [num_targets-1:0]      intr_sec_lvl,
    
    // output logic        intr_1_irq,
    // input logic         intr_1_irq_ack,
    // input logic  [4:0]  intr_1_irq_ack_id,
    // output logic [4:0]  intr_1_irq_id,
    // output logic        intr_1_sec,
    // input logic         intr_1_sec_lvl,
    
    input  logic [num_sources-1:0]source
);


typedef enum {IS_RESET, IS_PENDING} interrupt_state_t;
typedef enum {AXI_RESET, AXI_READ, AXI_WRITE_AH, AXI_WRITE_AWH, AXI_WRITE} AXI_FSM_t;

logic [num_sources-1:0] last_source_irq;
logic [num_sources-1:0] edge_detected;
logic [num_sources-1:0][num_targets-1:0] ack_tbl;

interrupt_state_t interrupt_state[num_sources];
AXI_FSM_t axi_state;

logic [31:0] memory_mapped_registers[num_targets + num_sources];
genvar j;
genvar k;

// AXI interface

assign PLIC_AXI_0_arready = axi_state == AXI_RESET;
assign PLIC_AXI_0_awready = axi_state == AXI_RESET;
assign PLIC_AXI_0_wready  = axi_state == AXI_RESET || axi_state == AXI_WRITE_AH;

assign PLIC_AXI_0_rvalid = axi_state == AXI_READ;
assign PLIC_AXI_0_bvalid = axi_state == AXI_WRITE_AWH;

assign PLIC_AXI_0_rresp = 3'b101;
assign PLIC_AXI_0_bresp = 3'b101;


always_comb
begin
    if(PLIC_AXI_0_arvalid)
    begin
        PLIC_AXI_0_rdata <= memory_mapped_registers[PLIC_AXI_0_araddr[$clog2(num_targets + num_sources)+2:2]];
    end
end

always_ff @(posedge aclk, negedge aresetn)
begin
    if(aresetn == 0)
    begin
    	  for(int i = 0; i < num_targets + num_sources; ++i)
    	      memory_mapped_registers[i] <= 0;
    end
    else if(PLIC_AXI_0_wvalid)
    begin
        memory_mapped_registers[PLIC_AXI_0_awaddr[$clog2(num_targets + num_sources)+2:2]] <= PLIC_AXI_0_wdata;
    end
end

always_ff @(posedge aclk, negedge aresetn)
begin
    if(aresetn == 0)
        axi_state <= AXI_RESET;
    else if(axi_state == AXI_RESET && PLIC_AXI_0_arvalid)
        axi_state <= AXI_READ;
    else if(axi_state == AXI_RESET && PLIC_AXI_0_awvalid && !PLIC_AXI_0_wvalid)
        axi_state <= AXI_WRITE_AH;
    else if(axi_state == AXI_RESET && PLIC_AXI_0_awvalid && PLIC_AXI_0_wvalid)
        axi_state <= AXI_WRITE_AWH;
                
    else if(axi_state == AXI_READ && PLIC_AXI_0_rready)
        axi_state <= AXI_RESET;
        
    else if(axi_state == AXI_WRITE_AH && PLIC_AXI_0_wvalid)
        axi_state <= AXI_WRITE_AWH;
    
    else if(axi_state == AXI_WRITE_AWH && PLIC_AXI_0_bready)
        axi_state <= AXI_RESET;
end

// Logic

// assign intr_0_sec = 1;
// assign intr_1_sec = 1;

assign intr_sec = '1;

always_ff @(posedge aclk, negedge aresetn)
begin
    for(int i = 0; i < num_sources; ++i)
    begin
        if(aresetn == 0)
            last_source_irq[i] <= 0;
        else
            last_source_irq[i] <= source[i];
    end
end;

always_comb
begin
    for(int i = 0; i < num_sources; ++i)
        edge_detected[i] = !last_source_irq[i] & source[i];
end

generate
    for(j=0;j<num_sources;j=j+1) begin: ack_tbl_gen
        for(k=0;k<num_targets;k=k+1) begin
                assign ack_tbl[j][k] = (intr_irq_ack[k] == 1) && (intr_irq_ack_id[k] == j);
        end
    end
endgenerate

always_ff @(posedge aclk, negedge aresetn)
begin
    for(int i = 0; i < num_sources; ++i)
    begin
        if(aresetn == 0)
            interrupt_state[i] <= IS_RESET;
        else if(interrupt_state[i] == IS_RESET && edge_detected[i])
            interrupt_state[i] <= IS_PENDING;
        else if(interrupt_state[i] == IS_PENDING && (|ack_tbl[i]))
        // else if(interrupt_state[i] == IS_PENDING && (intr_0_irq_ack == 1 && intr_0_irq_ack_id == i || //todo
        //                                              intr_1_irq_ack == 1 && intr_1_irq_ack_id == i))
            interrupt_state[i] <= IS_RESET;
    end
end
        
// always_ff @(posedge aclk, negedge aresetn)
// begin
//     for(int i = 0; i < num_sources; ++i)
//     begin
//         if(aresetn == 0)
//             interrupt_state[i] <= IS_RESET;
//         else if(interrupt_state[i] == IS_RESET && edge_detected[i])
//             interrupt_state[i] <= IS_PENDING;
//         else if(interrupt_state[i] == IS_PENDING && (intr_0_irq_ack == 1 && intr_0_irq_ack_id == i ||
//                                                      intr_1_irq_ack == 1 && intr_1_irq_ack_id == i))
//             interrupt_state[i] <= IS_RESET;
//     end
// end



generate
    for(j=0;j<num_targets;j=j+1) begin:intr_irq_gen
        always_comb
        begin
            static logic any_pending = 0;
            for(int i = 0; i < num_sources; ++i)
            begin
                if(interrupt_state[i] == IS_PENDING &&
                   memory_mapped_registers[num_targets+i][9:0] > memory_mapped_registers[j][9:0] && // priotity threshold
                   memory_mapped_registers[num_targets+i][30:27] == j && // hartid match
                   memory_mapped_registers[num_targets+i][31] == 1)   //enabled
                begin
                    any_pending = 1;
                end
            end
            intr_irq[j] = any_pending;
        end
    end
endgenerate


// always_comb
// begin
//     static logic any_pending;
//     any_pending = 0;
//     for(int i = 0; i < num_sources; ++i)
//     begin
//         if(interrupt_state[i] == IS_PENDING &&
//            memory_mapped_registers[num_targets+i][9:0] > memory_mapped_registers[1][9:0] && // priotity threshold
//            memory_mapped_registers[num_targets+i][30:27] == 1 && // hartid match
//            memory_mapped_registers[num_targets+i][31] == 1)   //enabled
//         begin
//             any_pending = 1;
//         end
//     end
//     intr_1_irq = any_pending;
// end

generate
    for(j=0;j<num_targets;j=j+1)begin:intr_irq_id_gen
        always_comb
        begin
            static logic [9:0] max_priority;
            static logic [4:0] max_priority_id;
            max_priority = 0;
            max_priority_id = 0;
            for(int i = 0; i < num_sources; ++i)
            begin
                if(interrupt_state[i] == IS_PENDING &&
                   memory_mapped_registers[num_targets+i][9:0] > memory_mapped_registers[j][9:0] && // priotity threshold
                   memory_mapped_registers[num_targets+i][30:27] == j && // hartid match
                   memory_mapped_registers[num_targets+i][31] == 1 &&
                   memory_mapped_registers[num_targets+i][9:0] > max_priority)   //enabled
                   begin
                        max_priority = memory_mapped_registers[num_targets+i][9:0];
                        max_priority_id = i;
                   end
            end
            intr_irq_id[j] = max_priority_id;
        end
    end
endgenerate

// always_comb
// begin
//     static logic [9:0] max_priority;
//     static logic [4:0] max_priority_id;
//     max_priority = 0;
//     max_priority_id = 0;
//     for(int i = 0; i < num_sources; ++i)
//     begin
//         if(interrupt_state[i] == IS_PENDING &&
//            memory_mapped_registers[num_targets+i][9:0] > memory_mapped_registers[1][9:0] && // priotity threshold
//            memory_mapped_registers[num_targets+i][30:27] == 1 && // hartid match
//            memory_mapped_registers[num_targets+i][31] == 1 &&
//            memory_mapped_registers[num_targets+i][9:0] > max_priority)   //enabled
//            begin
//                 max_priority = memory_mapped_registers[num_targets+i][9:0];
//                 max_priority_id = i;
//            end
//     end
//     intr_1_irq_id = max_priority_id;
// end

endmodule
