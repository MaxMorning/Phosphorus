module GPUBoard (
    input wire clk,
    input wire reset,

    output wire cs_n,
    input wire sdi,
    output wire sdo,
    output wire wp_n,
    output wire hld_n,

    output wire [3:0] oRed, // red signal
    output wire [3:0] oGreen, // green signal
    output wire [3:0] oBlue, // blue signal
    output wire oHs, // Hori sync
    output wire oVs // Vert sync
);

    wire clk_100MHz;
    wire clk_vga;
    wire clk_50MHz;

    wire wb_ack;
    clk_div clocker(
        .clk_out1(clk_100MHz),     // output clk_out1
        .clk_out2(clk_vga),     // output clk_out2
        .clk_out3(clk_50MHz),
    // Clock in ports
        .clk_in1(clk)      // input clk_in1
    );

    wire vram_we;
    wire[26:0] vram_addr;
    wire[31:0] vram_data;

    WbController wb_controller(
        .clk_50MHz(clk_50MHz),
        .clk_100MHz(clk_100MHz),
        .reset_n(~reset),

        .vram_we(vram_we),
        .vram_addr(vram_addr),
        .vram_data(vram_data),

        .cs_n(cs_n),
        .sdi(sdi),
        .sdo(sdo),
        .wp_n(wp_n),
        .hld_n(hld_n)
    );

    GPUTop gpu(
        .clk_100MHz(clk_100MHz),
        .reset_n(~reset),

        .wb_we_i(vram_we),
        .wb_sel_i(4'hf),
        .wb_adr_i(vram_addr),
        .wb_dat_i(vram_data),
        .wb_ack_o(wb_ack),
        .wb_cyc_i(~wb_ack),
        .wb_stb_i(~wb_ack),

        .clk_vga(clk_vga),

        .oRed(oRed),
        .oBlue(oBlue),
        .oGreen(oGreen),
        .oHs(oHs),
        .oVs(oVs)
    );
endmodule