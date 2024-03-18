`timescale 1ns / 1ps

module function_calculator(
    input clk_i,
    input rst_i,
    input [15:0] sw_i,
    input start_i,
    output busy_o, 
    output reg [15:0] y_calc
 );
    
    localparam IDLE = 0,
    STEP = 1,
    WORK_MULT = 2,
    WORK_CUBEROOT = 3,
    WORK_SUM = 4;
    
    wire [7:0] a_i;
    wire [7:0] b_i;
    reg [4:0] state;
    reg [7:0] a;
    reg [7:0] b;
    wire [15:0] square_of_a;
    wire [3:0] cuberoot_result;
    reg [15:0] result;
    reg start_mult;
    reg start_cuberoot;
    wire mult_busy;
    wire cube_busy;
    reg [15:0] mult_result;
    reg [3:0] cube_result;
    
    assign a_i = sw_i[15:8];
    assign b_i = sw_i[7:0];
    
    multer mult(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .a_bi(a),
        .b_bi(a),
        .start_i(start_mult),
        .busy_o(mult_busy),
        .y_bo(square_of_a)
    );    

    cuberoot cube1(
        .clk_c(clk_i),
        .rst_c(rst_i),
        .a(b),
        .start_c(start_cuberoot),
        .busy_o(cube_busy),
        .y_bo(cuberoot_result)
    );
    
    assign busy_o = (state != IDLE);
    
    always @(posedge clk_i) begin
        if (rst_i) begin
            y_calc <= 0;
            start_cuberoot <= 0;
            start_mult <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE:
                    begin
                        if (start_i) begin
                            y_calc <= 0;
                            start_cuberoot <= 0;
                            state <= STEP;
                            start_mult <= 0;
                        end
                    end
                STEP:
                    begin
                        start_mult <= 1;
                        a <= a_i;
                        state <= WORK_MULT;
                    end
                WORK_MULT:
                    begin
                        start_mult <= 0;
                        if (~mult_busy && ~start_mult) begin
                            state <= WORK_CUBEROOT;
                            b <= b_i;
                            start_cuberoot <= 1;
                        end
                    end
                WORK_CUBEROOT:
                    begin
                        start_cuberoot <= 0;
                        if (~cube_busy && ~start_cuberoot) begin
                            state <= WORK_SUM;
                        end
                    end
                WORK_SUM:
                    begin
                        y_calc <= square_of_a + cuberoot_result;
                        state <= IDLE;
                    end
            endcase
        end
    end
    
endmodule
