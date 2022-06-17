`timescale 1ns/1ps

module BoardTB;
    
    reg reset;
    reg clk;

    wire [3:0] oRed; // red signal
    wire [3:0] oGreen; // green signal
    wire [3:0] oBlue; // blue signal
    wire oHs; // Hori sync
    wire oVs; // Vert sync

    GPUBoard gpu_board(
        .clk(clk),
        .reset(reset),

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
        reset = 1;

        #17
        reset = 0;
    end
endmodule