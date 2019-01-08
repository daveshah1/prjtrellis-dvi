// (c) fpga4fun.com & KNJN LLC 2013

////////////////////////////////////////////////////////////////////////
module DVI_test
(
	input pixclk,  // 25MHz
	input shiftclk, // 250MHz
	output [2:0] TMDSp, TMDSn,
	output TMDSp_clock, TMDSn_clock
);

////////////////////////////////////////////////////////////////////////
assign clk_TMDS = shiftclk;

////////////////////////////////////////////////////////////////////////
reg [9:0] CounterX, CounterY;
reg hSync, vSync, DrawArea;
always @(posedge pixclk) DrawArea <= (CounterX<640) && (CounterY<480);

always @(posedge pixclk) CounterX <= (CounterX==799) ? 0 : CounterX+1;
always @(posedge pixclk) if(CounterX==799) CounterY <= (CounterY==524) ? 0 : CounterY+1;

always @(posedge pixclk) hSync <= (CounterX>=656) && (CounterX<752);
always @(posedge pixclk) vSync <= (CounterY>=490) && (CounterY<492);

////////////////
parameter anim_bits = 26; // less -> faster
reg [anim_bits-1:0] ANIM;
always @(posedge pixclk) ANIM <= ANIM + 1;
wire [9:0] CX, CY;
assign CX = CounterX + ANIM[anim_bits-1:anim_bits-9];
assign CY = CounterY + ANIM[anim_bits-1:anim_bits-8];
wire [7:0] W = {8{CX[7:0]==CY[7:0]}};
wire [7:0] A = {8{CX[7:5]==3'h2 && CY[7:5]==3'h2}};
reg [7:0] red, green, blue;
always @(posedge pixclk) red <= ({CX[5:0] & {6{CY[4:3]==~CX[4:3]}}, 2'b00} | W) & ~A;
always @(posedge pixclk) green <= (CX[7:0] & {8{CY[6]}} | W) & ~A;
always @(posedge pixclk) blue <= CY[7:0] | W | A;

////////////////////////////////////////////////////////////////////////
wire [9:0] TMDS_red, TMDS_green, TMDS_blue;
TMDS_encoder encode_R(.clk(pixclk), .VD(red  ), .CD(2'b00)        , .VDE(DrawArea), .TMDS(TMDS_red));
TMDS_encoder encode_G(.clk(pixclk), .VD(green), .CD(2'b00)        , .VDE(DrawArea), .TMDS(TMDS_green));
TMDS_encoder encode_B(.clk(pixclk), .VD(blue ), .CD({vSync,hSync}), .VDE(DrawArea), .TMDS(TMDS_blue));

////////////////////////////////////////////////////////////////////////
reg [3:0] TMDS_mod10=0;  // modulus 10 counter
reg [9:0] TMDS_shift_red=0, TMDS_shift_green=0, TMDS_shift_blue=0;
reg TMDS_shift_load=0;
always @(posedge clk_TMDS) TMDS_shift_load <= (TMDS_mod10==4'd9);

always @(posedge clk_TMDS)
begin
	TMDS_shift_red   <= TMDS_shift_load ? TMDS_red   : TMDS_shift_red  [9:1];
	TMDS_shift_green <= TMDS_shift_load ? TMDS_green : TMDS_shift_green[9:1];
	TMDS_shift_blue  <= TMDS_shift_load ? TMDS_blue  : TMDS_shift_blue [9:1];	
	TMDS_mod10 <= (TMDS_mod10==4'd9) ? 4'd0 : TMDS_mod10+4'd1;
end

OBUFDS OBUFDS_red  (.I(TMDS_shift_red  [0]), .O(TMDSp[2]), .OB(TMDSn[2]));
OBUFDS OBUFDS_green(.I(TMDS_shift_green[0]), .O(TMDSp[1]), .OB(TMDSn[1]));
OBUFDS OBUFDS_blue (.I(TMDS_shift_blue [0]), .O(TMDSp[0]), .OB(TMDSn[0]));
OBUFDS OBUFDS_clock(.I(pixclk), .O(TMDSp_clock), .OB(TMDSn_clock));
endmodule

////////////////////////////////////////////////////////////////////////
