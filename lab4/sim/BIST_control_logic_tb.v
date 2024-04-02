`timescale 1ns / 1ps
module BIST_control_logic_tb;

reg clk_tb = 1;
reg rst_tb;
reg start_test;
reg start_tb = 0;
reg [15:0] sw;
reg [7:0] a;
reg [7:0] b;
reg [15:0] y;
wire busy_tb;
wire [7:0] crc_tb;
wire [7:0] number_of_self_tests_tb;
reg [7:0] i;
wire test_mod;

BIST_control_logic bist(
    .rst_i(rst_tb),
    .clk_i(clk_tb),
    .test_button(start_test),
    .start_work(start_tb),
    .sw_i(sw),
    .busy_i(busy_tb),
    .crc_i(crc_tb),
    .number_of_self_tests_i(number_of_self_tests_tb),
    .test_m(test_mod)
);
    
always begin
    #5 clk_tb = !clk_tb;
end

initial begin
    i = 0;
    rst_tb = 1;
    #10
    rst_tb = 0;
    start_test = 1;
    #10
    start_test = 0;
    #10
    while (i < 10) begin
        start_tb = 1;
        #10
        start_tb = 0;
        #478060
        if (~busy_tb) begin
            $display("crc = %d, number_of_self_tests = %d", crc_tb, number_of_self_tests_tb);
        end
        i = i + 1;
    end
    start_test = 1;
    #10
    start_test = 0;
    #10
    #10
    a = 15;
    b = 50;
    sw[15:8] = a;
    sw[7:0] = b;
    #10
    start_tb = 1;
    #10
    start_tb = 0;
    #1350
    if (~busy_tb) begin
        y[15:8] = crc_tb[7:0];
        y[7:0] = number_of_self_tests_tb[7:0];
        #10
        $display("a = %d, b = %d, y = %d, mod = %d", a, b, y, test_mod);
    end
    
//    #100
//    start_test = 1;
//    #1000000
//    start_test = 0;
//    #1000000
//    start_tb = 1;
//    #1000000
//    start_tb = 0;
//    #10000000
//    if (~busy_tb) begin
//        $display("crc = %d, number_of_self_tests = %d, mod = %d", crc_tb, number_of_self_tests_tb, test_mod);
//    end
//    #100
//    start_tb = 1;
//    #1000000
//    start_tb = 0;
//    #10000000
//    if (~busy_tb) begin
//        $display("crc = %d, number_of_self_tests = %d, mod = %d", crc_tb, number_of_self_tests_tb, test_mod);
//    end
//    #10
//    start_tb = 1;
//    #1000000
//    start_tb = 0;
//    #10000000
//    if (~busy_tb) begin
//        $display("crc = %d, number_of_self_tests = %d, mod = %d", crc_tb, number_of_self_tests_tb, test_mod);
//    end
//    #10
//    start_tb = 1;
//    #1000000
//    start_tb = 0;
//    #10000000
//    if (~busy_tb) begin
//        $display("crc = %d, number_of_self_tests = %d", crc_tb, number_of_self_tests_tb);
//    end
//    #100
//    start_tb = 1;
//    #1000000
//    start_tb = 0;
//    #10000000
//    if (~busy_tb) begin
//        $display("crc = %d, number_of_self_tests = %d", crc_tb, number_of_self_tests_tb);
//    end
    
//    #10
//    start_test = 1;
//    #1000000
//    start_test = 0;
//    #1000
//    a = 100;
//    b = 27;
//    sw[15:8] = a;
//    sw[7:0] = b;
//    #1000
//    start_tb = 1;
//    #1000000
//    start_tb = 0;
//    #10000000
//    if (~busy_tb) begin
//        y[15:8] = crc_tb[7:0];
//        y[7:0] = number_of_self_tests_tb[7:0];
//        #1000
//        $display("a = %d, b = %d, y = %d, mod = %d", a, b, y, test_mod);
//    end
    
//    #1000
//    a = 200;
//    b = 126;
//    sw[15:8] = a;
//    sw[7:0] = b;
//    #1000000
//    start_tb = 1;
//    #1000000
//    start_tb = 0;
//    #10000000
//    if (~busy_tb) begin
//        y[15:8] = crc_tb[7:0];
//        y[7:0] = number_of_self_tests_tb[7:0];
//        #1000
//        $display("a = %d, b = %d, y = %d", a, b, y);
//    end
    
//    #100
//    start_test = 1;
//    #1000000
//    start_test = 0;
//    #1000000
//    start_tb = 1;
//    #1000000
//    start_tb = 0;
//    #10000000
//    if (~busy_tb) begin
//        $display("crc = %d, number_of_self_tests = %d", crc_tb, number_of_self_tests_tb);
//    end
    
//    #1000
//    start_tb = 1;
//    #1000000
//    start_tb = 0;
//    #10000000
//    if (~busy_tb) begin
//        $display("crc = %d, number_of_self_tests = %d", crc_tb, number_of_self_tests_tb);
//    end
    
//    #1000
//    start_tb = 1;
//    #1000000
//    start_tb = 0;
//    #10000000
//    if (~busy_tb) begin
//        $display("crc = %d, number_of_self_tests = %d", crc_tb, number_of_self_tests_tb);
//    end
    
//    #100
//    start_test = 1;
//    #1000000
//    start_test = 0;
//    #1000000
//    a = 50;
//    b = 255;
//    sw[15:8] = a;
//    sw[7:0] = b;
//    #1000
//    start_tb = 1;
//    #1000
//    start_tb = 0;
//    #10000000
//    if (~busy_tb) begin
//        y[15:8] = crc_tb[7:0];
//        y[7:0] = number_of_self_tests_tb[7:0];
//        #1000
//        $display("a = %d, b = %d, y = %d, mod = %d", a, b, y, test_mod);
//    end
    
    $stop;
end

always @(posedge clk_tb)
    if (start_test && busy_tb) begin
        start_test = 0;
    end 
endmodule
