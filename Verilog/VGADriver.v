module VGADriver (
    input wire clk,
    input wire clk_vga,

    input wire i_sm_render_done,
    input wire [5:0] i_current_tile_x,
    input wire [5:0] i_current_tile_y,
    input wire [3:0] i_tile_row,

    input wire [255:0] i_sm_color_data,

    output wire [3:0] oRed, // red signal
    output wire [3:0] oGreen, // green signal
    output wire [3:0] oBlue, // blue signal
    output wire oHs, // Hori sync
    output wire oVs, // Vert sync
);
    
endmodule