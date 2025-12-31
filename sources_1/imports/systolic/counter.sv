module counter(
    input clk,
    input rst_n,
    input inc,
    input [1:0] maxVal,
    output isMax,
    output [1:0] value
);
    
    reg [1:0] out_tmp = 7'b000_000_0;
    
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 1'b0) begin
            out_tmp <= 2'b00;
        end
        else if (inc == 1'b1) begin
            out_tmp <= out_tmp + 1;
        end
   end
   
   assign isMax = (value == maxVal);
   assign value = out_tmp;
   
endmodule