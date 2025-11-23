library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.COMANDOS_LCD_REVD.all;

entity LIB_LCD_INTESC_REVD is
    generic (FPGA_CLK : integer := 50_000_000);
    port (
        CLK : in std_logic;
        VELOCIDAD_IN : in integer range 0 to 3; -- Entrada de dato
        RS : out std_logic;
        RW : out std_logic;
        ENA : out std_logic;
        DATA_LCD : out std_logic_vector(7 downto 0)
    );
end LIB_LCD_INTESC_REVD;

architecture Behavioral of LIB_LCD_INTESC_REVD is
    constant NUM_INST : integer := 25;
    signal VECTOR_MEM : std_logic_vector(8 downto 0);
    signal C1, C2, C3, C4, C5, C6, C7, C8 : std_logic_vector(39 downto 0);
    signal DIR_MEM : integer range 0 to NUM_INST;
    signal BD_LCD : std_logic_vector(7 downto 0);

    type RAM is array (0 to NUM_INST) of std_logic_vector(8 downto 0);
    signal INST : RAM;

    component PROCESADOR_LCD_REVD
        generic (
            FPGA_CLK : integer;
            NUM_INST : integer);
        port (
            CLK : in std_logic;
            VECTOR_MEM : in std_logic_vector(8 downto 0);
            C1A, C2A, C3A, C4A, C5A, C6A, C7A, C8A : in std_logic_vector(39 downto 0);
            RS, RW, ENA : out std_logic;
            BD_LCD : out std_logic_vector(7 downto 0);
            DATA : out std_logic_vector(7 downto 0);
            DIR_MEM : out integer range 0 to NUM_INST
        );
    end component;

    component CARACTERES_ESPECIALES_REVD
        port (C1, C2, C3, C4, C5, C6, C7, C8 : out std_logic_vector(39 downto 0));
    end component;

begin

    U1 : PROCESADOR_LCD_REVD generic map(FPGA_CLK, NUM_INST)
    port map(CLK, VECTOR_MEM, C1, C2, C3, C4, C5, C6, C7, C8, RS, RW, ENA, BD_LCD, DATA_LCD, DIR_MEM);

    U2 : CARACTERES_ESPECIALES_REVD port map(C1, C2, C3, C4, C5, C6, C7, C8);

    VECTOR_MEM <= INST(DIR_MEM);

    --- AQUÍ ESCRIBIMOS EL MENSAJE
    PROCESO_VISUALIZACION : process (VELOCIDAD_IN)
    begin
        INST(0) <= LCD_INI("00");
        INST(1) <= POS(1, 1);
        INST(2) <= CHAR(M);
        INST(3) <= CHAR(o);
        INST(4) <= CHAR(t);
        INST(5) <= CHAR(o);
        INST(6) <= CHAR(r);
        INST(7) <= CHAR_ASCII(x"3A");
        INST(8) <= POS(2, 1);
        INST(9) <= CHAR(N);
        INST(10) <= CHAR(i);
        INST(11) <= CHAR(v);
        INST(12) <= CHAR(e);
        INST(13) <= CHAR(l);
        INST(14) <= CHAR_ASCII(x"20");
        INST(15) <= BUCLE_INI(1);
        INST(16) <= POS(2, 7);
        case VELOCIDAD_IN is
            when 0 => INST(17) <= CHAR_ASCII(x"30"); -- '0'
            when 1 => INST(17) <= CHAR_ASCII(x"31"); -- '1'
            when 2 => INST(17) <= CHAR_ASCII(x"32"); -- '2'
            when 3 => INST(17) <= CHAR_ASCII(x"33"); -- '3'
            when others => INST(17) <= CHAR_ASCII(x"45"); -- 'E'
        end case;
        INST(18) <= BUCLE_FIN(1);
        -- Bloque de seguridad anti-overflow
        INST(19) <= CODIGO_FIN(1);
        INST(20) <= CODIGO_FIN(1);
        INST(21) <= CODIGO_FIN(1);
        INST(22) <= CODIGO_FIN(1);
        INST(23) <= CODIGO_FIN(1);
        INST(24) <= CODIGO_FIN(1);
        INST(25) <= CODIGO_FIN(1);

    end process;

end Behavioral;