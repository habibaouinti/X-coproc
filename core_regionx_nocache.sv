`define XTENSION_EN
`include "cv32e40x_if_xif.sv"
module core_regionx_wtdcache import cv32e40x_pkg::*;
#(
    parameter id_width          = 2             ,
    parameter itcm_start        = 32'h2000_0000 ,
    parameter itcm_size         = 4096          ,
    parameter dtcm_start        = 32'h40000000  ,
    parameter dtcm_size         = 4096          ,
    parameter boot_addr         = 32'h00000000  ,
    parameter core_id           = 4'b0000       ,
    parameter cluster_id        = 6'b000000     

)
(
    input wire  aclk,
    input wire  aresetn,
    
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

    // Data AXI interface
    output logic [id_width-1:0]   data_axi_awid       ,
    output logic [31:0]  data_axi_awaddr     ,
    output logic [7:0]   data_axi_awlen      ,
    output logic [2:0]   data_axi_awsize     ,
    output logic [1:0]   data_axi_awburst    ,
    output logic [0:0]   data_axi_awlock     ,
    output logic [3:0]   data_axi_awcache    ,
    output logic [2:0]   data_axi_awprot     ,
    output logic [3:0]   data_axi_awqos      ,
    output logic [3:0]   data_axi_awregion   ,
    output logic         data_axi_awvalid    ,
    input  logic         data_axi_awready    ,
    output logic [id_width-1:0]   data_axi_wid        ,
    output logic [31:0]  data_axi_wdata      ,
    output logic [3:0]   data_axi_wstrb      ,
    output logic         data_axi_wlast      ,
    output logic         data_axi_wvalid     ,
    input  logic         data_axi_wready     ,
    input  logic [id_width-1:0]   data_axi_bid        ,
    input  logic [1:0]   data_axi_bresp      ,
    input  logic         data_axi_bvalid     ,
    output logic         data_axi_bready     ,
    output logic [1:0]   data_axi_arid       ,
    output logic [31:0]  data_axi_araddr     ,
    output logic [7:0]   data_axi_arlen      ,
    output logic [2:0]   data_axi_arsize     ,
    output logic [1:0]   data_axi_arburst    ,
    output logic [0:0]   data_axi_arlock     ,
    output logic [3:0]   data_axi_arcache    ,
    output logic [2:0]   data_axi_arprot     ,
    output logic [3:0]   data_axi_arqos      ,
    output logic [3:0]   data_axi_arregion   ,
    output logic         data_axi_arvalid    ,
    input  logic         data_axi_arready    ,
    input  logic [id_width-1:0]   data_axi_rid        ,
    input  logic [31:0]  data_axi_rdata      ,
    input  logic [1:0]   data_axi_rresp      ,
    input  logic         data_axi_rlast      ,
    input  logic         data_axi_rvalid     ,
    output logic         data_axi_rready     ,

    // Interrupt interface
    input  wire             irq,
    input  wire [4:0]       irq_id,
    output wire             irq_ack,
    output wire [4:0]       irq_ack_id,
    input  wire             irq_sec,
    output wire             sec_lvl
);

    // Pulp I port signals
    wire [31:0] iaddress;
    wire [31:0] idata;
    wire        ireq;
    wire        igrant;
    wire        ivalid;
    wire [1:0]  imemtype;
    wire [2:0]  iprot;
    
    // Pulp D port signals
    wire [31:0] daddress;
    wire [31:0] dwdata;
    wire        dreq;
    wire        dgrant;
    wire        dvalid;
    wire [31:0] drdata;
    wire        dwnr;
    wire [3:0]  dbe;
    wire [5:0]  datop;
    wire        dexokay;
    wire        derr;
    wire [1:0]  dmemtype;
    wire [2:0]  dprot;
    
    // ITCM signals
    wire [31:0] i_tcm_address;
    wire        i_tcm_req;
    wire [31:0] i_tcm_read_data;
    wire        i_tcm_grant;
    wire        i_tcm_valid;
    
    wire [31:0] d_itcm_address;
    wire        d_itcm_req;
    wire        d_itcm_write_en;
    wire [3:0]  d_itcm_write_be;
    wire [31:0] d_itcm_write_data;
    wire [31:0] d_itcm_read_data;
    wire        d_itcm_grant;
    wire        d_itcm_valid;
    
    // DTCM signals
    wire [31:0] d_tcm_address;
    wire d_tcm_req;
    wire d_tcm_write_en;
    wire [3:0] d_tcm_write_be;
    wire [31:0] d_tcm_write_data;
    wire [31:0] d_tcm_read_data;
    wire d_tcm_grant;
    wire d_tcm_valid;



    
    //todo: axi interface
    // Instantiation of components
    instr_bridge
    #(
        .id_width           (id_width   ),
        .itcm_start         (itcm_start ),
        .itcm_size          (itcm_size  )
    )
    instr_bridge_i
    (
        .aclk               (aclk   ),
        .aresetn            (aresetn),
            
        // Instr AXI Lite interface
        .instr_axi_awid    (instr_axi_awid    ),
        .instr_axi_awaddr  (instr_axi_awaddr  ),
        .instr_axi_awlen   (instr_axi_awlen   ),
        .instr_axi_awsize  (instr_axi_awsize  ),
        .instr_axi_awburst (instr_axi_awburst ),
        .instr_axi_awlock  (instr_axi_awlock  ),
        .instr_axi_awcache (instr_axi_awcache ),
        .instr_axi_awprot  (instr_axi_awprot  ),
        .instr_axi_awqos   (instr_axi_awqos   ),
        .instr_axi_awregion(instr_axi_awregion),
        .instr_axi_awvalid (instr_axi_awvalid ),
        .instr_axi_awready (instr_axi_awready ),
        .instr_axi_wid     (instr_axi_wid     ),
        .instr_axi_wdata   (instr_axi_wdata   ),
        .instr_axi_wstrb   (instr_axi_wstrb   ),
        .instr_axi_wlast   (instr_axi_wlast   ),
        .instr_axi_wvalid  (instr_axi_wvalid  ),
        .instr_axi_wready  (instr_axi_wready  ),
        .instr_axi_bid     (instr_axi_bid     ),
        .instr_axi_bresp   (instr_axi_bresp   ),
        .instr_axi_bvalid  (instr_axi_bvalid  ),
        .instr_axi_bready  (instr_axi_bready  ),
        .instr_axi_arid    (instr_axi_arid    ),
        .instr_axi_araddr  (instr_axi_araddr  ),
        .instr_axi_arlen   (instr_axi_arlen   ),
        .instr_axi_arsize  (instr_axi_arsize  ),
        .instr_axi_arburst (instr_axi_arburst ),
        .instr_axi_arlock  (instr_axi_arlock  ),
        .instr_axi_arcache (instr_axi_arcache ),
        .instr_axi_arprot  (instr_axi_arprot  ),
        .instr_axi_arqos   (instr_axi_arqos   ),
        .instr_axi_arregion(instr_axi_arregion),
        .instr_axi_arvalid (instr_axi_arvalid ),
        .instr_axi_arready (instr_axi_arready ),
        .instr_axi_rid     (instr_axi_rid     ),
        .instr_axi_rdata   (instr_axi_rdata   ),
        .instr_axi_rresp   (instr_axi_rresp   ),
        .instr_axi_rlast   (instr_axi_rlast   ),
        .instr_axi_rvalid  (instr_axi_rvalid  ),
        .instr_axi_rready  (instr_axi_rready  ),
            
        // Pulp I port signals
        .iaddress           (iaddress),
        .idata              (idata),
        .ireq               (ireq),
        .igrant             (igrant),
        .ivalid             (ivalid),
            
        // ITCM signals
        .i_tcm_address      (i_tcm_address),
        .i_tcm_req          (i_tcm_req),
        .i_tcm_read_data    (i_tcm_read_data),
        .i_tcm_grant        (i_tcm_grant),
        .i_tcm_valid        (i_tcm_valid)
    );
    
