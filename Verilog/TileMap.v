module TileMap (
    input wire clk,

    input wire [5:0] i_tilemap_x_idx,
    input wire [5:0] i_tilemap_y_idx,
    output reg [7:0] o_tilemap_texture_idx,

    input wire[31:0] i_wdata,
    input wire i_wea,
    input wire [3:0] i_wselect,
    input wire [26:0] i_waddr
);
    wire [3:0] select_with_we = {4{i_wea}} & i_wselect;
    
    wire [11:0] read_byte_address = {i_tilemap_y_idx, 5'h0} + {i_tilemap_y_idx, 3'h0} + i_tilemap_x_idx;

    wire [31:0] raw_read_data;

    tilemap_block_mem tilemap_block_mem_inst (
        .clka(clk),    // input wire clka
        .wea(select_with_we),      // input wire [3 : 0] wea
        .addra(i_waddr[11:2]),  // input wire [9 : 0] addra
        .dina(i_wdata),    // input wire [31 : 0] dina
        .clkb(clk),    // input wire clkb
        .addrb(read_byte_address[11:2]),  // input wire [9 : 0] addrb
        .doutb(raw_read_data)  // output wire [31 : 0] doutb
    );

    always @(*) begin
        case (read_byte_address[1:0])
            2'b00: 
            begin
                o_tilemap_texture_idx = raw_read_data[31:24];
            end

            2'b01:
            begin
                o_tilemap_texture_idx = raw_read_data[23:16];
            end

            2'b10:
            begin
                o_tilemap_texture_idx = raw_read_data[15:8];
            end

            default:
            begin
                o_tilemap_texture_idx = raw_read_data[7:0];
            end
        endcase
    end
endmodule