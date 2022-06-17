module TextureMemory (
    input wire clk,

    input wire[7:0] i_texture_idx,
    output wire[2047:0] o_texture_data,

    input wire[31:0] i_wdata,
    input wire i_wea,
    input wire [26:0] i_waddr
);
    wire [9:0] write_word_idx = {i_waddr[15:12] - 4'h2, i_waddr[11:6]};

    wire [15:0] row_we = 16'h0 << i_waddr[5:2];

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin
            texture_block_mem_row texture_block_mem_inst (
                .clka(clk),    // input wire clka
                .wea(row_we[i]),      // input wire [0 : 0] wea
                .addra(write_word_idx),  // input wire [8 : 0] addra
                .dina(i_wdata),    // input wire [31 : 0] dina
                .clkb(clk),    // input wire clkb
                .addrb(i_texture_idx[6:0]),  // input wire [6 : 0] addrb
                .doutb(o_texture_data[128 * i + 127 -: 127])  // output wire [128 : 0] doutb
            );
        end
    endgenerate

endmodule