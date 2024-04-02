`timescale 1ns / 1ps

module CRC8_tb;

reg clk_tb = 1;
reg rst_tb;
reg [15:0] func_y_tb;
reg start_tb = 0;
reg [8:0] i;
reg [8:0] count_tb;
wire busy_tb;
wire [7:0] crc_tb;


CRC8 crc8_tb(
    .clk(clk_tb),
    .rst(rst_tb),
    .data(func_y_tb),
    .start_i(start_tb),
    .count(count_tb),
    .busy(busy_tb),
    .crc_res(crc_tb)
);

always begin
    #5 clk_tb = !clk_tb;
end

initial begin
    rst_tb = 1;
    #1
    rst_tb = 0;
    func_y_tb = 2120;
    count_tb = 3;
    #1
    start_tb = 1;
    #5000
    #1
    func_y_tb = 8469;
    #1
    start_tb = 1;
    #5000
    #1
    func_y_tb = 33860;
    #1
    start_tb = 1;
    #5000
    if (~busy_tb) begin
        $display("crc = %d", crc_tb);
    end
    
    
    $stop;
end

always @(posedge clk_tb)
    if (start_tb && busy_tb) begin
        start_tb = 0;
    end     

endmodule
