module datapath 
    #(parameter MAT_SIZE_BITS = 4,
    BRAM_DEPTH = 10,
    IN_SIZE = 8,
    VAL_SIZE = 24
    )
    (
    input clk,
    input rst_n,
    
    input err_cal,
    
    input [MAT_SIZE_BITS - 1:0]  M, N, K,
    input [BRAM_DEPTH - 1:0] base_addr_in1,
    input [BRAM_DEPTH - 1:0] base_addr_in2,
    input [BRAM_DEPTH - 1:0] base_addr_out,
    
    input        M_en, N_en, K_en,
    input        bai1_en, bai2_en, bao_en,
    
    input [VAL_SIZE - 1:0] dout_mem,
    
    input        i_cnt, j_cnt, h_cnt,
    input        i_rstn, j_rstn, h_rstn,
    input        b_en, c_en, h_m_en,
    input        base_cal,
    input [3:0]  bi2_sel,
    input [1:0]  bi1_o_sel,
    input [1:0]  addr_sel,
    input        ai2_en, ai1_en, ao_en, a_en, am_en,
    
    input [1:0]  dout_sel,
    input [1:0]  w_sel,
    input [1:0]  i_sel,
    input        wshift, 
    input [3:0]  pe_en, adder_en, mul_en,
    input        buf_en,
    input [1:0]  fpo_sel,
    input        d_en,
    input        fout_en,
    input        dm_en,
    
    output reg err_found,
    output [VAL_SIZE - 1:0] din_mem,
    output [BRAM_DEPTH - 1:0] addr_mem_q,
    
    output        i_max, j_max, h_max,
    output        h_out_point, h_in_point
);

    wire [3:0]  M_q, N_q, K_q;
    wire [BRAM_DEPTH - 1:0] base_addr_in1_q;
    wire [BRAM_DEPTH - 1:0] base_addr_in2_q;
    wire [BRAM_DEPTH - 1:0] base_addr_out_q;
    wire [1:0]  b, c, b_q, c_q;
    wire [4:0]  h_m, h_m_q;
    wire [1:0]  i_value, j_value; 
    wire [4:0]  h_value;
    wire [9:0] bi1, bi2, bo;
    wire [9:0] bi1_q, bi2_q, bo_q;
    wire [BRAM_DEPTH - 1:0] addr_in2, addr_in1, addr_out;
    wire [BRAM_DEPTH - 1:0] addr_in2_q, addr_in1_q, addr_out_q;
    wire [BRAM_DEPTH - 1:0] addr_mem;
    wire [VAL_SIZE - 1:0] dout_mem_q;
    wire [1:0]  addr_sel_q;
    
    wire        wo_en, io_en, ro_en;
    wire [7:0]  weight_o, in_o;
    wire [7:0]  weight [3:0];
    wire [7:0]  in [3:0];
    wire        w_en_0, w_en_1, w_en_2, w_en_3;
    wire        i_en_0, i_en_1, i_en_2, i_en_3;
    
    wire [7:0]  dout_wi;
    wire [VAL_SIZE - 1:0] result, result_q;
    wire [VAL_SIZE - 1:0] pe_output [3:0];
    wire [1:0]  fpo_sel_q;
    wire [VAL_SIZE - 1:0] fout, fout_q;
    wire [VAL_SIZE - 1:0] f_result, f_result_q;

    wire [(IN_SIZE * 4) - 1:0] weight_flat, in_flat;
    wire [(VAL_SIZE * 4) - 1:0] pe_output_flat;
    
    assign b = N[MAT_SIZE_BITS - 1:2];
    assign c = K[MAT_SIZE_BITS - 1:2];
    assign h_m = M + 4;
    
    reg_4b reg_M (
        .clk(clk),
        .rst_n(rst_n),
        .en(M_en),
        .d(M),
        .q(M_q)
    );
    
    reg_4b reg_N (
        .clk(clk),
        .rst_n(rst_n),
        .en(N_en),
        .d(N),
        .q(N_q)
    );
    
    reg_4b reg_K (
        .clk(clk),
        .rst_n(rst_n),
        .en(K_en),
        .d(K),
        .q(K_q)
    );
    
    reg_10b reg_bai1 (
        .clk(clk),
        .rst_n(rst_n),
        .en(bai1_en),
        .d(base_addr_in1),
        .q(base_addr_in1_q)
    );
    
    reg_10b reg_bai2 (
        .clk(clk),
        .rst_n(rst_n),
        .en(bai2_en),
        .d(base_addr_in2),
        .q(base_addr_in2_q)
    );
    
    reg_10b reg_bao (
        .clk(clk),
        .rst_n(rst_n),
        .en(bao_en),
        .d(base_addr_out),
        .q(base_addr_out_q)
    );
    
    reg_2b reg_b (
        .clk(clk),
        .rst_n(rst_n),
        .en(b_en),
        .d(b),
        .q(b_q)
    ); 
    
    reg_2b reg_c (
        .clk(clk),
        .rst_n(rst_n),
        .en(c_en),
        .d(c),
        .q(c_q)
    );
     
    reg_5b reg_h_m (
        .clk(clk),
        .rst_n(rst_n),
        .en(h_m_en),
        .d(h_m),
        .q(h_m_q)
    ); 
    
    error_check ec_module (
        .clk(clk),
        .rst_n(rst_n),
        .err_cal(err_cal),
        .M(M),
        .N(N),
        .K(K),
        .base_addr_in1(base_addr_in1),
        .base_addr_in2(base_addr_in2),
        .base_addr_out(base_addr_out),
        .err_found(err_found)
    );
    
    counter counter_i (
        .clk(clk),
        .rst_n(i_rstn),
        .inc(i_cnt),
        .maxVal(b_q),
        .isMax(i_max),
        .value(i_value)
    );
    
    counter counter_j (
        .clk(clk),
        .rst_n(j_rstn),
        .inc(j_cnt),
        .maxVal(c_q),
        .isMax(j_max),
        .value(j_value)
    );
    
    
    counter_2p counter_h (
        .clk(clk),
        .rst_n(h_rstn),
        .inc(h_cnt),
        .maxVal(h_m_q),
        .isPoint1(h_out_point),
        .isPoint2(h_in_point),
        .isMax(h_max),
        .value(h_value)
    );
    
    assign bi2 = base_addr_in2_q + ((K_q * i_value) << 2) + (j_value << 2);
    assign bi1 = base_addr_in1_q + (i_value << 2);
    assign bo = base_addr_out_q + (j_value << 2);
    
    reg_10b reg_bi2 (
        .clk(clk),
        .rst_n(rst_n),
        .en(base_cal),
        .d(bi2),
        .q(bi2_q)
    ); 
    
    reg_10b reg_bi1 (
        .clk(clk),
        .rst_n(rst_n),
        .en(base_cal),
        .d(bi1),
        .q(bi1_q)
    ); 
    
    reg_10b reg_bo (
        .clk(clk),
        .rst_n(rst_n),
        .en(base_cal),
        .d(bo),
        .q(bo_q)
    ); 
    
    assign addr_in2 =  bi2_q + bi2_sel[3:2] * K_q + bi2_sel[1:0];
    assign addr_in1 = bi1_q + N_q * h_value + bi1_o_sel;
    assign addr_out = bo_q + K_q * (h_value - 4) + bi1_o_sel;
    
    reg_10b reg_ai2 (
        .clk(clk),
        .rst_n(rst_n),
        .en(ai2_en),
        .d(addr_in2),
        .q(addr_in2_q)
    ); 
    
    reg_10b reg_ai1 (
        .clk(clk),
        .rst_n(rst_n),
        .en(ai1_en),
        .d(addr_in1),
        .q(addr_in1_q)
    ); 
    
    reg_10b reg_ao (
        .clk(clk),
        .rst_n(rst_n),
        .en(ao_en),
        .d(addr_out),
        .q(addr_out_q)
    ); 
    
    reg_2b reg_addr_sel (
        .clk(clk),
        .rst_n(rst_n),
        .en(a_en),
        .d(addr_sel),
        .q(addr_sel_q)
    ); 
    
    assign addr_mem = (addr_sel_q == 2'b00) ? addr_in2_q :
                      (addr_sel_q == 2'b01) ? addr_in1_q :
                      (addr_sel_q == 2'b10) ? addr_out_q : 0;
    
    reg_10b reg_am (
        .clk(clk),
        .rst_n(rst_n),
        .en(am_en),
        .d(addr_mem),
        .q(addr_mem_q)
    );
    
    
    assign wo_en = (dout_sel == 2'b00);
    assign io_en = (dout_sel == 2'b01);
    assign ro_en = (dout_sel == 2'b10);
    assign dout_wi = dout_mem[7:0];

    reg_8b wo_reg ( .clk(clk), .rst_n(rst_n), .en(wo_en), .d(dout_wi), .q(weight_o));
    reg_8b io_reg ( .clk(clk), .rst_n(rst_n), .en(io_en), .d(dout_wi), .q(in_o));
    reg_24b ro_reg ( .clk(clk), .rst_n(rst_n), .en(ro_en), .d(dout_mem), .q(result));
    
    assign w_en_0 = (w_sel == 2'b00);
    assign w_en_1 = (w_sel == 2'b01);
    assign w_en_2 = (w_sel == 2'b10);
    assign w_en_3 = (w_sel == 2'b11);
    
    reg_8b wreg0 ( .clk(clk), .rst_n(rst_n), .en(w_en_0), .d(weight_o), .q(weight[0]));
    reg_8b wreg1 ( .clk(clk), .rst_n(rst_n), .en(w_en_1), .d(weight_o), .q(weight[1]));
    reg_8b wreg2 ( .clk(clk), .rst_n(rst_n), .en(w_en_2), .d(weight_o), .q(weight[2]));
    reg_8b wreg3 ( .clk(clk), .rst_n(rst_n), .en(w_en_3), .d(weight_o), .q(weight[3]));
    
    assign i_en_0 = (i_sel == 2'b00);
    assign i_en_1 = (i_sel == 2'b01);
    assign i_en_2 = (i_sel == 2'b10);
    assign i_en_3 = (i_sel == 2'b11);
    
    reg_8b ireg0 ( .clk(clk), .rst_n(rst_n), .en(i_en_0), .d(in_o), .q(in[0]));
    reg_8b ireg1 ( .clk(clk), .rst_n(rst_n), .en(i_en_1), .d(in_o), .q(in[1]));
    reg_8b ireg2 ( .clk(clk), .rst_n(rst_n), .en(i_en_2), .d(in_o), .q(in[2]));
    reg_8b ireg3 ( .clk(clk), .rst_n(rst_n), .en(i_en_3), .d(in_o), .q(in[3]));
    
    assign weight_flat = {weight[3], weight[2], weight[1], weight[0]};
    assign in_flat = {in[3], in[2], in[1], in[0]};
    
    systolic systolic_module (
        .clk(clk),
        .rst_n(rst_n),
        .wshift(wshift),
        .pe_en(pe_en),
        .mul_en(mul_en),
        .adder_en(adder_en),
        .weight_flat(weight_flat),
        .I_flat(in_flat),
        .pe_output_flat(pe_output_flat)
    );
    
    assign {pe_output[3], pe_output[2], pe_output[1], pe_output[0]} = pe_output_flat;
    
    reg_2b reg_fout_sel (
        .clk(clk),
        .rst_n(rst_n),
        .en(d_en),
        .d(fpo_sel),
        .q(fpo_sel_q)
        );

    assign fout = (fpo_sel == 2'b00) ? pe_output[0] : 
                  (fpo_sel == 2'b01) ? pe_output[1] :
                  (fpo_sel == 2'b10) ? pe_output[2] :
                  (fpo_sel == 2'b11) ? pe_output[3] : 0;
    
    reg_24b reg_buf (
        .clk(clk),
        .rst_n(rst_n),
        .en(buf_en),
        .d(result),
        .q(result_q)
    );
                      
    reg_24b reg_fout (
        .clk(clk),
        .rst_n(rst_n),
        .en(fout_en),
        .d(fout),
        .q(fout_q)
    ); 
     
    assign f_result = result_q + fout_q;

    reg_24b reg_f_result (
        .clk(clk),
        .rst_n(rst_n),
        .en(dm_en),
        .d(f_result),
        .q(f_result_q)
    ); 
    
    assign din_mem = f_result_q;
     
endmodule