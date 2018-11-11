
-- This part of project was written by hand.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity rsrx is
  generic(
    sysclk : integer := 14000000;
    rate : integer := 9600
    );
  port(
    clk  : in  std_logic;
    reset  : in  std_logic;
    din  : in  std_logic;
    rd   : out std_logic;
    dout : out std_logic_vector( 7 downto 0 )
    );
end rsrx;

architecture rtl of rsrx is
  component clk_div is
    port(
      clk     : in  std_logic;
      rst     : in  std_logic;
      div     : in  std_logic_vector(15 downto 0);
      clk_out : out std_logic
      );
  end component;
  signal buf    : std_logic_vector(7 downto 0) := (others => '0');
  signal start  : std_logic := '0';
  signal cbit   : integer range 0 to 150 := 0;
  signal rx_en  : std_logic;
  signal rx_div : std_logic_vector(15 downto 0);

  signal din_d, din_dd : std_logic;

begin
  rx_div <= conv_std_logic_vector(((sysclk / rate) / 4) - 1, 16);
  U0: clk_div port map (clk, reset, rx_div, rx_en);

  process(clk)
  begin
    if rising_edge(clk) then
      din_d <= din;
      din_dd <= din_d;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        start <= '0';
        cbit  <= 0;
        buf   <= (others => '0');
        dout  <= (others => '0');
        rd    <= '0';
      elsif rx_en = '1' then
        if(start = '0') then
          rd <= '0';
          if(din_dd = '0') then
            start <= '1';
          end if;
        else
          case cbit is
            when 2 =>
              if(din_dd = '1') then
                start <= '0';
              else
                cbit <= cbit + 1;
              end if;
            when 6 | 10 | 14 | 18 | 22 | 26 | 30 | 34 =>
              cbit <= cbit + 1;
              buf  <= din_dd & buf(7 downto 1);
            when 38 =>
              cbit  <= 0;
              dout  <= buf;
              start <= '0';
              rd    <= '1';
            when others =>
              cbit <= cbit + 1;
          end case;
        end if;
      end if;
    end if;
  end process;

end RTL;
