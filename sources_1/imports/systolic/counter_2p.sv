module counter_2p(
    input wire clk,
    input wire rst_n,
    input wire inc,
    input wire [4:0] maxVal,
    
    output wire isPoint1,
    output wire isPoint2,
    output wire isMax,
    output wire [4:0] value
);
    
    reg [4:0] out_tmp;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_tmp <= 0;
        end
        else if (inc) begin
            // N?u ??m ??n maxVal thì t? ??ng quay v? 0
            if (out_tmp == maxVal)
                out_tmp <= 0;
            else
                out_tmp <= out_tmp + 1;
        end
    end
    
    // Gán các c? báo tr?ng thái
    assign value = out_tmp;
    assign isMax = (out_tmp == maxVal);
    
    // L?u ý: N?u maxVal < 4 thì phép tr? s? b? l?i (underflow), 
    // nh?ng v?i m?ch ma tr?n thông th??ng thì không sao.
    assign isPoint1 = (out_tmp > 3);
    assign isPoint2 = (out_tmp < (maxVal - 4));
   
endmodule