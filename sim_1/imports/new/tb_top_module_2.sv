`timescale 1ns / 1ps

module tb_combined_test;

    // =========================================================
    // 1. PASTE CODE PYTHON IN RA VÀO ?ÂY
    // =========================================================
    int cfg_M[4]       = '{4, 8, 8, 12};
    int cfg_N[4]       = '{4, 4, 4, 12};
    int cfg_K[4]       = '{4, 8, 4, 12};
    int cfg_addr_A[4]  = '{0, 48, 176, 256};
    int cfg_addr_B[4]  = '{16, 80, 208, 400};
    int cfg_addr_C[4]  = '{32, 112, 224, 544};
    int cfg_gold_idx[4]= '{0, 16, 80, 112};
    int cfg_res_len[4] = '{16, 64, 32, 144};
    // =========================================================

    reg clk;
    reg rst_n;
    reg start;
    reg [3:0] M, N, K;
    reg [9:0] base_addr_in1, base_addr_in2, base_addr_out;
    wire done;
    wire [23:0] din_mem_out;
    wire w_out;
    wire err;

    // Expected 
    reg [23:0] expected_mem [0:1023]; 

    integer case_idx;
    integer i;
    integer err_total = 0;
    integer err_case = 0;
    reg [23:0] dut_val, gold_val;
    
    // DUT
    top_module dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .M(M), .N(N), .K(K),
        .base_addr_in1(base_addr_in1),
        .base_addr_in2(base_addr_in2),
        .base_addr_out(base_addr_out),
        .done(done),
        .din_mem_out(din_mem_out), .w_out(w_out), .err(err)
    );

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // MAIN PROCESS
    initial begin
    
        $readmemh("combined_gold.dat", expected_mem);
        
        rst_n = 0;
        start = 0;
        #100;
        rst_n = 1;
        #50;

        $display("--------------------------------------------------");
        $display(" STARTING AUTOMATED TEST FOR 4 CASES SEQUENCE ");
        $display("--------------------------------------------------");

        // --- LOOP QUA 4 TEST CASES ---
        for (case_idx = 0; case_idx < 4; case_idx++) begin
            
            M = cfg_M[case_idx][3:0];
            N = cfg_N[case_idx][3:0];
            K = cfg_K[case_idx][3:0];
            base_addr_in1 = cfg_addr_A[case_idx][9:0];
            base_addr_in2 = cfg_addr_B[case_idx][9:0];
            base_addr_out = cfg_addr_C[case_idx][9:0];

            $display("\n[CASE %0d] Config: %0dx%0dx%0d | OutAddr: %0d", 
                     case_idx + 1, M, N, K, base_addr_out);
            
            // Start Pulse
            @(negedge clk);
            start = 1;
            @(negedge clk);
            start = 0; 

            wait(done == 1);
            
            $display("[CASE %0d] Processing Done. Verifying...", case_idx + 1); 
            // Check result
            err_case = 0;
            for (i = 0; i < cfg_res_len[case_idx]; i++) begin
                // golden model data
                gold_val = expected_mem[cfg_gold_idx[case_idx] + i];

                // memory data
                dut_val = dut.bram_inst.inst.native_mem_module.blk_mem_gen_v8_4_2_inst.memory[base_addr_out + i];

                if (dut_val !== gold_val) begin
                    $display("   [FAIL] Offset %0d | Exp: %h | Act: %h", i, gold_val, dut_val);
                    err_case++;
                end
            end

            if (err_case == 0) 
                $display("[CASE %0d] PASSED!", case_idx + 1);
            else 
                $display("[CASE %0d] FAILED with %0d errors!", case_idx + 1, err_case);

            err_total += err_case;
            
            // Reset
            #50;
            rst_n = 0;
            #20;
            rst_n = 1;
            #50;
        end

        $display("\n==================================================");
        if (err_total == 0)
            $display(" FINAL RESULT: ALL 4 CASES PASSED PERFECTLY!");
        else
            $display(" FINAL RESULT: FAILED with total %0d errors.", err_total);
        $display("==================================================");
        
        $finish;
    end
    
    // Timeout
    initial begin
        #10000000; // 10ms
        $display("TIMEOUT GLOBAL!");
        $stop;
    end

endmodule

