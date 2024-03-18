`timescale 1ns / 1ps

module cuberoot_tb;

reg clk_tb = 1;
reg rst_tb;
reg [7:0] a_tb;
reg start_tb = 0;
reg [8:0] i;
reg flag = 0;
wire busy;
wire [3:0] y_tb;

cuberoot cube(
    .clk_c(clk_tb),
    .rst_c(rst_tb),
    .a(a_tb),
    .start_c(start_tb),
    .busy_o(busy),
    .y_bo(y_tb)
);
always begin
    #5 clk_tb = !clk_tb;
end

initial begin
    rst_tb = 1;
    #1
    rst_tb = 0;
    start_tb = 1;
    i = 0;
    while (i <= 256) begin
        a_tb = i;
        #10
        start_tb = 1;
        #2500
        if (~busy) begin
            $display("%d корень равен %d",a_tb, y_tb);
            i = i + 1;
        end
        if (i == 256) begin
            $stop;
        end
    end
end


always @(posedge clk_tb)
    if (start_tb && busy) begin
        start_tb = 0;
    end 

endmodule