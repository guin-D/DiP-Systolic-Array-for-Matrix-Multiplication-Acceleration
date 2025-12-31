module button_debouncer(
    input wire clk,
    input wire btn_in,
    output reg btn_out
);
    reg [19:0] cnt;
    reg btn_sync_0, btn_sync_1;
    always @(posedge clk) begin
        btn_sync_0 <= btn_in;
        btn_sync_1 <= btn_sync_0;
        if (btn_sync_1 == btn_out) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1;
            if (cnt == 20'hFFFF) begin // hFFFF~10ms
                btn_out <= btn_sync_1;
            end
        end
    end
endmodule
