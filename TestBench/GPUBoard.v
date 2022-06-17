module GPUBoard (
    input wire clk,
    input wire reset,

    output wire [3:0] oRed, // red signal
    output wire [3:0] oGreen, // green signal
    output wire [3:0] oBlue, // blue signal
    output wire oHs, // Hori sync
    output wire oVs // Vert sync
);

    wire clk_100MHz;
    wire clk_vga;
    wire wb_ack;
    clk_div clocker(
        .clk_out1(clk_100MHz),     // output clk_out1
        .clk_out2(clk_vga),     // output clk_out2
    // Clock in ports
        .clk_in1(clk)      // input clk_in1
    );

    GPUTop gpu(
        .clk_100MHz(clk_100MHz),
        .reset_n(~reset),

        .wb_we_i(0),
        .wb_sel_i(4'hf),
        .wb_adr_i(0),
        .wb_dat_i(0),
        .wb_ack_o(wb_ack),

        .clk_vga(clk_vga),

        .oRed(oRed),
        .oBlue(oBlue),
        .oGreen(oGreen),
        .oHs(oHs),
        .oVs(oVs)
    );
endmodule