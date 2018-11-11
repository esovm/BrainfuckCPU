library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Hardware is
  port (
    clk : in std_logic;
    reset : in std_logic;
    b_io_obj_tx_dout_exp : out std_logic;
    b_io_obj_rx_din_exp : in std_logic;
    main_busy : out std_logic;
    main_req : in std_logic
  );
end Hardware;

architecture RTL of Hardware is

  attribute mark_debug : string;
  attribute keep : string;
  attribute S : string;

  component Brainfuck
    port (
      clk : in std_logic;
      reset : in std_logic;
      io_obj_tx_dout_exp : out std_logic;
      io_obj_rx_din_exp : in std_logic;
      startup_busy : out std_logic;
      startup_req : in std_logic;
      read_busy : out std_logic;
      read_req : in std_logic;
      print_busy : out std_logic;
      print_req : in std_logic;
      init_busy : out std_logic;
      init_req : in std_logic;
      step_return : out std_logic;
      step_busy : out std_logic;
      step_req : in std_logic
    );
  end component Brainfuck;

  signal clk_sig : std_logic := '0';
  signal reset_sig : std_logic := '0';
  signal b_io_obj_tx_dout_exp_sig : std_logic := '0';
  signal b_io_obj_rx_din_exp_sig : std_logic := '0';
  signal main_busy_sig : std_logic := '1';
  signal main_req_sig : std_logic := '0';

  signal class_b_0000_clk : std_logic := '0';
  signal class_b_0000_reset : std_logic := '0';
  signal class_b_0000_startup_busy : std_logic := '0';
  signal class_b_0000_startup_req : std_logic := '0';
  signal class_b_0000_read_busy : std_logic := '0';
  signal class_b_0000_read_req : std_logic := '0';
  signal class_b_0000_print_busy : std_logic := '0';
  signal class_b_0000_print_req : std_logic := '0';
  signal class_b_0000_init_busy : std_logic := '0';
  signal class_b_0000_init_req : std_logic := '0';
  signal class_b_0000_step_return : std_logic := '0';
  signal class_b_0000_step_busy : std_logic := '0';
  signal class_b_0000_step_req : std_logic := '0';
  signal main_flag_0007 : std_logic := '1';
  signal method_result_00009 : std_logic := '0';
  signal main_req_flag : std_logic := '0';
  signal main_req_local : std_logic := '0';
  signal tmp_0001 : std_logic := '0';
  type Type_main_method is (
    main_method_IDLE,
    main_method_S_0000,
    main_method_S_0001,
    main_method_S_0002,
    main_method_S_0003,
    main_method_S_0005,
    main_method_S_0006,
    main_method_S_0007,
    main_method_S_0008,
    main_method_S_0009,
    main_method_S_0010,
    main_method_S_0002_body,
    main_method_S_0002_wait,
    main_method_S_0005_body,
    main_method_S_0005_wait,
    main_method_S_0006_body,
    main_method_S_0006_wait,
    main_method_S_0007_body,
    main_method_S_0007_wait,
    main_method_S_0009_body,
    main_method_S_0009_wait  
  );
  signal main_method : Type_main_method := main_method_IDLE;
  signal main_method_delay : signed(32-1 downto 0) := (others => '0');
  signal main_req_flag_d : std_logic := '0';
  signal main_req_flag_edge : std_logic := '0';
  signal tmp_0002 : std_logic := '0';
  signal tmp_0003 : std_logic := '0';
  signal tmp_0004 : std_logic := '0';
  signal tmp_0005 : std_logic := '0';
  signal class_b_0000_startup_ext_call_flag_0002 : std_logic := '0';
  signal tmp_0006 : std_logic := '0';
  signal tmp_0007 : std_logic := '0';
  signal tmp_0008 : std_logic := '0';
  signal tmp_0009 : std_logic := '0';
  signal tmp_0010 : std_logic := '0';
  signal tmp_0011 : std_logic := '0';
  signal class_b_0000_init_ext_call_flag_0005 : std_logic := '0';
  signal tmp_0012 : std_logic := '0';
  signal tmp_0013 : std_logic := '0';
  signal tmp_0014 : std_logic := '0';
  signal tmp_0015 : std_logic := '0';
  signal class_b_0000_read_ext_call_flag_0006 : std_logic := '0';
  signal tmp_0016 : std_logic := '0';
  signal tmp_0017 : std_logic := '0';
  signal tmp_0018 : std_logic := '0';
  signal tmp_0019 : std_logic := '0';
  signal class_b_0000_print_ext_call_flag_0007 : std_logic := '0';
  signal tmp_0020 : std_logic := '0';
  signal tmp_0021 : std_logic := '0';
  signal tmp_0022 : std_logic := '0';
  signal tmp_0023 : std_logic := '0';
  signal class_b_0000_step_ext_call_flag_0009 : std_logic := '0';
  signal tmp_0024 : std_logic := '0';
  signal tmp_0025 : std_logic := '0';
  signal tmp_0026 : std_logic := '0';
  signal tmp_0027 : std_logic := '0';
  signal tmp_0028 : std_logic := '0';
  signal tmp_0029 : std_logic := '0';
  signal tmp_0030 : std_logic := '0';
  signal tmp_0031 : std_logic := '0';
  signal tmp_0032 : std_logic := '0';
  signal tmp_0033 : std_logic := '0';

