`timescale 1ns / 1ps

module top_module
    #(parameter MAT_SIZE_BITS = 4,
    BRAM_DEPTH = 10,
    VAL_SIZE = 24
    )
    (
    input wire clk,
    input wire rst_n,
    (* MARK_DEBUG = "true" *) input wire start,
    input wire [MAT_SIZE_BITS - 1:0] M, N, K,
    input wire [BRAM_DEPTH - 1:0] base_addr_in1, base_addr_in2, base_addr_out,
    (* MARK_DEBUG = "true" *) output wire done,
    (* MARK_DEBUG = "true" *) output wire [VAL_SIZE - 1:0] din_mem_out,
    (* MARK_DEBUG = "true" *) output wire [BRAM_DEPTH - 1:0] add_out,
    (* MARK_DEBUG = "true" *) output wire w_out,
    output wire err
);
    
    //==============================================================
    // 1. Internal Wires Declaration
    //==============================================================

    // Pre-counter / Config enables
    wire b_en, c_en, h_m_en;
    wire M_en, N_en, K_en;
    wire bai1_en, bai2_en, bao_en;
    
    wire err_cal;
    wire err_found;
    
    assign err = err_found;
    
    // Counter control signals
    wire i_cnt, j_cnt, h_cnt;
    wire i_max, j_max, h_max, h_in_point, h_out_point;
    // Note: Datapath asks for separate resets, but Controller uses global reset logic
    // We will tie these to 0 or derive from rst_n if needed.
    wire i_rstn, j_rstn, h_rstn; 

    // Address calculation signals
    wire base_cal;
    wire [3:0] bi2_sel, bi1_o_sel;

    // Address register enables
    wire ai2_en, ai1_en, ao_en;

    // Pre-addr mux
    wire a_en;
    wire [1:0] addr_sel;

    // AM reg
    wire am_en;

    // Mux selects (Width mismatch note: Controller sends 3 bits, Datapath might use 2)
    wire [1:0] dout_sel;
    wire [1:0] w_sel;
    wire [1:0] i_sel;
    
    // Systolic / Buffer controls
    wire buf_en;
    wire wshift;
    wire [3:0] pe_en, mul_en, adder_en;

    // Output selection
    wire d_en;
    wire [1:0] fpo_sel;
    wire fout_en;
    wire dm_en;
    
    // Memory Interface
    wire w;                 // Write/Read enable from Controller
    wire [VAL_SIZE - 1:0] din_mem;       // Data TO Memory (from Datapath)
    wire [BRAM_DEPTH - 1:0] addr_mem_q;    // Address TO Memory (from Datapath)
    (* MARK_DEBUG = "true" *) wire [VAL_SIZE - 1:0] dout_mem;      // Data FROM Memory (to Datapath)
    
    // Controller specific
    
//    assign dout_mem_out = dout_mem;
    assign din_mem_out = din_mem;
    assign w_out = w;
    assign add_out = addr_mem_q;
    // Memory Loopback (GIA LAP: N?u không có RAM, gán d? li?u ??c = 0 ?? tránh l?i Z)
    //assign dout_mem = 24'd0; 

    //==============================================================
    // 2. Controller Instantiation
    //==============================================================
    controller ctrl_inst (
        .rst_n      (rst_n), 
        .clk        (clk),
        .start      (start),
        .done       (done),
        .err_cal    (err_cal), // Input
        .err_found  (err_found), 
        
        // Counter Inputs (Status from Datapath)
        .i_max      (i_max), 
        .j_max      (j_max), 
        .h_max      (h_max), 
        .h_in_point (h_in_point),
.h_out_point(h_out_point),

        // Control Outputs (To Datapath)
        .b_en       (b_en), .c_en(c_en), .h_m_en(h_m_en),
        .M_en       (M_en), .N_en(N_en), .K_en(K_en),
        .bai1_en    (bai1_en), .bai2_en(bai2_en), .bao_en(bao_en),
        
        .i_cnt      (i_cnt), .j_cnt(j_cnt), .h_cnt(h_cnt),
        .i_rstn      (i_rstn), .j_rstn(j_rstn), .h_rstn(h_rstn),
        
        .base_cal   (base_cal),
        .bi2_sel    (bi2_sel), .bi1_o_sel(bi1_o_sel),
        
        .ai2_en     (ai2_en), .ai1_en(ai1_en), .ao_en(ao_en),
        .a_en       (a_en), .addr_sel(addr_sel),
        .am_en      (am_en),
        
        .dout_sel   (dout_sel),
        .w_sel      (w_sel),
        .i_sel      (i_sel),
        
        .buf_en     (buf_en),
        .wshift     (wshift),
        .pe_en      (pe_en), .mul_en(mul_en), .adder_en(adder_en),
        
        .d_en       (d_en), .fpo_sel(fpo_sel),
        .fout_en    (fout_en),
        .dm_en      (dm_en),
        
        .w          (w)
        //.r          (r)
    );

    //==============================================================
    // 3. Datapath Instantiation
    //==============================================================
    datapath #(.MAT_SIZE_BITS(MAT_SIZE_BITS),
                .BRAM_DEPTH(BRAM_DEPTH),
                .VAL_SIZE(VAL_SIZE)
                )
        dtp_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        
        // Configuration Values (Hardcoded as per snippet)
        .M              (M), 
        .N              (N), 
        .K              (K),
        .base_addr_in1  (base_addr_in1),
        .base_addr_in2  (base_addr_in2),
        .base_addr_out  (base_addr_out),
        
        .err_cal(err_cal),
        .err_found(err_found),
        
        // Configuration Enables
        .M_en       (M_en), .N_en(N_en), .K_en(K_en),
        .bai1_en    (bai1_en), .bai2_en(bai2_en), .bao_en(bao_en),
        
        // Memory Data In
        .dout_mem   (dout_mem),
        
        // Counters
        .i_cnt      (i_cnt), .j_cnt(j_cnt), .h_cnt(h_cnt),
        .i_rstn      (i_rstn), .j_rstn(j_rstn), .h_rstn(h_rstn),
        .b_en       (b_en), .c_en(c_en), .h_m_en(h_m_en),
        
        // Address Calculation
        .base_cal   (base_cal),
        .bi2_sel    (bi2_sel),
        .bi1_o_sel  (bi1_o_sel),
        .addr_sel   (addr_sel),
        
        // Registers
        .ai2_en     (ai2_en), .ai1_en(ai1_en), .ao_en(ao_en), 
        .a_en       (a_en), .am_en(am_en),
        
        // Mux Selects (Fixing syntax error from original snippet)
        // Assuming Datapath accepts the lower bits if width differs
        .dout_sel   (dout_sel), 
        .w_sel      (w_sel),
        .i_sel      (i_sel),
        
        // Systolic / PE
        .wshift     (wshift), 
        .pe_en      (pe_en), 
        .adder_en   (adder_en), 
        .mul_en     (mul_en),
        
        // Output logic
        .buf_en     (buf_en),
        .fpo_sel    (fpo_sel),
        .d_en       (d_en),
        .fout_en    (fout_en),
        .dm_en      (dm_en),
// Outputs to Memory/Controller
        .din_mem    (din_mem),
        .addr_mem_q (addr_mem_q),
        
        .i_max      (i_max), 
        .j_max      (j_max), 
        .h_max      (h_max),
        .h_out_point(h_out_point), 
        .h_in_point (h_in_point)
    );
    blk_mem_gen_0 bram_inst (
    .clka(clk),
    .wea(w),
    .addra(addr_mem_q),
    .dina(din_mem),
    .douta(dout_mem)
    );
endmodule