`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.02.2019 09:36:04
// Design Name: 
// Module Name: data_bridge
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


module data_bridge
#(
    parameter itcm_start = 32'h20000000,
    parameter itcm_size = 4096,
    parameter dtcm_start = 32'h40000000,
    parameter dtcm_size = 4096
)
(
    input wire  aclk,
    input wire  aresetn,
    
    // Data AXI interface
    output logic [1:0]                 data_axi_awid                ,
    output logic [31:0]                data_axi_awaddr              ,
    output logic [7:0]                 data_axi_awlen               ,
    output logic [2:0]                 data_axi_awsize              ,
    output logic [1:0]                 data_axi_awburst             ,
    output logic [0:0]                 data_axi_awlock              ,
    output logic [3:0]                 data_axi_awcache             ,
    output logic [2:0]                 data_axi_awprot              ,
    output logic [3:0]                 data_axi_awqos               ,
    output logic [3:0]                 data_axi_awregion            ,
    output logic                       data_axi_awvalid             ,
    input  logic                       data_axi_awready             ,
    output logic [2:0]                 data_axi_wid                 ,
    output logic [31:0]                data_axi_wdata               ,
    output logic [3:0]                 data_axi_wstrb               ,
    output logic                       data_axi_wlast               ,
    output logic                       data_axi_wvalid              ,
    input  logic                       data_axi_wready              ,
    input  logic [1:0]                 data_axi_bid                 ,
    input  logic [1:0]                 data_axi_bresp               ,
    input  logic                       data_axi_bvalid              ,
    output logic                       data_axi_bready              ,
    output logic [1:0]                 data_axi_arid                ,
    output logic [31:0]                data_axi_araddr              ,
    output logic [7:0]                 data_axi_arlen               ,
    output logic [2:0]                 data_axi_arsize              ,
    output logic [1:0]                 data_axi_arburst             ,
    output logic [0:0]                 data_axi_arlock              ,
    output logic [3:0]                 data_axi_arcache             ,
    output logic [2:0]                 data_axi_arprot              ,
    output logic [3:0]                 data_axi_arqos               ,
    output logic [3:0]                 data_axi_arregion            ,
    output logic                       data_axi_arvalid             ,
    input  logic                       data_axi_arready             ,
    input  logic [1:0]                 data_axi_rid                 ,
    input  logic [31:0]                data_axi_rdata               ,
    input  logic [1:0]                 data_axi_rresp               ,
    input  logic                       data_axi_rlast               ,
    input  logic                       data_axi_rvalid              ,
    output logic                       data_axi_rready              ,

     // Pulp D port signals

    input  logic [31:0]                daddress                     ,
    input  logic [31:0]                dwdata                       ,
    input  logic                       dreq                         ,
    output logic                       dgrant                       ,
    output logic                       dvalid                       ,
    output logic [31:0]                drdata                       ,
    input  logic                       dwnr                         ,
    input  logic [3:0]                 dbe                          ,
    input  logic [5:0]                 datop                        ,      //todo: new signal
    input  logic [1:0]                 dmemtype                     ,
    input  logic [2:0]                 dprot                        ,
    output logic                       derr                         ,       //todo: new signal
    output logic                       dexokay                      ,    //todo: new signal
    input  logic                       flush_req                    ,  //todo: send to dcache, new signal
    output logic                       flush_ack                    ,  //todo: send from dcache, new signal    
  
    // ITCM signals
    output logic [31:0]                i_tcm_address                ,
    output logic                       i_tcm_req                    ,
    output logic                       i_tcm_write_en               ,
    output logic [3:0]                 i_tcm_write_be               ,
    output logic [31:0]                i_tcm_write_data             ,
    input  logic [31:0]                i_tcm_read_data              ,
    input  logic                       i_tcm_grant                  ,
    input  logic                       i_tcm_valid                  ,

    // DTCM signals
    output logic [31:0]                 d_tcm_address               ,
    output logic                        d_tcm_req                   ,
    output logic                        d_tcm_write_en              ,
    output logic [3:0]                  d_tcm_write_be              ,
    output logic [31:0]                 d_tcm_write_data            ,
    input  logic [31:0]                 d_tcm_read_data             ,
    input  logic                        d_tcm_grant                 ,
    input  logic                        d_tcm_valid                 

);

    // d-fetch state machine
    typedef enum {d_reset,
                  d_itcm_read, d_itcm_write,
                  d_dtcm_read, d_dtcm_write,
                  d_dmem_read, d_dmem_read_ah,
                  d_dmem_write, d_dmem_write_ah, d_dmem_write_awh} d_lsu_fsm_type;
    // Request signals
    wire d_port_i_tcm_read_req;
    wire d_port_i_tcm_write_req;
    wire d_port_d_tcm_read_req;
    wire d_port_d_tcm_write_req;
    wire d_mem_read_req;
    wire d_mem_write_req;
    
    // states
    d_lsu_fsm_type dmem_next_state;
    d_lsu_fsm_type dmem_state;
    
    // D-AXI signals
    wire isDMemAddress;
    reg [31:0] d_axi_addr_save;
    reg [31:0] d_axi_wdata_save;
    reg [3:0] d_axi_wbe_save;
    
    
    // Pulp D port signals
    always_comb
    begin
        if(dmem_next_state == d_itcm_read || dmem_next_state == d_itcm_write)
            dgrant = i_tcm_grant;
        else if(dmem_next_state == d_dtcm_write || dmem_next_state == d_dtcm_read)
            dgrant = d_tcm_grant;
        else if(dmem_next_state == d_dmem_read_ah)
            dgrant = data_axi_arready && data_axi_arvalid;
        else
            dgrant = data_axi_awready && data_axi_awvalid;
    end
    
    always_comb
    begin
        if(dmem_state == d_itcm_write)
        begin
            drdata = 32'hxxxxxxxx;
            dvalid = i_tcm_valid;
        end
        else if(dmem_state == d_itcm_read)
        begin
            drdata = i_tcm_read_data;
            dvalid = i_tcm_valid;
        end
        else if(dmem_state == d_dtcm_write || dmem_state == d_dtcm_read)
        begin
            dvalid = d_tcm_valid;
            drdata = d_tcm_read_data;
        end
        else if(dmem_state == d_dmem_read_ah)
        begin
            drdata = data_axi_rdata;
            dvalid = data_axi_rready && data_axi_rvalid;
        end
        else
        begin
            drdata = 32'hxxxxxxxx;
            dvalid = data_axi_bvalid && data_axi_bready;
        end
    end

    // core signals
    assign derr = (data_axi_bresp == 2'b10) || (data_axi_bresp == 2'b11) || 
                    (data_axi_rresp == 2'b10) || (data_axi_rresp == 2'b11);

    assign dexokay = (data_axi_bresp == 2'b01) || (data_axi_rresp == 2'b01);
    
    // I-TCM port signals
    assign i_tcm_address = daddress;
    assign i_tcm_req = dmem_next_state == d_itcm_write || dmem_next_state == d_itcm_read;
    assign i_tcm_write_en = dmem_next_state == d_itcm_write;
    assign i_tcm_write_be = dbe;
    assign i_tcm_write_data = dwdata;
        
    // D-TCM port signals
    assign d_tcm_address = daddress;
    assign d_tcm_req = dmem_next_state == d_dtcm_write || dmem_next_state == d_dtcm_read;
    assign d_tcm_write_en = dmem_next_state == d_dtcm_write;
    assign d_tcm_write_be = dbe;
    assign d_tcm_write_data = dwdata;
    


    // Request signals
    assign d_port_i_tcm_write_req = (daddress >= itcm_start) && (daddress < itcm_start + itcm_size) && dwnr && dreq;
    assign d_port_i_tcm_read_req = (daddress >= itcm_start) && (daddress < itcm_start + itcm_size) && !dwnr && dreq;
    assign d_port_d_tcm_read_req = (daddress >= dtcm_start) && (daddress < dtcm_start + dtcm_size) && !dwnr && dreq;
    assign d_port_d_tcm_write_req = (daddress >= dtcm_start) && (daddress < dtcm_start + dtcm_size) && dwnr && dreq;
    
    assign d_mem_read_req = isDMemAddress && dreq && !dwnr;
    assign d_mem_write_req = isDMemAddress && dreq && dwnr;
    

    assign isDMemAddress = !((daddress >= itcm_start) && (daddress < itcm_start + itcm_size)) && 
                           !((daddress >= dtcm_start) && (daddress < dtcm_start + dtcm_size));
                                        
    // D-AXI port
    assign data_axi_awid     = 'b0;
    assign data_axi_awaddr   = {d_axi_addr_save[31:2], 2'b00};
    assign data_axi_awlen    = 'b0;
    assign data_axi_awsize   = 'b000;
    assign data_axi_awburst  = 'b01;
    assign data_axi_awlock   = 'b0;
    assign data_axi_awcache  = 'b0;
    assign data_axi_awprot   = 3'b101;
    assign data_axi_awqos    = 'b0;
    assign data_axi_awregion = 'b0;
    assign data_axi_awvalid = dmem_state == d_dmem_write;
    assign data_axi_wid      = 'b0;
    assign data_axi_wdata    = d_axi_wdata_save;
    assign data_axi_wstrb    = d_axi_wbe_save;
    assign data_axi_wlast    = data_axi_wvalid;
    assign data_axi_wvalid  = dmem_state == d_dmem_write || dmem_state == d_dmem_write_ah;
    // assign data_axi_wvalid   = dmem_state == d_dmem_write_ah;
    assign data_axi_bready = dmem_state == d_dmem_write_awh;
    assign data_axi_arid     = 'b0;
    assign data_axi_araddr = {d_axi_addr_save[31:2], 2'b00};
    assign data_axi_arlen    = 0;
    assign data_axi_arsize   = 3'b000;
    assign data_axi_arburst  = 2'b01;
    assign data_axi_arlock   = 'b0;
    assign data_axi_arcache  = 'b0;
    assign data_axi_arprot   = 3'b101;
    assign data_axi_arqos    = 'b0;
    assign data_axi_arregion = 'b0;
    assign data_axi_arvalid = dmem_state == d_dmem_read;
    assign data_axi_rready = dmem_state == d_dmem_read_ah;

    
    always_ff @(posedge aclk, negedge aresetn)
    begin
        if(aresetn == 0)
        begin
        	  d_axi_addr_save <= 0;
            d_axi_wdata_save <= 0;
            d_axi_wbe_save <= 0;
        end
        else if((d_mem_read_req || d_mem_write_req) && (dmem_state == d_reset || dmem_state == d_itcm_write || dmem_state == d_itcm_read || dmem_state == d_dtcm_read || dmem_state == d_dtcm_write ))
        begin
            d_axi_addr_save <= daddress;
            d_axi_wdata_save <= dwdata;
            d_axi_wbe_save <= dbe;
        end
    end
    
    always_comb
    begin
        // Reset
        if( dmem_state == d_reset && d_port_i_tcm_read_req)
            dmem_next_state = d_itcm_read;
        else if( dmem_state == d_reset && d_port_i_tcm_write_req)
            dmem_next_state = d_itcm_write;
        else if(dmem_state == d_reset && d_port_d_tcm_read_req)
             dmem_next_state = d_dtcm_read;
        else if(dmem_state == d_reset && d_port_d_tcm_write_req)
            dmem_next_state = d_dtcm_write;
        else if(dmem_state == d_reset && d_mem_read_req)
            dmem_next_state = d_dmem_read;
        else if(dmem_state == d_reset && d_mem_write_req)
            dmem_next_state = d_dmem_write;
        
        // ITCM read
        else if(dmem_state == d_itcm_read && d_port_i_tcm_read_req)
            dmem_next_state = d_itcm_read;
        else if(dmem_state == d_itcm_read && d_port_i_tcm_write_req)
            dmem_next_state = d_itcm_write;
        else if(dmem_state == d_itcm_read && d_port_d_tcm_read_req)
            dmem_next_state = d_dtcm_read;
        else if(dmem_state == d_itcm_read && d_port_d_tcm_write_req)
            dmem_next_state = d_dtcm_write;
        else if(dmem_state == d_itcm_read && d_mem_read_req)
            dmem_next_state = d_dmem_read;
        else if(dmem_state == d_itcm_read && d_mem_write_req)
            dmem_next_state = d_dmem_write;
        else if(dmem_state == d_itcm_read)
            dmem_next_state = d_reset;
        
        // ITCM write
        else if(dmem_state == d_itcm_write && d_port_i_tcm_read_req)
            dmem_next_state = d_itcm_read;
        else if(dmem_state == d_itcm_write && d_port_i_tcm_write_req)
            dmem_next_state = d_itcm_write;
        else if(dmem_state == d_itcm_write && d_port_d_tcm_read_req)
            dmem_next_state = d_dtcm_read;
        else if(dmem_state == d_itcm_write && d_port_d_tcm_write_req)
            dmem_next_state = d_dtcm_write;
        else if(dmem_state == d_itcm_write && d_mem_read_req)
            dmem_next_state = d_dmem_read;
        else if(dmem_state == d_itcm_write && d_mem_write_req)
            dmem_next_state = d_dmem_write;
        else if(dmem_state == d_itcm_write)
            dmem_next_state = d_reset;
        
        // DTCM read
        else if(dmem_state == d_dtcm_read && d_port_i_tcm_read_req)
            dmem_next_state = d_itcm_read;
        else if(dmem_state == d_dtcm_read && d_port_i_tcm_write_req)
            dmem_next_state = d_itcm_write;
        else if(dmem_state == d_dtcm_read && d_port_d_tcm_read_req)
            dmem_next_state = d_dtcm_read;
        else if(dmem_state == d_dtcm_read && d_port_d_tcm_write_req)
            dmem_next_state = d_dtcm_write;
        else if(dmem_state == d_dtcm_read && d_mem_read_req)
            dmem_next_state = d_dmem_read;
        else if(dmem_state == d_dtcm_read && d_mem_write_req)
            dmem_next_state = d_dmem_write;
        else if(dmem_state == d_dtcm_read)
            dmem_next_state = d_reset;
        
        // DTCM write
        else if(dmem_state == d_dtcm_write && d_port_i_tcm_read_req)
            dmem_next_state = d_itcm_read;
        else if(dmem_state == d_dtcm_write && d_port_i_tcm_write_req)
            dmem_next_state = d_itcm_write;
        else if(dmem_state == d_dtcm_write && d_port_d_tcm_read_req)
            dmem_next_state = d_dtcm_read;
        else if(dmem_state == d_dtcm_write && d_port_d_tcm_write_req)
            dmem_next_state = d_dtcm_write;
        else if(dmem_state == d_dtcm_write && d_mem_read_req)
            dmem_next_state = d_dmem_read;
        else if(dmem_state == d_dtcm_write && d_mem_write_req)
            dmem_next_state = d_dmem_write;
        else if(dmem_state == d_dtcm_write)
            dmem_next_state = d_reset;
        
        // Data mem read request
        else if(dmem_state == d_dmem_read && data_axi_arready)
            dmem_next_state = d_dmem_read_ah;
        
        // Data mem read handshake
        else if(dmem_state == d_dmem_read_ah && data_axi_rvalid && d_port_i_tcm_read_req)
            dmem_next_state = d_itcm_read;
        else if(dmem_state == d_dmem_read_ah && data_axi_rvalid && d_port_i_tcm_write_req)
            dmem_next_state = d_itcm_write;
        else if(dmem_state == d_dmem_read_ah && data_axi_rvalid && d_port_d_tcm_read_req)
            dmem_next_state = d_dtcm_read;
        else if(dmem_state == d_dmem_read_ah && data_axi_rvalid && d_port_d_tcm_write_req)
            dmem_next_state = d_dtcm_write;
        else if(dmem_state == d_dmem_read_ah && data_axi_rvalid)
            dmem_next_state = d_reset;
            
        // Data mem write request
        else if(dmem_state == d_dmem_write && data_axi_awready && data_axi_wready)
            dmem_next_state = d_dmem_write_awh;
        else if(dmem_state == d_dmem_write && data_axi_awready)
            dmem_next_state = d_dmem_write_ah;
        
        // Data mem write address handshake
        else if(dmem_state == d_dmem_write_ah && data_axi_wready)
            dmem_next_state = d_dmem_write_awh;
        
        // Data mem write address, data handshake
        else if(dmem_state == d_dmem_write_awh && data_axi_bvalid && d_port_i_tcm_read_req)
            dmem_next_state = d_itcm_read;
        else if(dmem_state == d_dmem_write_awh && data_axi_bvalid && d_port_i_tcm_write_req)
            dmem_next_state = d_itcm_write;
        else if(dmem_state == d_dmem_write_awh && data_axi_bvalid && d_port_d_tcm_read_req)
            dmem_next_state = d_dtcm_read;
        else if(dmem_state == d_dmem_write_awh && data_axi_bvalid && d_port_d_tcm_write_req)
            dmem_next_state = d_dtcm_write;
        else if(dmem_state == d_dmem_write_awh && data_axi_bvalid)
            dmem_next_state = d_reset;
        
        // no transition
        else
            dmem_next_state = dmem_state;
    end
    
    always_ff @(posedge aclk, negedge aresetn)
    begin
        if(aresetn == 0)
            dmem_state <= d_reset;
        else
        begin
            dmem_state <= dmem_next_state;
        end
    end
endmodule
