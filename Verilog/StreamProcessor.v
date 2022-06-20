module StreamProcessor #(
    parameter my_position_x = 0,
    parameter my_position_y = 0
) (
    input wire clk,
    input wire reset_n,

    input wire ena,

    input wire [16 * 8 - 1 :0] i_texture_data,
    input wire [4:0] i_start_x,
    input wire [4:0] i_start_y,
    input wire [7:0] i_position_z,

    output wire [7:0] o_color
);
    reg [7:0] current_position;
    reg [7:0] current_color;
    reg [7:0] output_color;

    wire [4:0] start_x_check = {1'b1, my_position_x[3:0]} - i_start_x;
    wire [4:0] start_y_check = {1'b1, my_position_y[3:0]} - i_start_y;

    assign o_color = output_color;

    wire [7:0] new_color = i_texture_data[{start_x_check[3:0], 3'h7} -: 8];

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_position <= 8'h0;
            current_color <= 255;
        end
        else if (ena) begin
            if (i_position_z == 0) begin
                // background
                if (current_color == 255) begin
                    output_color <= new_color;
                end
                else begin
                    output_color <= current_color;
                    current_color <= 255;
                end
                current_position <= 0;
            end
            else begin
                // spirit
                if (current_position <= i_position_z &&
                    start_x_check[4] == 0 &&
                    start_y_check[4] == 0 &&
                    new_color != 255) begin
                    current_color <= new_color;
                    current_position <= i_position_z;
                end
            end
        end
    end
endmodule