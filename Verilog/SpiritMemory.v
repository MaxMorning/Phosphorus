module SpiritMemory (
    input wire clk,

    input wire [4:0] i_spirit_idx,
    output wire [63:0] o_spirit_position_struct,

    input wire[31:0] i_wdata,
    input wire i_wea,
    input wire [3:0] i_wselect,
    input wire [26:0] i_waddr
);
    
endmodule