library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rs232c is
  port (
    clk : in std_logic;
    reset : in std_logic;
    tx_dout_exp : out std_logic;
    rx_din_exp : in std_logic;
    write_data : in signed(8-1 downto 0);
    read_return : out signed(8-1 downto 0);
    read_busy : out std_logic;
    read_req : in std_logic;
    write_busy : out std_logic;
    write_req : in std_logic
  );
end rs232c;

architecture RTL of rs232c is

  attribute mark_debug : string;
  attribute keep : string;
  attribute S : string;

  component rstx
    generic (
      sys_clk : integer := 25000000;
      rate : integer := 9600
    );
    port (
      clk : in std_logic;
      reset : in std_logic;
      dout : out std_logic;
      wr : in std_logic;
      din : in std_logic_vector(7 downto 0);
      ready : out std_logic
    );
  end component rstx;
  component rsrx
    generic (
      sys_clk : integer := 25000000;
      rate : integer := 9600
    );
    port (
      clk : in std_logic;
      reset : in std_logic;
      din : in std_logic;
      rd : out std_logic;
      dout : out std_logic_vector(7 downto 0)
    );
  end component rsrx;

  signal clk_sig : std_logic := '0';
  signal reset_sig : std_logic := '0';
  signal tx_dout_exp_sig : std_logic := '0';
  signal rx_din_exp_sig : std_logic := '0';
  signal write_data_sig : signed(8-1 downto 0) := (others => '0');
  signal read_return_sig : signed(8-1 downto 0) := (others => '0');
  signal read_busy_sig : std_logic := '1';
  signal read_req_sig : std_logic := '0';
  signal write_busy_sig : std_logic := '1';
  signal write_req_sig : std_logic := '0';

  signal class_tx_0000_clk : std_logic := '0';
  signal class_tx_0000_reset : std_logic := '0';
  signal class_tx_0000_wr : std_logic := '0';
  signal class_tx_0000_din : std_logic_vector(8-1 downto 0) := (others => '0');
  signal class_tx_0000_ready : std_logic := '0';
  signal class_rx_0002_clk : std_logic := '0';
  signal class_rx_0002_reset : std_logic := '0';
  signal class_rx_0002_rd : std_logic := '0';
  signal class_rx_0002_dout : std_logic_vector(8-1 downto 0) := (others => '0');
  signal field_access_00004 : std_logic := '0';
  signal binary_expr_00006 : std_logic := '0';
  signal field_access_00007 : std_logic := '0';
  signal binary_expr_00009 : std_logic := '0';
  signal field_access_00010 : signed(8-1 downto 0) := (others => '0');
  signal write_data_0011 : signed(8-1 downto 0) := (others => '0');
  signal write_data_local : signed(8-1 downto 0) := (others => '0');
  signal field_access_00012 : std_logic := '0';
  signal binary_expr_00014 : std_logic := '0';
  signal field_access_00015 : signed(8-1 downto 0) := (others => '0');
  signal field_access_00017 : std_logic := '0';
  signal field_access_00019 : std_logic := '0';
  signal read_req_flag : std_logic := '0';
  signal read_req_local : std_logic := '0';
  signal tmp_0001 : std_logic := '0';
  signal write_req_flag : std_logic := '0';
  signal write_req_local : std_logic := '0';
  signal tmp_0002 : std_logic := '0';
  type Type_read_method is (
    read_method_IDLE,
    read_method_S_0000,
    read_method_S_0001,
    read_method_S_0002,
    read_method_S_0003,
    read_method_S_0004,
    read_method_S_0007,
    read_method_S_0008,
    read_method_S_0009,
    read_method_S_0012,
    read_method_S_0013  
  );
  signal read_method : Type_read_method := read_method_IDLE;
  signal read_method_delay : signed(32-1 downto 0) := (others => '0');
  signal read_req_flag_d : std_logic := '0';
  signal read_req_flag_edge : std_logic := '0';
  signal tmp_0003 : std_logic := '0';
  signal tmp_0004 : std_logic := '0';
  signal tmp_0005 : std_logic := '0';
  signal tmp_0006 : std_logic := '0';
  signal tmp_0007 : std_logic := '0';
  signal tmp_0008 : std_logic := '0';
  signal tmp_0009 : std_logic := '0';
  signal tmp_0010 : std_logic := '0';
  signal tmp_0011 : std_logic := '0';
  signal tmp_0012 : std_logic := '0';
  signal tmp_0013 : std_logic := '0';
  signal tmp_0014 : std_logic := '0';
  signal tmp_0015 : std_logic := '0';
  signal tmp_0016 : std_logic := '0';
  type Type_write_method is (
    write_method_IDLE,
    write_method_S_0000,
    write_method_S_0001,
    write_method_S_0002,
    write_method_S_0003,
    write_method_S_0004,
    write_method_S_0007,
    write_method_S_0008,
    write_method_S_0009,
    write_method_S_0010,
    write_method_S_0011,
    write_method_S_0012  
  );
  signal write_method : Type_write_method := write_method_IDLE;
  signal write_method_delay : signed(32-1 downto 0) := (others => '0');
  signal write_req_flag_d : std_logic := '0';
  signal write_req_flag_edge : std_logic := '0';
  signal tmp_0017 : std_logic := '0';
  signal tmp_0018 : std_logic := '0';
  signal tmp_0019 : std_logic := '0';
  signal tmp_0020 : std_logic := '0';
  signal tmp_0021 : std_logic := '0';
  signal tmp_0022 : std_logic := '0';
  signal tmp_0023 : std_logic := '0';
  signal tmp_0024 : std_logic := '0';
  signal tmp_0025 : std_logic := '0';
  signal tmp_0026 : std_logic := '0';
  signal tmp_0027 : signed(8-1 downto 0) := (others => '0');
  signal tmp_0028 : std_logic := '0';

