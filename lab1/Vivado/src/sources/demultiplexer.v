`timescale 1ns / 1ps

module demultiplexer(
    input y,
    input x1,
    input x2,
    output z0,
    output z1,
    output z2,
    output z3
);

wire not_x1, not_x2, not_y;
wire nor_x12, nor_nx2ny, nor_nx1ny, nor_nx1nx2;
wire not_nor_x12, not_nor_nx2ny, not_nor_nx1ny, not_nor_nx1nx2;

nor(not_x1, x1, x1);
nor(not_x2, x2, x2);
nor(not_y, y, y);

nor(nor_x12, x1, x2);
nor(nor_nx2ny, not_x2, not_y);
nor(nor_nx1ny, not_x1, not_y);
nor(nor_nx1nx2, not_x1, not_x2);

nor(not_nor_x12, nor_x12, nor_x12);
nor(not_nor_nx2ny, nor_nx2ny, nor_nx2ny);
nor(not_nor_nx1ny, nor_nx1ny, nor_nx1ny);
nor(not_nor_nx1nx2, nor_nx1nx2, nor_nx1nx2);

nor(z0, not_nor_x12, not_y);
nor(z1, not_nor_nx2ny, x1);
nor(z2, not_nor_nx1ny, x2);
nor(z3, not_nor_nx1nx2, not_y);

endmodule
