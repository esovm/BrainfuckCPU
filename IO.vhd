library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity IO is
  port (
    clk : in std_logic;
    reset : in std_logic;
    obj_tx_dout_exp : out std_logic;
    obj_rx_din_exp : in std_logic;
    putchar_c : in signed(8-1 downto 0);
    putchar_busy : out std_logic;
    putchar_req : in std_logic;
    getchar_return : out signed(8-1 downto 0);
    getchar_busy : out std_logic;
    getchar_req : in std_logic
  );
end IO;

architecture RTL of IO is

  attribute mark_debug : string;
  attribute keep : string;
  attribute S : string;

  component rs232c
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
  end component rs232c;

  signal clk_sig : std_logic := '0';
  signal reset_sig : std_logic := '0';
  signal obj_tx_dout_exp_sig : std_logic := '0';
  signal obj_rx_din_exp_sig : std_logic := '0';
  signal putchar_c_sig : signed(8-1 downto 0) := (others => '0');
  signal putchar_busy_sig : std_logic := '1';
  signal putchar_req_sig : std_logic := '0';
  signal getchar_return_sig : signed(8-1 downto 0) := (others => '0');
  signal getchar_busy_sig : std_logic := '1';
  signal getchar_req_sig : std_logic := '0';

  signal class_obj_0000_clk : std_logic := '0';
  signal class_obj_0000_reset : std_logic := '0';
  signal class_obj_0000_write_data : signed(8-1 downto 0) := (others => '0');
  signal class_obj_0000_read_return : signed(8-1 downto 0) := (others => '0');
  signal class_obj_0000_read_busy : std_logic := '0';
  signal class_obj_0000_read_req : std_logic := '0';
  signal class_obj_0000_write_busy : std_logic := '0';
  signal class_obj_0000_write_req : std_logic := '0';
  signal putchar_c_0002 : signed(8-1 downto 0) := (others => '0');
  signal putchar_c_local : signed(8-1 downto 0) := (others => '0');
  signal getchar_b_0004 : signed(8-1 downto 0) := (others => '0');
  signal method_result_00005 : signed(8-1 downto 0) := (others => '0');
  signal putchar_req_flag : std_logic := '0';
  signal putchar_req_local : std_logic := '0';
  signal tmp_0001 : std_logic := '0';
  signal getchar_req_flag : std_logic := '0';
  signal getchar_req_local : std_logic := '0';
  signal tmp_0002 : std_logic := '0';
  type Type_putchar_method is (
    putchar_method_IDLE,
    putchar_method_S_0000,
    putchar_method_S_0001,
    putchar_method_S_0002,
    putchar_method_S_0002_body,
    putchar_method_S_0002_wait  
  );
  signal putchar_method : Type_putchar_method := putchar_method_IDLE;
  signal putchar_method_delay : signed(32-1 downto 0) := (others => '0');
  signal putchar_req_flag_d : std_logic := '0';
  signal putchar_req_flag_edge : std_logic := '0';
  signal tmp_0003 : std_logic := '0';
  signal tmp_0004 : std_logic := '0';
  signal tmp_0005 : std_logic := '0';
  signal tmp_0006 : std_logic := '0';
  signal class_obj_0000_write_ext_call_flag_0002 : std_logic := '0';
  signal tmp_0007 : std_logic := '0';
  signal tmp_0008 : std_logic := '0';
  signal tmp_0009 : std_logic := '0';
  signal tmp_0010 : std_logic := '0';
  signal tmp_0011 : std_logic := '0';
  signal tmp_0012 : std_logic := '0';
  signal tmp_0013 : std_logic := '0';
  signal tmp_0014 : std_logic := '0';
  signal tmp_0015 : signed(8-1 downto 0) := (others => '0');
  type Type_getchar_method is (
    getchar_method_IDLE,
    getchar_method_S_0000,
    getchar_method_S_0001,
    getchar_method_S_0002,
    getchar_method_S_0003,
    getchar_method_S_0004,
    getchar_method_S_0002_body,
    getchar_method_S_0002_wait  
  );
  signal getchar_method : Type_getchar_method := getchar_method_IDLE;
  signal getchar_method_delay : signed(32-1 downto 0) := (others => '0');
  signal getchar_req_flag_d : std_logic := '0';
  signal getchar_req_flag_edge : std_logic := '0';
  signal tmp_0016 : std_logic := '0';
  signal tmp_0017 : std_logic := '0';
  signal tmp_0018 : std_logic := '0';
  signal tmp_0019 : std_logic := '0';
  signal class_obj_0000_read_ext_call_flag_0002 : std_logic := '0';
  signal tmp_0020 : std_logic := '0';
  signal tmp_0021 : std_logic := '0';
  signal tmp_0022 : std_logic := '0';
  signal tmp_0023 : std_logic := '0';
  signal tmp_0024 : std_logic := '0';
  signal tmp_0025 : std_logic := '0';
  signal tmp_0026 : std_logic := '0';
  signal tmp_0027 : std_logic := '0';

