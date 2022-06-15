`timescale 1ns/1ps

module total_tb ();
    reg reset_n;
    reg clk;

    wire [3:0] oRed; // red signal
    wire [3:0] oGreen; // green signal
    wire [3:0] oBlue; // blue signal
    wire oHs; // Hori sync
    wire oVs; // Vert sync

    openmips_min_sopc inst(
        .clk(clk),
        .reset_n(reset_n),

        .oRed(oRed),
        .oGreen(oGreen),
        .oBlue(oBlue),
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
        reset_n = 0;

        #17
        reset_n = 1;
    end
endmodule