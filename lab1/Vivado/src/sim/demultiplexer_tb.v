`timescale 1ns / 1ps

module demultiplexer_tb;
    reg [1:0]y_t;
    reg [2:0] x;
    wire z0_t, z1_t, z2_t, z3_t;
    
    demultiplexer dem(
        .x1(x[1]),
        .x2(x[0]),
        .y(y_t[0]),
        .z0(z0_t),
        .z1(z1_t),
        .z2(z2_t),
        .z3(z3_t)
    );
    
    
    initial begin
        y_t = 2'b00;
        while (y_t < 2'b10) begin
            x = 2'b00;
            while (x <= 2'b11) begin
                #10
                $display("x1=%b, x2=%b, input=%b, output: z0=%b, z1=%b, z2=%b, z3=%b", x[1], x[0], y_t[0], z0_t, z1_t, z2_t, z3_t);
              
                x = x + 1;
            end
            y_t = y_t + 1;
        end
        $stop;
  
    end
endmodule