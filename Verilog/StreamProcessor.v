module StreamProcessor #(
    parameter my_position_x = 0,
    parameter my_position_y = 0
) (
    input wire clk,
    input wire reset_n,

    input wire ena,

    input wire [2 * 16 * 8 - 1 :0] i_texture_data,
    input wire [3:0] i_start_x,
    input wire [7:0] i_position_z,

    output wire [7:0] o_color
);
    reg [7:0] current_position;
    reg [7:0] current_color;

    wire [7:0] new_color = i_texture_data[{{my_position_y, 4'h0} + (my_position_x - i_start_x), 3'h7} -: 8];

    always @(posedge clk) begin
        if (!reset_n) begin
            current_position <= 8'h0;
            current_color <= 8'h0;
        end
        else if (
            ena &&
            current_position <= i_position_z &&
            my_position_x >= i_start_x &&
            (i_position_z == 0 || new_color != 0)
        ) begin
            current_color <= new_color;
            current_position <= i_position_z;
        end
    end
endmodule