// todo: change interface
    data_bridge
    #(
        .itcm_start     (itcm_start),
        .itcm_size      (itcm_size),
        .dtcm_start     (dtcm_start),
        .dtcm_size      (dtcm_size)
    )
    data_bridge_i
    (
        .aclk           (aclk),
        .aresetn        (aresetn),
        
        // Data AXI interface
        .data_axi_awid     (data_axi_awid     ),
        .data_axi_awaddr   (data_axi_awaddr   ),
        .data_axi_awlen    (data_axi_awlen    ),
        .data_axi_awsize   (data_axi_awsize   ),
        .data_axi_awburst  (data_axi_awburst  ),
        .data_axi_awlock   (data_axi_awlock   ),
        .data_axi_awcache  (data_axi_awcache  ),
        .data_axi_awprot   (data_axi_awprot   ),
        .data_axi_awqos    (data_axi_awqos    ),
        .data_axi_awregion (data_axi_awregion ),
        .data_axi_awvalid  (data_axi_awvalid  ),
        .data_axi_awready  (data_axi_awready  ),
        .data_axi_wid      (data_axi_wid      ),
        .data_axi_wdata    (data_axi_wdata    ),
        .data_axi_wstrb    (data_axi_wstrb    ),
        .data_axi_wlast    (data_axi_wlast    ),
        .data_axi_wvalid   (data_axi_wvalid   ),
        .data_axi_wready   (data_axi_wready   ),
        .data_axi_bid      (data_axi_bid      ),
        .data_axi_bresp    (data_axi_bresp    ),
        .data_axi_bvalid   (data_axi_bvalid   ),
        .data_axi_bready   (data_axi_bready   ),
        .data_axi_arid     (data_axi_arid     ),
        .data_axi_araddr   (data_axi_araddr   ),
        .data_axi_arlen    (data_axi_arlen    ),
        .data_axi_arsize   (data_axi_arsize   ),
        .data_axi_arburst  (data_axi_arburst  ),
        .data_axi_arlock   (data_axi_arlock   ),
        .data_axi_arcache  (data_axi_arcache  ),
        .data_axi_arprot   (data_axi_arprot   ),
        .data_axi_arqos    (data_axi_arqos    ),
        .data_axi_arregion (data_axi_arregion ),
        .data_axi_arvalid  (data_axi_arvalid  ),
        .data_axi_arready  (data_axi_arready  ),
        .data_axi_rid      (data_axi_rid      ),
        .data_axi_rdata    (data_axi_rdata    ),
        .data_axi_rresp    (data_axi_rresp    ),
        .data_axi_rlast    (data_axi_rlast    ),
        .data_axi_rvalid   (data_axi_rvalid   ),
        .data_axi_rready   (data_axi_rready   ),
        
         // Pulp D port signals
        .daddress           (daddress),
        .dwdata             (dwdata),
        .dreq               (dreq),
        .dgrant             (dgrant),
        .dvalid             (dvalid),
        .drdata             (drdata),
        .dwnr               (dwnr),
        .dbe                (dbe),
        .datop              (datop),
        .derr               (derr), //bus error
        .dexokay            (dexokay),
        .flush_ack          (flush_ack),
        .flush_req          (flush_req),
        
        // ITCM signals
        .i_tcm_address      (d_itcm_address),
        .i_tcm_req          (d_itcm_req),
        .i_tcm_write_en     (d_itcm_write_en),
        .i_tcm_write_be     (d_itcm_write_be),
        .i_tcm_write_data   (d_itcm_write_data),
        .i_tcm_read_data    (d_itcm_read_data),
        .i_tcm_grant        (d_itcm_grant),
        .i_tcm_valid        (d_itcm_valid),
        
        // DTCM signals
        .d_tcm_address      (d_tcm_address),
        .d_tcm_req          (d_tcm_req),
        .d_tcm_write_en     (d_tcm_write_en),
        .d_tcm_write_be     (d_tcm_write_be),
        .d_tcm_write_data   (d_tcm_write_data),
        .d_tcm_read_data    (d_tcm_read_data),
        .d_tcm_grant        (d_tcm_grant),
        .d_tcm_valid        (d_tcm_valid)
    );
    
    
    dual_port_tcm_ram
    #(
        .start_address      (itcm_start ),
        .size               (itcm_size  )
    )
    i_tcm_ram
    (
        .aclk               (aclk       ),
        .aresetn            (aresetn    ),
        
        .address_a          (i_tcm_address  ),
        .request_a          (i_tcm_req      ),
        .read_data_a        (i_tcm_read_data),
        .grant_a            (i_tcm_grant    ),
        .valid_a            (i_tcm_valid    ),
        
        .address_b          (d_itcm_address     ),
        .request_b          (d_itcm_req         ),
        .write_enable_b     (d_itcm_write_en    ),
        .write_byte_enable_b(d_itcm_write_be    ),
        .write_data_b       (d_itcm_write_data  ),
        .read_data_b        (d_itcm_read_data   ),
        .grant_b            (d_itcm_grant       ),
        .valid_b            (d_itcm_valid       )
    );
    
      // eXtension interface
  cv32e40x_if_xif ext_if ();
    // tcm_ram
    // #(
    //     .start_address(dtcm_start),
    //     .size(dtcm_size)
    // )
    // d_tcm_ram
    // (
    //     .aclk(aclk),
    //     .aresetn(aresetn),
        
    //     .address(d_tcm_address),
    //     .request(d_tcm_req),
    //     .write_enable(d_tcm_write_en),
    //     .write_byte_enable(d_tcm_write_be),
    //     .write_data(d_tcm_write_data),
    //     .read_data(d_tcm_read_data),
    //     .grant(d_tcm_grant),
    //     .valid(d_tcm_valid)
    // );
