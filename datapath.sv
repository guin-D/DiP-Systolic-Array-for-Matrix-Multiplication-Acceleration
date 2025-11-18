module datapath (
    input clk,
    input rst_n,
    
    input [8:0] M, N, K,
    input [23:0] base_addr_in1,
    input [23:0] base_addr_in2,
    input [23:0] base_addr_out,
    
    input i_cnt, j_cnt, h_cnt,
    input base_cal,
    input [1:0] sel_addr
);

    wire [6:0]  b, c;
    wire [6:0]  i_value, j_value, h_value;
    
    wire [23:0] bi1, bi2, bo;
    wire [23:0] bi1_q, bi2_q, bo_q;
    wire [23:0] addr_in2, addr_in1, addr_out;
    wire [23:0] addr_mem;
    wire [23:0] bi2_val;
    wire [23:0] bi1_o_val;
    
    wire [7:0] weight_o, in_o;
    wire [7:0] weight [15:0];
    wire [7:0] in [15:0];
    wire [23:0] pe_output [15:0];
    wire [23:0] din_mem, dout_mem;
    wire [23:0] result;
    wire [23:0] f_result, f_result_q;
    wire [23:0] f_pe_output;
    
    wire [3:0] bi2_sel;
    wire [1:0] bi1_o_sel;
    wire [1:0] addr_sel;
    wire [1:0] dout_sel;
    wire [1:0] w_sel;
    wire [1:0] i_sel;
    wire [1:0] fpo_sel;
    
    
    
    assign b = N[9:2];
    assign c = K[9:2];
    
    assign bi2 = base_addr_in2 + 4 * K * i_value + 4 * j_value;
    assign bi1 = base_addr_in1 + 4 * i_value;
    assign bo = base_addr_out + 4 * j_value;
    
    assign bi2_val = bi2_sel;
    assign bi1_o_val = bi2_sel;
    
    assign addr_in2 = bi2_q + bi2_val;
    assign addr_in1 = bi1_q + N * h_value + bi1_o_val;
    assign addr_out = bo_q + K * (h_value - 4) + bi1_o_val;
    
    assign addr_mem = (addr_sel == 2'b00) ? addr_in2 :
                      (addr_sel == 2'b01) ? addr_in1 :
                      (addr_sel == 2'b10) ? addr_out : 0;
                      
    assign weight_o = (dout_sel == 2'b00) ? dout_mem[7:0] : 0;
    assign in_o = (dout_sel == 2'b01) ? dout_mem[7:0] : 0;
    assign result = (dout_sel == 2'b10) ? dout_mem : 0;
    
    assign weight[0] = (w_sel == 2'b00) ? weight_o : 0;
    assign weight[1] = (w_sel == 2'b01) ? weight_o : 0;
    assign weight[2] = (w_sel == 2'b10) ? weight_o : 0;
    assign weight[3] = (w_sel == 2'b11) ? weight_o : 0;
    
    assign in[0] = (i_sel == 2'b00) ? in_o : 0;
    assign in[1] = (i_sel == 2'b01) ? in_o : 0;
    assign in[2] = (i_sel == 2'b10) ? in_o : 0;
    assign in[3] = (i_sel == 2'b11) ? in_o : 0;
    
    assign f_pe_output = (fpo_sel == 2'b00) ? pe_output[12] : 
                         (fpo_sel == 2'b01) ? pe_output[13] :
                         (fpo_sel == 2'b10) ? pe_output[14] :
                         (fpo_sel == 2'b11) ? pe_output[15] : 0;
                         
    assign f_result = result + f_pe_output;
    assign din_mem = f_result_q;
     
endmodule