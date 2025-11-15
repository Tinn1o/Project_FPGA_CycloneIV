library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

entity frequency_divider is
    generic(
        CLK_FREQUENCY : natural := 50_000_000;  -- Clk FPGA
		  -- 1000 -> 1 s, 2000 -> 2s ...
        EDGE_DELAY_MS : natural := 3000         -- milisegundos entre flancos
    );
    port(
        clk_i  : in  std_logic;
        rst_i  : in  std_logic;       
        out_o  : out std_logic
    );
end entity;

architecture RTL of frequency_divider is
    -- Ciclos de reloj por milisegundo
    constant CYCLES_PER_MS : natural := CLK_FREQUENCY / 1000;

    -- Ciclos totales para producir un flanco
    constant C_TOGGLE_LIMIT : natural := CYCLES_PER_MS * EDGE_DELAY_MS;
	 
    signal count : natural range 0 to C_TOGGLE_LIMIT - 1 := 0;
    signal s_out : std_logic := '0';

begin
	-- Conectando la salida a la señal interna
    out_o <= s_out; 
	 
    Divider_Process : process(clk_i, rst_i)
    begin
        if rst_i = '0' then 
            count    <= 0;
            s_out <= '0';
        elsif rising_edge(clk_i) then
            if count = C_TOGGLE_LIMIT - 1 then
                -- Límite alcanzado (0 a 49,999)
                count    <= 0; -- Reinicio el contador de flanco
                s_out <= not s_out; -- Invierto la salida
            else
                count <= count + 1; 
            end if;
        end if;
    end process Divider_Process;
end architecture RTL;