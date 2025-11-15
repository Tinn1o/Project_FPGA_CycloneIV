library ieee;
use ieee.std_logic_1164.all; -- Para trabajar con señales de 1 bit o arrays.
use ieee.std_logic_unsigned.all; -- Para trabajar con operadores aritmeticos

entity Counter_Binary is 
	port(
		clk50mhz : in std_logic; -- Reloj prinicipal 50mhz
		rst : in std_logic; -- reset
		leds : out std_logic_vector(3 downto 0) -- Array de bits
	);
end entity; 

architecture behavior of Counter_Binary is
   --                                           3210   
	signal num : std_logic_vector(3 downto 0) :="0000"; -- Contador 4 bits
	signal RelojDiv : std_logic; 
	
	-- Declaracion del modulo Frequency_Divider
	component frequency_Divider is
		 port(
        clk_i  : in  std_logic; 
        rst_i  : in  std_logic;       
        out_o  : out std_logic
		);
	end component;
begin
	-- Instancia 1: 
	-- Conectaremos las señales locales del Counter_Binary 
	-- a nuestras señales locales
	Instance1: frequency_Divider
		port map(
			clk_i => clk50mhz, -- Recibe nuestra clk
			rst_i => rst, -- Recibe nuestro rst
			out_o => RelojDiv -- El modulo entrega la salida reducida
		);
		
	-- Proceso Counter se activara o despertara si las señales
	-- dentro del parentesis cambian su estado
	Counter: process(rst,RelojDiv)
	begin
	   -- Comprobamos si rst esta presionado
		if rst = '0' then
			num <= "0000"; -- Reset counter
		-- Si detecta un flanco de subida se activo esta sentencia
		elsif rising_edge(RelojDiv) then
			num <= num +1; -- Incrementa el Counter Binary
		end if;
	end process Counter;
	-- Invertimos su valor de num dado a que es activo-bajo
	leds <= not num;
		
end architecture behavior; 