module SpiritMemory (
    input wire clk,

    input wire [4:0] i_spirit_idx,
    output wire [63:0] o_spirit_position_struct,

    input wire[31:0] i_wdata,
    input wire i_wea,
    input wire [3:0] i_wselect,
    input wire [26:0] i_waddr
);
    wire [3:0] select_with_we = {4{i_wea}} & i_wselect;
    wire [11:0] write_address = i_waddr - 12'h100;

    spirit_block_mem spirit_block_mem_inst (
        .clka(clk),    // input wire clka
        .wea(select_with_we),      // input wire [3 : 0] wea
        .addra(write_address[7:2]),  // input wire [5 : 0] addra
        .dina(i_wdata),    // input wire [31 : 0] dina
        .clkb(clk),    // input wire clkb
        .addrb(i_spirit_idx),  // input wire [4 : 0] addrb
        .doutb(o_spirit_position_struct)  // output wire [63 : 0] doutb
    );
endmodule