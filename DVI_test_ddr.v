// (c) fpga4fun.com & KNJN LLC 2013

////////////////////////////////////////////////////////////////////////
module DVI_test
(
	input pixclk,  // 25MHz
	input shiftclk, // 250MHz
	output [3:0] TMDSp, TMDSn
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
parameter [9:0] TMDS_clock = 10'b0000011111;
reg [9:0] TMDS_pshift_red, TMDS_pshift_green, TMDS_pshift_blue, TMDS_pshift_clock =  TMDS_clock;
reg [9:0] TMDS_nshift_red, TMDS_nshift_green, TMDS_nshift_blue, TMDS_nshift_clock = ~TMDS_clock;
reg TMDS_shift_load=0;

always @(posedge clk_TMDS)
begin
        TMDS_shift_load   <= TMDS_pshift_clock[3:2] == 2'b01;
	TMDS_pshift_clock <= { TMDS_pshift_clock[1:0], TMDS_pshift_clock[9:2] };
	TMDS_pshift_red   <= TMDS_shift_load ?  TMDS_red   : TMDS_pshift_red  [9:2];
	TMDS_pshift_green <= TMDS_shift_load ?  TMDS_green : TMDS_pshift_green[9:2];
	TMDS_pshift_blue  <= TMDS_shift_load ?  TMDS_blue  : TMDS_pshift_blue [9:2];	
	TMDS_nshift_clock <= { TMDS_nshift_clock[1:0], TMDS_nshift_clock[9:2] };
	TMDS_nshift_red   <= TMDS_shift_load ? ~TMDS_red   : TMDS_nshift_red  [9:2];
	TMDS_nshift_green <= TMDS_shift_load ? ~TMDS_green : TMDS_nshift_green[9:2];
	TMDS_nshift_blue  <= TMDS_shift_load ? ~TMDS_blue  : TMDS_nshift_blue [9:2];	
end

ODDRX1F ddr_pclock_inst (.D0(TMDS_pshift_clock[0]), .D1(TMDS_pshift_clock[1]), .Q(TMDSp[3]), .SCLK(clk_TMDS), .RST(0) );
ODDRX1F ddr_pred_inst   (.D0(TMDS_pshift_red  [0]), .D1(TMDS_pshift_red  [1]), .Q(TMDSp[2]), .SCLK(clk_TMDS), .RST(0) );
ODDRX1F ddr_pgreen_inst (.D0(TMDS_pshift_green[0]), .D1(TMDS_pshift_green[1]), .Q(TMDSp[1]), .SCLK(clk_TMDS), .RST(0) );
ODDRX1F ddr_pblue_inst  (.D0(TMDS_pshift_blue [0]), .D1(TMDS_pshift_blue [1]), .Q(TMDSp[0]), .SCLK(clk_TMDS), .RST(0) );

ODDRX1F ddr_nclock_inst (.D0(TMDS_nshift_clock[0]), .D1(TMDS_nshift_clock[1]), .Q(TMDSn[3]), .SCLK(clk_TMDS), .RST(0) );
ODDRX1F ddr_nred_inst   (.D0(TMDS_nshift_red  [0]), .D1(TMDS_nshift_red  [1]), .Q(TMDSn[2]), .SCLK(clk_TMDS), .RST(0) );
ODDRX1F ddr_ngreen_inst (.D0(TMDS_nshift_green[0]), .D1(TMDS_nshift_green[1]), .Q(TMDSn[1]), .SCLK(clk_TMDS), .RST(0) );
ODDRX1F ddr_nblue_inst  (.D0(TMDS_nshift_blue [0]), .D1(TMDS_nshift_blue [1]), .Q(TMDSn[0]), .SCLK(clk_TMDS), .RST(0) );

endmodule

////////////////////////////////////////////////////////////////////////
