module core_region_xwt_wrapper
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
    output wire [id_width-1:0]   instr_axi_awid      ,
    output wire [31:0]  instr_axi_awaddr    ,
    output wire [7:0]   instr_axi_awlen     ,
    output wire [2:0]   instr_axi_awsize    ,
    output wire [1:0]   instr_axi_awburst   ,
    output wire [0:0]   instr_axi_awlock    ,
    output wire [3:0]   instr_axi_awcache   ,
    output wire [2:0]   instr_axi_awprot    ,
    output wire [3:0]   instr_axi_awqos     ,
    output wire [3:0]   instr_axi_awregion  ,
    output wire         instr_axi_awvalid   ,
    input  wire         instr_axi_awready   ,
    output wire [id_width-1:0]   instr_axi_wid       ,
    output wire [31:0]  instr_axi_wdata     ,
    output wire [3:0]   instr_axi_wstrb     ,
    output wire         instr_axi_wlast     ,
    output wire         instr_axi_wvalid    ,
    input  wire         instr_axi_wready    ,
    input  wire [id_width-1:0]   instr_axi_bid       ,
    input  wire [1:0]   instr_axi_bresp     ,
    input  wire         instr_axi_bvalid    ,
    output wire         instr_axi_bready    ,
    output wire [id_width-1:0]   instr_axi_arid      ,
    output wire [31:0]  instr_axi_araddr    ,
    output wire [7:0]   instr_axi_arlen     ,
    output wire [2:0]   instr_axi_arsize    ,
    output wire [1:0]   instr_axi_arburst   ,
    output wire [0:0]   instr_axi_arlock    ,
    output wire [3:0]   instr_axi_arcache   ,
    output wire [2:0]   instr_axi_arprot    ,
    output wire [3:0]   instr_axi_arqos     ,
    output wire [3:0]   instr_axi_arregion  ,
    output wire         instr_axi_arvalid   ,
    input  wire         instr_axi_arready   ,
    input  wire [id_width-1:0]   instr_axi_rid       ,
    input  wire [31:0]  instr_axi_rdata     ,
    input  wire [1:0]   instr_axi_rresp     ,
    input  wire         instr_axi_rlast     ,
    input  wire         instr_axi_rvalid    ,
    output wire         instr_axi_rready    ,

    // Data AXI interface
    output wire [id_width-1:0]   data_axi_awid       ,
    output wire [31:0]  data_axi_awaddr     ,
    output wire [7:0]   data_axi_awlen      ,
    output wire [2:0]   data_axi_awsize     ,
    output wire [1:0]   data_axi_awburst    ,
    output wire [0:0]   data_axi_awlock     ,
    output wire [3:0]   data_axi_awcache    ,
    output wire [2:0]   data_axi_awprot     ,
    output wire [3:0]   data_axi_awqos      ,
    output wire [3:0]   data_axi_awregion   ,
    output wire         data_axi_awvalid    ,
    input  wire         data_axi_awready    ,
    output wire [id_width-1:0]   data_axi_wid        ,
    output wire [31:0]  data_axi_wdata      ,
    output wire [3:0]   data_axi_wstrb      ,
    output wire         data_axi_wlast      ,
    output wire         data_axi_wvalid     ,
    input  wire         data_axi_wready     ,
    input  wire [id_width-1:0]   data_axi_bid        ,
    input  wire [1:0]   data_axi_bresp      ,
    input  wire         data_axi_bvalid     ,
    output wire         data_axi_bready     ,
    output wire [id_width-1:0]   data_axi_arid       ,
    output wire [31:0]  data_axi_araddr     ,
    output wire [7:0]   data_axi_arlen      ,
    output wire [2:0]   data_axi_arsize     ,
    output wire [1:0]   data_axi_arburst    ,
    output wire [0:0]   data_axi_arlock     ,
    output wire [3:0]   data_axi_arcache    ,
    output wire [2:0]   data_axi_arprot     ,
    output wire [3:0]   data_axi_arqos      ,
    output wire [3:0]   data_axi_arregion   ,
    output wire         data_axi_arvalid    ,
    input  wire         data_axi_arready    ,
    input  wire [id_width-1:0]   data_axi_rid        ,
    input  wire [31:0]  data_axi_rdata      ,
    input  wire [1:0]   data_axi_rresp      ,
    input  wire         data_axi_rlast      ,
    input  wire         data_axi_rvalid     ,
    output wire         data_axi_rready     ,


    // Interrupt interface
    input  wire             irq,
    input  wire [4:0]       irq_id,
    output wire             irq_ack,
    output wire [4:0]       irq_ack_id,
    input  wire             irq_sec,
    output wire             sec_lvl,

    //snp bus
    output [5:0]             snp_own_sendM_atop   ,
    output                   snp_own_sendM_valid  ,
    output                   snp_own_sendS_valid  ,
    output  [31:0]           snp_own_send_addr    ,
    input                    snp_other_sendM_valid,
    input  [31:0]            snp_other_sendM_addr ,
    input                    snp_bus_exokay       ,
    input                    snp_bus_sc_gnt
);


