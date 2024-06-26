`timescale 1ns / 1ps


module BIST_control_logic(
    input rst_i,
    input clk_i,
    input test_button,
    input start_work,
    input [15:0] sw_i,
    output busy_i,
    output reg [7:0] crc_i,
    output reg [7:0] number_of_self_tests_i,
    output test_m
);
    

reg rst_lfsr;
reg is_first_pol_i;
reg start;
reg [7:0] initial_num_i;
reg [7:0] LFSR1 = 8'b00010111;
reg [7:0] LFSR2 = 8'b00101101;  
wire busy_lfsr;
wire [7:0] generated_num_i;

LFSR_generator lfsr(
    .clk(clk_i),
    .rst(rst_lfsr), 
    .is_first_pol(is_first_pol_i),
    .start_i(start),
    .initial_num(initial_num_i),
    .busy(busy_lfsr),
    .generated_num(generated_num_i)
);
    
reg rst_func;
reg [15:0] sw;
reg [7:0] a;
reg [7:0] b;
reg start_func;
wire busy_func;
wire [15:0] y;

function_calculator func(
    .clk_i(clk_i),
    .rst_i(rst_func),
    .sw_i(sw),
    .start_i(start_func),
    .busy_o(busy_func),
    .y_calc(y)
);

reg rst_crc;
reg start_crc;
reg [8:0] count_crc;
wire busy_crc;
wire [7:0] crc;
 
CRC8 crc8(
    .clk(clk_i),
    .rst(rst_crc),
    .data(y),
    .start_i(start_crc),
    .count(count_crc),
    .busy(busy_crc),
    .crc_res(crc)
);

reg [7:0] number_of_self_tests;
reg [3:0] state;
reg [8:0] i;
reg [7:0] prev_LFSR1;
reg [7:0] prev_LFSR2;
reg test_mod;
reg start_test_signal;

localparam IDLE = 4'b0000;
localparam GENERATE_A = 4'b0001;
localparam WAIT_GEN_A = 4'b0010;
localparam GENERATE_B = 4'b0011;
localparam WAIT_GEN_B = 4'b0100;
localparam GENERATE_INPUT_DATA = 4'b0101;
localparam WAIT_CALC_FUNC_TEST = 4'b0110;
localparam WAIT_CALC_CRC = 4'b0111;
localparam PREPARE_LFSR = 4'b1000;
localparam CALC_FUNC = 4'b1001;
localparam IDLE_START = 4'b1010;
localparam WAIT_CALC_FUNC = 4'b1011;
localparam IDLE_CALC_FUNC = 4'b1100;
localparam WAIT_TEST_BUTTON = 4'b1101;
localparam WAIT_START_BUTTON = 4'b1110;
localparam END = 4'b1111;


assign busy_i = ~(state == IDLE_START || state == IDLE_CALC_FUNC); //todo
assign test_m = test_mod;

always @(posedge clk_i) begin
    if (rst_i) begin
        //todo
        rst_func <= 1;
        rst_crc <= 1;
        crc_i <= 0;
        rst_lfsr <= 1;
        number_of_self_tests_i <= 0;
        number_of_self_tests <= 1;
        state <= IDLE_CALC_FUNC;
        test_mod <= 0;
    end else begin
        case (state)
            IDLE_START:
                begin
                    rst_func <= 0;
                    rst_crc <= 0;
                    rst_lfsr <= 0;
                    if (test_button && test_mod) begin
                        state <= WAIT_TEST_BUTTON;
                        test_mod <= 0;
                    end
                    if (start_work && test_mod) begin
                            state <= WAIT_START_BUTTON;
                            i <= 0;
                            prev_LFSR1 <= LFSR1;
                            prev_LFSR2 <= LFSR2;
                            rst_crc <= 1;
                            //todo
                        end
                end
            GENERATE_A:
                begin
                    rst_crc <= 0;
                    is_first_pol_i <= 1;
                    start <= 1;
                    initial_num_i <= prev_LFSR1;
                    state <= WAIT_GEN_A;
                end
            WAIT_GEN_A:
                begin
                    start <= 0;
                    if (~busy_lfsr && ~start) begin
                        a <= generated_num_i;
                        state <= GENERATE_B;
                    end
                end
            GENERATE_B:
                begin
                    is_first_pol_i <= 0;
                    start <= 1;
                    initial_num_i <= prev_LFSR2;
                    state <= WAIT_GEN_B;
                end 
            WAIT_GEN_B:
                begin
                    start <= 0;
                    if (~busy_lfsr && ~start) begin
                        b <= generated_num_i;
                        state <= GENERATE_INPUT_DATA;
                    end
                end
            GENERATE_INPUT_DATA:
                begin
                    sw[15:8] <= a;
                    sw[7:0] <= b;
                    start_func <= 1;
                    state <= WAIT_CALC_FUNC_TEST;
                end
            WAIT_CALC_FUNC_TEST:
                begin
                    start_func <= 0;
                    if (~busy_func && ~start_func) begin
                        //todo data <= y автоматически
                        start_crc <= 1;
                        count_crc <= 256;
                        i <= i + 1;
                        state <= WAIT_CALC_CRC;
                    end
                end
            WAIT_CALC_CRC:
                begin
                    start_crc <= 0;
                    if (~busy_crc && ~start_crc) begin
                        if (i == 256) begin
                            state <= END;
                            //todo
                        end else begin
                            state <= PREPARE_LFSR;
                        end
                    end
                end
            PREPARE_LFSR:
                begin
                    prev_LFSR1 <= a;
                    prev_LFSR2 <= b;
                    state <= GENERATE_A;
                end
            END:
                begin
                    crc_i <= crc;
                    number_of_self_tests_i <= number_of_self_tests;
                    number_of_self_tests <=  number_of_self_tests + 1;
                    state <= IDLE_START;
                end
            IDLE_CALC_FUNC:
                begin
                    rst_func <= 0;
                    rst_crc <= 0;
                    rst_lfsr <= 0;
                    if (test_button && ~test_mod) begin
                        state <= WAIT_TEST_BUTTON;
                        test_mod <= 1;
                    end
                    if (start_work && ~test_mod) begin
                        state <= WAIT_START_BUTTON;
                    end
                end
            CALC_FUNC:
                begin   
                    sw <= sw_i;
                    start_func <= 1;
                    state <= WAIT_CALC_FUNC;
                end
            WAIT_CALC_FUNC:
                begin
                    start_func <= 0;
                    if (~busy_func && ~start_func) begin
                        crc_i <= y[15:8];
                        number_of_self_tests_i <= y[7:0];
                        state <= IDLE_CALC_FUNC;
                    end
                end    
            WAIT_TEST_BUTTON:
                begin
                    if (~test_button && ~test_mod) begin
                        state <= IDLE_CALC_FUNC;
                    end
                    if (~test_button && test_mod) begin
                        state <= IDLE_START;
                    end
                end
            WAIT_START_BUTTON:
                begin
                    if (~start_work && test_mod) begin
                        state <= GENERATE_A;
                    end
                    if (~start_work && ~test_mod) begin
                        state <= CALC_FUNC;
                    end
                end
        endcase
    end    
end

//always @(posedge test_button)
//    if (~busy_i) begin
//        if (test_mod) begin
//            test_mod <= 0;
//            state <= IDLE_CALC_FUNC;
//        end else begin
//            test_mod <= 1;
//            state <= IDLE_START;
//        end
//    end 

endmodule
