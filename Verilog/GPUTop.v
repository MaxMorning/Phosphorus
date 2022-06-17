module GPUTop (
    input wire clk_100MHz,
    input wire reset_n,
    input wire wb_we_i,
    input wire [3:0] wb_sel_i,
    input wire [26:0] wb_adr_i,
    input wire [31:0] wb_dat_i,
    output wire [31:0] wb_dat_o,
    output wire        wb_ack_o,

    input wire clk_vga,

    output wire [3:0] oRed, // red signal
    output wire [3:0] oGreen, // green signal
    output wire [3:0] oBlue, // blue signal
    output wire oHs, // Hori sync
    output wire oVs // Vert sync
);
    wire sm_ena;
    wire [16 * 16 * 8 - 1 :0] texture_data_bus;
    wire [4:0] sm_start_x;
    wire [4:0] sm_start_y;
    wire [7:0] sm_position_z;

    wire [16 * 16 * 8 - 1 :0] sm_color_data;

    wire [3:0] texture_row_idx[15:0];

    wire sm_render_done;

    genvar sm_pos_x;
    genvar sm_pos_y;
    generate
        for (sm_pos_y = 0; sm_pos_y < 16; sm_pos_y = sm_pos_y + 1) begin
            for (sm_pos_x = 0; sm_pos_x < 16; sm_pos_x = sm_pos_x + 1) begin
                StreamProcessor #(sm_pos_x, sm_pos_y) sm_inst (
                    .clk(clk_100MHz),
                    .reset_n(reset_n & ~sm_render_done),

                    .ena(sm_ena),

                    .i_texture_data(texture_data_bus[texture_row_idx[sm_pos_y] * 128 + 127 -: 128]),
                    .i_start_x(sm_start_x),
                    .i_position_z(sm_position_z),

                    .o_color(sm_color_data[{sm_pos_y[3:0], sm_pos_x[3:0], 3'h7} -: 8])
                );
            end

            assign texture_row_idx[sm_pos_y] = {1'b1, sm_pos_y[3:0]} - sm_start_y;
        end
    endgenerate

    reg wishbone_ena; // 分频50MHz，匹配Wishbone总线

    assign wb_ack_o = ~wishbone_ena & wb_we_i;

    wire [7:0] texture_idx;


    reg CR_we;
    reg spirit_memory_we;
    reg tile_memory_we;
    reg texture_memory_we;

    // Wishbone Bus Decoder
    always @(*) begin
        case (wb_adr_i[15:12])
            4'h0:
            begin
                // CR & Spirit Tile Position
                if (wb_adr_i[11:8] != 0) begin
                    // Spirit Tile Position
                    CR_we <= 0;
                    spirit_memory_we <= 1;
                    tile_memory_we <= 0;
                    texture_memory_we <= 0;
                end
                else begin
                    // CR
                    CR_we <= 1;
                    spirit_memory_we <= 0;
                    tile_memory_we <= 0;
                    texture_memory_we <= 0;
                end
            end 

            4'h1:
            begin
                // Tile Map
                CR_we <= 0;
                spirit_memory_we <= 0;
                tile_memory_we <= 1;
                texture_memory_we <= 0;
            end
            default: 
            begin
                // Texture Memory
                CR_we <= 0;
                spirit_memory_we <= 0;
                tile_memory_we <= 0;
                texture_memory_we <= 1;
            end
        endcase
    end

    wire [4:0] spirit_idx;
    wire [63:0] spirit_position_struct;

    wire [5:0] tilemap_x_idx;
    wire [5:0] tilemap_y_idx;
    wire [7:0] tilemap_texture_idx;

    wire output_ena;

    wire [5:0] current_tile_x;
    wire [5:0] current_tile_y;
    
    GPUController controller(
        .clk(clk_100MHz),
        .reset_n(reset_n),

        .i_cr_we(CR_we & wishbone_ena),
        .i_cr_addr(wb_adr_i[3:0]),
        .i_cr_value(wb_dat_i[4:0]),

        .o_texture_idx(texture_idx),

        .o_spirit_idx(spirit_idx),
        .i_spirit_position_struct(spirit_position_struct),

        .o_tilemap_x_idx(tilemap_x_idx),
        .o_tilemap_y_idx(tilemap_y_idx),
        .i_tilemap_texture_idx(tilemap_texture_idx),

        .o_calc_ena(sm_ena),
        .o_calc_start_x(sm_start_x),
        .o_calc_start_y(sm_start_y),
        .o_calc_position_z(sm_position_z),

        .o_output_ena(output_ena),

        .o_current_tile_x(current_tile_x),
        .o_current_tile_y(current_tile_y),
        .o_sm_render_done(sm_render_done)
    );

    always @(posedge clk_100MHz) begin
        if (!reset_n) begin
            wishbone_ena <= 0;
        end
        else begin
            wishbone_ena <= ~wishbone_ena;
        end
    end

    TextureMemory textureMemory(
        .clk(clk_100MHz),

        .i_texture_idx(texture_idx),
        .o_texture_data(texture_data_bus),

        .i_wdata(wb_dat_i),
        .i_wea(texture_memory_we & wishbone_ena),
        .i_waddr(wb_adr_i)
    );

    SpiritMemory spiritMemory(
        .clk(clk_100MHz),

        .i_spirit_idx(spirit_idx),
        .o_spirit_position_struct(spirit_position_struct),

        .i_wdata(wb_dat_i),
        .i_wea(spirit_memory_we & wishbone_ena),
        .i_wselect(wb_sel_i),
        .i_waddr(wb_adr_i)
    );

    TileMap tileMap(
        .clk(clk_100MHz),

        .i_tilemap_x_idx(tilemap_x_idx),
        .i_tilemap_y_idx(tilemap_y_idx),
        .o_tilemap_texture_idx(tilemap_texture_idx),

        .i_wdata(wb_dat_i),
        .i_wea(tile_memory_we & wishbone_ena),
        .i_wselect(wb_sel_i),
        .i_waddr(wb_adr_i)
    );

    VGADriver vga_driver(
        .clk(clk_100MHz),
        .clk_vga(clk_vga),
        
        .reset_n(reset_n),

        .i_sm_render_done(sm_render_done),
        .i_current_tile_x(current_tile_x),
        .i_current_tile_y(current_tile_y),

        .i_sm_color_data(sm_color_data),

        .oRed(oRed),
        .oGreen(oGreen),
        .oBlue(oBlue),
        .oHs(oHs),
        .oVs(oVs)
    );
endmodule