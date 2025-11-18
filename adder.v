`timescale 1ns / 1ps

module adder(
    input [15:0]a,
    input [23:0]b,
    
    output [23:0]s
    
    );
    
    assign s = a + b;
endmodule
