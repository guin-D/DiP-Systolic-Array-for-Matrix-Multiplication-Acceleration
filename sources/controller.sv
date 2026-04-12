`timescale 1ns / 1ps

module controller (
    input  logic rst_n, clk,
    input  logic start,
    output logic done,
    
    //error signal
    output logic err_cal,
    input logic err_found,

    // pre-counter control signals
    output logic b_en, c_en, h_m_en,
    output logic M_en, N_en, K_en,
    output logic bai1_en, bai2_en, bao_en,
    

    // counter control signals
    output logic i_cnt, j_cnt, h_cnt,	
	output logic i_rstn, j_rstn, h_rstn,
    input  logic i_max, j_max, h_max, h_in_point, h_out_point,

    // addr cal control signals
    output logic base_cal,
    output logic [3:0] bi2_sel, bi1_o_sel,

    // addr reg control signals
    output logic ai2_en, ai1_en, ao_en,

    // pre-addr mux control signal
    output logic a_en,
    output logic [1:0] addr_sel,

    // am reg control signal
    output logic am_en,

    // DM out control signal
    output logic [1:0] dout_sel,

    // weight control signal
    output logic [1:0] w_sel,

    // input control signal
    output logic [1:0] i_sel,
    
    //result_buffer control signal
    output logic buf_en,

    // systolic control signals
    output logic wshift,
    output logic [3:0] pe_en, mul_en, adder_en,

    // f-out-sel reg control signal
    output logic d_en,
    output logic [1:0] fpo_sel,

    // f-out reg control signal
    output logic fout_en,

    // f-result reg control signal
    output logic dm_en,
    
    //memory control signals
    output logic w
);

    //==================================================
    // State definition 
    //==================================================
    typedef enum logic [5:0] {
        INIT,               
        
        START1_CHECK, 
        SETUP,      
        ERROR_CHECK,

        s1, s2, s3, s4, s5, 
        s6, s7, s8, s9, s10, s11, s12, s13,
        s14, s15, s16, s17, s18, s19, s20, s21,
        s22, s23, s24, s25, s26, s27,

        s28, s29,
        s30, s31, s32, s33, s34,
        s35, s36, s37, s38, s39,
        s41, s42, s43, s44, s45, s46,
        s47, s48, s49, s50, s51, 
        
        s52, s53, s54,

        DONE_1,            
        START0_CHECK,      
        DONE_0             
    } state_t;

    (* MARK_DEBUG = "true" *) state_t state;
    state_t next_state;
	
	reg i_rst, j_rst, h_rst;
	assign i_rstn = ~i_rst;
	assign j_rstn = ~j_rst;
	assign h_rstn = ~h_rst;

    //==================================================
    // 1. State Register Update (Sequential)
    //==================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= INIT;
        else
            state <= next_state;
    end

    //==================================================
    // 2. Next State Logic (Combinational)
    //    Ch? tính toán ???ng ?i, không quan tâm ngõ ra
    //==================================================
    always_comb begin
        next_state = state; // Default

        case (state)
            INIT:           next_state = START1_CHECK;
            
            
            START1_CHECK:   if (start) next_state = SETUP;
                            else       next_state = START1_CHECK;
            SETUP:                      next_state = ERROR_CHECK;
            ERROR_CHECK:    if(err_found) next_state = START0_CHECK;
                            else        next_state = s1;

            s1:             next_state = s2;
            s2:             if(!j_max) next_state = s3;
                            else       next_state = DONE_1;
            
            s3:             next_state = s4;
            s4: begin
                        if(!i_max) next_state = s5;
                            else       next_state = s54;
                            end
            
            s5:  next_state = s6;
            s6:  next_state = s7;
            s7:  next_state = s8;
            s8:  next_state = s9;
            s9:  next_state = s10;
            s10: next_state = s11;
            s11: next_state = s12;
            s12: next_state = s13;
            s13: next_state = s14;
            s14: next_state = s15;
            s15: next_state = s16;
            s16: next_state = s17;
            s17: next_state = s18;
            s18: next_state = s19;
            s19: next_state = s20;
            s20: next_state = s21;
            s21: next_state = s22;
            s22: next_state = s23;
            s23: next_state = s24;
            s24: next_state = s25;
            s25: next_state = s26;
            s26: next_state = s27;
            s27: next_state = s28;

            s28:            if(!h_max) next_state = s29;
                            else       next_state = s53;
            
            s29:            if(h_out_point) next_state = s30;
                            else            next_state = s41;

            s30: next_state = s31;
            s31: next_state = s32;
            s32: next_state = s33;
            s33: next_state = s34;
            s34: next_state = s35;
            s35: next_state = s36;
            s36: next_state = s37;
            s37: next_state = s38;
            s38: next_state = s39;
            s39:            if(h_in_point) next_state = s41;
                            else           next_state = s49;           

            s41: next_state = s42;
            s42: next_state = s43;
            s43: next_state = s44;
            s44: next_state = s45;
            s45: next_state = s46;
            s46: next_state = s47;
            s47: next_state = s48;
            s48: next_state = s49;
            s49: next_state = s50;
            s50: next_state = s51;
            s51: next_state = s52;
            
            s52: next_state = s28;// Loop h
            s53: next_state = s4; // Loop j
            s54: next_state = s2;  // Loop i 


            DONE_1:         next_state = START0_CHECK;
            START0_CHECK:   if(start) next_state = DONE_0;
                            else       next_state = START0_CHECK;
            DONE_0:         next_state = INIT;
            
            default:        next_state = INIT;
        endcase
    end

    //==================================================
//    [cite_start]// 3. Output Logic (Sequential / Registered) [cite: 1]
    //    D?a trên NEXT_STATE ?? tránh tr? 1 nh?p
    //==================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all outputs
            done <= 0;
            b_en <= 0; c_en <= 0; h_m_en <= 0;
            i_cnt <= 0; j_cnt <= 0; h_cnt <= 0;	
			i_rst <= 0; j_rst <= 0; h_rst <= 0;
            base_cal <= 0;
            bi2_sel <= 0; bi1_o_sel <= 0;
            ai2_en <= 0; ai1_en <= 0; ao_en <= 0;
            a_en <= 0; addr_sel <= 0;
            am_en <= 0; dout_sel <= 2'b11;
            w_sel <= 2'b11; i_sel <= 2'b11;
            buf_en <= 0; wshift <= 0;
            pe_en <= 0; mul_en <= 0; adder_en <= 0;
            d_en <= 0; fpo_sel <= 0;
            fout_en <= 0; dm_en <= 0;
            w <= 0; 
            M_en <= 0; N_en <= 0; K_en <= 0;
            bai1_en <= 0; bai2_en <= 0; bao_en <= 0;
        end else begin
            // ------------------------------------
            // Default Values (Quan tr?ng ?? t? xóa v? 0 ? nh?p sau)
            // ------------------------------------
            done <= 0;
            b_en <= 0; c_en <= 0; h_m_en <= 0;
            i_cnt <= 0; j_cnt <= 0; h_cnt <= 0;
			i_rst <= 0; j_rst <= 0; h_rst <= 0;
            base_cal <= 0;
            bi2_sel <= 0; bi1_o_sel <= 0;
            ai2_en <= 0; ai1_en <= 0; ao_en <= 0;
            a_en <= 0; addr_sel <= 0;
            am_en <= 0; dout_sel <= 2'b11;
            w_sel <= 2'b11; i_sel <= 2'b11;
            buf_en <= 0; wshift <= 0;
            pe_en <= 0; mul_en <= 0; adder_en <= 0;
            d_en <= 0; fpo_sel <= 0;
            fout_en <= 0; dm_en <= 0;
            w <= 0; 
            M_en <= 0; N_en <= 0; K_en <= 0;
            bai1_en <= 0; bai2_en <= 0; bao_en <= 0;
            // ------------------------------------
            // Output Assignments based on NEXT_STATE
            // ------------------------------------
            case (next_state)
                SETUP: begin
                    // Gi? s? c?n enable ?? load giá tr? ban ??u
                    b_en <= 1; c_en <= 1; h_m_en <= 1;
                    M_en <= 1; N_en <= 1; K_en <= 1;
                    bai1_en <= 1; bai2_en <= 1; bao_en <= 1;
                    err_cal <= 1;
                end			  
				
				s1: j_rst <= 1'b1;
				
				s3: i_rst <= 1'b1;

                s5: begin
                    base_cal <= 1'b1;
                end
                
                s6: begin
                    ai2_en <= 1'b1; bi2_sel <= 4'b1100; addr_sel <= 2'b00; a_en <= 1'b1;
                end
                
                s7: begin
                    ai2_en <= 1'b1; am_en <= 1'b1;  bi2_sel <= 4'b0001;
                end
                
                s8: begin
                    ai2_en <= 1'b1; am_en <= 1'b1; bi2_sel <= 4'b0110;
                end
                
                s9: begin
                    ai2_en <= 1'b1; am_en <= 1'b1; bi2_sel <= 4'b1011; dout_sel <= 2'b00;
                    
                end
                
                s10: begin
                    ai2_en <= 1'b1; am_en <= 1'b1; bi2_sel <= 4'b1000;  dout_sel <= 2'b00; w_sel <= 2'b00;
                end
                
                s11: begin
                    ai2_en <= 1'b1; am_en <= 1'b1; bi2_sel <= 4'b1101;  dout_sel <= 2'b00; w_sel <= 2'b01;
                end
                
                s12: begin
                    ai2_en <= 1'b1; am_en <= 1'b1; bi2_sel <= 4'b0010;  dout_sel <= 2'b00; w_sel <= 2'b10;
                end
                
                s13: begin
                    ai2_en <= 1'b1; am_en <= 1'b1; bi2_sel <= 4'b0111;   dout_sel <= 2'b00; w_sel <= 2'b11; 
                end

                s14: begin
                    ai2_en <= 1'b1; am_en <= 1'b1; bi2_sel <= 4'b0100;  dout_sel <= 2'b00; w_sel <= 2'b00; wshift <= 1'b1;
                end

                s15: begin
                    ai2_en <= 1'b1; am_en <= 1'b1; bi2_sel <= 4'b1001;  dout_sel <= 2'b00; w_sel <= 2'b01; 
                end

                s16: begin
                    ai2_en <= 1'b1; am_en <= 1'b1; bi2_sel <= 4'b1110;  dout_sel <= 2'b00; w_sel <= 2'b10;
                end

                s17: begin
                    ai2_en <= 1'b1; am_en <= 1'b1; bi2_sel <= 4'b0011; 
                     dout_sel <= 2'b00; w_sel <= 2'b11; 
                end

                s18: begin
                    ai2_en <= 1'b1; am_en <= 1'b1; bi2_sel <= 4'b0000;  dout_sel <= 2'b00; w_sel <= 2'b00; wshift <= 1'b1;
                end

                s19: begin
                    ai2_en <= 1'b1; am_en <= 1'b1; bi2_sel <= 4'b0101;  dout_sel <= 2'b00; w_sel <= 2'b01; 
                end

                s20: begin
                    ai2_en <= 1'b1; am_en <= 1'b1; bi2_sel <= 4'b1010;  dout_sel <= 2'b00; w_sel <= 2'b10;
                end

                s21: begin
                    ai2_en <= 1'b1; am_en <= 1'b1; bi2_sel <= 4'b1111;  dout_sel <= 2'b00; w_sel <= 2'b11; 
                end

                s22: begin
                    am_en <= 1'b1;  dout_sel <= 2'b00; w_sel <= 2'b00; wshift <= 1'b1;
                end
                
                s23: begin
                    dout_sel <= 2'b00; w_sel <= 2'b01; 
                end
                
                s24: begin
                     dout_sel <= 2'b00; w_sel <= 2'b10;
                end
                
                s25: begin
                    dout_sel <= 2'b00; w_sel <= 2'b11; 
                end
                
                s26: begin
                    dout_sel <= 2'b00; wshift <= 1'b1;
                end
                
                s27: begin 
					h_rst <= 1'b1;
				end

                s30: begin
                     bi1_o_sel <= 4'b0000; addr_sel <= 2'b10; a_en <= 1'b1;  ao_en <= 1'b1;
                end 
                
                s31: begin
                     ao_en <= 1'b1; bi1_o_sel <= 4'b0001; am_en <= 1'b1;
                end
                
                s32: begin
                    am_en <= 1'b1; ao_en <= 1'b1; bi1_o_sel <= 4'b0010;
                end
                
                s33: begin
                    am_en <= 1'b1; ao_en <= 1'b1; bi1_o_sel <= 4'b0011; 
                    dout_sel <= 2'b10; 
                    
                end
                
                s34: begin
                    am_en <= 1'b1; ao_en <= 1'b1; bi1_o_sel <= 4'b0000; 
                    dout_sel <= 2'b10; buf_en <= 1'b1; 
                    d_en <= 1'b1; fpo_sel <= 2'b00; fout_en <= 1'b1; 
                end

                s35: begin
                    am_en <= 1'b1; ao_en <= 1'b1; bi1_o_sel <= 4'b0001; 
                    dout_sel <= 2'b10; buf_en <= 1'b1; 
                    d_en <= 1'b1; fpo_sel <= 2'b01; fout_en <= 1'b1; dm_en <= 1'b1;
                end

                s36: begin
                    am_en <= 1'b1; ao_en <= 1'b1; bi1_o_sel <= 4'b0010; 
                    dout_sel <= 2'b10; buf_en <= 1'b1; 
                    d_en <= 1'b1; fpo_sel <= 2'b10; fout_en <= 1'b1; dm_en <= 1'b1; w <= 1'b1;
                end

                s37: begin
                    am_en <= 1'b1; ao_en <= 1'b1; bi1_o_sel <= 4'b0011;
                    buf_en <= 1'b1;
                    d_en <= 1'b1; fpo_sel <= 2'b11; fout_en <= 1'b1;
                    dm_en <= 1'b1; w <= 1'b1;
                end

                s38: begin
                    am_en <= 1'b1;
                    dm_en <= 1'b1;
                    w <= 1'b1;
                end
                
                s39: begin
                     w <= 1'b1;
                end
                
                s41: begin
                    bi1_o_sel <= 4'b0000; ai1_en <= 1'b1; addr_sel <= 2'b01; a_en <= 1'b1;
                end
                
                s42: begin
                    ai1_en <= 1'b1; bi1_o_sel <= 4'b0001; am_en <= 1'b1;
                end
                
                s43: begin
                    ai1_en <= 1'b1; am_en <= 1'b1; bi1_o_sel <= 4'b0010;
                end
                
                s44: begin
                    ai1_en <= 1'b1; am_en <= 1'b1; bi1_o_sel <= 4'b0011;  dout_sel <= 2'b01;
                end
                
                s45: begin
                     am_en <= 1'b1;  dout_sel <= 2'b01; i_sel <= 2'b00;
                end
                
                s46: begin
                     dout_sel <= 2'b01; i_sel <= 2'b01;
                end
                
                s47: begin
                     dout_sel <= 2'b01;  i_sel <= 2'b10;
                end
                
                s48: begin
                   i_sel <= 2'b11;
                end
                
                s49: pe_en <= 4'b1111; // Enable PE
                
                s50: mul_en <= 4'b1111; // Enable MUL
                s51: adder_en <= 4'b1111; // Enable Adder

                // ==========================================
                
                // ==========================================
                s52: h_cnt <= 1'b1;
                s53: i_cnt <= 1'b1;
                s54: j_cnt <= 1'b1;

                DONE_1: done <= 1'b1;
                START0_CHECK: done <= 1'b1;
                
                default: ; // Do nothing (keep 0 as per default block)
            endcase
        end
    end

endmodule