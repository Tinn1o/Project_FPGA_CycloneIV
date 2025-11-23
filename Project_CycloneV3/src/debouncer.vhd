library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity debouncer is
    generic (
        CLK_FREQ : integer := 50_000_000;
        TIME_MS : integer := 20
    );
    port (
        clk : in std_logic;
        btn_in : in std_logic;
        btn_out : out std_logic
    );
end debouncer;

architecture Behavioral of debouncer is
    -- Calculamos cuántos ciclos son 20ms
    constant CONTADOR_MAX : integer := (CLK_FREQ / 1000) * TIME_MS;
    signal contador : integer range 0 to CONTADOR_MAX := 0;
    signal estado_estable : std_logic := '1';
    signal btn_sync : std_logic := '1';
begin
    process (clk)
    begin
        if rising_edge(clk) then
            btn_sync <= btn_in;

            if (btn_sync /= estado_estable) then
                if contador < CONTADOR_MAX then -- Si la pulsacion no dura 20 ms
                    contador <= contador + 1;
                else
                    estado_estable <= btn_sync; -- Paso 20ms, tomamos su valor
                    contador <= 0;
                end if;
            else
                contador <= 0; -- Si fue ruido, reseteamos cuenta
            end if;
        end if;
    end process;
    btn_out <= estado_estable;
end Behavioral;