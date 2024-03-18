`timescale 1ns / 1ps
module cuberoot(
    input clk_c,
    input rst_c,
    input [7:0] a,
    input start_c,
    output busy_o,
    output reg [3:0] y_bo
    );
    wire end_step;
    reg [7:0] x;
    reg [1:0] i;
    reg [4:0] state;
    reg [3:0] ans;
    reg [7:0] local_mask;
    reg [7:0] mask;
    reg [7:0] tmp;
    reg [15:0] tmp_mult_result;
    reg mult_start;
    wire mult_busy;
    
    reg [7:0] mult_a;
    reg [7:0] mult_b;
    wire [15:0] mult_result;
    multer multiplier(
        .clk_i(clk_c),
        .rst_i(rst_c),
        .a_bi(mult_a),
        .b_bi(mult_b),
        .start_i(mult_start),
        .busy_o(mult_busy),
        .y_bo(mult_result)
    );

    localparam IDLE = 0,
           CALC_SHIFT = 1,
           MASK = 2,
           NEW_ANS_BIT = 3,
           MUL1 = 4,
           WAIT_MUL1 = 5,
           MUL2 = 6,
           WAIT_MUL2 = 7,
           CHECK_X = 8,
           INVERT_ANS_BIT = 9,
           SUB_I = 10;    
    assign end_step = (i == 2'b11);
    assign busy_o = (state != IDLE);
    
    always @(posedge clk_c) begin
       if (rst_c) begin
            y_bo <= 0;
            i <= 0;
            mult_start <= 0;
            state <= IDLE;
            i <= 2'b10;
            local_mask <= 3'b111;
            mask <= 0;
       end else begin
            case(state)
                IDLE:
                    begin
                        if (start_c) begin
                            y_bo <= 0;
                            state <= CALC_SHIFT;
                            mult_start <= 0;
                            local_mask <= 3'b111;
                            mask <= 0;
                            x <= a;
                            i <= 2'b10;
                            ans <= 0;
                         end
                     end
                 CALC_SHIFT:
                    begin
                        mult_a <= 3;
                        mult_b <= i;
                        mult_start <= 1;
                        state <= MASK;
                    end
                 MASK:
                    begin
                        if (end_step) begin
                            y_bo <= ans;
                            state <= IDLE;
                        end else begin
                            mult_start <= 0;
                            if (~mult_busy && ~mult_start) begin
                                mask <= mask | (local_mask << (3 * i));
                                state <= NEW_ANS_BIT;
                            end
                        end
                    end
                 NEW_ANS_BIT:
                    begin
                        tmp <= x & mask;
                        ans <= ans ^ (1 << i);
                        state <= MUL1;
                    end
                 MUL1:
                    begin
                        mult_a <= ans;
                        mult_b <= ans;
                        mult_start <= 1;
                        state <= WAIT_MUL1;
                    end
                 WAIT_MUL1:
                    begin
                        mult_start <= 0;
                        if (~mult_busy && ~mult_start) begin
                            tmp_mult_result <= mult_result;
                            state <= MUL2;
                        end
                    end
                 MUL2:
                    begin
                        mult_a <= tmp_mult_result[7:0];
                        mult_b <= ans;
                        mult_start <= 1;
                        state <= CHECK_X;
                    end
                 CHECK_X:
                    begin
                       mult_start <= 0;
                       if (~mult_busy && ~mult_start) begin
                            tmp_mult_result <= mult_result;
                            state <= INVERT_ANS_BIT;
                       end 
                    end
                 INVERT_ANS_BIT:
                    begin
                        if (tmp < tmp_mult_result) begin
                            ans <= ans ^ (1 << i);
                        end
                        state <= SUB_I;
                    end
                 SUB_I: 
                    begin
                        if (i == 2'b00) begin
                            i <= 2'b11;
                        end else begin
                            i <= i - 1;
                        end
                        state <= CALC_SHIFT;
                    end
            endcase
       end
    end
   
endmodule