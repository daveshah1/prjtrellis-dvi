-- diamond clock

library IEEE;
use IEEE.std_logic_1164.all;
library ECP5U;
use ECP5U.components.all;

entity clk_25_125_250_25_83 is
    port
    (
        clkin_25MHz: in std_logic; -- CLKI
        clk_125MHz: out std_logic; -- CLKOP 
        clk_250MHz: out std_logic; -- CLKOS 
        clk_25MHz: out std_logic;  -- CLKOS2
        clk_83M333Hz: out std_logic; -- CLKOS3
        locked: out std_logic
    );
end;

architecture Structure of clk_25_125_250_25_83 is

    -- internal signal declarations
    signal REFCLK: std_logic;
    signal LOCK: std_logic;
    signal CLKOS3_t: std_logic;
    signal CLKOS2_t: std_logic;
    signal CLKOS_t: std_logic;
    signal CLKOP_t: std_logic;
    signal scuba_vhi: std_logic;
    signal scuba_vlo: std_logic;

    attribute FREQUENCY_PIN_CLKOS3 : string; 
    attribute FREQUENCY_PIN_CLKOS2 : string; 
    attribute FREQUENCY_PIN_CLKOS : string; 
    attribute FREQUENCY_PIN_CLKOP : string; 
    attribute FREQUENCY_PIN_CLKI : string; 
    attribute ICP_CURRENT : string; 
    attribute LPF_RESISTOR : string; 
    attribute FREQUENCY_PIN_CLKOS3 of PLLInst_0 : label is "83.333333";
    attribute FREQUENCY_PIN_CLKOS2 of PLLInst_0 : label is "25.000000";
    attribute FREQUENCY_PIN_CLKOS of PLLInst_0 : label is "250.000000";
    attribute FREQUENCY_PIN_CLKOP of PLLInst_0 : label is "125.000000";
    attribute FREQUENCY_PIN_CLKI of PLLInst_0 : label is "25.000000";
    attribute ICP_CURRENT of PLLInst_0 : label is "9";
    attribute LPF_RESISTOR of PLLInst_0 : label is "8";
    attribute syn_keep : boolean;
    attribute NGD_DRC_MASK : integer;
    attribute NGD_DRC_MASK of Structure : architecture is 1;

begin
    -- component instantiation statements
    scuba_vhi_inst: VHI
        port map (Z=>scuba_vhi);

    scuba_vlo_inst: VLO
        port map (Z=>scuba_vlo);

    PLLInst_0: EHXPLLL
        generic map (PLLRST_ENA=> "DISABLED", INTFB_WAKE=> "DISABLED", 
        STDBY_ENABLE=> "DISABLED", DPHASE_SOURCE=> "DISABLED", 
        CLKOS3_FPHASE=>  0, CLKOS3_CPHASE=>  5, CLKOS2_FPHASE=>  0, 
        CLKOS2_CPHASE=>  19, CLKOS_FPHASE=>  0, CLKOS_CPHASE=>  1, 
        CLKOP_FPHASE=>  0, CLKOP_CPHASE=>  3, PLL_LOCK_MODE=>  0, 
        CLKOS_TRIM_DELAY=>  0, CLKOS_TRIM_POL=> "FALLING", 
        CLKOP_TRIM_DELAY=>  0, CLKOP_TRIM_POL=> "FALLING", 
        OUTDIVIDER_MUXD=> "DIVD", CLKOS3_ENABLE=> "ENABLED", 
        OUTDIVIDER_MUXC=> "DIVC", CLKOS2_ENABLE=> "ENABLED", 
        OUTDIVIDER_MUXB=> "DIVB", CLKOS_ENABLE=> "ENABLED", 
        OUTDIVIDER_MUXA=> "DIVA", CLKOP_ENABLE=> "ENABLED", CLKOS3_DIV=>  6, 
        CLKOS2_DIV=>  20, CLKOS_DIV=>  2, CLKOP_DIV=>  4, CLKFB_DIV=>  5, 
        CLKI_DIV=>  1, FEEDBK_PATH=> "CLKOP")
        port map (CLKI=>clkin_25MHz, CLKFB=>CLKOP_t, PHASESEL1=>scuba_vlo, 
            PHASESEL0=>scuba_vlo, PHASEDIR=>scuba_vlo, 
            PHASESTEP=>scuba_vlo, PHASELOADREG=>scuba_vlo, 
            STDBY=>scuba_vlo, PLLWAKESYNC=>scuba_vlo, RST=>scuba_vlo, 
            ENCLKOP=>scuba_vlo, ENCLKOS=>scuba_vlo, ENCLKOS2=>scuba_vlo, 
            ENCLKOS3=>scuba_vlo, CLKOP=>CLKOP_t, CLKOS=>CLKOS_t, 
            CLKOS2=>CLKOS2_t, CLKOS3=>CLKOS3_t, LOCK=>LOCK, 
            INTLOCK=>open, REFCLK=>REFCLK, CLKINTFB=>open);

    clk_125MHz <= CLKOP_t;
    clk_250MHz <= CLKOS_t;
    clk_25MHz <= CLKOS2_t;
    clk_83M333Hz <= CLKOS3_t;
    locked <= LOCK;

end Structure;
