`timescale 1ns/1ps

module BoardTB;
    
    reg reset;
    reg clk;

    wire [3:0] oRed; // red signal
    wire [3:0] oGreen; // green signal
    wire [3:0] oBlue; // blue signal
    wire oHs; // Hori sync
    wire oVs; // Vert sync

    wire cs_n;
    reg sdi;
    wire sdo;
    wire wp_n;
    wire hld_n;

    GPUBoard gpu_board(
        .clk(clk),
        .reset(reset),

        .cs_n(cs_n),
        .sdi(sdi),
        .sdo(sdo),
        .wp_n(wp_n),
        .hld_n(hld_n),
        
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

    // always @(posedge gpu_board.wb_controller.flash.sck) begin
    //     sdi <= ~sdi;
    // end

    initial begin
        reset = 1;
        sdi = 1'b0;

        #17
        reset = 0;
    end
endmodule