core_regionx_wtdcache #(
    .id_width               (id_width       ),
    .itcm_start             (itcm_start     ),
    .itcm_size              (itcm_size      ),
    .dtcm_start             (dtcm_start     ),
    .dtcm_size              (dtcm_size      ),
    .boot_addr              (boot_addr      ),
    .core_id                (core_id        ),
    .cluster_id             (cluster_id     )

)core_regionx_wtdcache_U0(
    .aclk                   (aclk                 ),
    .aresetn                (aresetn              ),
    .instr_axi_awid         (instr_axi_awid       ),
    .instr_axi_awaddr       (instr_axi_awaddr     ),
    .instr_axi_awlen        (instr_axi_awlen      ),
    .instr_axi_awsize       (instr_axi_awsize     ),
    .instr_axi_awburst      (instr_axi_awburst    ),
    .instr_axi_awlock       (instr_axi_awlock     ),
    .instr_axi_awcache      (instr_axi_awcache    ),
    .instr_axi_awprot       (instr_axi_awprot     ),
    .instr_axi_awqos        (instr_axi_awqos      ),
    .instr_axi_awregion     (instr_axi_awregion   ),
    .instr_axi_awvalid      (instr_axi_awvalid    ),
    .instr_axi_awready      (instr_axi_awready    ),
    .instr_axi_wid          (instr_axi_wid        ),
    .instr_axi_wdata        (instr_axi_wdata      ),
    .instr_axi_wstrb        (instr_axi_wstrb      ),
    .instr_axi_wlast        (instr_axi_wlast      ),
    .instr_axi_wvalid       (instr_axi_wvalid     ),
    .instr_axi_wready       (instr_axi_wready     ),
    .instr_axi_bid          (instr_axi_bid        ),
    .instr_axi_bresp        (instr_axi_bresp      ),
    .instr_axi_bvalid       (instr_axi_bvalid     ),
    .instr_axi_bready       (instr_axi_bready     ),
    .instr_axi_arid         (instr_axi_arid       ),
    .instr_axi_araddr       (instr_axi_araddr     ),
    .instr_axi_arlen        (instr_axi_arlen      ),
    .instr_axi_arsize       (instr_axi_arsize     ),
    .instr_axi_arburst      (instr_axi_arburst    ),
    .instr_axi_arlock       (instr_axi_arlock     ),
    .instr_axi_arcache      (instr_axi_arcache    ),
    .instr_axi_arprot       (instr_axi_arprot     ),
    .instr_axi_arqos        (instr_axi_arqos      ),
    .instr_axi_arregion     (instr_axi_arregion   ),
    .instr_axi_arvalid      (instr_axi_arvalid    ),
    .instr_axi_arready      (instr_axi_arready    ),
    .instr_axi_rid          (instr_axi_rid        ),
    .instr_axi_rdata        (instr_axi_rdata      ),
    .instr_axi_rresp        (instr_axi_rresp      ),
    .instr_axi_rlast        (instr_axi_rlast      ),
    .instr_axi_rvalid       (instr_axi_rvalid     ),
    .instr_axi_rready       (instr_axi_rready     ),
    .data_axi_awid          (data_axi_awid        ),
    .data_axi_awaddr        (data_axi_awaddr      ),
    .data_axi_awlen         (data_axi_awlen       ),
    .data_axi_awsize        (data_axi_awsize      ),
    .data_axi_awburst       (data_axi_awburst     ),
    .data_axi_awlock        (data_axi_awlock      ),
    .data_axi_awcache       (data_axi_awcache     ),
    .data_axi_awprot        (data_axi_awprot      ),
    .data_axi_awqos         (data_axi_awqos       ),
    .data_axi_awregion      (data_axi_awregion    ),
    .data_axi_awvalid       (data_axi_awvalid     ),
    .data_axi_awready       (data_axi_awready     ),
    .data_axi_wid           (data_axi_wid         ),
    .data_axi_wdata         (data_axi_wdata       ),
    .data_axi_wstrb         (data_axi_wstrb       ),
    .data_axi_wlast         (data_axi_wlast       ),
    .data_axi_wvalid        (data_axi_wvalid      ),
    .data_axi_wready        (data_axi_wready      ),
    .data_axi_bid           (data_axi_bid         ),
    .data_axi_bresp         (data_axi_bresp       ),
    .data_axi_bvalid        (data_axi_bvalid      ),
    .data_axi_bready        (data_axi_bready      ),
    .data_axi_arid          (data_axi_arid        ),
    .data_axi_araddr        (data_axi_araddr      ),
    .data_axi_arlen         (data_axi_arlen       ),
    .data_axi_arsize        (data_axi_arsize      ),
    .data_axi_arburst       (data_axi_arburst     ),
    .data_axi_arlock        (data_axi_arlock      ),
    .data_axi_arcache       (data_axi_arcache     ),
    .data_axi_arprot        (data_axi_arprot      ),
    .data_axi_arqos         (data_axi_arqos       ),
    .data_axi_arregion      (data_axi_arregion    ),
    .data_axi_arvalid       (data_axi_arvalid     ),
    .data_axi_arready       (data_axi_arready     ),
    .data_axi_rid           (data_axi_rid         ),
    .data_axi_rdata         (data_axi_rdata       ),
    .data_axi_rresp         (data_axi_rresp       ),
    .data_axi_rlast         (data_axi_rlast       ),
    .data_axi_rvalid        (data_axi_rvalid      ),
    .data_axi_rready        (data_axi_rready      ),
    .irq                    (irq                  ),
    .irq_id                 (irq_id               ),
    .irq_ack                (irq_ack              ),
    .irq_ack_id             (irq_ack_id           ),
    .irq_sec                (irq_sec              ),
    .sec_lvl                (sec_lvl              )
);

    
endmodule