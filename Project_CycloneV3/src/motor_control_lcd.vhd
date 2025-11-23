library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity motor_control_lcd is
    port (
        clk : in std_logic;
        rst_n : in std_logic;

        -- Botones Active Low
        btn_vel_n : in std_logic;
        btn_cw_n : in std_logic;
        btn_ccw_n : in std_logic;

        -- Salidas Físicas
        leds_n : out std_logic_vector(4 downto 1);
        motor_ena : out std_logic;
        motor_in1 : out std_logic;
        motor_in2 : out std_logic;

        -- COMUNICACIÓN CON LCD
        nivel_velocidad : out integer range 0 to 3
    );
end motor_control_lcd;

architecture arch of motor_control_lcd is

    type t_estados_vel is (APAGADO, VEL_BAJA, VEL_MEDIA, VEL_MAX); -- Maquina de estados
    signal estado_vel : t_estados_vel := APAGADO;

    type t_estados_dir is (DIR_STOP, DIR_CW, DIR_CCW, ESPERA_SEGURIDAD); -- Maquina de estados
    signal estado_dir : t_estados_dir := DIR_STOP;
    signal estado_destino : t_estados_dir := DIR_STOP;

    constant CLK_FREQ : integer := 50_000_000;
    constant PWM_PERIOD : integer := 50_000;
    constant UMBRAL_BAJO : integer := 13_350;
    constant UMBRAL_MEDIO : integer := 29_200;
    constant UMBRAL_ALTO : integer := 50_000;
    constant TIEMPO_MUERTO_MAX : integer := 50_000_000;

    signal btn_vel_limpio_n, btn_cw_limpio_n, btn_ccw_limpio_n : std_logic;
    signal vel_reg_n : std_logic := '1';
    signal flanco_vel : std_logic := '0';

    signal contador_pwm : integer range 0 to PWM_PERIOD := 0;
    signal umbral_actual : integer range 0 to PWM_PERIOD := 0;
    signal pwm_base : std_logic := '0';
    signal contador_espera : integer range 0 to TIEMPO_MUERTO_MAX := 0;

    -- Debouncer
    component debouncer
        generic (
            CLK_FREQ : integer;
            TIME_MS : integer);
        port (
            clk : in std_logic;
            btn_in : in std_logic;
            btn_out : out std_logic);
    end component;

begin
    -- Instancias
    D1 : debouncer generic map(50_000_000, 20) port map(clk, btn_vel_n, btn_vel_limpio_n);
    D2 : debouncer generic map(50_000_000, 20) port map(clk, btn_cw_n, btn_cw_limpio_n);
    D3 : debouncer generic map(50_000_000, 20) port map(clk, btn_ccw_n, btn_ccw_limpio_n);

    -- Lógica de Velocidad
    process (clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                estado_vel <= APAGADO;
                vel_reg_n <= '1';
                umbral_actual <= 0;
                nivel_velocidad <= 0;
            else
                vel_reg_n <= btn_vel_limpio_n;
                if (vel_reg_n = '1' and btn_vel_limpio_n = '0') then
                    flanco_vel <= '1';
                else
                    flanco_vel <= '0';
                end if;

                case estado_vel is
                    when APAGADO =>
                        umbral_actual <= 0;
                        nivel_velocidad <= 0;
                        if flanco_vel = '1' then
                            estado_vel <= VEL_BAJA;
                        end if;
                    when VEL_BAJA =>
                        umbral_actual <= UMBRAL_BAJO;
                        nivel_velocidad <= 1;
                        if flanco_vel = '1' then
                            estado_vel <= VEL_MEDIA;
                        end if;
                    when VEL_MEDIA =>
                        umbral_actual <= UMBRAL_MEDIO;
                        nivel_velocidad <= 2;
                        if flanco_vel = '1' then
                            estado_vel <= VEL_MAX;
                        end if;
                    when VEL_MAX =>
                        umbral_actual <= UMBRAL_ALTO;
                        nivel_velocidad <= 3;
                        if flanco_vel = '1' then
                            estado_vel <= APAGADO;
                        end if;
                    when others => estado_vel <= APAGADO;
                end case;
            end if;
        end if;
    end process;

    -- Lógica de Dirección
    process (clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                estado_dir <= DIR_STOP;
                contador_espera <= 0;
            else
                if (btn_cw_limpio_n = '0' and btn_ccw_limpio_n = '0') then
                    estado_dir <= DIR_STOP;
                else
                    case estado_dir is
                        when DIR_STOP =>
                            contador_espera <= 0;
                            if btn_cw_limpio_n = '0' then
                                estado_dir <= DIR_CW;
                            elsif btn_ccw_limpio_n = '0' then
                                estado_dir <= DIR_CCW;
                            end if;
                        when DIR_CW =>
                            if btn_ccw_limpio_n = '0' then
                                estado_dir <= ESPERA_SEGURIDAD;
                                estado_destino <= DIR_CCW;
                            end if;
                        when DIR_CCW =>
                            if btn_cw_limpio_n = '0' then
                                estado_dir <= ESPERA_SEGURIDAD;
                                estado_destino <= DIR_CW;
                            end if;
                        when ESPERA_SEGURIDAD =>
                            if contador_espera < TIEMPO_MUERTO_MAX then
                                contador_espera <= contador_espera + 1;
                            else
                                estado_dir <= estado_destino;
                                contador_espera <= 0;
                            end if;
                    end case;
                end if;
            end if;
        end if;
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            if contador_pwm < PWM_PERIOD - 1 then
                contador_pwm <= contador_pwm + 1;
            else
                contador_pwm <= 0;
            end if;
            if contador_pwm < umbral_actual then
                pwm_base <= '1';
            else
                pwm_base <= '0';
            end if;
        end if;
    end process;

    leds_n <= (others => not pwm_base);

    process (estado_dir, pwm_base)
    begin
        case estado_dir is
            when DIR_CW =>
                motor_ena <= pwm_base;
                motor_in1 <= '1';
                motor_in2 <= '0';
            when DIR_CCW =>
                motor_ena <= pwm_base;
                motor_in1 <= '0';
                motor_in2 <= '1';
            when others =>
                motor_ena <= '0';
                motor_in1 <= '0';
                motor_in2 <= '0';
        end case;
    end process;

end architecture;