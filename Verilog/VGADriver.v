module VGADriver (
    input wire clk,
    input wire clk_vga,
    input wire reset_n,

    input wire i_sm_render_done,
    input wire [5:0] i_current_tile_x,
    input wire [5:0] i_current_tile_y,
    input wire [3:0] i_tile_row,

    input wire [255:0] i_sm_color_data,

    output reg [3:0] oRed, // red signal
    output reg [3:0] oGreen, // green signal
    output reg [3:0] oBlue, // blue signal
    output wire oHs, // Hori sync
    output wire oVs // Vert sync
);

    /* -----------------------------VGA Part------------------------------ */
    // 800 * 600
    parameter   C_H_SYNC_PULSE   = 128, 
                C_H_BACK_PORCH   = 88,
                C_H_ACTIVE_TIME  = 800,
                C_H_FRONT_PORCH  = 40,
                C_H_LINE_PERIOD  = 1056;
    
    parameter   C_V_SYNC_PULSE   = 4, 
                C_V_BACK_PORCH   = 23,
                C_V_ACTIVE_TIME  = 600,
                C_V_FRONT_PORCH  = 1,
                C_V_FRAME_PERIOD = 628;
    
    

    reg [10:0] hCnt; // Hori Counter
    reg [10:0] vCnt; // Vert Counter

    wire isActive;

     // Hori
    always @ (posedge clk_vga or negedge reset_n) begin
        if (!reset_n || hCnt == C_H_LINE_PERIOD - 1)
            hCnt <= 11'd0;
        else
            hCnt <= hCnt + 1;
    end

    assign oHs = (hCnt < C_H_SYNC_PULSE) ? 1'b0 : 1'b1;


    //Vert
    always @ (posedge clk_vga or negedge reset_n) begin
        if (!reset_n) begin
            vCnt <= 11'h0;
        end
        else if ((vCnt == C_V_FRAME_PERIOD - 1'b1) && (hCnt == C_H_LINE_PERIOD - 1'b1)) begin
            vCnt <= 11'h0;
        end
        else if (hCnt == C_H_LINE_PERIOD - 1'b1) begin
            vCnt <= vCnt + 1;
        end
        else begin
            vCnt <= vCnt;
        end
    end

    assign oVs = (vCnt < C_V_SYNC_PULSE) ? 1'b0 : 1'b1;

    assign isActive =   (hCnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH                  ))  &&
                        (hCnt <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_ACTIVE_TIME))  && 
                        (vCnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH                  ))  &&
                        (vCnt <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_ACTIVE_TIME))  ;

    wire [10:0] hPos;
    wire [10:0] vPos;
    assign hPos = hCnt - (C_H_SYNC_PULSE + C_H_BACK_PORCH);
    assign vPos = vCnt - (C_V_SYNC_PULSE + C_V_BACK_PORCH);

    wire [7:0] frame_buffer_read_color;

    wire [7:0] read_color_red;
    wire [7:0] read_color_green;
    wire [7:0] read_color_blue;

    ColorConverter color_converter(
        .color256(frame_buffer_read_color),

        .r_value(read_color_red),
        .g_value(read_color_green),
        .b_value(read_color_blue)
    );

    always @ (posedge clk_vga or negedge reset_n) begin
        if (!reset_n) begin
            oRed <= 4'b0000;
            oGreen <= 4'b0000;
            oBlue <= 4'b0000;
        end
        else if (isActive) begin
            if (vPos < 480 && hPos < 640) begin
                oRed <= read_color_red[7:4];
                oGreen <= read_color_green[7:4];
                oBlue <= read_color_blue[7:4];
            end
            else begin
                oRed <= 4'b0000;
                oGreen <= 4'b0000;
                oBlue <= 4'b1111;
            end
        end
        else begin
            oRed <= 4'b0000;
            oGreen <= 4'b1111;
            oBlue <= 4'b0000;
        end
    end


    /* -----------------------------FrameBuffer Part------------------------------ */
    reg store_second_16_byte;

    wire frame_buffer_we = store_second_16_byte & i_sm_render_done;

    wire [127:0] frame_buffer_write_data = store_second_16_byte ? i_sm_color_data[255:128] : i_sm_color_data[127:0];
    wire [14:0] frame_buffer_write_address = {{i_current_tile_y, 5'h0} + {i_current_tile_y, 3'h0} + i_current_tile_x, i_tile_row[3:1], store_second_16_byte};

    wire [18:0] frame_buffer_read_address = vPos * 640 + hPos + 1; // plus 1 because block memory have 1 cycle latency to read data.
    
    frame_block_mem frame_block_mem_inst (
        .clka(clk),    // input wire clka
        .wea(frame_buffer_we),      // input wire [0 : 0] wea
        .addra(frame_buffer_write_address),  // input wire [14 : 0] addra
        .dina(frame_buffer_write_data),    // input wire [127 : 0] dina
        .clkb(clk_vga),    // input wire clkb
        .addrb(frame_buffer_read_address),  // input wire [18 : 0] addrb
        .doutb(frame_buffer_read_color)  // output wire [7 : 0] doutb
    );

    always @(posedge clk) begin
        if (!reset_n) begin
            store_second_16_byte <= 0;
        end
        else begin
            if (i_sm_render_done) begin
                store_second_16_byte <= 1;
            end
            else begin
                store_second_16_byte <= 0;
            end
        end
    end
endmodule