begin

  clk_sig <= clk;
  reset_sig <= reset;
  main_busy <= main_busy_sig;
  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        main_busy_sig <= '1';
      else
        if main_method = main_method_S_0000 then
          main_busy_sig <= '0';
        elsif main_method = main_method_S_0001 then
          main_busy_sig <= tmp_0005;
        end if;
      end if;
    end if;
  end process;

  main_req_sig <= main_req;

  -- expressions
  tmp_0001 <= main_req_local or main_req_sig;
  tmp_0002 <= not main_req_flag_d;
  tmp_0003 <= main_req_flag and tmp_0002;
  tmp_0004 <= main_req_flag or main_req_flag_d;
  tmp_0005 <= main_req_flag or main_req_flag_d;
  tmp_0006 <= '1' when class_b_0000_startup_busy = '0' else '0';
  tmp_0007 <= '1' when class_b_0000_startup_req = '0' else '0';
  tmp_0008 <= tmp_0006 and tmp_0007;
  tmp_0009 <= '1' when tmp_0008 = '1' else '0';
  tmp_0010 <= '1';
  tmp_0011 <= '0';
  tmp_0012 <= '1' when class_b_0000_init_busy = '0' else '0';
  tmp_0013 <= '1' when class_b_0000_init_req = '0' else '0';
  tmp_0014 <= tmp_0012 and tmp_0013;
  tmp_0015 <= '1' when tmp_0014 = '1' else '0';
  tmp_0016 <= '1' when class_b_0000_read_busy = '0' else '0';
  tmp_0017 <= '1' when class_b_0000_read_req = '0' else '0';
  tmp_0018 <= tmp_0016 and tmp_0017;
  tmp_0019 <= '1' when tmp_0018 = '1' else '0';
  tmp_0020 <= '1' when class_b_0000_print_busy = '0' else '0';
  tmp_0021 <= '1' when class_b_0000_print_req = '0' else '0';
  tmp_0022 <= tmp_0020 and tmp_0021;
  tmp_0023 <= '1' when tmp_0022 = '1' else '0';
  tmp_0024 <= '1' when class_b_0000_step_busy = '0' else '0';
  tmp_0025 <= '1' when class_b_0000_step_req = '0' else '0';
  tmp_0026 <= tmp_0024 and tmp_0025;
  tmp_0027 <= '1' when tmp_0026 = '1' else '0';
  tmp_0028 <= '1' when method_result_00009 = '1' else '0';
  tmp_0029 <= '1' when method_result_00009 = '0' else '0';
  tmp_0030 <= '1' when main_method /= main_method_S_0000 else '0';
  tmp_0031 <= '1' when main_method /= main_method_S_0001 else '0';
  tmp_0032 <= tmp_0031 and main_req_flag_edge;
  tmp_0033 <= tmp_0030 and tmp_0032;

  -- sequencers
  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        main_method <= main_method_IDLE;
        main_method_delay <= (others => '0');
      else
        case (main_method) is
          when main_method_IDLE => 
            main_method <= main_method_S_0000;
          when main_method_S_0000 => 
            main_method <= main_method_S_0001;
          when main_method_S_0001 => 
            if tmp_0004 = '1' then
              main_method <= main_method_S_0002;
            end if;
          when main_method_S_0002 => 
            main_method <= main_method_S_0002_body;
          when main_method_S_0003 => 
            if tmp_0010 = '1' then
              main_method <= main_method_S_0005;
            elsif tmp_0011 = '1' then
              main_method <= main_method_S_0000;
            end if;
          when main_method_S_0005 => 
            main_method <= main_method_S_0005_body;
          when main_method_S_0006 => 
            main_method <= main_method_S_0006_body;
          when main_method_S_0007 => 
            main_method <= main_method_S_0007_body;
          when main_method_S_0008 => 
            main_method <= main_method_S_0009;
            main_method <= main_method_S_0009;
          when main_method_S_0009 => 
            main_method <= main_method_S_0009_body;
          when main_method_S_0010 => 
            if tmp_0028 = '1' then
              main_method <= main_method_S_0009;
            elsif tmp_0029 = '1' then
              main_method <= main_method_S_0003;
            end if;
          when main_method_S_0002_body => 
            main_method <= main_method_S_0002_wait;
          when main_method_S_0002_wait => 
            if class_b_0000_startup_ext_call_flag_0002 = '1' then
              main_method <= main_method_S_0003;
            end if;
          when main_method_S_0005_body => 
            main_method <= main_method_S_0005_wait;
          when main_method_S_0005_wait => 
            if class_b_0000_init_ext_call_flag_0005 = '1' then
              main_method <= main_method_S_0006;
            end if;
          when main_method_S_0006_body => 
            main_method <= main_method_S_0006_wait;
          when main_method_S_0006_wait => 
            if class_b_0000_read_ext_call_flag_0006 = '1' then
              main_method <= main_method_S_0007;
            end if;
          when main_method_S_0007_body => 
            main_method <= main_method_S_0007_wait;
          when main_method_S_0007_wait => 
            if class_b_0000_print_ext_call_flag_0007 = '1' then
              main_method <= main_method_S_0008;
            end if;
          when main_method_S_0009_body => 
            main_method <= main_method_S_0009_wait;
          when main_method_S_0009_wait => 
            if class_b_0000_step_ext_call_flag_0009 = '1' then
              main_method <= main_method_S_0010;
            end if;
          when others => null;
        end case;
        main_req_flag_d <= main_req_flag;
        if (tmp_0030 and tmp_0032) = '1' then
          main_method <= main_method_S_0001;
        end if;
      end if;
    end if;
  end process;


  class_b_0000_clk <= clk_sig;

  class_b_0000_reset <= reset_sig;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_b_0000_startup_req <= '0';
      else
        if main_method = main_method_S_0002_body then
          class_b_0000_startup_req <= '1';
        else
          class_b_0000_startup_req <= '0';
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_b_0000_read_req <= '0';
      else
        if main_method = main_method_S_0006_body then
          class_b_0000_read_req <= '1';
        else
          class_b_0000_read_req <= '0';
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_b_0000_print_req <= '0';
      else
        if main_method = main_method_S_0007_body then
          class_b_0000_print_req <= '1';
        else
          class_b_0000_print_req <= '0';
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_b_0000_init_req <= '0';
      else
        if main_method = main_method_S_0005_body then
          class_b_0000_init_req <= '1';
        else
          class_b_0000_init_req <= '0';
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_b_0000_step_req <= '0';
      else
        if main_method = main_method_S_0009_body then
          class_b_0000_step_req <= '1';
        else
          class_b_0000_step_req <= '0';
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        main_flag_0007 <= '1';
      else
        if main_method = main_method_S_0008 then
          main_flag_0007 <= '1';
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        method_result_00009 <= '0';
      else
        if main_method = main_method_S_0009_wait then
          method_result_00009 <= class_b_0000_step_return;
        end if;
      end if;
    end if;
  end process;

  main_req_flag <= tmp_0001;

  main_req_flag_edge <= tmp_0003;

  class_b_0000_startup_ext_call_flag_0002 <= tmp_0009;

  class_b_0000_init_ext_call_flag_0005 <= tmp_0015;

  class_b_0000_read_ext_call_flag_0006 <= tmp_0019;

  class_b_0000_print_ext_call_flag_0007 <= tmp_0023;

  class_b_0000_step_ext_call_flag_0009 <= tmp_0027;


  inst_class_b_0000 : Brainfuck
  port map(
    clk => clk,
    reset => reset,
    startup_busy => class_b_0000_startup_busy,
    startup_req => class_b_0000_startup_req,
    read_busy => class_b_0000_read_busy,
    read_req => class_b_0000_read_req,
    print_busy => class_b_0000_print_busy,
    print_req => class_b_0000_print_req,
    init_busy => class_b_0000_init_busy,
    init_req => class_b_0000_init_req,
    step_return => class_b_0000_step_return,
    step_busy => class_b_0000_step_busy,
    step_req => class_b_0000_step_req,
    io_obj_tx_dout_exp => b_io_obj_tx_dout_exp,
    io_obj_rx_din_exp => b_io_obj_rx_din_exp
  );


end RTL;
