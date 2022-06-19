module TextureMemory (
    input wire clk,

    input wire[7:0] i_texture_idx,
    output wire[2047:0] o_texture_data,

    input wire[31:0] i_wdata,
    input wire i_wea,
    input wire [26:0] i_waddr
);
    // write_address[12:6] => tile idx
    // write_address[5:2] => row idx of tile
    // write_address[1:0] => word idx of row
    wire [12:0] write_address = {i_waddr[15:12] - 4'h2, i_waddr[11:2]};

    wire [31:0] reassemble_wdata = {i_wdata[7:0], i_wdata[15:8], i_wdata[23:16], i_wdata[31:24]};
    
    // reassemble_waddr[5] == 1 means this word is in the [0:127] bytes
    // reassemble_waddr[5] == 0 means this word is in the [128:255] bytes
    // wire [12:0] reassemble_waddr = {write_address[12:6], 6'd63 - write_address[5:0]};

    texture_block_mem_1024_0 texture_block_mem_inst_0 (
        .clka(clk),    // input wire clka
        .wea(i_wea & ~write_address[5]),      // input wire [0 : 0] wea
        .addra({write_address[12:6], write_address[4:0]}),  // input wire [11 : 0] addra
        .dina(reassemble_wdata),    // input wire [31 : 0] dina
        .clkb(clk),    // input wire clkb
        .addrb(i_texture_idx),  // input wire [6 : 0] addrb
        .doutb(o_texture_data[1023:0])  // output wire [1023 : 0] doutb
    );

    texture_block_mem_1024_1 texture_block_mem_inst_1 (
        .clka(clk),    // input wire clka
        .wea(i_wea & write_address[5]),      // input wire [0 : 0] wea
        .addra({write_address[12:6], write_address[4:0]}),  // input wire [11 : 0] addra
        .dina(reassemble_wdata),    // input wire [31 : 0] dina
        .clkb(clk),    // input wire clkb
        .addrb(i_texture_idx),  // input wire [6 : 0] addrb
        .doutb(o_texture_data[2047:1024])  // output wire [1023 : 0] doutb
    );
endmodule