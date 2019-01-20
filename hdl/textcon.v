module textcon(
	input clk,
	input [11:0] x,
	input [10:0] y,
	input hs_in, vs_in, blk_in,
	output reg [7:0] r, g, b,
	output hs_out, vs_out, blk_out
);

wire [10:0] rom_addr = {x[9:3], y[2:0]};

reg [7:0] font_rom[0:1023];
initial $readmemh("hdl/font_8x8.dat", font_rom);

reg [7:0] rom_data;

reg [7:0] font_r, font_g, font_b;
reg [10:0] x_next;

reg [2:0] ctrl_del1, ctrl_del2;

wire pixel = rom_data[3'd7 - x_next[2:0]];

always @(posedge clk) begin
	rom_data <= font_rom[rom_addr];
	case (y[5:3])
		3'b000: begin font_r = 8'hFF; font_g = 8'hFF; font_b = 8'hFF; end
		3'b001: begin font_r = 8'hFF; font_g = 8'h00; font_b = 8'h00; end
		3'b010: begin font_r = 8'h00; font_g = 8'hFF; font_b = 8'h00; end
		3'b011: begin font_r = 8'h00; font_g = 8'h00; font_b = 8'hFF; end
		3'b100: begin font_r = 8'hFF; font_g = 8'hFF; font_b = 8'h00; end
		3'b101: begin font_r = 8'h00; font_g = 8'hFF; font_b = 8'hFF; end
		3'b110: begin font_r = 8'hFF; font_g = 8'h00; font_b = 8'hFF; end
		3'b111: begin font_r = 8'h7F; font_g = 8'h7F; font_b = 8'h7F; end
	endcase

	x_next <= x;
	r <= pixel ? font_r : 8'h00;
	g <= pixel ? font_g : 8'h00;
	b <= pixel ? font_b : 8'h00;
	// Delay hs, vs, blank by same amount as video data
	ctrl_del1 <= {hs_in, vs_in, blk_in};
	ctrl_del2 <= ctrl_del1;
end

assign {hs_out, vs_out, blk_out} = ctrl_del2;

endmodule