begin

  clk_sig <= clk;
  reset_sig <= reset;
  putchar_c_sig <= putchar_c;
  putchar_busy <= putchar_busy_sig;
  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        putchar_busy_sig <= '1';
      else
        if putchar_method = putchar_method_S_0000 then
          putchar_busy_sig <= '0';
        elsif putchar_method = putchar_method_S_0001 then
          putchar_busy_sig <= tmp_0006;
        end if;
      end if;
    end if;
  end process;

  putchar_req_sig <= putchar_req;
  getchar_return <= getchar_return_sig;
  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        getchar_return_sig <= (others => '0');
      else
        if getchar_method = getchar_method_S_0004 then
          getchar_return_sig <= getchar_b_0004;
        end if;
      end if;
    end if;
  end process;

  getchar_busy <= getchar_busy_sig;
  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        getchar_busy_sig <= '1';
      else
        if getchar_method = getchar_method_S_0000 then
          getchar_busy_sig <= '0';
        elsif getchar_method = getchar_method_S_0001 then
          getchar_busy_sig <= tmp_0019;
        end if;
      end if;
    end if;
  end process;

  getchar_req_sig <= getchar_req;

  -- expressions
  tmp_0001 <= putchar_req_local or putchar_req_sig;
  tmp_0002 <= getchar_req_local or getchar_req_sig;
  tmp_0003 <= not putchar_req_flag_d;
  tmp_0004 <= putchar_req_flag and tmp_0003;
  tmp_0005 <= putchar_req_flag or putchar_req_flag_d;
  tmp_0006 <= putchar_req_flag or putchar_req_flag_d;
  tmp_0007 <= '1' when class_obj_0000_write_busy = '0' else '0';
  tmp_0008 <= '1' when class_obj_0000_write_req = '0' else '0';
  tmp_0009 <= tmp_0007 and tmp_0008;
  tmp_0010 <= '1' when tmp_0009 = '1' else '0';
  tmp_0011 <= '1' when putchar_method /= putchar_method_S_0000 else '0';
  tmp_0012 <= '1' when putchar_method /= putchar_method_S_0001 else '0';
  tmp_0013 <= tmp_0012 and putchar_req_flag_edge;
  tmp_0014 <= tmp_0011 and tmp_0013;
  tmp_0015 <= putchar_c_sig when putchar_req_sig = '1' else putchar_c_local;
  tmp_0016 <= not getchar_req_flag_d;
  tmp_0017 <= getchar_req_flag and tmp_0016;
  tmp_0018 <= getchar_req_flag or getchar_req_flag_d;
  tmp_0019 <= getchar_req_flag or getchar_req_flag_d;
  tmp_0020 <= '1' when class_obj_0000_read_busy = '0' else '0';
  tmp_0021 <= '1' when class_obj_0000_read_req = '0' else '0';
  tmp_0022 <= tmp_0020 and tmp_0021;
  tmp_0023 <= '1' when tmp_0022 = '1' else '0';
  tmp_0024 <= '1' when getchar_method /= getchar_method_S_0000 else '0';
  tmp_0025 <= '1' when getchar_method /= getchar_method_S_0001 else '0';
  tmp_0026 <= tmp_0025 and getchar_req_flag_edge;
  tmp_0027 <= tmp_0024 and tmp_0026;

  -- sequencers
  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        putchar_method <= putchar_method_IDLE;
        putchar_method_delay <= (others => '0');
      else
        case (putchar_method) is
          when putchar_method_IDLE => 
            putchar_method <= putchar_method_S_0000;
          when putchar_method_S_0000 => 
            putchar_method <= putchar_method_S_0001;
          when putchar_method_S_0001 => 
            if tmp_0005 = '1' then
              putchar_method <= putchar_method_S_0002;
            end if;
          when putchar_method_S_0002 => 
            putchar_method <= putchar_method_S_0002_body;
          when putchar_method_S_0002_body => 
            putchar_method <= putchar_method_S_0002_wait;
          when putchar_method_S_0002_wait => 
            if class_obj_0000_write_ext_call_flag_0002 = '1' then
              putchar_method <= putchar_method_S_0000;
            end if;
          when others => null;
        end case;
        putchar_req_flag_d <= putchar_req_flag;
        if (tmp_0011 and tmp_0013) = '1' then
          putchar_method <= putchar_method_S_0001;
        end if;
      end if;
    end if;
  end process;

  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        getchar_method <= getchar_method_IDLE;
        getchar_method_delay <= (others => '0');
      else
        case (getchar_method) is
          when getchar_method_IDLE => 
            getchar_method <= getchar_method_S_0000;
          when getchar_method_S_0000 => 
            getchar_method <= getchar_method_S_0001;
          when getchar_method_S_0001 => 
            if tmp_0018 = '1' then
              getchar_method <= getchar_method_S_0002;
            end if;
          when getchar_method_S_0002 => 
            getchar_method <= getchar_method_S_0002_body;
          when getchar_method_S_0003 => 
            getchar_method <= getchar_method_S_0004;
            getchar_method <= getchar_method_S_0004;
          when getchar_method_S_0004 => 
            getchar_method <= getchar_method_S_0000;
          when getchar_method_S_0002_body => 
            getchar_method <= getchar_method_S_0002_wait;
          when getchar_method_S_0002_wait => 
            if class_obj_0000_read_ext_call_flag_0002 = '1' then
              getchar_method <= getchar_method_S_0003;
            end if;
          when others => null;
        end case;
        getchar_req_flag_d <= getchar_req_flag;
        if (tmp_0024 and tmp_0026) = '1' then
          getchar_method <= getchar_method_S_0001;
        end if;
      end if;
    end if;
  end process;


  class_obj_0000_clk <= clk_sig;

  class_obj_0000_reset <= reset_sig;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_obj_0000_write_data <= (others => '0');
      else
        if putchar_method = putchar_method_S_0002_body and putchar_method_delay = 0 then
          class_obj_0000_write_data <= putchar_c_0002;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_obj_0000_read_req <= '0';
      else
        if getchar_method = getchar_method_S_0002_body then
          class_obj_0000_read_req <= '1';
        else
          class_obj_0000_read_req <= '0';
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_obj_0000_write_req <= '0';
      else
        if putchar_method = putchar_method_S_0002_body then
          class_obj_0000_write_req <= '1';
        else
          class_obj_0000_write_req <= '0';
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        putchar_c_0002 <= (others => '0');
      else
        if putchar_method = putchar_method_S_0001 then
          putchar_c_0002 <= tmp_0015;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        getchar_b_0004 <= (others => '0');
      else
        if getchar_method = getchar_method_S_0003 then
          getchar_b_0004 <= method_result_00005;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        method_result_00005 <= (others => '0');
      else
        if getchar_method = getchar_method_S_0002_wait then
          method_result_00005 <= class_obj_0000_read_return;
        end if;
      end if;
    end if;
  end process;

  putchar_req_flag <= tmp_0001;

  getchar_req_flag <= tmp_0002;

  putchar_req_flag_edge <= tmp_0004;

  class_obj_0000_write_ext_call_flag_0002 <= tmp_0010;

  getchar_req_flag_edge <= tmp_0017;

  class_obj_0000_read_ext_call_flag_0002 <= tmp_0023;


  inst_class_obj_0000 : rs232c
  port map(
    clk => clk,
    reset => reset,
    write_data => class_obj_0000_write_data,
    read_return => class_obj_0000_read_return,
    read_busy => class_obj_0000_read_busy,
    read_req => class_obj_0000_read_req,
    write_busy => class_obj_0000_write_busy,
    write_req => class_obj_0000_write_req,
    tx_dout_exp => obj_tx_dout_exp,
    rx_din_exp => obj_rx_din_exp
  );


end RTL;
