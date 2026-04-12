module reg_8b(
    input clk,
    input rst_n,
    input en,
    input [7:0]d,
    
    output reg [7:0]q
    );
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 0) begin
            q <= 8'b0;
        end
        else if (en == 1) begin
            q <= d;
        end
    end
endmodule