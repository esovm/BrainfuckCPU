
-- This part of project was written by hand.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity rstx is
  generic (
    sysclk : integer := 14000000;
    rate    : integer := 9600
    );
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    wr    : in  std_logic;
    din   : in  std_logic_vector(7 downto 0);
    dout  : out std_logic := '1';
    ready : out std_logic
    );
end rstx;

architecture rtl of rstx is
  component clk_div is
    port (clk      : in  std_logic;
           rst     : in  std_logic;
           div     : in  std_logic_vector(15 downto 0);
           clk_out : out std_logic);
  end component;
  signal in_din : std_logic_vector(7 downto 0);
  signal buf    : std_logic_vector(7 downto 0);
  signal load   : std_logic := '0';
  signal cbit   : std_logic_vector(2 downto 0) := (others => '0');
  signal run : std_logic := '0';
  signal tx_en  : std_logic;
  signal tx_div : std_logic_vector(15 downto 0);
  signal status : std_logic_vector(1 downto 0);

begin
  tx_div <= conv_std_logic_vector((sysclk / rate) - 1, 16);
  U0: clk_div port map (clk, reset, tx_div, tx_en);
  ready <= '1' when (wr = '0' and run = '0' and load = '0') else '0';
  process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '1') then
        load <= '0';
      else
        if(wr = '1' and run = '0') then
          load   <= '1';
          in_din <= din;
        end if;
        if(load = '1' and run = '1') then
          load <= '0';
        end if;
      end if;
    end if;
  end process;
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        dout <= '1';
        cbit <= (others => '0');
        status <= (others => '0');
        run <= '0';
      elsif tx_en = '1' then
        case conv_integer(status) is
          when 0 =>
            cbit <= (others => '0');
            if load = '1' then
              dout <= '0';
              status <= status + 1;
              buf <= in_din;
              run <= '1';
            else
              dout <= '1';
              run <= '0';
            end if;
          when 1 =>
            cbit <= cbit + 1;
            dout <= buf(conv_integer(cbit));
            if(conv_integer(cbit) = 7) then
              status <= status + 1;
            end if;
          when 2 =>
            dout <= '1';
            status <= (others => '0');
          when others =>
            status <= (others => '0');
        end case;
      end if;
    end if;
  end process;

end rtl;
