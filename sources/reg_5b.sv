module reg_5b(
    input clk,
    input rst_n,
    input en,
    input [4:0]d,
    
    output reg [4:0]q
    );
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 0) begin
            q <= 5'b0;
        end
        else if (en == 1) begin
            q <= d;
        end
    end
endmodule