cv32e40x_core #(
    .LIB                        (            '0 ), //Standard cell library
    .RV32                       (        RV32I ), //choose RV32I or RV32E
    .A_EXT                      (        A_NONE), //enable Atomic Instruction (A) support.
                                                  //A_EXT = A_NONE: No Atomic instructions supported. 
                                                  //A_EXT = ZALRSC: Only LR.W and SC.W instructions supported. 
                                                  //A_EXT = A: Full A extension supported.
    .B_EXT                      (       B_NONE ), //enable Bit Manipulation support
    .M_EXT                      (            M ), //enable Multiply / Divide support.
//eXtension interface
    .X_EXT                      (           '1 ), //enable eXtension Interface (X) support, not enables
    .X_NUM_RS                   (            2 ), //number of register file read ports that can be used by the eXtension interface.
    .X_ID_WIDTH                 (            4 ),
    .X_MEM_WIDTH                (           32 ),
    .X_RFR_WIDTH                (           32 ),
    .X_RFW_WIDTH                (           32 ),
    .X_MISA                     (        32'h0 ),
    .X_ECS_XS                   (         2'b0 ),
//debug interface
    .DEBUG                      (            '0 ), //not enabled
    .DM_REGION_START            ( 32'hF0000000 ),
    .DM_REGION_END              ( 32'hF0003FFF ),
    .DBG_NUM_TRIGGERS           (            1 ),
//performance counter
    .NUM_MHPMCOUNTERS           (            1 ),
//physical memory attribution
    .PMA_NUM_REGIONS            (            1 ), //only 1 main memory
    .PMA_CFG                    ('{PMA_R_CONFIG}), //PMA_R_CONFIG
//CLIC  
    .CLIC                       (            '0 ), // enable CLINT
    .CLIC_ID_WIDTH              (            5 )
) u_core (
    // Clock and reset
    .clk_i                    (aclk         ),
    .rst_ni                   (aresetn      ),
    .scan_cg_en_i             ('0            ),//scan clock gate enable, DUT related

    // Configuration
    .boot_addr_i              (boot_addr    ),
    .mtvec_addr_i             ('0            ),
    .dm_halt_addr_i           ('0            ),//Address to jump to when entering Debug Mode
    .dm_exception_addr_i      ('0            ),//Address to jump to when an exception occurs when executing code during Debug Mode
    .mhartid_i                (core_id      ),//Hart ID, usually static
    .mimpid_patch_i           ('0            ),//Implementation ID patch. Must be static.     

    // Instruction memory interface
    .instr_req_o              (ireq         ),
    .instr_gnt_i              (igrant       ),
    .instr_addr_o             (iaddress     ),
    .instr_memtype_o          (imemtype     ),//to instr_bridge, Memory Type attributes (cacheable, bufferable)
    .instr_prot_o             (iprot        ),//to instr_bridge, Protection attributes
    .instr_dbg_o              (             ),//Debug mode access
    .instr_rvalid_i           (ivalid       ),
    .instr_rdata_i            (idata        ),
    .instr_err_i              ('0            ),

    // Data memory interface
    .data_req_o               (dreq         ),
    .data_gnt_i               (dgrant       ),
    .data_addr_o              (daddress     ),
    .data_atop_o              (datop        ),//sent together with data_req_o.
    .data_be_o                (dbe          ),
    .data_memtype_o           (dmemtype     ),//Memory Type attributes (cacheable, bufferable), sent together with data_req_o.
    .data_prot_o              (dprot        ),//Protection attributes
    .data_dbg_o               (             ),//Debug mode access
    .data_wdata_o             (dwdata       ),
    .data_we_o                (dwnr         ),
    .data_rvalid_i            (dvalid       ),
    .data_rdata_i             (drdata       ),
    .data_err_i               ('0            ),//todo: A data interface error occurred
    .data_exokay_i            ('0            ),//todo: Exclusive transaction status(for LR/SC)

    // Cycle, Time
    .mcycle_o                 (             ),
    .time_i                   ('0            ),
         // eXtension interface
    .xif_compressed_if        (ext_if),
    .xif_issue_if             (ext_if),
    .xif_commit_if            (ext_if),
    .xif_mem_if               (ext_if),
    .xif_mem_result_if        (ext_if),
    .xif_result_if            (ext_if),

     // Interrupt interface
    .irq_i                    (irq          ),

    .clic_irq_i               ('0            ),//disabled
    .clic_irq_id_i            ('0            ),
    .clic_irq_level_i         ('0            ),
    .clic_irq_priv_i          ('0            ),
    .clic_irq_shv_i           ('0            ),

    // Fencei flush handshake
    .fencei_flush_req_o       (flush_req    ),//to flush external cache
    .fencei_flush_ack_i       (flush_ack    ),

    // Debug interface
    .debug_req_i              ('0            ), //disabled
    .debug_havereset_o        (             ),
    .debug_running_o          (             ),
    .debug_halted_o           (             ),
    .debug_pc_valid_o         (             ),
    .debug_pc_o               (             ),

    // Special control signals
    .fetch_enable_i           (1'b1         ),
    .core_sleep_o             (             ),
    .wu_wfe_i                 (1'b1         )//Wake-up signal for custom wfe instruction. 
);


      coprocessor copro0 (
        .clk_i          ( aclk  ),
        .rst_ni         ( aresetn ),
        .xif_compressed ( ext_if ),
        .xif_issue      ( ext_if ),
        .xif_commit     ( ext_if ),
        .xif_mem        ( ext_if ),
        .xif_mem_result ( ext_if ),
        .xif_result     ( ext_if )
    );
/*      coproc_unit coproc(
        .clk_i                    (aclk         ),
        .rst_ni                   (aresetn      ),
         // eXtension interface
    .xif_compressed_if        (ext_if),
    .xif_issue_if             (ext_if),
    .xif_commit_if            (ext_if),
    .xif_mem_if               (ext_if),
    .xif_mem_result_if        (ext_if),
    .xif_result_if            (ext_if)

        );*/
    
///////////////////////////////////

`ifdef EVAL
reg [31:0] mem_cycle;
reg [31:0] mem_cnt;
reg mem_cnt_en;

wire start_en;
reg reg_start;

assign start_en = (daddress == 'h10000060) && dreq && dwnr;


always @(posedge aclk, negedge aresetn) begin
    if(!aresetn) begin
        reg_start <= 'b0;
    end
    else if (start_en) begin
        reg_start <= 1'b1;
    end

    if (!aresetn) begin
        mem_cnt <= 'b0;
        // mem_cnt_en <= 'b0;
    end
    else if(reg_start && dreq && dgrant) begin
        mem_cnt <= mem_cnt + 1;
        // mem_cnt_en <= 'b1;
    end

    if(!aresetn) begin
        mem_cnt_en <= 'b0;
    end
    else if (reg_start && dreq) begin
        mem_cnt_en <= 'b1;
    end
    else if (reg_start && dvalid) begin
        mem_cnt_en <= 'b0;
    end

    if(!aresetn) begin
        mem_cycle <= 'b0;
    end
    if (mem_cnt_en) begin
        mem_cycle <= mem_cycle + 1;
    end
    
end

`endif
////////////////////////////////
endmodule

module dummy_extension import cvxif_pkg::*;

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

    //Instantiate accelerator top and adaptor
    wire  [3:0]  id;
    wire         req_valid;
    wire  [31:0] instr;
    wire  [31:0] rs1,rs2;
    wire   [4:0] rd;

    //Pack the x interface
    //assign input output
   
    //COMPRESSED INTERFACE - NOT USED
    assign xif_compressed.compressed_ready = '0;
    assign xif_compressed.compressed_resp  = '0;

    //ISSUE INTERFACE
    assign req_valid = xif_issue.issue_valid;
    assign id = xif_issue.issue_req.id;
    assign instr = xif_issue.issue_req.instr; //Contains instr
    assign rs1 = xif_issue.issue_req.rs[0]; //register operand 1
    assign rs2 = xif_issue.issue_req.rs[1]; //register operand 2
    assign xif_issue.issue_ready = '1; 
    assign rd = instr[11:7];
      //Commit interface
//  logic               x_commit_valid_i;
//  x_commit_t          x_commit_i;
    logic sel;
//    reg mask ;
//    assign mask = 32'b11111110000000000111000001111111 ;
//    assign sel = (instr & 32'hfe00707f == 32'h200000b); 
      assign sel = (instr[6:0] == 7'b0001011);
always_comb begin
    xif_issue.issue_resp.accept    = '0;
    xif_issue.issue_resp.writeback = '0;
    xif_issue.issue_resp.dualwrite = '0;
    xif_issue.issue_resp.dualread  = '0;
    xif_issue.issue_resp.loadstore = '0;
    xif_issue.issue_resp.ecswrite  = '0;
    xif_issue.issue_resp.exc       = '0;
      if (sel) begin
        xif_issue.issue_resp.accept     = '1;
        xif_issue.issue_resp.writeback  = '1;
        xif_issue.issue_resp.dualwrite  = '0;
        xif_issue.issue_resp.dualread   = '0;
        xif_issue.issue_resp.loadstore  = '0;
        xif_issue.issue_resp.ecswrite   = '0;
        xif_issue.issue_resp.exc        = '0;
      end
  end

    //COMMIT INTERFACE
//    assign x_commit_valid_i                = xif_commit.commit_valid;
//    assign x_commit_i                      = xif_commit.commit;

    assign xif_mem.mem_valid               = '0;
    assign xif_mem.mem_req                 = '0;
//    assign xif_result.result_valid         = xif_result.result_ready;
    //RESULT INTERFACE
    assign xif_result.result_valid = '1;
    assign xif_result.result.id = id;
    assign xif_result.result.data = 10;
    assign xif_result.result.rd = rd;
    assign xif_result.result.we = '1;
    assign xif_result.result.exc = '0;
    assign xif_result.result.exccode = '0;

endmodule
