module top_dvitest
(
  input clk_pin,
  input btn_pin,
  output [7:0] led_pin,
  output [3:0] gpdi_dp_pin, gpdi_dn_pin,
  output gpio0_pin
);

    wire clk;
    wire [7:0] led;
    wire btn;
    wire gpio0;
    wire [3:0] gpdi_dp, gpdi_dn;

    (* LOC="G2" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("INPUT")) clk_buf (.B(clk_pin), .O(clk));

    (* LOC="R1" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("INPUT")) btn_buf (.B(btn_pin), .O(btn));

    (* LOC="B2" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) led_buf_0 (.B(led_pin[0]), .I(led[0]));
    (* LOC="C2" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) led_buf_1 (.B(led_pin[1]), .I(led[1]));
    (* LOC="C1" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) led_buf_2 (.B(led_pin[2]), .I(led[2]));
    (* LOC="D2" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) led_buf_3 (.B(led_pin[3]), .I(led[3]));

    (* LOC="D1" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) led_buf_4 (.B(led_pin[4]), .I(led[4]));
    (* LOC="E2" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) led_buf_5 (.B(led_pin[5]), .I(led[5]));
    (* LOC="E1" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) led_buf_6 (.B(led_pin[6]), .I(led[6]));
    (* LOC="H3" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) led_buf_7 (.B(led_pin[7]), .I(led[7]));


    (* LOC="A16" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) gpdi_buf_dp0 (.B(gpdi_dp_pin[0]), .I(gpdi_dp[0]));
    (* LOC="B16" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) gpdi_buf_dn0 (.B(gpdi_dn_pin[0]), .I(gpdi_dn[0]));

    (* LOC="A14" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) gpdi_buf_dp1 (.B(gpdi_dp_pin[1]), .I(gpdi_dp[1]));
    (* LOC="C14" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) gpdi_buf_dn1 (.B(gpdi_dn_pin[1]), .I(gpdi_dn[1]));

    (* LOC="A12" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) gpdi_buf_dp2 (.B(gpdi_dp_pin[2]), .I(gpdi_dp[2]));
    (* LOC="A13" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) gpdi_buf_dn2 (.B(gpdi_dn_pin[2]), .I(gpdi_dn[2]));

    (* LOC="A17" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) gpdi_buf_dp3 (.B(gpdi_dp_pin[3]), .I(gpdi_dp[3]));
    (* LOC="B18" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) gpdi_buf_dn3 (.B(gpdi_dn_pin[3]), .I(gpdi_dn[3]));


    (* LOC="L2" *) (* IO_TYPE="LVCMOS33" *)
    TRELLIS_IO #(.DIR("OUTPUT")) gpio0_buf (.B(gpio0_pin), .I(gpio0));

    // Tie GPIO0, keep board from rebooting
    assign gpio0 = 1'b1;

    localparam counter_width = 28;
    wire [7:0] countblink;
    vhdl_blink
    #(
      .bits(counter_width)
    )
    vhdl_blink_instance
    (
      .clk(clk),
      .led(countblink)
    );
    assign led[0] = btn;
    assign led[7:1] = countblink[7:1];

    wire clk_25MHz, clk_250MHz;
    clock
    clock_instance
    (
      .clkin_25MHz(clk),
      .clk_25MHz(clk_25MHz),
      .clk_250MHz(clk_250MHz)
    );

    DVI_test
    DVI_test_instance
    (
      .pixclk(clk_25MHz),
      .shiftclk(clk_250MHz),
      .TMDSp(gpdi_dp[2:0]),
      .TMDSn(gpdi_dn[2:0]),
      .TMDSp_clock(gpdi_dp[3]),
      .TMDSn_clock(gpdi_dn[3])
    );

endmodule
