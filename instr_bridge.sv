`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.02.2019 09:06:32
// Design Name: 
// Module Name: instr_bridge
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


module instr_bridge
#(
    parameter id_width   = 2            ,
    parameter itcm_start = 32'h20000000,
    parameter itcm_size = 4096
)
(
    input  logic         aclk,
    input  logic         aresetn,
    
    // Instr AXI Lite interface
    output logic [id_width-1:0]   instr_axi_awid      ,
    output logic [31:0]  instr_axi_awaddr    ,
    output logic [7:0]   instr_axi_awlen     ,
    output logic [2:0]   instr_axi_awsize    ,
    output logic [1:0]   instr_axi_awburst   ,
    output logic [0:0]   instr_axi_awlock    ,
    output logic [3:0]   instr_axi_awcache   ,
    output logic [2:0]   instr_axi_awprot    ,
    output logic [3:0]   instr_axi_awqos     ,
    output logic [3:0]   instr_axi_awregion  ,
    output logic         instr_axi_awvalid   ,
    input  logic         instr_axi_awready   ,
    output logic [id_width-1:0]   instr_axi_wid       ,
    output logic [31:0]  instr_axi_wdata     ,
    output logic [3:0]   instr_axi_wstrb     ,
    output logic         instr_axi_wlast     ,
    output logic         instr_axi_wvalid    ,
    input  logic         instr_axi_wready    ,
    input  logic [id_width-1:0]   instr_axi_bid       ,
    input  logic [1:0]   instr_axi_bresp     ,
    input  logic         instr_axi_bvalid    ,
    output logic         instr_axi_bready    ,
    output logic [id_width-1:0]   instr_axi_arid      ,
    output logic [31:0]  instr_axi_araddr    ,
    output logic [7:0]   instr_axi_arlen     ,
    output logic [2:0]   instr_axi_arsize    ,
    output logic [1:0]   instr_axi_arburst   ,
    output logic [0:0]   instr_axi_arlock    ,
    output logic [3:0]   instr_axi_arcache   ,
    output logic [2:0]   instr_axi_arprot    ,
    output logic [3:0]   instr_axi_arqos     ,
    output logic [3:0]   instr_axi_arregion  ,
    output logic         instr_axi_arvalid   ,
    input  logic         instr_axi_arready   ,
    input  logic [id_width-1:0]   instr_axi_rid       ,
    input  logic [31:0]  instr_axi_rdata     ,
    input  logic [1:0]   instr_axi_rresp     ,
    input  logic         instr_axi_rlast     ,
    input  logic         instr_axi_rvalid    ,
    output logic         instr_axi_rready    ,
    
    // Pulp I port signals
    input  logic [31 : 0]iaddress,
    output logic [31 : 0]idata,
    input  logic         ireq,
    output logic         igrant,
    output logic         ivalid,
    
    // ITCM signals
    output logic  [31 : 0]i_tcm_address,
    output logic          i_tcm_req,
    input  logic  [31 : 0]i_tcm_read_data,
    input  logic          i_tcm_grant,
    input  logic          i_tcm_valid
);
    
    // i-fetch state machine
    typedef enum {i_reset, i_itcm_read, i_imem_read, i_imem_read_ah} i_fetch_fsm_type;
    
    
    
    // Request signals
    logic i_port_i_tcm_read_req;
    logic i_mem_read_req;
    
    // states
    i_fetch_fsm_type imem_state;
    i_fetch_fsm_type imem_next_state;
    
    // I-AXI signals
    logic [31:0] i_axi_addr_save;
    
    // Pulp I port signals
    assign ivalid = (imem_state == i_itcm_read)? i_tcm_valid : instr_axi_rvalid && instr_axi_rready;
    assign idata = (imem_state == i_itcm_read)? i_tcm_read_data: instr_axi_rdata;
    assign igrant = (imem_next_state == i_itcm_read)? i_tcm_grant : i_mem_read_req == 1 && (imem_state == i_reset || imem_state == i_itcm_read);
    
    // I-TCM port signals
    assign i_tcm_address = iaddress;
    assign i_tcm_req = imem_next_state == i_itcm_read;
    
    // Request signals
    assign i_port_i_tcm_read_req = (iaddress >= itcm_start && iaddress < itcm_start + itcm_start) && ireq;
    assign i_mem_read_req = !(iaddress >= itcm_start && iaddress < itcm_start + itcm_start) && ireq;
    
    // I-AXI port

    assign instr_axi_awid     = 'b0;
    assign instr_axi_awaddr   = 'b0;
    assign instr_axi_awlen    = 'b0;
    assign instr_axi_awsize   = 'b010;
    assign instr_axi_awburst  = 'b01;
    assign instr_axi_awlock   = 'b0;
    assign instr_axi_awcache  = 'b0;
    assign instr_axi_awprot   = 3'b101;
    assign instr_axi_awqos    = 'b0;
    assign instr_axi_awregion = 'b0;
    assign instr_axi_awvalid  = 'b0;
    assign instr_axi_wid      = 'b0;
    assign instr_axi_wdata    = 'b0;
    assign instr_axi_wstrb    = 'b0;
    assign instr_axi_wlast    = 'b0;
    assign instr_axi_wvalid   = 'b0;
    assign instr_axi_bready   = 'b0;
    assign instr_axi_arid     = 'b0;

    always @* begin
        if(imem_state == i_imem_read || imem_state == i_imem_read_ah)
            instr_axi_araddr = {i_axi_addr_save[31:2], 2'b00};
        else
            instr_axi_araddr = {iaddress[31:2], 2'b00};
    end    

    assign instr_axi_arlen    = 'b0;
    assign instr_axi_arsize   = 3'b010;
    assign instr_axi_arburst  = 2'b01;
    assign instr_axi_arlock   = 'b0;
    assign instr_axi_arcache  = 'b0;
    assign instr_axi_arprot   = 3'b101;
    assign instr_axi_arqos    = 'b0;
    assign instr_axi_arregion = 'b0;
    assign instr_axi_arvalid = imem_state == i_imem_read;
    assign instr_axi_rready = imem_state == i_imem_read_ah;

    
    always_ff @(posedge aclk, negedge aresetn)
    begin
        if(aresetn == 0)
            i_axi_addr_save <= 0;
        else if(i_mem_read_req && (imem_state == i_reset || imem_state == i_itcm_read))
            i_axi_addr_save <= iaddress;
    end
    
    always_comb
    begin
        // Reset
        if(imem_state == i_reset && i_port_i_tcm_read_req)
            imem_next_state = i_itcm_read;
        else if(imem_state == i_reset && i_mem_read_req)
            imem_next_state = i_imem_read;
        
        // ITCM
        else if(imem_state == i_itcm_read && i_port_i_tcm_read_req)
            imem_next_state = i_itcm_read;
        else if(imem_state == i_itcm_read && i_mem_read_req)
            imem_next_state = i_imem_read;
        else if(imem_state == i_itcm_read)
            imem_next_state = i_reset;
        
        // I Data mem request
        else if(imem_state == i_imem_read && instr_axi_arready)
            imem_next_state = i_imem_read_ah;
        
        // I Data mem handshake
        else if(imem_state == i_imem_read_ah && instr_axi_rready && instr_axi_rvalid && i_port_i_tcm_read_req)
                    imem_next_state = i_itcm_read;
        else if(imem_state == i_imem_read_ah && instr_axi_rready && instr_axi_rvalid)
            imem_next_state = i_reset;
        
        // no transition
        else
            imem_next_state = imem_state;
    end
    
    always_ff @(posedge aclk, negedge aresetn)
    begin
        if(aresetn == 0)
            imem_state <= i_reset;
        else
            imem_state <= imem_next_state;
    end
endmodule
