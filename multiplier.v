`timescale 1ns / 1ps

module multiplier(
    input [7:0]a, b,
    
    output [15:0]p
    );
    assign p = a * b;
endmodule
