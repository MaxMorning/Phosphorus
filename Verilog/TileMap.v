module TileMap (
    input wire clk,

    input wire [5:0] i_tilemap_x_idx,
    input wire [5:0] i_tilemap_y_idx,
    output wire [7:0] o_tilemap_texture_idx,

    input wire[31:0] i_wdata,
    input wire i_wea,
    input wire [3:0] i_wselect,
    input wire [26:0] i_waddr
);
    
endmodule