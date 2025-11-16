library ieee;
use ieee.std_logic_1164.all;
entity StateMachineProject is
	Port(
		rst : in std_logic;  
		clk : in std_logic; --50mhz
		sw : in std_logic_vector(4 downto 1); -- vector with 4 elements
		led : out std_logic_vector(4 downto 1)
	);
end entity;

architecture rtl of StateMachineProject is

component PLL IS
	PORT
	(
		areset		: IN STD_LOGIC  := '0'; -- reset PPL
		inclk0		: IN STD_LOGIC  := '0'; -- Reloj de 50 Mhz 
		c0		: OUT STD_LOGIC -- Salida reducida (25Mhz)
	);
end component PLL;
	-- Definimos la Maquina de estados
	type DataTypeOfSMState is (STATE1,STATE2,STATE3,STATE4);

	signal StateVariable : DataTypeOfSMState; -- Estado actual
	signal clk_25mhz : std_logic; -- Reloj divido por PPL


begin
	-- Instancia del PPL
	-- Convierte el reloj 50Mhz -> 25 Mhz, este PPL fue generado a traves de
	-- de IP Catalog / Basic Functions / Clocks../ PLL, debido a que lo usaremos
	-- como reloj.
	PLL1: PLL
	port map
	(
		areset => not(rst),
		inclk0 => clk, -- 50Mhz
		c0		=> clk_25Mhz -- 25Mhz
	);

	Process1 : process(rst,clk_25Mhz) -- sincronysus process
	begin
		if rst = '0' then
			StateVariable <= STATE1;
			led <= "1111"; -- Disabled all LED's

		elsif rising_edge(clk_25Mhz) then
			case StateVariable is
				when STATE1 => 
					--      4321 
					led <= "1110"; -- 1 LED prendido
					if sw(1) = '0' then
						StateVariable <= STATE2; -- Avanza al STATE2
					end if;
				when STATE2 =>
					led <= "1101"; -- 2 LED prendido
					if sw(2) = '0' then
						StateVariable <= STATE3; -- Avanza al STATE3
					end if;
				when STATE3 =>
					led <= "1011"; -- 3 LED prendido
					if sw(3) = '0' then 
						StateVariable <= STATE4; -- Avanza al STATE4
					end if;
				when STATE4 =>
					led <= "0111"; -- 4 LED prendido
					if sw(4) = '0' then 
						StateVariable <= STATE1; -- Devuelve al STATE1
					end if;
				when others =>  -- Important
					-- Esta linea protege contra estados invalidos
					Statevariable <= STATE1; -- FIX bugs, line protector, si es que no existe un valor y no se quede estancado.
			end case;
		end if;
	end process Process1;
end architecture rtl;