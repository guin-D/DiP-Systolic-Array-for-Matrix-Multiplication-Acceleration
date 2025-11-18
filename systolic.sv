`timescale 1ns / 1ps

module systolic
    #(
    parameter N=4
    )(
    input clk,
    input rst_n,
    
    
    input wshift,
    input pe_en,
    input mul_en,
    input adder_en,
    
    
    input [23:0]psum[N-1:0],
    input [7:0]weight[N-1:0],
    input [7:0]I[N-1:0],
    
    output [23:0]pe_output[N-1:0]
    );
    
    wire [23:0] wire_psum_out[N-1:0][N-1:0];
    wire [7:0]  wire_weight_out [N-1:0][N-1:0];
    wire [7:0]  wire_I_out [N-1:0][N-1:0];
    
    
    genvar i, j;
    generate 
        for(i=0; i<N; i++) begin: ROW
            for(j=0; j<N; j++) begin: COL
                wire [23:0] p_in_curr;
                wire [7:0] w_in_curr;
                wire [7:0] I_in_curr;
                
                //psum
                if(i==0) begin
                    assign p_in_curr = psum[j];
                end else begin
                    assign p_in_curr = wire_psum_out[i-1][j];
                end
                
                
                //weight
                if(i==0) begin
                    assign w_in_curr = weight[j];
                end else begin 
                    assign w_in_curr = wire_weight_out[i-1][j];
                end    
                    
                //input
                if(i==0) begin
                    assign I_in_curr = I[j];
                end else if(j==N-1) begin
                    assign I_in_curr = wire_I_out[i-1][0];
                end else begin
                    assign I_in_curr = wire_I_out[i-1][j+1];
                end
                
                pe inst(
                    .clk(clk),
                    .rst_n(rst_n),
                    .wshift(wshift),
                    .pe_en(pe_en),
                    .mul_en(mul_en),
                    .adder_en(adder_en),
                    
                    .psum(p_in_curr),
                    .weight(w_in_curr),
                    .Inp(I_in_curr),
                    
                    .pe_output(wire_psum_out[i][j]),
                    .weight_shifted(wire_weight_out[i][j]),
                    .Input_shifted(wire_I_out[i][j])
                );
           end
       end
    endgenerate
    
    
    genvar k;
    generate
        for(k=0; k<N; k++) begin:OUT
            assign pe_output[k] = wire_psum_out[N-1][k];
        end
    endgenerate
endmodule
