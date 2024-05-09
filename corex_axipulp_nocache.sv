import axi_pkg::*;
`include "typedef.svh"

module corex_axipulp_wtdcache 
import cf_math_pkg::idx_width;
#(
    parameter                CORE_NUM           = 1             ,
    parameter                itcm_start         = 32'h2000_0000 ,
    parameter                itcm_size          = 4096          ,
    parameter                dtcm_start         = 32'h40000000  ,
    parameter                dtcm_size          = 4096          ,
    parameter                boot_addr          = 32'h00000000   ,
    parameter                cluster_id         = 6'b000000      ,
    parameter int unsigned   AXI_USER_WIDTH     = 0             ,
    parameter int unsigned   NoSlvPorts         = 2    ,   /// increae it to add more peripheral 
    parameter int unsigned   NoMstPorts         = 6            ,
    parameter int unsigned   MaxMstTrans        = 6             ,
    parameter int unsigned   MaxSlvTrans        = 6             ,
    parameter bit            FallThrough        = 1             ,
    parameter axi_pkg::xbar_latency_e LatencyMode  = NO_LATENCY ,
    parameter int unsigned   PipelineStages     = 0             ,
    parameter int unsigned   AxiIdWidthSlvPorts = 5             ,
    parameter int unsigned   AxiIdUsedSlvPorts  = 1             ,
    parameter bit            UniqueIds          = 'b0           ,
    parameter int unsigned   AxiAddrWidth       = 32            ,
    parameter int unsigned   AxiDataWidth       = 32            ,
    parameter int unsigned   NoAddrRules        = 6             , /// increase it to add more peripheral 
    parameter bit            ATOPS              = 1'b0          ,
    parameter bit [NoSlvPorts-1:0][NoMstPorts-1:0] CONNECTIVITY = '1,
    parameter type rule_t                       = axi_pkg::xbar_rule_32_t
)(
    input   aclk,
    input   aresetn,
//from axi to bram_ctrl_0
	output logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]  axi_awid_0,
    output logic [31:0]                axi_awaddr_0              ,
    output logic [7:0]                 axi_awlen_0               ,
    output logic [2:0]                 axi_awsize_0              ,
    output logic [1:0]                 axi_awburst_0             ,
    output logic [0:0]                 axi_awlock_0              ,
    output logic [3:0]                 axi_awcache_0             ,
    output logic [2:0]                 axi_awprot_0              ,
    output logic [3:0]                 axi_awqos_0               ,
    output logic [3:0]                 axi_awregion_0            ,
    output logic                       axi_awvalid_0             ,
    input  logic                       axi_awready_0             ,
    output logic [31:0]                axi_wdata_0               ,
    output logic [3:0]                 axi_wstrb_0               ,
    output logic                       axi_wlast_0               ,
    output logic                       axi_wvalid_0              ,
    input  logic                       axi_wready_0              ,
    input  logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_bid_0                 ,
    input  logic [1:0]                 axi_bresp_0               ,
    input  logic                       axi_bvalid_0              ,
    output logic                       axi_bready_0              ,
    output logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_arid_0                ,
    output logic [31:0]                axi_araddr_0              ,
    output logic [7:0]                 axi_arlen_0               ,
    output logic [2:0]                 axi_arsize_0              ,
    output logic [1:0]                 axi_arburst_0             ,
    output logic [0:0]                 axi_arlock_0              ,
    output logic [3:0]                 axi_arcache_0             ,
    output logic [2:0]                 axi_arprot_0              ,
    output logic [3:0]                 axi_arqos_0               ,
    output logic [3:0]                 axi_arregion_0            ,
    output logic                       axi_arvalid_0             ,
    input  logic                       axi_arready_0             ,
    input  logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_rid_0                 ,
    input  logic [31:0]                axi_rdata_0               ,
    input  logic [1:0]                 axi_rresp_0               ,
    input  logic                       axi_rlast_0               ,
    input  logic                       axi_rvalid_0              ,
    output logic                       axi_rready_0              ,
//from axi to bram_ctrl_1
	output logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_awid_1                ,
    output logic [31:0]                axi_awaddr_1              ,
    output logic [7:0]                 axi_awlen_1               ,
    output logic [2:0]                 axi_awsize_1              ,
    output logic [1:0]                 axi_awburst_1             ,
    output logic [0:0]                 axi_awlock_1              ,
    output logic [3:0]                 axi_awcache_1             ,
    output logic [2:0]                 axi_awprot_1              ,
    output logic [3:0]                 axi_awqos_1               ,
    output logic [3:0]                 axi_awregion_1            ,
    output logic                       axi_awvalid_1             ,
    input  logic                       axi_awready_1             ,
    output logic [31:0]                axi_wdata_1               ,
    output logic [3:0]                 axi_wstrb_1               ,
    output logic                       axi_wlast_1               ,
    output logic                       axi_wvalid_1              ,
    input  logic                       axi_wready_1              ,
    input  logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_bid_1                 ,
    input  logic [1:0]                 axi_bresp_1               ,
    input  logic                       axi_bvalid_1              ,
    output logic                       axi_bready_1              ,
    output logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_arid_1                ,
    output logic [31:0]                axi_araddr_1              ,
    output logic [7:0]                 axi_arlen_1               ,
    output logic [2:0]                 axi_arsize_1              ,
    output logic [1:0]                 axi_arburst_1             ,
    output logic [0:0]                 axi_arlock_1              ,
    output logic [3:0]                 axi_arcache_1             ,
    output logic [2:0]                 axi_arprot_1              ,
    output logic [3:0]                 axi_arqos_1               ,
    output logic [3:0]                 axi_arregion_1            ,
    output logic                       axi_arvalid_1             ,
    input  logic                       axi_arready_1             ,
    input  logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_rid_1                 ,
    input  logic [31:0]                axi_rdata_1               ,
    input  logic [1:0]                 axi_rresp_1               ,
    input  logic                       axi_rlast_1               ,
    input  logic                       axi_rvalid_1              ,
    output logic                       axi_rready_1              ,
    
    //from axi to peripheral_1
	output logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_awid_2                ,
    output logic [31:0]                axi_awaddr_2              ,
    output logic [7:0]                 axi_awlen_2               ,
    output logic [2:0]                 axi_awsize_2              ,
    output logic [1:0]                 axi_awburst_2             ,
    output logic [0:0]                 axi_awlock_2              ,
    output logic [3:0]                 axi_awcache_2             ,
    output logic [2:0]                 axi_awprot_2              ,
    output logic [3:0]                 axi_awqos_2               ,
    output logic [3:0]                 axi_awregion_2            ,
    output logic                       axi_awvalid_2             ,
    input  logic                       axi_awready_2             ,
    output logic [31:0]                axi_wdata_2               ,
    output logic [3:0]                 axi_wstrb_2               ,
    output logic                       axi_wlast_2               ,
    output logic                       axi_wvalid_2              ,
    input  logic                       axi_wready_2              ,
    input  logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_bid_2                 ,
    input  logic [1:0]                 axi_bresp_2               ,
    input  logic                       axi_bvalid_2              ,
    output logic                       axi_bready_2              ,
    output logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_arid_2                ,
    output logic [31:0]                axi_araddr_2              ,
    output logic [7:0]                 axi_arlen_2               ,
    output logic [2:0]                 axi_arsize_2              ,
    output logic [1:0]                 axi_arburst_2             ,
    output logic [0:0]                 axi_arlock_2              ,
    output logic [3:0]                 axi_arcache_2             ,
    output logic [2:0]                 axi_arprot_2              ,
    output logic [3:0]                 axi_arqos_2              ,
    output logic [3:0]                 axi_arregion_2            ,
    output logic                       axi_arvalid_2             ,
    input  logic                       axi_arready_2             ,
    input  logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_rid_2                 ,
    input  logic [31:0]                axi_rdata_2               ,
    input  logic [1:0]                 axi_rresp_2               ,
    input  logic                       axi_rlast_2               ,
    input  logic                       axi_rvalid_2              ,
    output logic                       axi_rready_2              ,
        //from axi to peripheral_2
	output logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_awid_3                ,
    output logic [31:0]                axi_awaddr_3              ,
    output logic [7:0]                 axi_awlen_3               ,
    output logic [2:0]                 axi_awsize_3              ,
    output logic [1:0]                 axi_awburst_3             ,
    output logic [0:0]                 axi_awlock_3              ,
    output logic [3:0]                 axi_awcache_3             ,
    output logic [2:0]                 axi_awprot_3              ,
    output logic [3:0]                 axi_awqos_3               ,
    output logic [3:0]                 axi_awregion_3            ,
    output logic                       axi_awvalid_3             ,
    input  logic                       axi_awready_3             ,
    output logic [31:0]                axi_wdata_3               ,
    output logic [3:0]                 axi_wstrb_3               ,
    output logic                       axi_wlast_3               ,
    output logic                       axi_wvalid_3              ,
    input  logic                       axi_wready_3              ,
    input  logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_bid_3                 ,
    input  logic [1:0]                 axi_bresp_3               ,
    input  logic                       axi_bvalid_3              ,
    output logic                       axi_bready_3              ,
    output logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_arid_3                ,
    output logic [31:0]                axi_araddr_3              ,
    output logic [7:0]                 axi_arlen_3              ,
    output logic [2:0]                 axi_arsize_3              ,
    output logic [1:0]                 axi_arburst_3             ,
    output logic [0:0]                 axi_arlock_3              ,
    output logic [3:0]                 axi_arcache_3             ,
    output logic [2:0]                 axi_arprot_3              ,
    output logic [3:0]                 axi_arqos_3              ,
    output logic [3:0]                 axi_arregion_3            ,
    output logic                       axi_arvalid_3             ,
    input  logic                       axi_arready_3             ,
    input  logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_rid_3                 ,
    input  logic [31:0]                axi_rdata_3               ,
    input  logic [1:0]                 axi_rresp_3               ,
    input  logic                       axi_rlast_3               ,
    input  logic                       axi_rvalid_3              ,
    output logic                       axi_rready_3              ,
    
            //from axi to peripheral_3
	output logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_awid_4                ,
    output logic [31:0]                axi_awaddr_4              ,
    output logic [7:0]                 axi_awlen_4               ,
    output logic [2:0]                 axi_awsize_4              ,
    output logic [1:0]                 axi_awburst_4             ,
    output logic [0:0]                 axi_awlock_4              ,
    output logic [3:0]                 axi_awcache_4             ,
    output logic [2:0]                 axi_awprot_4              ,
    output logic [3:0]                 axi_awqos_4               ,
    output logic [3:0]                 axi_awregion_4            ,
    output logic                       axi_awvalid_4             ,
    input  logic                       axi_awready_4             ,
    output logic [31:0]                axi_wdata_4               ,
    output logic [3:0]                 axi_wstrb_4               ,
    output logic                       axi_wlast_4               ,
    output logic                       axi_wvalid_4              ,
    input  logic                       axi_wready_4              ,
    input  logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_bid_4                 ,
    input  logic [1:0]                 axi_bresp_4               ,
    input  logic                       axi_bvalid_4              ,
    output logic                       axi_bready_4              ,
    output logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_arid_4                ,
    output logic [31:0]                axi_araddr_4              ,
    output logic [7:0]                 axi_arlen_4             ,
    output logic [2:0]                 axi_arsize_4              ,
    output logic [1:0]                 axi_arburst_4             ,
    output logic [0:0]                 axi_arlock_4              ,
    output logic [3:0]                 axi_arcache_4             ,
    output logic [2:0]                 axi_arprot_4              ,
    output logic [3:0]                 axi_arqos_4              ,
    output logic [3:0]                 axi_arregion_4            ,
    output logic                       axi_arvalid_4             ,
    input  logic                       axi_arready_4             ,
    input  logic [AxiIdWidthSlvPorts + $clog2(NoSlvPorts)-1:0]                 axi_rid_4                 ,
    input  logic [31:0]                axi_rdata_4               ,
    input  logic [1:0]                 axi_rresp_4               ,
    input  logic                       axi_rlast_4               ,
    input  logic                       axi_rvalid_4              ,
    output logic                       axi_rready_4              
);
    localparam axi_pkg::xbar_cfg_t Cfg = {
        NoSlvPorts        ,
        NoMstPorts        ,
        MaxMstTrans       ,     
        MaxSlvTrans       ,  
        FallThrough       , 
        LatencyMode       , 
        PipelineStages , 
        AxiIdWidthSlvPorts ,
        AxiIdUsedSlvPorts   ,
        UniqueIds          ,
        AxiAddrWidth    ,    
        AxiDataWidth    ,
        NoAddrRules        
    };


    logic [CORE_NUM-1:0]      intr_irq               ;
    logic [CORE_NUM-1:0]      intr_irq_ack           ;
    logic [CORE_NUM-1:0][4:0] intr_irq_ack_id        ;   
    logic [CORE_NUM-1:0][4:0] intr_irq_id            ;
    logic [CORE_NUM-1:0]      intr_sec               ;
    logic [CORE_NUM-1:0]      intr_sec_lvl           ;
    

    rule_t [NoAddrRules-1:0]  addr_map_i;
//// peripheral start addreses and length
    assign addr_map_i[0] = {
        'h0,      
        'h0000_0000,      
        'h0003_ffff   
    };
    assign addr_map_i[1] = {
        'h1,      
        'h1000_0000,      
        'h107f_ffff   
    };
    assign addr_map_i[2] = {
        'h2,      
        'h8000_0000,      
        'h8000_0fff   
    };

    assign addr_map_i[3] = {
        'h3,      
        'h9000_0000,      
        'hd07f_ffff   
    };
    
   assign addr_map_i[4] = {
        'h4,      
        'he000_0000,      
        'he07f_ffff   
    };
    
        
   assign addr_map_i[5] = {
        'h5,      
        'hf000_0000,      
        'hf07f_ffff   
    };


 localparam int unsigned AxiIdWidthMstPorts = Cfg.AxiIdWidthSlvPorts + $clog2(Cfg.NoSlvPorts);
 //localparam int unsigned AxiIdWidthMstPorts = 10;
 typedef logic [AxiIdWidthMstPorts     -1:0] id_mst_t;
 typedef logic [Cfg.AxiIdWidthSlvPorts -1:0] id_slv_t;
 typedef logic [Cfg.AxiAddrWidth       -1:0] addr_t;
 typedef logic [Cfg.AxiDataWidth       -1:0] data_t;
 typedef logic [Cfg.AxiDataWidth/8     -1:0] strb_t;
 typedef logic [AXI_USER_WIDTH         -1:0] user_t;

 `AXI_TYPEDEF_AW_CHAN_T(mst_aw_chan_t, addr_t, id_mst_t, user_t)
 `AXI_TYPEDEF_AW_CHAN_T(slv_aw_chan_t, addr_t, id_slv_t, user_t)
 `AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)
 `AXI_TYPEDEF_B_CHAN_T(mst_b_chan_t, id_mst_t, user_t)
 `AXI_TYPEDEF_B_CHAN_T(slv_b_chan_t, id_slv_t, user_t)
 `AXI_TYPEDEF_AR_CHAN_T(mst_ar_chan_t, addr_t, id_mst_t, user_t)
 `AXI_TYPEDEF_AR_CHAN_T(slv_ar_chan_t, addr_t, id_slv_t, user_t)
 `AXI_TYPEDEF_R_CHAN_T(mst_r_chan_t, data_t, id_mst_t, user_t)
 `AXI_TYPEDEF_R_CHAN_T(slv_r_chan_t, data_t, id_slv_t, user_t)
 `AXI_TYPEDEF_REQ_T(mst_req_t, mst_aw_chan_t, w_chan_t, mst_ar_chan_t)
 `AXI_TYPEDEF_REQ_T(slv_req_t, slv_aw_chan_t, w_chan_t, slv_ar_chan_t)
 `AXI_TYPEDEF_RESP_T(mst_resp_t, mst_b_chan_t, mst_r_chan_t)
 `AXI_TYPEDEF_RESP_T(slv_resp_t, slv_b_chan_t, slv_r_chan_t)

 //mst_req_t   [Cfg.NoMstPorts-1:0]  mst_reqs;
 //mst_resp_t  [Cfg.NoMstPorts-1:0]  mst_resps;
 mst_req_t   [5:0]  mst_reqs;
 mst_resp_t  [5:0]  mst_resps;
 slv_req_t   [Cfg.NoSlvPorts-1:0]  slv_reqs;
 slv_resp_t  [Cfg.NoSlvPorts-1:0]  slv_resps;

 axi_xbar #(
   .Cfg  (Cfg),
   .ATOPs          ( ATOPS         ),
   .Connectivity   ( CONNECTIVITY  ),
   .slv_aw_chan_t  ( slv_aw_chan_t ),
   .mst_aw_chan_t  ( mst_aw_chan_t ),
   .w_chan_t       ( w_chan_t      ),
   .slv_b_chan_t   ( slv_b_chan_t  ),
   .mst_b_chan_t   ( mst_b_chan_t  ),
   .slv_ar_chan_t  ( slv_ar_chan_t ),
   .mst_ar_chan_t  ( mst_ar_chan_t ),
   .slv_r_chan_t   ( slv_r_chan_t  ),
   .mst_r_chan_t   ( mst_r_chan_t  ),
   .slv_req_t      ( slv_req_t     ),
   .slv_resp_t     ( slv_resp_t    ),
   .mst_req_t      ( mst_req_t     ),
   .mst_resp_t     ( mst_resp_t    ),
   .rule_t         ( rule_t        )
 ) i_xbar (
   .clk_i                   (aclk       ),
   .rst_ni                  (aresetn    ),
   .test_i                  ('0         ),
   .slv_ports_req_i         (slv_reqs   ),
   .slv_ports_resp_o        (slv_resps  ),
   .mst_ports_req_o         (mst_reqs   ),
   .mst_ports_resp_i        (mst_resps  ),
   .addr_map_i              (addr_map_i ),
   .en_default_mst_port_i   ('0         ),  
   .default_mst_port_i      ('0         )
 );

genvar i;

generate
    for(i=0;i<CORE_NUM;i=i+1) begin: core_region_gen
        core_region_xwt_wrapper #(
            .id_width         (AxiIdWidthSlvPorts),
            .itcm_start       (itcm_start     ),
            .itcm_size        (itcm_size      ),
            .dtcm_start       (dtcm_start     ),
            .dtcm_size        (dtcm_size      ),
            .boot_addr        (boot_addr      ),
            .core_id          (i              ),
            .cluster_id       (cluster_id     )
        )core_region_xwt_wrapper_Ux(
            .aclk                 (aclk                         ),
            .aresetn              (aresetn                      ),
            .instr_axi_awid       (slv_reqs[2*i].aw.id          ),
            .instr_axi_awaddr     (slv_reqs[2*i].aw.addr        ),
            .instr_axi_awlen      (slv_reqs[2*i].aw.len         ),
            .instr_axi_awsize     (slv_reqs[2*i].aw.size        ),
            .instr_axi_awburst    (slv_reqs[2*i].aw.burst       ),
            .instr_axi_awlock     (slv_reqs[2*i].aw.lock        ),
            .instr_axi_awcache    (slv_reqs[2*i].aw.cache       ),
            .instr_axi_awprot     (slv_reqs[2*i].aw.prot        ),
            .instr_axi_awqos      (slv_reqs[2*i].aw.qos         ),
            .instr_axi_awregion   (slv_reqs[2*i].aw.region      ),
            .instr_axi_awvalid    (slv_reqs[2*i].aw_valid       ),
            .instr_axi_awready    (slv_resps[2*i].aw_ready      ),
            .instr_axi_wdata      (slv_reqs[2*i].w.data         ),
            .instr_axi_wstrb      (slv_reqs[2*i].w.strb         ),
            .instr_axi_wlast      (slv_reqs[2*i].w.last         ),
            .instr_axi_wvalid     (slv_reqs[2*i].w_valid        ),
            .instr_axi_wready     (slv_resps[2*i].w_ready       ),
            .instr_axi_bid        (slv_resps[2*i].b.id          ),
            .instr_axi_bresp      (slv_resps[2*i].b.resp        ),
            .instr_axi_bvalid     (slv_resps[2*i].b_valid       ),
            .instr_axi_bready     (slv_reqs[2*i].b_ready        ),
            .instr_axi_arid       (slv_reqs[2*i].ar.id          ),
            .instr_axi_araddr     (slv_reqs[2*i].ar.addr        ),
            .instr_axi_arlen      (slv_reqs[2*i].ar.len         ),
            .instr_axi_arsize     (slv_reqs[2*i].ar.size        ),
            .instr_axi_arburst    (slv_reqs[2*i].ar.burst       ),
            .instr_axi_arlock     (slv_reqs[2*i].ar.lock        ),
            .instr_axi_arcache    (slv_reqs[2*i].ar.cache       ),
            .instr_axi_arprot     (slv_reqs[2*i].ar.prot        ),
            .instr_axi_arqos      (slv_reqs[2*i].ar.qos         ),
            .instr_axi_arregion   (slv_reqs[2*i].ar.region      ),
            .instr_axi_arvalid    (slv_reqs[2*i].ar_valid       ),
            .instr_axi_arready    (slv_resps[2*i].ar_ready      ),
            .instr_axi_rid        (slv_resps[2*i].r.id          ),
            .instr_axi_rdata      (slv_resps[2*i].r.data        ),
            .instr_axi_rresp      (slv_resps[2*i].r.resp        ),
            .instr_axi_rlast      (slv_resps[2*i].r.last        ),
            .instr_axi_rvalid     (slv_resps[2*i].r_valid       ),
            .instr_axi_rready     (slv_reqs[2*i].r_ready        ),
            .data_axi_awid        (slv_reqs[2*i+1].aw.id        ),
            .data_axi_awaddr      (slv_reqs[2*i+1].aw.addr      ),
            .data_axi_awlen       (slv_reqs[2*i+1].aw.len       ),
            .data_axi_awsize      (slv_reqs[2*i+1].aw.size      ),
            .data_axi_awburst     (slv_reqs[2*i+1].aw.burst     ),
            .data_axi_awlock      (slv_reqs[2*i+1].aw.lock      ),
            .data_axi_awcache     (slv_reqs[2*i+1].aw.cache     ),
            .data_axi_awprot      (slv_reqs[2*i+1].aw.prot      ),
            .data_axi_awqos       (slv_reqs[2*i+1].aw.qos       ),
            .data_axi_awregion    (slv_reqs[2*i+1].aw.region    ),
            .data_axi_awvalid     (slv_reqs[2*i+1].aw_valid     ),
            .data_axi_awready     (slv_resps[2*i+1].aw_ready    ),
            .data_axi_wdata       (slv_reqs[2*i+1].w.data       ),
            .data_axi_wstrb       (slv_reqs[2*i+1].w.strb       ),
            .data_axi_wlast       (slv_reqs[2*i+1].w.last       ),
            .data_axi_wvalid      (slv_reqs[2*i+1].w_valid      ),
            .data_axi_wready      (slv_resps[2*i+1].w_ready     ),
            .data_axi_bid         (slv_resps[2*i+1].b.id        ),
            .data_axi_bresp       (slv_resps[2*i+1].b.resp      ),
            .data_axi_bvalid      (slv_resps[2*i+1].b_valid     ),
            .data_axi_bready      (slv_reqs[2*i+1].b_ready      ),
            .data_axi_arid        (slv_reqs[2*i+1].ar.id        ),
            .data_axi_araddr      (slv_reqs[2*i+1].ar.addr      ),
            .data_axi_arlen       (slv_reqs[2*i+1].ar.len       ),
            .data_axi_arsize      (slv_reqs[2*i+1].ar.size      ),
            .data_axi_arburst     (slv_reqs[2*i+1].ar.burst     ),
            .data_axi_arlock      (slv_reqs[2*i+1].ar.lock      ),
            .data_axi_arcache     (slv_reqs[2*i+1].ar.cache     ),
            .data_axi_arprot      (slv_reqs[2*i+1].ar.prot      ),
            .data_axi_arqos       (slv_reqs[2*i+1].ar.qos       ),
            .data_axi_arregion    (slv_reqs[2*i+1].ar.region    ),
            .data_axi_arvalid     (slv_reqs[2*i+1].ar_valid     ),
            .data_axi_arready     (slv_resps[2*i+1].ar_ready    ),
            .data_axi_rid         (slv_resps[2*i+1].r.id        ),
            .data_axi_rdata       (slv_resps[2*i+1].r.data      ),
            .data_axi_rresp       (slv_resps[2*i+1].r.resp      ),
            .data_axi_rlast       (slv_resps[2*i+1].r.last      ),
            .data_axi_rvalid      (slv_resps[2*i+1].r_valid     ),
            .data_axi_rready      (slv_reqs[2*i+1].r_ready      ),
            .irq                  (intr_irq        [i]          ),
            .irq_id               (intr_irq_id     [i]          ),
            .irq_ack              (intr_irq_ack    [i]          ),
            .irq_ack_id           (intr_irq_ack_id [i]          ),        
            .irq_sec              (intr_sec        [i]          )
        );
    end
endgenerate


//plic

PLIC_n_core
#(
    .num_targets (CORE_NUM),
    .num_sources (2       )
)PLIC_n_core_U0(
    .aclk               (aclk                   ),
    .aresetn            (aresetn                ),
    .PLIC_AXI_0_araddr  (mst_reqs[2].ar.addr    ),
    .PLIC_AXI_0_arprot  (mst_reqs[2].ar.prot    ),
    .PLIC_AXI_0_arlen   (mst_reqs[2].ar.len     ),
    .PLIC_AXI_0_arsize  (mst_reqs[2].ar.size    ),
    .PLIC_AXI_0_arburst (mst_reqs[2].ar.burst   ),
    .PLIC_AXI_0_arvalid (mst_reqs[2].ar_valid   ),
    .PLIC_AXI_0_arready (mst_resps[2].ar_ready  ),
    .PLIC_AXI_0_awaddr  (mst_reqs[2].aw.addr    ),
    .PLIC_AXI_0_awprot  (mst_reqs[2].aw.prot    ),
    .PLIC_AXI_0_awvalid (mst_reqs[2].aw_valid   ),
    .PLIC_AXI_0_awready (mst_resps[2].aw_ready  ),
    .PLIC_AXI_0_bresp   (mst_resps[2].b.resp    ),
    .PLIC_AXI_0_bvalid  (mst_resps[2].b_valid   ),
    .PLIC_AXI_0_bready  (mst_reqs[2].b_ready    ),
    .PLIC_AXI_0_rdata   (mst_resps[2].r.data    ),
    .PLIC_AXI_0_rresp   (mst_resps[2].r.resp    ),
    .PLIC_AXI_0_rvalid  (mst_resps[2].r_valid   ),
    .PLIC_AXI_0_rready  (mst_reqs[2].r_ready    ),
    .PLIC_AXI_0_wdata   (mst_reqs[2].w.data     ),
    .PLIC_AXI_0_wstrb   (mst_reqs[2].w.strb     ),
    .PLIC_AXI_0_wvalid  (mst_reqs[2].w_valid    ),
    .PLIC_AXI_0_wready  (mst_resps[2].w_ready   ),
    .intr_irq           (intr_irq               ),
    .intr_irq_ack       (intr_irq_ack           ),
    .intr_irq_ack_id    (intr_irq_ack_id        ),
    .intr_irq_id        (intr_irq_id            ),
    .intr_sec           (intr_sec               ),
    .intr_sec_lvl       (intr_sec_lvl           ),
    .source             ('0                     )
);

//convert axi_intf to wire
	assign axi_awid_0     = mst_reqs[0].aw.id          ;
    assign axi_awaddr_0   = mst_reqs[0].aw.addr        ;
    assign axi_awlen_0    = mst_reqs[0].aw.len         ;
    assign axi_awsize_0   = mst_reqs[0].aw.size        ;
    assign axi_awburst_0  = mst_reqs[0].aw.burst       ;
    assign axi_awlock_0   = mst_reqs[0].aw.lock        ;
    assign axi_awcache_0  = mst_reqs[0].aw.cache       ;
    assign axi_awprot_0   = mst_reqs[0].aw.prot        ;
    assign axi_awqos_0    = mst_reqs[0].aw.qos         ;
    assign axi_awregion_0 = mst_reqs[0].aw.region      ;
    assign axi_awvalid_0  = mst_reqs[0].aw_valid       ;
    assign mst_resps[0].aw_ready = axi_awready_0        ;


    assign axi_wdata_0    = mst_reqs[0].w.data         ;           
    assign axi_wstrb_0    = mst_reqs[0].w.strb         ;           
    assign axi_wlast_0    = mst_reqs[0].w.last         ;           
    assign axi_wvalid_0   = mst_reqs[0].w_valid        ;           
    assign mst_resps[0].w_ready = axi_wready_0          ;

    assign mst_resps[0].b.id    = axi_bid_0             ;              
    assign mst_resps[0].b.resp  = axi_bresp_0           ;              
    assign mst_resps[0].b_valid = axi_bvalid_0          ;              
    assign axi_bready_0  = mst_reqs[0].b_ready         ;

    assign axi_arid_0     = mst_reqs[0].ar.id          ;            
    assign axi_araddr_0   = mst_reqs[0].ar.addr        ;            
    assign axi_arlen_0    = mst_reqs[0].ar.len         ;            
    assign axi_arsize_0   = mst_reqs[0].ar.size        ;            
    assign axi_arburst_0  = mst_reqs[0].ar.burst       ;            
    assign axi_arlock_0   = mst_reqs[0].ar.lock        ;            
    assign axi_arcache_0  = mst_reqs[0].ar.cache       ;            
    assign axi_arprot_0   = mst_reqs[0].ar.prot        ;            
    assign axi_arqos_0    = mst_reqs[0].ar.qos         ;            
    assign axi_arregion_0 = mst_reqs[0].ar.region      ;            
    assign axi_arvalid_0  = mst_reqs[0].ar_valid       ;            
    assign mst_resps[0].ar_ready = axi_arready_0        ;         

    assign mst_resps[0].r.id    = axi_rid_0             ;             
    assign mst_resps[0].r.data  = axi_rdata_0           ;             
    assign mst_resps[0].r.resp  = axi_rresp_0           ;             
    assign mst_resps[0].r.last  = axi_rlast_0           ;             
    assign mst_resps[0].r_valid = axi_rvalid_0          ;             
    assign axi_rready_0 = mst_reqs[0].r_ready          ;         
//from axi to bram_ctrl_1
	assign axi_awid_1     = mst_reqs[1].aw.id          ;
    assign axi_awaddr_1   = mst_reqs[1].aw.addr        ;
    assign axi_awlen_1    = mst_reqs[1].aw.len         ;
    assign axi_awsize_1   = mst_reqs[1].aw.size        ;
    assign axi_awburst_1  = mst_reqs[1].aw.burst       ;
    assign axi_awlock_1   = mst_reqs[1].aw.lock        ;
    assign axi_awcache_1  = mst_reqs[1].aw.cache       ;
    assign axi_awprot_1   = mst_reqs[1].aw.prot        ;
    assign axi_awqos_1    = mst_reqs[1].aw.qos         ;
    assign axi_awregion_1 = mst_reqs[1].aw.region      ;
    assign axi_awvalid_1  = mst_reqs[1].aw_valid       ;
    assign mst_resps[1].aw_ready = axi_awready_1        ;


    assign axi_wdata_1    = mst_reqs[1].w.data         ;           
    assign axi_wstrb_1    = mst_reqs[1].w.strb         ;           
    assign axi_wlast_1    = mst_reqs[1].w.last         ;           
    assign axi_wvalid_1   = mst_reqs[1].w_valid        ;           
    assign mst_resps[1].w_ready = axi_wready_1          ;

    assign mst_resps[1].b.id    = axi_bid_1             ;              
    assign mst_resps[1].b.resp  = axi_bresp_1           ;              
    assign mst_resps[1].b_valid = axi_bvalid_1          ;              
    assign axi_bready_1  = mst_reqs[1].b_ready         ;

    assign axi_arid_1     = mst_reqs[1].ar.id          ;            
    assign axi_araddr_1   = mst_reqs[1].ar.addr        ;            
    assign axi_arlen_1    = mst_reqs[1].ar.len         ;            
    assign axi_arsize_1   = mst_reqs[1].ar.size        ;            
    assign axi_arburst_1  = mst_reqs[1].ar.burst       ;            
    assign axi_arlock_1   = mst_reqs[1].ar.lock        ;            
    assign axi_arcache_1  = mst_reqs[1].ar.cache       ;            
    assign axi_arprot_1   = mst_reqs[1].ar.prot        ;            
    assign axi_arqos_1    = mst_reqs[1].ar.qos         ;            
    assign axi_arregion_1 = mst_reqs[1].ar.region      ;            
    assign axi_arvalid_1  = mst_reqs[1].ar_valid       ;            
    assign mst_resps[1].ar_ready = axi_arready_1        ;         

    assign mst_resps[1].r.id    = axi_rid_1             ;             
    assign mst_resps[1].r.data  = axi_rdata_1           ;             
    assign mst_resps[1].r.resp  = axi_rresp_1           ;             
    assign mst_resps[1].r.last  = axi_rlast_1           ;             
    assign mst_resps[1].r_valid = axi_rvalid_1          ;             
    assign axi_rready_1 = mst_reqs[1].r_ready          ;  
    
    //////////////// prephiral _1 ///////////////////////////7
    
    assign axi_awid_2     = mst_reqs[3].aw.id          ;
    assign axi_awaddr_2   = mst_reqs[3].aw.addr        ;
    assign axi_awlen_2    = mst_reqs[3].aw.len         ;
    assign axi_awsize_2   = mst_reqs[3].aw.size        ;
    assign axi_awburst_2  = mst_reqs[3].aw.burst       ;
    assign axi_awlock_2   = mst_reqs[3].aw.lock        ;
    assign axi_awcache_2  = mst_reqs[3].aw.cache       ;
    assign axi_awprot_2   = mst_reqs[3].aw.prot        ;
    assign axi_awqos_2    = mst_reqs[3].aw.qos         ;
    assign axi_awregion_2 = mst_reqs[3].aw.region      ;
    assign axi_awvalid_2  = mst_reqs[3].aw_valid       ;
    assign mst_resps[3].aw_ready = axi_awready_2        ;


    assign axi_wdata_2    = mst_reqs[3].w.data         ;           
    assign axi_wstrb_2    = mst_reqs[3].w.strb         ;           
    assign axi_wlast_2    = mst_reqs[3].w.last         ;           
    assign axi_wvalid_2   = mst_reqs[3].w_valid        ;           
    assign mst_resps[3].w_ready = axi_wready_2          ;

    assign mst_resps[3].b.id    = axi_bid_2             ;              
    assign mst_resps[3].b.resp  = axi_bresp_2           ;              
    assign mst_resps[3].b_valid = axi_bvalid_2          ;              
    assign axi_bready_2  = mst_reqs[3].b_ready         ;

    assign axi_arid_2     = mst_reqs[3].ar.id          ;            
    assign axi_araddr_2   = mst_reqs[3].ar.addr        ;            
    assign axi_arlen_2    = mst_reqs[3].ar.len         ;            
    assign axi_arsize_2   = mst_reqs[3].ar.size        ;            
    assign axi_arburst_2  = mst_reqs[3].ar.burst       ;            
    assign axi_arlock_2   = mst_reqs[3].ar.lock        ;            
    assign axi_arcache_2  = mst_reqs[3].ar.cache       ;            
    assign axi_arprot_2   = mst_reqs[3].ar.prot        ;            
    assign axi_arqos_2    = mst_reqs[3].ar.qos         ;            
    assign axi_arregion_2 = mst_reqs[3].ar.region      ;            
    assign axi_arvalid_2  = mst_reqs[3].ar_valid       ;            
    assign mst_resps[3].ar_ready = axi_arready_2        ;         

    assign mst_resps[3].r.id    = axi_rid_2             ;             
    assign mst_resps[3].r.data  = axi_rdata_2           ;             
    assign mst_resps[3].r.resp  = axi_rresp_2           ;             
    assign mst_resps[3].r.last  = axi_rlast_2           ;             
    assign mst_resps[3].r_valid = axi_rvalid_2          ;             
    assign axi_rready_2 = mst_reqs[3].r_ready          ;       
    
    //////////////// prephiral _2 ///////////////////////////7
    
    assign axi_awid_3     = mst_reqs[4].aw.id          ;
    assign axi_awaddr_3   = mst_reqs[4].aw.addr        ;
    assign axi_awlen_3    = mst_reqs[4].aw.len         ;
    assign axi_awsize_3   = mst_reqs[4].aw.size        ;
    assign axi_awburst_3  = mst_reqs[4].aw.burst       ;
    assign axi_awlock_3   = mst_reqs[4].aw.lock        ;
    assign axi_awcache_3  = mst_reqs[4].aw.cache       ;
    assign axi_awprot_3   = mst_reqs[4].aw.prot        ;
    assign axi_awqos_3    = mst_reqs[4].aw.qos         ;
    assign axi_awregion_3 = mst_reqs[4].aw.region      ;
    assign axi_awvalid_3  = mst_reqs[4].aw_valid       ;
    assign mst_resps[4].aw_ready = axi_awready_3        ;


    assign axi_wdata_3    = mst_reqs[4].w.data         ;           
    assign axi_wstrb_3    = mst_reqs[4].w.strb         ;           
    assign axi_wlast_3    = mst_reqs[4].w.last         ;           
    assign axi_wvalid_3   = mst_reqs[4].w_valid        ;           
    assign mst_resps[4].w_ready = axi_wready_3          ;

    assign mst_resps[4].b.id    = axi_bid_3             ;              
    assign mst_resps[4].b.resp  = axi_bresp_3           ;              
    assign mst_resps[4].b_valid = axi_bvalid_3          ;              
    assign axi_bready_3  = mst_reqs[4].b_ready         ;

    assign axi_arid_3     = mst_reqs[4].ar.id          ;            
    assign axi_araddr_3   = mst_reqs[4].ar.addr        ;            
    assign axi_arlen_3    = mst_reqs[4].ar.len         ;            
    assign axi_arsize_3   = mst_reqs[4].ar.size        ;            
    assign axi_arburst_3  = mst_reqs[4].ar.burst       ;            
    assign axi_arlock_3   = mst_reqs[4].ar.lock        ;            
    assign axi_arcache_3  = mst_reqs[4].ar.cache       ;            
    assign axi_arprot_3   = mst_reqs[4].ar.prot        ;            
    assign axi_arqos_3    = mst_reqs[4].ar.qos         ;            
    assign axi_arregion_3 = mst_reqs[4].ar.region      ;            
    assign axi_arvalid_3  = mst_reqs[4].ar_valid       ;            
    assign mst_resps[4].ar_ready = axi_arready_3        ;         

    assign mst_resps[4].r.id    = axi_rid_3             ;             
    assign mst_resps[4].r.data  = axi_rdata_3           ;             
    assign mst_resps[4].r.resp  = axi_rresp_3           ;             
    assign mst_resps[4].r.last  = axi_rlast_3           ;             
    assign mst_resps[4].r_valid = axi_rvalid_3          ;             
    assign axi_rready_3 = mst_reqs[4].r_ready          ;        
 
 
  //////////////// prephiral _3 ///////////////////////////7
    
    assign axi_awid_4     = mst_reqs[5].aw.id          ;
    assign axi_awaddr_4   = mst_reqs[5].aw.addr        ;
    assign axi_awlen_4    = mst_reqs[5].aw.len         ;
    assign axi_awsize_4   = mst_reqs[5].aw.size        ;
    assign axi_awburst_4  = mst_reqs[5].aw.burst       ;
    assign axi_awlock_4   = mst_reqs[5].aw.lock        ;
    assign axi_awcache_4  = mst_reqs[5].aw.cache       ;
    assign axi_awprot_4   = mst_reqs[5].aw.prot        ;
    assign axi_awqos_4    = mst_reqs[5].aw.qos         ;
    assign axi_awregion_4 = mst_reqs[5].aw.region      ;
    assign axi_awvalid_4  = mst_reqs[5].aw_valid       ;
    assign mst_resps[5].aw_ready = axi_awready_4        ;


    assign axi_wdata_4    = mst_reqs[5].w.data         ;           
    assign axi_wstrb_4    = mst_reqs[5].w.strb         ;           
    assign axi_wlast_4    = mst_reqs[5].w.last         ;           
    assign axi_wvalid_4   = mst_reqs[5].w_valid        ;           
    assign mst_resps[5].w_ready = axi_wready_4          ;

    assign mst_resps[5].b.id    = axi_bid_4             ;              
    assign mst_resps[5].b.resp  = axi_bresp_4           ;              
    assign mst_resps[5].b_valid = axi_bvalid_4          ;              
    assign axi_bready_4  = mst_reqs[5].b_ready         ;

    assign axi_arid_4     = mst_reqs[5].ar.id          ;            
    assign axi_araddr_4   = mst_reqs[5].ar.addr        ;            
    assign axi_arlen_4    = mst_reqs[5].ar.len         ;            
    assign axi_arsize_4   = mst_reqs[5].ar.size        ;            
    assign axi_arburst_4  = mst_reqs[5].ar.burst       ;            
    assign axi_arlock_4   = mst_reqs[5].ar.lock        ;            
    assign axi_arcache_4  = mst_reqs[5].ar.cache       ;            
    assign axi_arprot_4   = mst_reqs[5].ar.prot        ;            
    assign axi_arqos_4    = mst_reqs[5].ar.qos         ;            
    assign axi_arregion_4 = mst_reqs[5].ar.region      ;            
    assign axi_arvalid_4  = mst_reqs[5].ar_valid       ;            
    assign mst_resps[5].ar_ready = axi_arready_4        ;         

    assign mst_resps[5].r.id    = axi_rid_4             ;             
    assign mst_resps[5].r.data  = axi_rdata_4           ;             
    assign mst_resps[5].r.resp  = axi_rresp_4           ;             
    assign mst_resps[5].r.last  = axi_rlast_4           ;             
    assign mst_resps[5].r_valid = axi_rvalid_4          ;             
    assign axi_rready_4 = mst_reqs[5].r_ready          ;        
 

endmodule