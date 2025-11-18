`timescale 1ns / 1ps
module pe(
    input [7:0]Inp,
    input [7:0]weight,
    input [23:0]psum,
    
    input clk,
    input wshift,
    input pe_en,
    input mul_en,
    input adder_en,
    input rst_n,
   
    output [7:0]Input_shifted,
    output [7:0]weight_shifted,
    output [23:0]pe_output
    );
    
    
    wire [7:0]weight_reg_out;
    register weight_reg (
    .clk(clk),
    .en(wshift),
    .rst_n(rst_n),
    .d(weight),
    .q(weight_reg_out)
    );
    assign weight_shifted = weight_reg_out;
    
    
    wire [7:0]Input_reg_out;
    register Input_reg (
    .clk(clk),
    .en(pe_en),
    .rst_n(rst_n),
    .d(Inp),
    .q(Input_reg_out)
    );
    assign Input_shifted = Input_reg_out;
    
    
    wire [15:0]mul_ans;
    multiplier mul(
    .a(weight_reg_out),
    .b(Input_reg_out),
    .p(mul_ans)
    );
    
    wire [15:0]mul_reg_out;
    register mul_reg (
    .clk(clk),
    .en(mul_en),
    .rst_n(rst_n),
    .d(mul_ans),
    .q(mul_reg_out)
    );
    
    wire [23:0]add_ans;
    adder add(
    .a(mul_reg_out),
    .b(psum),
    .s(add_ans)
    );
    
    register add_reg (
    .clk(clk),
    .en(adder_en),
    .rst_n(rst_n),
    .d(add_ans),
    .q(pe_output)
    );
endmodule
