module error_check (
    input clk,
    input rst_n,
    input err_cal,
    input [3:0] M, N, K,
    input [9:0] base_addr_in1,
    input [9:0] base_addr_in2,
    input [9:0] base_addr_out,
    output reg err_found
);

    wire sz_flag;
    
    assign sz_flag = (M < 4) | (N < 4) | (K < 4);   
    
    wire div_flag;
    
    assign div_flag = M[1] | M[0] | N[1] | N[0] | K[1] | K[0];
    
    wire [10:0] size1, size2, size3;
    
    assign size1 = M*N;
    assign size2 = N*K;
    assign size3 = M*K;
    
    wire [10:0] end1, end2, end3;
    
    assign end1 = base_addr_in1 + size1;
    assign end2 = base_addr_in2 + size2;
    assign end3 = base_addr_out + size3;
    
    wire ovf_flag;
    
    assign ovf_flag = end1[10] | end2[10] | end3[10];
    
    wire ovl_1_2, ovl_2_3, ovl_1_3;
    
    assign ovl_1_2 = (base_addr_in1 < end2) && (base_addr_in2 < end1);
    assign ovl_2_3 = (base_addr_in2 < end3) && (base_addr_out < end2);
    assign ovl_1_3 = (base_addr_in1 < end3) && (base_addr_out < end1);
    
    wire ovl_flag;
    
    assign ovl_flag = ovl_1_2 | ovl_2_3 | ovl_1_3;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            err_found <= 1'b0;
        end else if (err_cal) begin
            if (sz_flag || div_flag || ovf_flag || ovl_flag)
                err_found <= 1'b1;
            else
                err_found <= 1'b0;
        end
    end
    
endmodule