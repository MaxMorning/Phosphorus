module TextureMemory (
    input wire clk,

    input wire[7:0] i_texture_idx,
    input wire[3:0] i_texture_row_idx,
    output wire[255:0] o_texture_data,

    input wire[31:0] i_wdata,
    input wire i_wea,
    input wire [26:0] i_waddr
);
    
    
endmodule