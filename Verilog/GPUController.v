module GPUController (
    input wire clk,
    input wire reset_n,

    input wire i_cr_we,
    input wire[3:0] i_cr_addr,
    input wire[4:0] i_cr_value,

    // output wire o_texture_memory_ena,
    output wire[7:0] o_texture_idx,

    // output wire o_spirit_memory_ena,
    output wire[4:0] o_spirit_idx,
    input wire[63:0] i_spirit_position_struct,

    // output wire o_tilemap_memory_ena,
    output wire[5:0] o_tilemap_x_idx,
    output wire[5:0] o_tilemap_y_idx,
    input wire[7:0] i_tilemap_texture_idx,

    output wire o_calc_ena,
    output reg[4:0] o_calc_start_x,
    output reg[4:0] o_calc_start_y,
    output reg[7:0] o_calc_position_z,

    output wire o_output_ena,

    output wire [5:0] o_current_tile_x,
    output wire [5:0] o_current_tile_y,
    output wire o_sm_render_done
);
    reg output_ena_reg;
    reg render_ena_reg;
    reg mode_reg;
    reg[4:0] spirit_cnt_reg;

    assign o_output_ena = output_ena_reg;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            output_ena_reg <= 1;
            render_ena_reg <= 1;
            mode_reg <= 1;
            spirit_cnt_reg <= 1;
        end
        else if (i_cr_we) begin
            case (i_cr_addr)
                4'h0: 
                begin
                    output_ena_reg <= i_cr_value[0];
                end

                4'h4:
                begin
                    render_ena_reg <= i_cr_value[0];
                end

                4'h8:
                begin
                    mode_reg <= i_cr_value[0];
                end

                4'hc:
                begin
                    spirit_cnt_reg <= i_cr_value;
                end
            endcase
        end
    end

    reg[5:0] current_tile_x;
    reg[5:0] current_tile_y;
    reg[4:0] spirit_idx;

    reg[7:0] frame_cnt;

    wire spirit_in_block;

    assign o_current_tile_x = current_tile_x;
    assign o_current_tile_y = current_tile_y;

    // (spirit_idx == spirit_cnt_reg) 表示当前正在处理背景图
    // (i_spirit_position_struct[47:40] != 0 && spirit_in_block) 表示当前处理的精灵图有效且在目前渲染区域里有内容
    assign o_calc_ena = render_ena_reg & ((spirit_idx == spirit_cnt_reg) | (i_spirit_position_struct[47:40] != 0 && spirit_in_block));
    // assign o_calc_position_z = (spirit_idx == spirit_cnt_reg) ? 0 : i_spirit_position_struct[47:40];

    wire[15:0] spirit_position_x = i_spirit_position_struct[15:0];
    wire[15:0] spirit_position_y = i_spirit_position_struct[31:16];

    assign spirit_in_block =    ((spirit_position_x > {current_tile_x - 1, 4'h0}) || spirit_position_x[15:4] == 0) &
                                (spirit_position_x < {current_tile_x + 1, 4'h0}) &
                                ((spirit_position_y > {current_tile_y - 1, 4'h0}) || spirit_position_y[15:4] == 0) &
                                (spirit_position_y < {current_tile_y + 1, 4'h0});


    assign o_texture_idx = (spirit_idx == 0) ? i_tilemap_texture_idx : i_spirit_position_struct[39:32];


    assign o_spirit_idx = spirit_idx;

    assign o_tilemap_x_idx = current_tile_x;
    assign o_tilemap_y_idx = current_tile_y;

    reg sm_render_done;
    assign o_sm_render_done = sm_render_done;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_tile_x <= 0;
            current_tile_y <= 0;
            spirit_idx <= 0;
            frame_cnt <= 0;
            sm_render_done <= 0;
            // o_texture_idx <= 0;
        end
        else if (render_ena_reg) begin
            if (current_tile_y == (480 / 16)) begin
                frame_cnt <= frame_cnt + 1;
                current_tile_y <= 0;
                current_tile_x <= 0;
                spirit_idx <= 0;
                sm_render_done <= 0;
            end
            else if (current_tile_x == (640 / 16)) begin
                current_tile_x <= 0;
                spirit_idx <= 0;
                current_tile_y <= current_tile_y + 1;
                sm_render_done <= 0;
            end
            else if (spirit_idx == spirit_cnt_reg) begin
                // 所有精灵图处理完成，接下来处理背景
                current_tile_x <= current_tile_x + 1;
                spirit_idx <= 0;
                sm_render_done <= 1;  // 此处render_done 指示的是上一个tile的render done
            end
            else begin
                spirit_idx <= spirit_idx + 1;
                sm_render_done <= 0;
            end
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            o_calc_position_z <= 0;
            o_calc_start_x <= 0;
            o_calc_start_y <= 0;
        end
        else if (spirit_idx == 0) begin
            // SM 将渲染背景
            o_calc_position_z <= 0;
            o_calc_start_x <= 5'b10000;
            o_calc_start_y <= 5'b10000;
        end
        else begin
            // SM 将渲染精灵
            o_calc_position_z <= i_spirit_position_struct[47:40];
            o_calc_start_x <= (spirit_position_x - {current_tile_x - 1, 4'h0});
            o_calc_start_y <= (spirit_position_y - {current_tile_y - 1, 4'h0});
        end
    end
endmodule