module systolic #(
    parameter N = 4
)(
    input clk,
    input rst_n,
    
    // Control signals
    (* MARK_DEBUG = "true" *) input wshift,                      
    (* MARK_DEBUG = "true" *) input [N-1:0] pe_en,                
    (* MARK_DEBUG = "true" *) input [N-1:0] mul_en,               
    (* MARK_DEBUG = "true" *) input [N-1:0] adder_en,             
    
    // Inputs (Packed)
        
    input [8*N-1:0]  weight_flat, 
    input [8*N-1:0]  I_flat,       
    
    // Outputs (Packed)
    output [24*N-1:0] pe_output_flat 
);
    
    // ====================================================
    // 1. UNPACKING INPUTS
    // ====================================================
    wire [23:0] psum_in [0:N-1];
    (* MARK_DEBUG = "true" *) wire [7:0]  w_in    [0:N-1];
    wire [7:0]  I_in    [0:N-1];

    genvar k;
    generate
        for (k = 0; k < N; k = k + 1) begin : UNPACK
            assign psum_in[k] = 0;
            assign w_in[k]    = weight_flat[8*(k+1)-1 : 8*k];
            assign I_in[k]    = I_flat[8*(k+1)-1 : 8*k];
        end
    endgenerate

    // ====================================================
    // 2. INTERNAL WIRES DEFINITION
    // Format: wire_<signal>_<row>_<col>
    // ====================================================
    
    // Row 0 Outputs
    (* MARK_DEBUG = "true" *) wire [23:0] p_out_00, p_out_01, p_out_02, p_out_03;
    wire [7:0]  w_out_00, w_out_01, w_out_02, w_out_03;
    (* MARK_DEBUG = "true" *) wire [7:0]  i_out_00, i_out_01, i_out_02, i_out_03;

    // Row 1 Outputs
    (* MARK_DEBUG = "true" *) wire [23:0] p_out_10, p_out_11, p_out_12, p_out_13;
    wire [7:0]  w_out_10, w_out_11, w_out_12, w_out_13;
    (* MARK_DEBUG = "true" *) wire [7:0]  i_out_10, i_out_11, i_out_12, i_out_13;

    // Row 2 Outputs
    (* MARK_DEBUG = "true" *) wire [23:0] p_out_20, p_out_21, p_out_22, p_out_23;
    wire [7:0]  w_out_20, w_out_21, w_out_22, w_out_23;
    (* MARK_DEBUG = "true" *) wire [7:0]  i_out_20, i_out_21, i_out_22, i_out_23;

    // Row 3 Outputs
    (* MARK_DEBUG = "true" *) wire [23:0] p_out_30, p_out_31, p_out_32, p_out_33;
    wire [7:0]  w_out_30, w_out_31, w_out_32, w_out_33;
    (* MARK_DEBUG = "true" *) wire [7:0]  i_out_30, i_out_31, i_out_32, i_out_33;

    // ====================================================
    // 3. STRUCTURAL INSTANTIATION (16 PEs)
    // ====================================================

    // ---------------- ROW 0 ----------------
    // from inputs
    pe pe_00 (.clk(clk), .rst_n(rst_n), .wshift(wshift), .pe_en(pe_en[0]), .mul_en(mul_en[0]), .adder_en(adder_en[0]),
        .psum(psum_in[0]), .weight(w_in[0]), .Inp(I_in[0]),
        .pe_output(p_out_00), .weight_shifted(w_out_00), .Input_shifted(i_out_00));

    pe pe_01 (.clk(clk), .rst_n(rst_n), .wshift(wshift), .pe_en(pe_en[0]), .mul_en(mul_en[0]), .adder_en(adder_en[0]),
        .psum(psum_in[1]), .weight(w_in[1]), .Inp(I_in[1]),
        .pe_output(p_out_01), .weight_shifted(w_out_01), .Input_shifted(i_out_01));

    pe pe_02 (.clk(clk), .rst_n(rst_n), .wshift(wshift), .pe_en(pe_en[0]), .mul_en(mul_en[0]), .adder_en(adder_en[0]),
        .psum(psum_in[2]), .weight(w_in[2]), .Inp(I_in[2]),
        .pe_output(p_out_02), .weight_shifted(w_out_02), .Input_shifted(i_out_02));

    pe pe_03 (.clk(clk), .rst_n(rst_n), .wshift(wshift), .pe_en(pe_en[0]), .mul_en(mul_en[0]), .adder_en(adder_en[0]),
        .psum(psum_in[3]), .weight(w_in[3]), .Inp(I_in[3]),
        .pe_output(p_out_03), .weight_shifted(w_out_03), .Input_shifted(i_out_03));


    // ---------------- ROW 1 ----------------
    // Vertical inputs: L?y t? Row 0 cùng c?t.
    // Diagonal Inputs: PE[1][0] <= PE[0][1], PE[1][1] <= PE[0][2], ..., PE[1][3] <= PE[0][0] (Wrap)
    
    pe pe_10 (.clk(clk), .rst_n(rst_n), .wshift(wshift), .pe_en(pe_en[1]), .mul_en(mul_en[1]), .adder_en(adder_en[1]),
        .psum(p_out_00), .weight(w_out_00), .Inp(i_out_01), // Diag: From 01
        .pe_output(p_out_10), .weight_shifted(w_out_10), .Input_shifted(i_out_10));

    pe pe_11 (.clk(clk), .rst_n(rst_n), .wshift(wshift), .pe_en(pe_en[1]), .mul_en(mul_en[1]), .adder_en(adder_en[1]),
        .psum(p_out_01), .weight(w_out_01), .Inp(i_out_02), // Diag: From 02
        .pe_output(p_out_11), .weight_shifted(w_out_11), .Input_shifted(i_out_11));

    pe pe_12 (.clk(clk), .rst_n(rst_n), .wshift(wshift), .pe_en(pe_en[1]), .mul_en(mul_en[1]), .adder_en(adder_en[1]),
        .psum(p_out_02), .weight(w_out_02), .Inp(i_out_03), // Diag: From 03
        .pe_output(p_out_12), .weight_shifted(w_out_12), .Input_shifted(i_out_12));

    pe pe_13 (.clk(clk), .rst_n(rst_n), .wshift(wshift), .pe_en(pe_en[1]), .mul_en(mul_en[1]), .adder_en(adder_en[1]),
        .psum(p_out_03), .weight(w_out_03), .Inp(i_out_00), // Diag: From 00 (WRAP)
        .pe_output(p_out_13), .weight_shifted(w_out_13), .Input_shifted(i_out_13));


    // ---------------- ROW 2 ----------------
    // Vertical inputs: L?y t? Row 1.
    // Diagonal Inputs: PE[2][0] <= PE[1][1], PE[2][1] <= PE[1][2], ...
    
    pe pe_20 (.clk(clk), .rst_n(rst_n), .wshift(wshift), .pe_en(pe_en[2]), .mul_en(mul_en[2]), .adder_en(adder_en[2]),
        .psum(p_out_10), .weight(w_out_10), .Inp(i_out_11), 
        .pe_output(p_out_20), .weight_shifted(w_out_20), .Input_shifted(i_out_20));

    pe pe_21 (.clk(clk), .rst_n(rst_n), .wshift(wshift), .pe_en(pe_en[2]), .mul_en(mul_en[2]), .adder_en(adder_en[2]),
        .psum(p_out_11), .weight(w_out_11), .Inp(i_out_12), 
        .pe_output(p_out_21), .weight_shifted(w_out_21), .Input_shifted(i_out_21));

    pe pe_22 (.clk(clk), .rst_n(rst_n), .wshift(wshift), .pe_en(pe_en[2]), .mul_en(mul_en[2]), .adder_en(adder_en[2]),
        .psum(p_out_12), .weight(w_out_12), .Inp(i_out_13), 
        .pe_output(p_out_22), .weight_shifted(w_out_22), .Input_shifted(i_out_22));

    pe pe_23 (.clk(clk), .rst_n(rst_n), .wshift(wshift), .pe_en(pe_en[2]), .mul_en(mul_en[2]), .adder_en(adder_en[2]),
        .psum(p_out_13), .weight(w_out_13), .Inp(i_out_10), // WRAP: From 10
        .pe_output(p_out_23), .weight_shifted(w_out_23), .Input_shifted(i_out_23));


    // ---------------- ROW 3 ----------------
    // Vertical inputs: L?y t? Row 2.
    // Diagonal Inputs: PE[3][0] <= PE[2][1], ...
    
    pe pe_30 (.clk(clk), .rst_n(rst_n), .wshift(wshift), .pe_en(pe_en[3]), .mul_en(mul_en[3]), .adder_en(adder_en[3]),
        .psum(p_out_20), .weight(w_out_20), .Inp(i_out_21), 
        .pe_output(p_out_30), .weight_shifted(w_out_30), .Input_shifted(i_out_30));

    pe pe_31 (.clk(clk), .rst_n(rst_n), .wshift(wshift), .pe_en(pe_en[3]), .mul_en(mul_en[3]), .adder_en(adder_en[3]),
        .psum(p_out_21), .weight(w_out_21), .Inp(i_out_22), 
        .pe_output(p_out_31), .weight_shifted(w_out_31), .Input_shifted(i_out_31));

    pe pe_32 (.clk(clk), .rst_n(rst_n), .wshift(wshift), .pe_en(pe_en[3]), .mul_en(mul_en[3]), .adder_en(adder_en[3]),
        .psum(p_out_22), .weight(w_out_22), .Inp(i_out_23), 
        .pe_output(p_out_32), .weight_shifted(w_out_32), .Input_shifted(i_out_32));

    pe pe_33 (.clk(clk), .rst_n(rst_n), .wshift(wshift), .pe_en(pe_en[3]), .mul_en(mul_en[3]), .adder_en(adder_en[3]),
        .psum(p_out_23), .weight(w_out_23), .Inp(i_out_20), // WRAP: From 20
        .pe_output(p_out_33), .weight_shifted(w_out_33), .Input_shifted(i_out_33));


    // ====================================================
    // 4. PACKING OUTPUTS
    // ====================================================
   
    
    assign pe_output_flat[24*1-1 : 24*0] = p_out_30;
    assign pe_output_flat[24*2-1 : 24*1] = p_out_31;
    assign pe_output_flat[24*3-1 : 24*2] = p_out_32;
    assign pe_output_flat[24*4-1 : 24*3] = p_out_33;

endmodule