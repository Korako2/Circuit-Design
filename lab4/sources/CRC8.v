`timescale 1ns / 1ps

module CRC8(
    input clk,
    input rst,
    input [15:0] data,
    input start_i,
    input [8:0] count,
    output busy,
    output reg [7:0] crc_res
    );

reg [15:0] num;
reg [2:0] state;    
reg [7:0] crc_pol = 8'b00011101;
reg [7:0] crc;
reg bit;
reg [8:0] k;

localparam IDLE = 3'b000;
localparam SHIFT = 3'b001;
localparam CHECK_XOR = 3'b010;
localparam XOR = 3'b011;
localparam END = 3'b100;

reg [4:0] i;
assign busy = (state != IDLE);
    
always@(posedge clk) begin
    if (rst) begin
        crc <= 0;
        num <= 0;
        state <= IDLE;
        crc_res <= 0;
        k <= 0;
    end else begin
        case (state)
            IDLE:
                begin
                    if (start_i) begin
                        state <= SHIFT;
                        i <= 15;
                        k <= k + 1;
                        num <= data;
                    end
                end
             SHIFT:
                begin
                    crc[0] <= num[i];
                    crc[1] <= crc[0];
                    crc[2] <= crc[1];
                    crc[3] <= crc[2];
                    crc[4] <= crc[3];
                    crc[5] <= crc[4];
                    crc[6] <= crc[5];
                    crc[7] <= crc[6];
                    bit <= crc[7];
                    state <= CHECK_XOR;
                    i = i - 1;
                end
             CHECK_XOR:
                begin
                    if (bit) begin
                        state <= XOR;
                    end else begin
                        if (i != 31) begin
                            state <= SHIFT;
                        end else begin
                            if (k == count) begin
                                state <= END;
                            end else begin 
                                state <= IDLE;
                            end
                        end
                    end
                end
             XOR:
                begin
                    crc <= crc ^ crc_pol;
                    if (i != 31) begin
                            state <= SHIFT;
                        end else begin
                            if (k == count) begin
                                state <= END;
                            end else begin 
                                state <= IDLE;
                            end
                    end
                end
             END:
                begin
                    crc_res <= crc;
                    state <= IDLE;
                end 
         endcase
    end
end    

endmodule
