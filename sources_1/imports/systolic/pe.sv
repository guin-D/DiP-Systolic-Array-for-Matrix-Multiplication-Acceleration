`timescale 1ns / 1ps
module pe (
    input clk, rst_n, wshift, pe_en, mul_en, adder_en,
    input [7:0] Inp, weight,
    input [23:0] psum,
    output [7:0] Input_shifted, weight_shifted,
    output reg [23:0] pe_output
);
    // 1. Weight Reg
    reg [7:0] w_reg;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) w_reg <= 0;
        else if(wshift) w_reg <= weight;
    end
    assign weight_shifted = w_reg;

    // 2. Input Reg
    reg [7:0] i_reg;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) i_reg <= 0;
        else if(pe_en) i_reg <= Inp;
    end
    assign Input_shifted = i_reg;

    // 3. MAC Pipeline
    reg signed [15:0] mul_reg;
    wire signed [15:0] mul_comb = $signed(w_reg) * $signed(i_reg);
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) mul_reg <= 0;
        else if(mul_en) mul_reg <= mul_comb;
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) pe_output <= 0;
        else if(adder_en) pe_output <= $signed(mul_reg) + $signed(psum);
    end
endmodule