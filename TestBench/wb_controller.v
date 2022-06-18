module WbController (
    input wire clk_50MHz,
    input wire clk_100MHz,
    input wire reset_n,

    output reg vram_we,
    output reg[26:0] vram_addr,
    output reg[31:0] vram_data,

    output wire            cs_n,
    input wire            sdi,
    output wire            sdo,
    output wire        	  wp_n,
    output wire           hld_n
);
    
    reg [26:0] flash_address;

    wire flash_ack;
    wire[31:0] flash_data_out;

    always @(posedge clk_50MHz) begin
        if (!reset_n) begin
            flash_address <= 27'h10000;
            vram_we <= 0;
            vram_addr <= 0;
            vram_data <= 0;
        end
        else if (flash_address < 27'h18000 && flash_ack) begin
            flash_address <= flash_address + 4;
            vram_we <= 1;
            vram_addr <= flash_address - 27'he000;
            vram_data <= flash_data_out;
        end
        else begin
            vram_we <= 0;
        end
    end

    flash_top flash(
        .wb_clk_i(clk_100MHz),
        .wb_rst_i(~reset_n),
        .wb_cyc_i(~flash_ack),
        .wb_stb_i(~flash_ack),
        .wb_we_i(0),
        .wb_sel_i(4'hf),
        .wb_adr_i(flash_address),
        .wb_dat_i(0),
        .wb_dat_o(flash_data_out),
        .wb_ack_o(flash_ack),

        .cs_n(cs_n),
        .sdi(sdi),
        .sdo(sdo),
        .wp_n(wp_n),
        .hld_n(hld_n)
    );
endmodule