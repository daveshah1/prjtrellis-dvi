module top_vgatest
(
  input clk_25mhz,
  input [6:0] btn,
  output [7:0] led,
  output [3:0] gpdi_dp, gpdi_dn,
  output wifi_gpio0
);
    parameter C_ddr = 1'b1; // 0:SDR 1:DDR 

    // wifi_gpio0=1 keeps board from rebooting
    // hold btn0 to let ESP32 take control over the board
    assign wifi_gpio0 = btn[0];

    // clock generator
    wire clk_25MHz, clk_125MHz, clk_250MHz;
    clk_25_125_250_25_83
    clock_instance
    (
      .clkin_25MHz(clk_25mhz),
      .clk_25MHz(clk_25MHz),
      .clk_125MHz(clk_125MHz),
      .clk_250MHz(clk_250MHz)
    );
    
    // shift clock choice SDR/DDR
    wire clk_pixel, clk_shift;
    assign clk_pixel = clk_25MHz;
    generate
      if(C_ddr == 1'b1)
        assign clk_shift = clk_125MHz;
      else
        assign clk_shift = clk_250MHz;
    endgenerate

    // LED blinky
    localparam counter_width = 28;
    wire [7:0] countblink;
    blink
    #(
      .bits(counter_width)
    )
    blink_instance
    (
      .clk(clk_pixel),
      .led(countblink)
    );
    assign led[0] = btn[1];
    assign led[7:1] = countblink[7:1];

    // VGA signal generator
    wire [7:0] vga_r, vga_g, vga_b;
    wire vga_hsync, vga_vsync, vga_blank;
    vga
    vga_instance
    (
      .clk_pixel(clk_pixel),
      .test_picture(1'b1), // enable test picture generation
      .vga_r(vga_r),
      .vga_g(vga_g),
      .vga_b(vga_b),
      .vga_hsync(vga_hsync),
      .vga_vsync(vga_vsync),
      .vga_blank(vga_blank)
    );

    // VGA to digital video converter
    wire [1:0] tmds[3:0];
    vga2dvid
    #(
      .C_ddr(C_ddr)
    )
    vga2dvid_instance
    (
      .clk_pixel(clk_pixel),
      .clk_shift(clk_shift),
      .in_red(vga_r),
      .in_green(vga_g),
      .in_blue(vga_b),
      .in_hsync(vga_hsync),
      .in_vsync(vga_vsync),
      .in_blank(vga_blank),
      .out_clock(tmds[3]),
      .out_red(tmds[2]),
      .out_green(tmds[1]),
      .out_blue(tmds[0])
    );

    // output SDR/DDR
    generate
      genvar i;
      if(C_ddr == 1'b1)
        for(i = 0; i < 4; i++)
        begin : DDR_output_mode
          ODDRX1F
          ddr_p_instance
          (
            .D0(tmds[i][0]),
            .D1(tmds[i][1]),
            .Q(gpdi_dp[i]),
            .SCLK(clk_shift),
            .RST(0)
          );
          ODDRX1F
          ddr_n_instance
          (
            .D0(~tmds[i][0]),
            .D1(~tmds[i][1]),
            .Q(gpdi_dn[i]),
            .SCLK(clk_shift),
            .RST(0)
          );
        end
      else
        for(i = 0; i < 4; i++)
        begin : SDR_output_mode
          assign gpdi_dp[i] =  tmds[i][0];
          assign gpdi_dn[i] = ~tmds[i][0];
        end
    endgenerate

endmodule
