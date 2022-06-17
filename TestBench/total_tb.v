`timescale 1ns/1ps

module total_tb ();
    reg reset_n;
    reg clk;
    reg clk_vga;

    reg wb_we;
    reg [31:0] wb_dat;
    reg [26:0] wb_adr;

    wire wb_ack;
    wire [3:0] oRed; // red signal
    wire [3:0] oGreen; // green signal
    wire [3:0] oBlue; // blue signal
    wire oHs; // Hori sync
    wire oVs; // Vert sync

    GPUTop gpu(
        .clk_100MHz(clk),
        .reset_n(reset_n),
        .wb_we_i(wb_we),
        .wb_sel_i(4'hf),
        .wb_adr_i(wb_adr),
        .wb_dat_i(wb_dat),
        .wb_ack_o(wb_ack),

        .clk_vga(clk_vga),

        .oRed(oRed),
        .oBlue(oBlue),
        .oGreen(oGreen),
        .oHs(oHs),
        .oVs(oVs)
    );

    initial begin
        clk = 0;

        forever begin
            #5
            clk = ~clk;
        end
    end

    initial begin
        clk_vga = 0;

        forever begin
            #12.5
            clk_vga = ~clk_vga;
        end

    end

    initial begin
        reset_n = 0;

        wb_we = 0;
        wb_adr = 0;
        wb_dat = 1;

        #17
        reset_n = 1;

        #20
        wb_we = 1;
        wb_adr = 26'h2000;
        wb_dat = 32'hfcfefdfa;

        #20
        wb_adr = 26'h100;
        wb_dat = 32'h0103;

        #20
        wb_adr = 26'h104;
        wb_dat = 32'h2010;

        #20
        wb_adr = 36'hc;
        wb_dat = 1;

        #20
        wb_adr = 26'h0;
        wb_dat = 1;

        #20
        wb_adr = 26'h4;

        #20
        wb_we = 0;
    end
endmodule