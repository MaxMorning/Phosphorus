module TextureMemory (
    input wire clk,

    input wire[7:0] i_texture_idx,
    input wire[3:0] i_texture_row_idx,
    output wire[255:0] o_texture_data,

    input wire[31:0] i_wdata,
    input wire i_wea,
    input wire [26:0] i_waddr
);
    wire [13:0] write_word_idx = {i_waddr[15:12] - 4'h2, i_waddr[11:2]};
    wire [9:0] read_block_idx = {i_texture_idx, i_texture_row_idx[3:1]};

    texture_block_mem texture_block_mem_inst (
        .clka(clk),    // input wire clka
        .wea(i_wea),      // input wire [0 : 0] wea
        .addra(write_word_idx[12:0]),  // input wire [12 : 0] addra
        .dina(i_wdata),    // input wire [31 : 0] dina
        .clkb(clk),    // input wire clkb
        .addrb(read_block_idx),  // input wire [9 : 0] addrb
        .doutb(o_texture_data)  // output wire [255 : 0] doutb
    );
endmodule