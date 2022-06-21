module VGADriver (
    input wire clk,
    input wire clk_vga,
    input wire reset_n,

    input wire i_sm_render_done,
    input wire [5:0] i_current_tile_x,
    input wire [5:0] i_current_tile_y,

    input wire [2047:0] i_sm_color_data,

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
                oRed <= 4'b0011;
                oGreen <= 4'b0011;
                oBlue <= 4'b0011;
            end
        end
        else begin
            oRed <= 4'b0000;
            oGreen <= 4'b0000;
            oBlue <= 4'b0000;
        end
    end


    /* -----------------------------FrameBuffer Part------------------------------ */
    wire [10:0] next_hPos = hPos + 1; // plus 1 because block memory have 1 cycle latency to read data.
    wire[5:0] read_tile_x = next_hPos[9:4];
    wire[5:0] read_tile_y = vPos[9:4];

    wire [3:0] row_idx_in_tile = 4'hf - vPos[3:0];
    wire [3:0] col_idx_in_tile = 4'hf - next_hPos[3:0];

    wire [15:0] frame_buffer_read_address = {read_tile_y * 40 + read_tile_x, {4'hf - row_idx_in_tile[3:0], ~col_idx_in_tile[3]}};

    wire frame_buffer_we = i_sm_render_done;
    wire[10:0] frame_buffer_write_address = (i_current_tile_x == 0 && i_current_tile_y == 0) ? 30 * 40 - 1 : i_current_tile_y * 40 + i_current_tile_x - 1; // -1 because the render_done signal have latency
    
    wire [63:0] frame_buffer_read_color_64bit;

    assign frame_buffer_read_color = frame_buffer_read_color_64bit[{3'b111 - col_idx_in_tile[2:0], 3'b111} -: 8];

    frame_block_mem frame_block_mem_inst (
        .clka(clk),    // input wire clka
        .wea(frame_buffer_we),      // input wire [0 : 0] wea
        .addra(frame_buffer_write_address),  // input wire [10 : 0] addra
        .dina(i_sm_color_data),    // input wire [2047 : 0] dina
        .clkb(clk_vga),    // input wire clkb
        .addrb(frame_buffer_read_address),  // input wire [15 : 0] addrb
        .doutb(frame_buffer_read_color_64bit)  // output wire [63 : 0] doutb
    );
endmodule