begin

  clk_sig <= clk;
  reset_sig <= reset;
  write_data_sig <= write_data;
  read_return <= read_return_sig;
  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        read_return_sig <= (others => '0');
      else
        if read_method = read_method_S_0013 then
          read_return_sig <= field_access_00010;
        end if;
      end if;
    end if;
  end process;

  read_busy <= read_busy_sig;
  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        read_busy_sig <= '1';
      else
        if read_method = read_method_S_0000 then
          read_busy_sig <= '0';
        elsif read_method = read_method_S_0001 then
          read_busy_sig <= tmp_0006;
        end if;
      end if;
    end if;
  end process;

  read_req_sig <= read_req;
  write_busy <= write_busy_sig;
  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        write_busy_sig <= '1';
      else
        if write_method = write_method_S_0000 then
          write_busy_sig <= '0';
        elsif write_method = write_method_S_0001 then
          write_busy_sig <= tmp_0020;
        end if;
      end if;
    end if;
  end process;

  write_req_sig <= write_req;

  -- expressions
  tmp_0001 <= read_req_local or read_req_sig;
  tmp_0002 <= write_req_local or write_req_sig;
  tmp_0003 <= not read_req_flag_d;
  tmp_0004 <= read_req_flag and tmp_0003;
  tmp_0005 <= read_req_flag or read_req_flag_d;
  tmp_0006 <= read_req_flag or read_req_flag_d;
  tmp_0007 <= '1' when binary_expr_00006 = '1' else '0';
  tmp_0008 <= '1' when binary_expr_00006 = '0' else '0';
  tmp_0009 <= '1' when binary_expr_00009 = '1' else '0';
  tmp_0010 <= '1' when binary_expr_00009 = '0' else '0';
  tmp_0011 <= '1' when read_method /= read_method_S_0000 else '0';
  tmp_0012 <= '1' when read_method /= read_method_S_0001 else '0';
  tmp_0013 <= tmp_0012 and read_req_flag_edge;
  tmp_0014 <= tmp_0011 and tmp_0013;
  tmp_0015 <= '1' when field_access_00004 /= '0' else '0';
  tmp_0016 <= '1' when field_access_00007 /= '1' else '0';
  tmp_0017 <= not write_req_flag_d;
  tmp_0018 <= write_req_flag and tmp_0017;
  tmp_0019 <= write_req_flag or write_req_flag_d;
  tmp_0020 <= write_req_flag or write_req_flag_d;
  tmp_0021 <= '1' when binary_expr_00014 = '1' else '0';
  tmp_0022 <= '1' when binary_expr_00014 = '0' else '0';
  tmp_0023 <= '1' when write_method /= write_method_S_0000 else '0';
  tmp_0024 <= '1' when write_method /= write_method_S_0001 else '0';
  tmp_0025 <= tmp_0024 and write_req_flag_edge;
  tmp_0026 <= tmp_0023 and tmp_0025;
  tmp_0027 <= write_data_sig when write_req_sig = '1' else write_data_local;
  tmp_0028 <= '1' when field_access_00012 = '0' else '0';

  -- sequencers
  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        read_method <= read_method_IDLE;
        read_method_delay <= (others => '0');
      else
        case (read_method) is
          when read_method_IDLE => 
            read_method <= read_method_S_0000;
          when read_method_S_0000 => 
            read_method <= read_method_S_0001;
          when read_method_S_0001 => 
            if tmp_0005 = '1' then
              read_method <= read_method_S_0002;
            end if;
          when read_method_S_0002 => 
            read_method <= read_method_S_0003;
            read_method <= read_method_S_0003;
          when read_method_S_0003 => 
            read_method <= read_method_S_0004;
            read_method <= read_method_S_0004;
          when read_method_S_0004 => 
            if tmp_0007 = '1' then
              read_method <= read_method_S_0002;
            elsif tmp_0008 = '1' then
              read_method <= read_method_S_0007;
            end if;
          when read_method_S_0007 => 
            read_method <= read_method_S_0008;
            read_method <= read_method_S_0008;
          when read_method_S_0008 => 
            read_method <= read_method_S_0009;
            read_method <= read_method_S_0009;
          when read_method_S_0009 => 
            if tmp_0009 = '1' then
              read_method <= read_method_S_0007;
            elsif tmp_0010 = '1' then
              read_method <= read_method_S_0012;
            end if;
          when read_method_S_0012 => 
            read_method <= read_method_S_0013;
            read_method <= read_method_S_0013;
          when read_method_S_0013 => 
            read_method <= read_method_S_0000;
          when others => null;
        end case;
        read_req_flag_d <= read_req_flag;
        if (tmp_0011 and tmp_0013) = '1' then
          read_method <= read_method_S_0001;
        end if;
      end if;
    end if;
  end process;

  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        write_method <= write_method_IDLE;
        write_method_delay <= (others => '0');
      else
        case (write_method) is
          when write_method_IDLE => 
            write_method <= write_method_S_0000;
          when write_method_S_0000 => 
            write_method <= write_method_S_0001;
          when write_method_S_0001 => 
            if tmp_0019 = '1' then
              write_method <= write_method_S_0002;
            end if;
          when write_method_S_0002 => 
            write_method <= write_method_S_0003;
            write_method <= write_method_S_0003;
          when write_method_S_0003 => 
            write_method <= write_method_S_0004;
            write_method <= write_method_S_0004;
          when write_method_S_0004 => 
            if tmp_0021 = '1' then
              write_method <= write_method_S_0002;
            elsif tmp_0022 = '1' then
              write_method <= write_method_S_0007;
            end if;
          when write_method_S_0007 => 
            write_method <= write_method_S_0008;
            write_method <= write_method_S_0008;
          when write_method_S_0008 => 
            write_method <= write_method_S_0009;
            write_method <= write_method_S_0009;
          when write_method_S_0009 => 
            write_method <= write_method_S_0010;
            write_method <= write_method_S_0010;
          when write_method_S_0010 => 
            write_method <= write_method_S_0011;
            write_method <= write_method_S_0011;
          when write_method_S_0011 => 
            write_method <= write_method_S_0012;
            write_method <= write_method_S_0012;
          when write_method_S_0012 => 
            write_method <= write_method_S_0000;
            write_method <= write_method_S_0000;
          when others => null;
        end case;
        write_req_flag_d <= write_req_flag;
        if (tmp_0023 and tmp_0025) = '1' then
          write_method <= write_method_S_0001;
        end if;
      end if;
    end if;
  end process;


  class_tx_0000_clk <= clk_sig;

  class_tx_0000_reset <= reset_sig;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_tx_0000_wr <= '0';
      else
        if write_method = write_method_S_0010 then
          class_tx_0000_wr <= '1';
        elsif write_method = write_method_S_0012 then
          class_tx_0000_wr <= '0';
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_tx_0000_din <= (others => '0');
      else
        if write_method = write_method_S_0008 then
          class_tx_0000_din <= std_logic_vector(write_data_0011);
        end if;
      end if;
    end if;
  end process;

  class_rx_0002_clk <= clk_sig;

  class_rx_0002_reset <= reset_sig;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        field_access_00004 <= '0';
      else
        if read_method = read_method_S_0002 then
          field_access_00004 <= class_rx_0002_rd;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00006 <= '0';
      else
        if read_method = read_method_S_0003 then
          binary_expr_00006 <= tmp_0015;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        field_access_00007 <= '0';
      else
        if read_method = read_method_S_0007 then
          field_access_00007 <= class_rx_0002_rd;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00009 <= '0';
      else
        if read_method = read_method_S_0008 then
          binary_expr_00009 <= tmp_0016;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        field_access_00010 <= (others => '0');
      else
        if read_method = read_method_S_0012 then
          field_access_00010 <= signed(class_rx_0002_dout);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        write_data_0011 <= (others => '0');
      else
        if write_method = write_method_S_0001 then
          write_data_0011 <= tmp_0027;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        field_access_00012 <= '0';
      else
        if write_method = write_method_S_0002 then
          field_access_00012 <= class_tx_0000_ready;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00014 <= '0';
      else
        if write_method = write_method_S_0003 then
          binary_expr_00014 <= tmp_0028;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        field_access_00015 <= (others => '0');
      else
        if write_method = write_method_S_0007 then
          field_access_00015 <= signed(class_tx_0000_din);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        field_access_00017 <= '0';
      else
        if write_method = write_method_S_0009 then
          field_access_00017 <= class_tx_0000_wr;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        field_access_00019 <= '0';
      else
        if write_method = write_method_S_0011 then
          field_access_00019 <= class_tx_0000_wr;
        end if;
      end if;
    end if;
  end process;

  read_req_flag <= tmp_0001;

  write_req_flag <= tmp_0002;

  read_req_flag_edge <= tmp_0004;

  write_req_flag_edge <= tmp_0018;


  inst_class_tx_0000 : rstx
  generic map(
    sys_clk => 66700000,
    rate => 9600
  )
  port map(
    clk => clk,
    reset => reset,
    wr => class_tx_0000_wr,
    din => class_tx_0000_din,
    ready => class_tx_0000_ready,
    dout => tx_dout_exp
  );

  inst_class_rx_0002 : rsrx
  generic map(
    sys_clk => 66700000,
    rate => 9600
  )
  port map(
    clk => clk,
    reset => reset,
    rd => class_rx_0002_rd,
    dout => class_rx_0002_dout,
    din => rx_din_exp
  );


end RTL;
