module top_dvitest_lpf
(
  input clk_25mhz,
  input [6:0] btn,
  output [7:0] led,
  output [3:0] gpdi_dp, gpdi_dn,
  output wifi_gpio0
);

    // Tie GPIO0, keep board from rebooting
    assign wifi_gpio0 = 1'b1;

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
    assign led[0] = btn[1];
    assign led[7:1] = countblink[7:1];

    wire clk_25MHz, clk_250MHz;
    clock
    clock_instance
    (
      .clkin_25MHz(clk_25mhz),
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
