`timescale 1ns / 1ps

module function_calculator_tb;
reg clk_tb = 1;
reg rst_tb;
reg [7:0] a_tb;
reg [7:0] b_tb;
reg start_tb = 0;
reg [8:0] i;
reg [8:0] j;
reg flag = 0;
wire busy;
wire [15:0] y_tb;

function_calculator calc(
    .clk_i(clk_tb),
    .rst_i(rst_tb),
    .a_i(a_tb),
    .b_i(b_tb),
    .start_i(start_tb),
    .busy_o(busy),
    .y_calc(y_tb)
);

always begin
    #5 clk_tb = !clk_tb;
end

initial begin
    rst_tb = 1;
    #1
    rst_tb = 0;
    start_tb = 0;
    #1
    for (i = 0; i <= 255; i = i + 1) begin
        for (j = 0; j <= 255; j = j + 1) begin
            if (~busy && ~start_tb) begin
                a_tb = i;
                b_tb = j;
                start_tb = 1;
                #2500
                if (~busy) begin
                    $display("a = %d, b = %d, результат = %d",a_tb, b_tb, y_tb);
                end
            end
        end 
    end
    $stop;
end

always @(posedge clk_tb)
    if (start_tb && busy) begin
        start_tb = 0;
    end 
endmodule
