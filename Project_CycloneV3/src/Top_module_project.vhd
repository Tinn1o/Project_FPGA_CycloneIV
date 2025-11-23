library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Top_module_project is
    port (
        clk : in std_logic;
        rst_n : in std_logic;

        -- Entradas
        btn_vel_n : in std_logic;
        btn_cw_n : in std_logic;
        btn_ccw_n : in std_logic;

        -- Salidas Motor
        motor_ena : out std_logic;
        motor_in1 : out std_logic;
        motor_in2 : out std_logic;
        leds_n : out std_logic_vector(4 downto 1);

        -- Salidas LCD
        RS, RW, ENA : out std_logic;
        DATA_LCD : out std_logic_vector(7 downto 0)
    );
end Top_module_project;

architecture Behavioral of Top_module_project is

    -- Cable interno para pasar el dato
    signal s_nivel_velocidad : integer range 0 to 3;

    component motor_control_lcd
        port (
            clk, rst_n : in std_logic;
            btn_vel_n, btn_cw_n, btn_ccw_n : in std_logic;
            leds_n : out std_logic_vector(4 downto 1);
            motor_ena, motor_in1, motor_in2 : out std_logic;
            nivel_velocidad : out integer range 0 to 3
        );
    end component;

    component LIB_LCD_INTESC_REVD
        generic (FPGA_CLK : integer);
        port (
            CLK : in std_logic;
            VELOCIDAD_IN : in integer range 0 to 3;
            RS, RW, ENA : out std_logic;
            DATA_LCD : out std_logic_vector(7 downto 0)
        );
    end component;

begin
    -- Instancia 1
    inst_motor : motor_control_lcd
    port map(
        clk => clk,
        rst_n => rst_n,
        btn_vel_n => btn_vel_n,
        btn_cw_n => btn_cw_n,
        btn_ccw_n => btn_ccw_n,
        leds_n => leds_n,
        motor_ena => motor_ena,
        motor_in1 => motor_in1,
        motor_in2 => motor_in2,
        nivel_velocidad => s_nivel_velocidad
    );

    -- Instancia 2
    inst_lcd : LIB_LCD_INTESC_REVD
    generic map(FPGA_CLK => 50_000_000)
    port map(
        CLK => clk,
        VELOCIDAD_IN => s_nivel_velocidad,
        RS => RS,
        RW => RW,
        ENA => ENA,
        DATA_LCD => DATA_LCD
    );

end Behavioral;