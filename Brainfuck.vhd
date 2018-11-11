library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Brainfuck is
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
end Brainfuck;

architecture RTL of Brainfuck is

  attribute mark_debug : string;
  attribute keep : string;
  attribute S : string;

  component IO
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
  end component IO;
  component singleportram
    generic (
      WIDTH : integer := 8;
      DEPTH : integer := 10;
      WORDS : integer := 1024
    );
    port (
      clk : in std_logic;
      reset : in std_logic;
      length : out signed(31 downto 0);
      address_b : in signed(31 downto 0);
      din_b : in signed(WIDTH-1 downto 0);
      dout_b : out signed(WIDTH-1 downto 0);
      we_b : in std_logic;
      oe_b : in std_logic
    );
  end component singleportram;

  signal clk_sig : std_logic := '0';
  signal reset_sig : std_logic := '0';
  signal io_obj_tx_dout_exp_sig : std_logic := '0';
  signal io_obj_rx_din_exp_sig : std_logic := '0';
  signal startup_busy_sig : std_logic := '1';
  signal startup_req_sig : std_logic := '0';
  signal read_busy_sig : std_logic := '1';
  signal read_req_sig : std_logic := '0';
  signal print_busy_sig : std_logic := '1';
  signal print_req_sig : std_logic := '0';
  signal init_busy_sig : std_logic := '1';
  signal init_req_sig : std_logic := '0';
  signal step_return_sig : std_logic := '0';
  signal step_busy_sig : std_logic := '1';
  signal step_req_sig : std_logic := '0';

  signal class_ARRAYSIZE_0000 : signed(32-1 downto 0) := X"00002710";
  signal class_CODESIZE_0002 : signed(32-1 downto 0) := X"00002710";
  signal class_io_0004_clk : std_logic := '0';
  signal class_io_0004_reset : std_logic := '0';
  signal class_io_0004_putchar_c : signed(8-1 downto 0) := (others => '0');
  signal class_io_0004_putchar_busy : std_logic := '0';
  signal class_io_0004_putchar_req : std_logic := '0';
  signal class_io_0004_getchar_return : signed(8-1 downto 0) := (others => '0');
  signal class_io_0004_getchar_busy : std_logic := '0';
  signal class_io_0004_getchar_req : std_logic := '0';
  signal class_prog_0006_clk : std_logic := '0';
  signal class_prog_0006_reset : std_logic := '0';
  signal class_prog_0006_length : signed(32-1 downto 0) := (others => '0');
  signal class_prog_0006_address_b : signed(32-1 downto 0) := (others => '0');
  signal class_prog_0006_din_b : signed(8-1 downto 0) := (others => '0');
  signal class_prog_0006_dout_b : signed(8-1 downto 0) := (others => '0');
  signal class_prog_0006_we_b : std_logic := '0';
  signal class_prog_0006_oe_b : std_logic := '0';
  signal class_data_0009_clk : std_logic := '0';
  signal class_data_0009_reset : std_logic := '0';
  signal class_data_0009_length : signed(32-1 downto 0) := (others => '0');
  signal class_data_0009_address_b : signed(32-1 downto 0) := (others => '0');
  signal class_data_0009_din_b : signed(8-1 downto 0) := (others => '0');
  signal class_data_0009_dout_b : signed(8-1 downto 0) := (others => '0');
  signal class_data_0009_we_b : std_logic := '0';
  signal class_data_0009_oe_b : std_logic := '0';
  signal class_ptr_0012 : signed(32-1 downto 0) := (others => '0');
  signal class_pc_0013 : signed(32-1 downto 0) := (others => '0');
  signal read_i_0054 : signed(32-1 downto 0) := X"00000000";
  signal binary_expr_00056 : std_logic := '0';
  signal unary_expr_00057 : signed(32-1 downto 0) := (others => '0');
  signal unary_expr_postfix_preserved_00058 : signed(32-1 downto 0) := (others => '0');
  signal read_b_0060 : signed(8-1 downto 0) := (others => '0');
  signal method_result_00061 : signed(8-1 downto 0) := (others => '0');
  signal cast_expr_00063 : std_logic_vector(16-1 downto 0) := (others => '0');
  signal binary_expr_00064 : std_logic := '0';
  signal cast_expr_00066 : std_logic_vector(16-1 downto 0) := (others => '0');
  signal binary_expr_00067 : std_logic := '0';
  signal binary_expr_00068 : std_logic := '0';
  signal array_access_00071 : signed(8-1 downto 0) := (others => '0');
  signal array_access_00072 : signed(8-1 downto 0) := (others => '0');
  signal print_flag_0073 : std_logic := '1';
  signal print_i_0075 : signed(32-1 downto 0) := X"00000000";
  signal binary_expr_00077 : std_logic := '0';
  signal unary_expr_00078 : signed(32-1 downto 0) := (others => '0');
  signal unary_expr_postfix_preserved_00079 : signed(32-1 downto 0) := (others => '0');
  signal print_b_0081 : signed(8-1 downto 0) := (others => '0');
  signal array_access_00082 : signed(8-1 downto 0) := (others => '0');
  signal cast_expr_00084 : signed(32-1 downto 0) := (others => '0');
  signal binary_expr_00085 : std_logic := '0';
  signal put_hex_b_0090 : signed(8-1 downto 0) := (others => '0');
  signal put_hex_b_local : signed(8-1 downto 0) := (others => '0');
  signal put_hex_h_0091 : signed(8-1 downto 0) := (others => '0');
  signal cast_expr_00093 : signed(32-1 downto 0) := (others => '0');
  signal binary_expr_00094 : signed(32-1 downto 0) := (others => '0');
  signal binary_expr_00096 : signed(32-1 downto 0) := (others => '0');
  signal cast_expr_00097 : signed(8-1 downto 0) := (others => '0');
  signal cast_expr_00099 : signed(32-1 downto 0) := (others => '0');
  signal binary_expr_00100 : std_logic := '0';
  signal cast_expr_00102 : signed(32-1 downto 0) := (others => '0');
  signal binary_expr_00103 : std_logic := '0';
  signal binary_expr_00104 : std_logic := '0';
  signal cast_expr_00107 : std_logic_vector(16-1 downto 0) := (others => '0');
  signal binary_expr_00108 : std_logic_vector(16-1 downto 0) := (others => '0');
  signal cast_expr_00109 : signed(8-1 downto 0) := (others => '0');
  signal cast_expr_00112 : signed(32-1 downto 0) := (others => '0');
  signal binary_expr_00113 : signed(32-1 downto 0) := (others => '0');
  signal binary_expr_00115 : signed(32-1 downto 0) := (others => '0');
  signal cast_expr_00116 : signed(8-1 downto 0) := (others => '0');
  signal put_hex_l_0117 : signed(8-1 downto 0) := (others => '0');
  signal cast_expr_00119 : signed(32-1 downto 0) := (others => '0');
  signal binary_expr_00120 : signed(32-1 downto 0) := (others => '0');
  signal binary_expr_00122 : signed(32-1 downto 0) := (others => '0');
  signal cast_expr_00123 : signed(8-1 downto 0) := (others => '0');
  signal cast_expr_00125 : signed(32-1 downto 0) := (others => '0');
  signal binary_expr_00126 : std_logic := '0';
  signal cast_expr_00128 : signed(32-1 downto 0) := (others => '0');
  signal binary_expr_00129 : std_logic := '0';
  signal binary_expr_00130 : std_logic := '0';
  signal cast_expr_00133 : std_logic_vector(16-1 downto 0) := (others => '0');
  signal binary_expr_00134 : std_logic_vector(16-1 downto 0) := (others => '0');
  signal cast_expr_00135 : signed(8-1 downto 0) := (others => '0');
  signal cast_expr_00138 : signed(32-1 downto 0) := (others => '0');
  signal binary_expr_00139 : signed(32-1 downto 0) := (others => '0');
  signal binary_expr_00141 : signed(32-1 downto 0) := (others => '0');
  signal cast_expr_00142 : signed(8-1 downto 0) := (others => '0');
  signal init_i_0148 : signed(32-1 downto 0) := X"00000000";
  signal binary_expr_00150 : std_logic := '0';
  signal unary_expr_00151 : signed(32-1 downto 0) := (others => '0');
  signal unary_expr_postfix_preserved_00152 : signed(32-1 downto 0) := (others => '0');
  signal array_access_00155 : signed(8-1 downto 0) := (others => '0');
  signal step_cmd_0156 : signed(8-1 downto 0) := (others => '0');
  signal array_access_00157 : signed(8-1 downto 0) := (others => '0');
  signal step_tmp_0158 : signed(8-1 downto 0) := (others => '0');
  signal step_nlvl_0159 : signed(32-1 downto 0) := X"00000000";
  signal unary_expr_00171 : signed(32-1 downto 0) := (others => '0');
  signal unary_expr_postfix_preserved_00172 : signed(32-1 downto 0) := (others => '0');
  signal array_access_00174 : signed(8-1 downto 0) := (others => '0');
  signal cast_expr_00176 : std_logic_vector(16-1 downto 0) := (others => '0');
  signal binary_expr_00177 : std_logic := '0';
  signal binary_expr_00179 : std_logic := '0';
  signal binary_expr_00180 : std_logic := '0';
  signal array_access_00181 : signed(8-1 downto 0) := (others => '0');
  signal cast_expr_00183 : std_logic_vector(16-1 downto 0) := (others => '0');
  signal binary_expr_00184 : std_logic := '0';
  signal unary_expr_00185 : signed(32-1 downto 0) := (others => '0');
  signal unary_expr_postfix_preserved_00186 : signed(32-1 downto 0) := (others => '0');
  signal array_access_00188 : signed(8-1 downto 0) := (others => '0');
  signal cast_expr_00190 : std_logic_vector(16-1 downto 0) := (others => '0');
  signal binary_expr_00191 : std_logic := '0';
  signal unary_expr_00192 : signed(32-1 downto 0) := (others => '0');
  signal unary_expr_postfix_preserved_00193 : signed(32-1 downto 0) := (others => '0');
  signal unary_expr_00195 : signed(32-1 downto 0) := (others => '0');
  signal unary_expr_postfix_preserved_00196 : signed(32-1 downto 0) := (others => '0');
  signal array_access_00198 : signed(8-1 downto 0) := (others => '0');
  signal binary_expr_00201 : std_logic := '0';
  signal unary_expr_00203 : signed(32-1 downto 0) := (others => '0');
  signal unary_expr_postfix_preserved_00204 : signed(32-1 downto 0) := (others => '0');
  signal array_access_00206 : signed(8-1 downto 0) := (others => '0');
  signal cast_expr_00208 : std_logic_vector(16-1 downto 0) := (others => '0');
  signal binary_expr_00209 : std_logic := '0';
  signal binary_expr_00211 : std_logic := '0';
  signal binary_expr_00212 : std_logic := '0';
  signal array_access_00213 : signed(8-1 downto 0) := (others => '0');
  signal cast_expr_00215 : std_logic_vector(16-1 downto 0) := (others => '0');
  signal binary_expr_00216 : std_logic := '0';
  signal unary_expr_00217 : signed(32-1 downto 0) := (others => '0');
  signal unary_expr_postfix_preserved_00218 : signed(32-1 downto 0) := (others => '0');
  signal array_access_00220 : signed(8-1 downto 0) := (others => '0');
  signal cast_expr_00222 : std_logic_vector(16-1 downto 0) := (others => '0');
  signal binary_expr_00223 : std_logic := '0';
  signal unary_expr_00224 : signed(32-1 downto 0) := (others => '0');
  signal unary_expr_postfix_preserved_00225 : signed(32-1 downto 0) := (others => '0');
  signal method_result_00227 : signed(8-1 downto 0) := (others => '0');
  signal array_access_00228 : signed(8-1 downto 0) := (others => '0');
  signal array_access_00230 : signed(8-1 downto 0) := (others => '0');
  signal array_access_00231 : signed(8-1 downto 0) := (others => '0');
  signal cast_expr_00233 : signed(32-1 downto 0) := (others => '0');
  signal binary_expr_00234 : signed(32-1 downto 0) := (others => '0');
  signal cast_expr_00235 : signed(8-1 downto 0) := (others => '0');
  signal array_access_00236 : signed(8-1 downto 0) := (others => '0');
  signal array_access_00237 : signed(8-1 downto 0) := (others => '0');
  signal cast_expr_00239 : signed(32-1 downto 0) := (others => '0');
  signal binary_expr_00240 : signed(32-1 downto 0) := (others => '0');
  signal cast_expr_00241 : signed(8-1 downto 0) := (others => '0');
  signal array_access_00242 : signed(8-1 downto 0) := (others => '0');
  signal unary_expr_00243 : signed(32-1 downto 0) := (others => '0');
  signal unary_expr_postfix_preserved_00244 : signed(32-1 downto 0) := (others => '0');
  signal unary_expr_00246 : signed(32-1 downto 0) := (others => '0');
  signal unary_expr_postfix_preserved_00247 : signed(32-1 downto 0) := (others => '0');
  signal unary_expr_00250 : signed(32-1 downto 0) := (others => '0');
  signal unary_expr_postfix_preserved_00251 : signed(32-1 downto 0) := (others => '0');
  signal startup_req_flag : std_logic := '0';
  signal startup_req_local : std_logic := '0';
  signal tmp_0001 : std_logic := '0';
  signal prompt_busy : std_logic := '0';
  signal prompt_req_flag : std_logic := '0';
  signal prompt_req_local : std_logic := '0';
  signal read_req_flag : std_logic := '0';
  signal read_req_local : std_logic := '0';
  signal tmp_0002 : std_logic := '0';
  signal print_req_flag : std_logic := '0';
  signal print_req_local : std_logic := '0';
  signal tmp_0003 : std_logic := '0';
  signal put_hex_busy : std_logic := '0';
  signal put_hex_req_flag : std_logic := '0';
  signal put_hex_req_local : std_logic := '0';
  signal init_req_flag : std_logic := '0';
  signal init_req_local : std_logic := '0';
  signal tmp_0004 : std_logic := '0';
  signal step_req_flag : std_logic := '0';
  signal step_req_local : std_logic := '0';
  signal tmp_0005 : std_logic := '0';
  type Type_startup_method is (
    startup_method_IDLE,
    startup_method_S_0000,
    startup_method_S_0001,
    startup_method_S_0002,
    startup_method_S_0003,
    startup_method_S_0004,
    startup_method_S_0005,
    startup_method_S_0006,
    startup_method_S_0007,
    startup_method_S_0008,
    startup_method_S_0009,
    startup_method_S_0010,
    startup_method_S_0011,
    startup_method_S_0012,
    startup_method_S_0013,
    startup_method_S_0002_body,
    startup_method_S_0002_wait,
    startup_method_S_0003_body,
    startup_method_S_0003_wait,
    startup_method_S_0004_body,
    startup_method_S_0004_wait,
    startup_method_S_0005_body,
    startup_method_S_0005_wait,
    startup_method_S_0006_body,
    startup_method_S_0006_wait,
    startup_method_S_0007_body,
    startup_method_S_0007_wait,
    startup_method_S_0008_body,
    startup_method_S_0008_wait,
    startup_method_S_0009_body,
    startup_method_S_0009_wait,
    startup_method_S_0010_body,
    startup_method_S_0010_wait,
    startup_method_S_0011_body,
    startup_method_S_0011_wait,
    startup_method_S_0012_body,
    startup_method_S_0012_wait  
  );
  signal startup_method : Type_startup_method := startup_method_IDLE;
  signal startup_method_delay : signed(32-1 downto 0) := (others => '0');
  signal startup_req_flag_d : std_logic := '0';
  signal startup_req_flag_edge : std_logic := '0';
  signal tmp_0006 : std_logic := '0';
  signal tmp_0007 : std_logic := '0';
  signal tmp_0008 : std_logic := '0';
  signal tmp_0009 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0002 : std_logic := '0';
  signal tmp_0010 : std_logic := '0';
  signal tmp_0011 : std_logic := '0';
  signal tmp_0012 : std_logic := '0';
  signal tmp_0013 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0003 : std_logic := '0';
  signal tmp_0014 : std_logic := '0';
  signal tmp_0015 : std_logic := '0';
  signal tmp_0016 : std_logic := '0';
  signal tmp_0017 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0004 : std_logic := '0';
  signal tmp_0018 : std_logic := '0';
  signal tmp_0019 : std_logic := '0';
  signal tmp_0020 : std_logic := '0';
  signal tmp_0021 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0005 : std_logic := '0';
  signal tmp_0022 : std_logic := '0';
  signal tmp_0023 : std_logic := '0';
  signal tmp_0024 : std_logic := '0';
  signal tmp_0025 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0006 : std_logic := '0';
  signal tmp_0026 : std_logic := '0';
  signal tmp_0027 : std_logic := '0';
  signal tmp_0028 : std_logic := '0';
  signal tmp_0029 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0007 : std_logic := '0';
  signal tmp_0030 : std_logic := '0';
  signal tmp_0031 : std_logic := '0';
  signal tmp_0032 : std_logic := '0';
  signal tmp_0033 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0008 : std_logic := '0';
  signal tmp_0034 : std_logic := '0';
  signal tmp_0035 : std_logic := '0';
  signal tmp_0036 : std_logic := '0';
  signal tmp_0037 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0009 : std_logic := '0';
  signal tmp_0038 : std_logic := '0';
  signal tmp_0039 : std_logic := '0';
  signal tmp_0040 : std_logic := '0';
  signal tmp_0041 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0010 : std_logic := '0';
  signal tmp_0042 : std_logic := '0';
  signal tmp_0043 : std_logic := '0';
  signal tmp_0044 : std_logic := '0';
  signal tmp_0045 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0011 : std_logic := '0';
  signal tmp_0046 : std_logic := '0';
  signal tmp_0047 : std_logic := '0';
  signal tmp_0048 : std_logic := '0';
  signal tmp_0049 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0012 : std_logic := '0';
  signal tmp_0050 : std_logic := '0';
  signal tmp_0051 : std_logic := '0';
  signal tmp_0052 : std_logic := '0';
  signal tmp_0053 : std_logic := '0';
  signal tmp_0054 : std_logic := '0';
  signal tmp_0055 : std_logic := '0';
  signal tmp_0056 : std_logic := '0';
  signal tmp_0057 : std_logic := '0';
  type Type_prompt_method is (
    prompt_method_IDLE,
    prompt_method_S_0000,
    prompt_method_S_0001,
    prompt_method_S_0002,
    prompt_method_S_0003,
    prompt_method_S_0004,
    prompt_method_S_0002_body,
    prompt_method_S_0002_wait,
    prompt_method_S_0003_body,
    prompt_method_S_0003_wait  
  );
  signal prompt_method : Type_prompt_method := prompt_method_IDLE;
  signal prompt_method_delay : signed(32-1 downto 0) := (others => '0');
  signal prompt_req_flag_d : std_logic := '0';
  signal prompt_req_flag_edge : std_logic := '0';
  signal tmp_0058 : std_logic := '0';
  signal tmp_0059 : std_logic := '0';
  signal tmp_0060 : std_logic := '0';
  signal tmp_0061 : std_logic := '0';
  signal tmp_0062 : std_logic := '0';
  signal tmp_0063 : std_logic := '0';
  signal tmp_0064 : std_logic := '0';
  signal tmp_0065 : std_logic := '0';
  type Type_read_method is (
    read_method_IDLE,
    read_method_S_0000,
    read_method_S_0001,
    read_method_S_0002,
    read_method_S_0003,
    read_method_S_0004,
    read_method_S_0005,
    read_method_S_0007,
    read_method_S_0009,
    read_method_S_0011,
    read_method_S_0012,
    read_method_S_0013,
    read_method_S_0014,
    read_method_S_0017,
    read_method_S_0018,
    read_method_S_0020,
    read_method_S_0022,
    read_method_S_0024,
    read_method_S_0002_body,
    read_method_S_0002_wait,
    read_method_S_0011_body,
    read_method_S_0011_wait  
  );
  signal read_method : Type_read_method := read_method_IDLE;
  signal read_method_delay : signed(32-1 downto 0) := (others => '0');
  signal read_req_flag_d : std_logic := '0';
  signal read_req_flag_edge : std_logic := '0';
  signal tmp_0066 : std_logic := '0';
  signal tmp_0067 : std_logic := '0';
  signal tmp_0068 : std_logic := '0';
  signal tmp_0069 : std_logic := '0';
  signal prompt_call_flag_0002 : std_logic := '0';
  signal tmp_0070 : std_logic := '0';
  signal tmp_0071 : std_logic := '0';
  signal tmp_0072 : std_logic := '0';
  signal tmp_0073 : std_logic := '0';
  signal tmp_0074 : std_logic := '0';
  signal tmp_0075 : std_logic := '0';
  signal class_io_0004_getchar_ext_call_flag_0011 : std_logic := '0';
  signal tmp_0076 : std_logic := '0';
  signal tmp_0077 : std_logic := '0';
  signal tmp_0078 : std_logic := '0';
  signal tmp_0079 : std_logic := '0';
  signal tmp_0080 : std_logic := '0';
  signal tmp_0081 : std_logic := '0';
  signal tmp_0082 : std_logic := '0';
  signal tmp_0083 : std_logic := '0';
  signal tmp_0084 : std_logic := '0';
  signal tmp_0085 : std_logic := '0';
  signal tmp_0086 : std_logic := '0';
  signal tmp_0087 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0088 : signed(16-1 downto 0) := (others => '0');
  signal tmp_0089 : signed(16-1 downto 0) := (others => '0');
  signal tmp_0090 : std_logic := '0';
  signal tmp_0091 : std_logic := '0';
  signal tmp_0092 : std_logic := '0';
  type Type_print_method is (
    print_method_IDLE,
    print_method_S_0000,
    print_method_S_0001,
    print_method_S_0002,
    print_method_S_0004,
    print_method_S_0005,
    print_method_S_0007,
    print_method_S_0009,
    print_method_S_0011,
    print_method_S_0023,
    print_method_S_0024,
    print_method_S_0012,
    print_method_S_0013,
    print_method_S_0014,
    print_method_S_0015,
    print_method_S_0017,
    print_method_S_0019,
    print_method_S_0021,
    print_method_S_0019_body,
    print_method_S_0019_wait,
    print_method_S_0021_body,
    print_method_S_0021_wait  
  );
  signal print_method : Type_print_method := print_method_IDLE;
  signal print_method_delay : signed(32-1 downto 0) := (others => '0');
  signal print_req_flag_d : std_logic := '0';
  signal print_req_flag_edge : std_logic := '0';
  signal tmp_0093 : std_logic := '0';
  signal tmp_0094 : std_logic := '0';
  signal tmp_0095 : std_logic := '0';
  signal tmp_0096 : std_logic := '0';
  signal tmp_0097 : std_logic := '0';
  signal tmp_0098 : std_logic := '0';
  signal tmp_0099 : std_logic := '0';
  signal tmp_0100 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0019 : std_logic := '0';
  signal tmp_0101 : std_logic := '0';
  signal tmp_0102 : std_logic := '0';
  signal tmp_0103 : std_logic := '0';
  signal tmp_0104 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0021 : std_logic := '0';
  signal tmp_0105 : std_logic := '0';
  signal tmp_0106 : std_logic := '0';
  signal tmp_0107 : std_logic := '0';
  signal tmp_0108 : std_logic := '0';
  signal tmp_0109 : std_logic := '0';
  signal tmp_0110 : std_logic := '0';
  signal tmp_0111 : std_logic := '0';
  signal tmp_0112 : std_logic := '0';
  signal tmp_0113 : std_logic := '0';
  signal tmp_0114 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0115 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0116 : std_logic := '0';
  type Type_put_hex_method is (
    put_hex_method_IDLE,
    put_hex_method_S_0000,
    put_hex_method_S_0001,
    put_hex_method_S_0002,
    put_hex_method_S_0003,
    put_hex_method_S_0004,
    put_hex_method_S_0005,
    put_hex_method_S_0006,
    put_hex_method_S_0007,
    put_hex_method_S_0008,
    put_hex_method_S_0011,
    put_hex_method_S_0012,
    put_hex_method_S_0014,
    put_hex_method_S_0015,
    put_hex_method_S_0016,
    put_hex_method_S_0017,
    put_hex_method_S_0019,
    put_hex_method_S_0020,
    put_hex_method_S_0021,
    put_hex_method_S_0022,
    put_hex_method_S_0023,
    put_hex_method_S_0025,
    put_hex_method_S_0026,
    put_hex_method_S_0027,
    put_hex_method_S_0028,
    put_hex_method_S_0029,
    put_hex_method_S_0032,
    put_hex_method_S_0033,
    put_hex_method_S_0034,
    put_hex_method_S_0035,
    put_hex_method_S_0037,
    put_hex_method_S_0038,
    put_hex_method_S_0039,
    put_hex_method_S_0040,
    put_hex_method_S_0042,
    put_hex_method_S_0043,
    put_hex_method_S_0044,
    put_hex_method_S_0045,
    put_hex_method_S_0046,
    put_hex_method_S_0048,
    put_hex_method_S_0017_body,
    put_hex_method_S_0017_wait,
    put_hex_method_S_0023_body,
    put_hex_method_S_0023_wait,
    put_hex_method_S_0040_body,
    put_hex_method_S_0040_wait,
    put_hex_method_S_0046_body,
    put_hex_method_S_0046_wait,
    put_hex_method_S_0048_body,
    put_hex_method_S_0048_wait  
  );
  signal put_hex_method : Type_put_hex_method := put_hex_method_IDLE;
  signal put_hex_method_delay : signed(32-1 downto 0) := (others => '0');
  signal put_hex_req_flag_d : std_logic := '0';
  signal put_hex_req_flag_edge : std_logic := '0';
  signal tmp_0117 : std_logic := '0';
  signal tmp_0118 : std_logic := '0';
  signal tmp_0119 : std_logic := '0';
  signal tmp_0120 : std_logic := '0';
  signal tmp_0121 : std_logic := '0';
  signal tmp_0122 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0017 : std_logic := '0';
  signal tmp_0123 : std_logic := '0';
  signal tmp_0124 : std_logic := '0';
  signal tmp_0125 : std_logic := '0';
  signal tmp_0126 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0023 : std_logic := '0';
  signal tmp_0127 : std_logic := '0';
  signal tmp_0128 : std_logic := '0';
  signal tmp_0129 : std_logic := '0';
  signal tmp_0130 : std_logic := '0';
  signal tmp_0131 : std_logic := '0';
  signal tmp_0132 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0040 : std_logic := '0';
  signal tmp_0133 : std_logic := '0';
  signal tmp_0134 : std_logic := '0';
  signal tmp_0135 : std_logic := '0';
  signal tmp_0136 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0046 : std_logic := '0';
  signal tmp_0137 : std_logic := '0';
  signal tmp_0138 : std_logic := '0';
  signal tmp_0139 : std_logic := '0';
  signal tmp_0140 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0048 : std_logic := '0';
  signal tmp_0141 : std_logic := '0';
  signal tmp_0142 : std_logic := '0';
  signal tmp_0143 : std_logic := '0';
  signal tmp_0144 : std_logic := '0';
  signal tmp_0145 : std_logic := '0';
  signal tmp_0146 : std_logic := '0';
  signal tmp_0147 : std_logic := '0';
  signal tmp_0148 : std_logic := '0';
  signal tmp_0149 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0150 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0151 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0152 : signed(8-1 downto 0) := (others => '0');
  signal tmp_0153 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0154 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0155 : std_logic := '0';
  signal tmp_0156 : std_logic := '0';
  signal tmp_0157 : std_logic := '0';
  signal tmp_0158 : signed(16-1 downto 0) := (others => '0');
  signal tmp_0159 : std_logic_vector(16-1 downto 0) := (others => '0');
  signal tmp_0160 : std_logic_vector(8-1 downto 0) := (others => '0');
  signal tmp_0161 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0162 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0163 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0164 : signed(8-1 downto 0) := (others => '0');
  signal tmp_0165 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0166 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0167 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0168 : std_logic := '0';
  signal tmp_0169 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0170 : signed(8-1 downto 0) := (others => '0');
  signal tmp_0171 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0172 : std_logic := '0';
  signal tmp_0173 : std_logic := '0';
  signal tmp_0174 : signed(16-1 downto 0) := (others => '0');
  signal tmp_0175 : std_logic_vector(16-1 downto 0) := (others => '0');
  signal tmp_0176 : std_logic_vector(8-1 downto 0) := (others => '0');
  signal tmp_0177 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0178 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0179 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0180 : signed(8-1 downto 0) := (others => '0');
  type Type_init_method is (
    init_method_IDLE,
    init_method_S_0000,
    init_method_S_0001,
    init_method_S_0002,
    init_method_S_0005,
    init_method_S_0006,
    init_method_S_0008,
    init_method_S_0010,
    init_method_S_0012,
    init_method_S_0015  
  );
  signal init_method : Type_init_method := init_method_IDLE;
  signal init_method_delay : signed(32-1 downto 0) := (others => '0');
  signal init_req_flag_d : std_logic := '0';
  signal init_req_flag_edge : std_logic := '0';
  signal tmp_0181 : std_logic := '0';
  signal tmp_0182 : std_logic := '0';
  signal tmp_0183 : std_logic := '0';
  signal tmp_0184 : std_logic := '0';
  signal tmp_0185 : std_logic := '0';
  signal tmp_0186 : std_logic := '0';
  signal tmp_0187 : std_logic := '0';
  signal tmp_0188 : std_logic := '0';
  signal tmp_0189 : std_logic := '0';
  signal tmp_0190 : std_logic := '0';
  signal tmp_0191 : std_logic := '0';
  signal tmp_0192 : signed(32-1 downto 0) := (others => '0');
  type Type_step_method is (
    step_method_IDLE,
    step_method_S_0000,
    step_method_S_0001,
    step_method_S_0002,
    step_method_S_0129,
    step_method_S_0130,
    step_method_S_0003,
    step_method_S_0005,
    step_method_S_0007,
    step_method_S_0009,
    step_method_S_0011,
    step_method_S_0013,
    step_method_S_0014,
    step_method_S_0131,
    step_method_S_0132,
    step_method_S_0015,
    step_method_S_0016,
    step_method_S_0018,
    step_method_S_0019,
    step_method_S_0021,
    step_method_S_0023,
    step_method_S_0133,
    step_method_S_0134,
    step_method_S_0024,
    step_method_S_0025,
    step_method_S_0026,
    step_method_S_0028,
    step_method_S_0030,
    step_method_S_0032,
    step_method_S_0135,
    step_method_S_0136,
    step_method_S_0033,
    step_method_S_0034,
    step_method_S_0035,
    step_method_S_0037,
    step_method_S_0039,
    step_method_S_0042,
    step_method_S_0044,
    step_method_S_0045,
    step_method_S_0047,
    step_method_S_0137,
    step_method_S_0138,
    step_method_S_0048,
    step_method_S_0049,
    step_method_S_0051,
    step_method_S_0053,
    step_method_S_0055,
    step_method_S_0056,
    step_method_S_0139,
    step_method_S_0140,
    step_method_S_0057,
    step_method_S_0058,
    step_method_S_0060,
    step_method_S_0061,
    step_method_S_0063,
    step_method_S_0065,
    step_method_S_0141,
    step_method_S_0142,
    step_method_S_0066,
    step_method_S_0067,
    step_method_S_0068,
    step_method_S_0070,
    step_method_S_0072,
    step_method_S_0074,
    step_method_S_0143,
    step_method_S_0144,
    step_method_S_0075,
    step_method_S_0076,
    step_method_S_0077,
    step_method_S_0079,
    step_method_S_0081,
    step_method_S_0085,
    step_method_S_0087,
    step_method_S_0088,
    step_method_S_0090,
    step_method_S_0092,
    step_method_S_0145,
    step_method_S_0146,
    step_method_S_0093,
    step_method_S_0094,
    step_method_S_0096,
    step_method_S_0147,
    step_method_S_0148,
    step_method_S_0097,
    step_method_S_0098,
    step_method_S_0099,
    step_method_S_0100,
    step_method_S_0102,
    step_method_S_0104,
    step_method_S_0149,
    step_method_S_0150,
    step_method_S_0105,
    step_method_S_0106,
    step_method_S_0107,
    step_method_S_0108,
    step_method_S_0110,
    step_method_S_0112,
    step_method_S_0113,
    step_method_S_0114,
    step_method_S_0115,
    step_method_S_0117,
    step_method_S_0118,
    step_method_S_0119,
    step_method_S_0120,
    step_method_S_0122,
    step_method_S_0124,
    step_method_S_0126,
    step_method_S_0127,
    step_method_S_0087_body,
    step_method_S_0087_wait,
    step_method_S_0093_body,
    step_method_S_0093_wait  
  );
  signal step_method : Type_step_method := step_method_IDLE;
  signal step_method_delay : signed(32-1 downto 0) := (others => '0');
  signal step_req_flag_d : std_logic := '0';
  signal step_req_flag_edge : std_logic := '0';
  signal tmp_0193 : std_logic := '0';
  signal tmp_0194 : std_logic := '0';
  signal tmp_0195 : std_logic := '0';
  signal tmp_0196 : std_logic := '0';
  signal tmp_0197 : std_logic := '0';
  signal tmp_0198 : std_logic := '0';
  signal tmp_0199 : std_logic := '0';
  signal tmp_0200 : std_logic := '0';
  signal tmp_0201 : std_logic := '0';
  signal tmp_0202 : std_logic := '0';
  signal tmp_0203 : std_logic := '0';
  signal tmp_0204 : std_logic := '0';
  signal tmp_0205 : std_logic := '0';
  signal tmp_0206 : std_logic := '0';
  signal tmp_0207 : std_logic := '0';
  signal tmp_0208 : std_logic := '0';
  signal tmp_0209 : std_logic := '0';
  signal tmp_0210 : std_logic := '0';
  signal tmp_0211 : std_logic := '0';
  signal tmp_0212 : std_logic := '0';
  signal tmp_0213 : std_logic := '0';
  signal tmp_0214 : std_logic := '0';
  signal tmp_0215 : std_logic := '0';
  signal tmp_0216 : std_logic := '0';
  signal tmp_0217 : std_logic := '0';
  signal tmp_0218 : std_logic := '0';
  signal tmp_0219 : std_logic := '0';
  signal tmp_0220 : std_logic := '0';
  signal tmp_0221 : std_logic := '0';
  signal tmp_0222 : std_logic := '0';
  signal tmp_0223 : std_logic := '0';
  signal class_io_0004_getchar_ext_call_flag_0087 : std_logic := '0';
  signal tmp_0224 : std_logic := '0';
  signal tmp_0225 : std_logic := '0';
  signal tmp_0226 : std_logic := '0';
  signal tmp_0227 : std_logic := '0';
  signal class_io_0004_putchar_ext_call_flag_0093 : std_logic := '0';
  signal tmp_0228 : std_logic := '0';
  signal tmp_0229 : std_logic := '0';
  signal tmp_0230 : std_logic := '0';
  signal tmp_0231 : std_logic := '0';
  signal tmp_0232 : std_logic := '0';
  signal tmp_0233 : std_logic := '0';
  signal tmp_0234 : std_logic := '0';
  signal tmp_0235 : std_logic := '0';
  signal tmp_0236 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0237 : signed(16-1 downto 0) := (others => '0');
  signal tmp_0238 : std_logic := '0';
  signal tmp_0239 : std_logic := '0';
  signal tmp_0240 : std_logic := '0';
  signal tmp_0241 : signed(16-1 downto 0) := (others => '0');
  signal tmp_0242 : std_logic := '0';
  signal tmp_0243 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0244 : signed(16-1 downto 0) := (others => '0');
  signal tmp_0245 : std_logic := '0';
  signal tmp_0246 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0247 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0248 : std_logic := '0';
  signal tmp_0249 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0250 : signed(16-1 downto 0) := (others => '0');
  signal tmp_0251 : std_logic := '0';
  signal tmp_0252 : std_logic := '0';
  signal tmp_0253 : std_logic := '0';
  signal tmp_0254 : signed(16-1 downto 0) := (others => '0');
  signal tmp_0255 : std_logic := '0';
  signal tmp_0256 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0257 : signed(16-1 downto 0) := (others => '0');
  signal tmp_0258 : std_logic := '0';
  signal tmp_0259 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0260 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0261 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0262 : signed(8-1 downto 0) := (others => '0');
  signal tmp_0263 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0264 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0265 : signed(8-1 downto 0) := (others => '0');
  signal tmp_0266 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0267 : signed(32-1 downto 0) := (others => '0');
  signal tmp_0268 : signed(32-1 downto 0) := (others => '0');

begin

  clk_sig <= clk;
  reset_sig <= reset;
  startup_busy <= startup_busy_sig;
  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        startup_busy_sig <= '1';
      else
        if startup_method = startup_method_S_0000 then
          startup_busy_sig <= '0';
        elsif startup_method = startup_method_S_0001 then
          startup_busy_sig <= tmp_0009;
        end if;
      end if;
    end if;
  end process;

  startup_req_sig <= startup_req;
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
          read_busy_sig <= tmp_0069;
        end if;
      end if;
    end if;
  end process;

  read_req_sig <= read_req;
  print_busy <= print_busy_sig;
  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        print_busy_sig <= '1';
      else
        if print_method = print_method_S_0000 then
          print_busy_sig <= '0';
        elsif print_method = print_method_S_0001 then
          print_busy_sig <= tmp_0096;
        end if;
      end if;
    end if;
  end process;

  print_req_sig <= print_req;
  init_busy <= init_busy_sig;
  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        init_busy_sig <= '1';
      else
        if init_method = init_method_S_0000 then
          init_busy_sig <= '0';
        elsif init_method = init_method_S_0001 then
          init_busy_sig <= tmp_0184;
        end if;
      end if;
    end if;
  end process;

  init_req_sig <= init_req;
  step_return <= step_return_sig;
  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        step_return_sig <= '0';
      else
        if step_method = step_method_S_0122 then
          step_return_sig <= '0';
        elsif step_method = step_method_S_0127 then
          step_return_sig <= '1';
        end if;
      end if;
    end if;
  end process;

  step_busy <= step_busy_sig;
  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        step_busy_sig <= '1';
      else
        if step_method = step_method_S_0000 then
          step_busy_sig <= '0';
        elsif step_method = step_method_S_0001 then
          step_busy_sig <= tmp_0196;
        end if;
      end if;
    end if;
  end process;

  step_req_sig <= step_req;

  -- expressions
  tmp_0001 <= startup_req_local or startup_req_sig;
  tmp_0002 <= read_req_local or read_req_sig;
  tmp_0003 <= print_req_local or print_req_sig;
  tmp_0004 <= init_req_local or init_req_sig;
  tmp_0005 <= step_req_local or step_req_sig;
  tmp_0006 <= not startup_req_flag_d;
  tmp_0007 <= startup_req_flag and tmp_0006;
  tmp_0008 <= startup_req_flag or startup_req_flag_d;
  tmp_0009 <= startup_req_flag or startup_req_flag_d;
  tmp_0010 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0011 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0012 <= tmp_0010 and tmp_0011;
  tmp_0013 <= '1' when tmp_0012 = '1' else '0';
  tmp_0014 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0015 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0016 <= tmp_0014 and tmp_0015;
  tmp_0017 <= '1' when tmp_0016 = '1' else '0';
  tmp_0018 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0019 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0020 <= tmp_0018 and tmp_0019;
  tmp_0021 <= '1' when tmp_0020 = '1' else '0';
  tmp_0022 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0023 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0024 <= tmp_0022 and tmp_0023;
  tmp_0025 <= '1' when tmp_0024 = '1' else '0';
  tmp_0026 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0027 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0028 <= tmp_0026 and tmp_0027;
  tmp_0029 <= '1' when tmp_0028 = '1' else '0';
  tmp_0030 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0031 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0032 <= tmp_0030 and tmp_0031;
  tmp_0033 <= '1' when tmp_0032 = '1' else '0';
  tmp_0034 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0035 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0036 <= tmp_0034 and tmp_0035;
  tmp_0037 <= '1' when tmp_0036 = '1' else '0';
  tmp_0038 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0039 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0040 <= tmp_0038 and tmp_0039;
  tmp_0041 <= '1' when tmp_0040 = '1' else '0';
  tmp_0042 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0043 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0044 <= tmp_0042 and tmp_0043;
  tmp_0045 <= '1' when tmp_0044 = '1' else '0';
  tmp_0046 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0047 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0048 <= tmp_0046 and tmp_0047;
  tmp_0049 <= '1' when tmp_0048 = '1' else '0';
  tmp_0050 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0051 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0052 <= tmp_0050 and tmp_0051;
  tmp_0053 <= '1' when tmp_0052 = '1' else '0';
  tmp_0054 <= '1' when startup_method /= startup_method_S_0000 else '0';
  tmp_0055 <= '1' when startup_method /= startup_method_S_0001 else '0';
  tmp_0056 <= tmp_0055 and startup_req_flag_edge;
  tmp_0057 <= tmp_0054 and tmp_0056;
  tmp_0058 <= not prompt_req_flag_d;
  tmp_0059 <= prompt_req_flag and tmp_0058;
  tmp_0060 <= prompt_req_flag or prompt_req_flag_d;
  tmp_0061 <= prompt_req_flag or prompt_req_flag_d;
  tmp_0062 <= '1' when prompt_method /= prompt_method_S_0000 else '0';
  tmp_0063 <= '1' when prompt_method /= prompt_method_S_0001 else '0';
  tmp_0064 <= tmp_0063 and prompt_req_flag_edge;
  tmp_0065 <= tmp_0062 and tmp_0064;
  tmp_0066 <= not read_req_flag_d;
  tmp_0067 <= read_req_flag and tmp_0066;
  tmp_0068 <= read_req_flag or read_req_flag_d;
  tmp_0069 <= read_req_flag or read_req_flag_d;
  tmp_0070 <= '1' when prompt_busy = '0' else '0';
  tmp_0071 <= '1' when prompt_req_local = '0' else '0';
  tmp_0072 <= tmp_0070 and tmp_0071;
  tmp_0073 <= '1' when tmp_0072 = '1' else '0';
  tmp_0074 <= '1' when binary_expr_00056 = '1' else '0';
  tmp_0075 <= '1' when binary_expr_00056 = '0' else '0';
  tmp_0076 <= '1' when class_io_0004_getchar_busy = '0' else '0';
  tmp_0077 <= '1' when class_io_0004_getchar_req = '0' else '0';
  tmp_0078 <= tmp_0076 and tmp_0077;
  tmp_0079 <= '1' when tmp_0078 = '1' else '0';
  tmp_0080 <= '1' when binary_expr_00068 = '1' else '0';
  tmp_0081 <= '1' when binary_expr_00068 = '0' else '0';
  tmp_0082 <= '1' when read_method /= read_method_S_0000 else '0';
  tmp_0083 <= '1' when read_method /= read_method_S_0001 else '0';
  tmp_0084 <= tmp_0083 and read_req_flag_edge;
  tmp_0085 <= tmp_0082 and tmp_0084;
  tmp_0086 <= '1' when read_i_0054 < class_CODESIZE_0002 else '0';
  tmp_0087 <= read_i_0054 + X"00000001";
  tmp_0088 <= (16-1 downto 8 => read_b_0060(7)) & read_b_0060;
  tmp_0089 <= (16-1 downto 8 => read_b_0060(7)) & read_b_0060;
  tmp_0090 <= '1' when signed(cast_expr_00063) = X"000a" else '0';
  tmp_0091 <= '1' when signed(cast_expr_00066) = X"000d" else '0';
  tmp_0092 <= binary_expr_00064 or binary_expr_00067;
  tmp_0093 <= not print_req_flag_d;
  tmp_0094 <= print_req_flag and tmp_0093;
  tmp_0095 <= print_req_flag or print_req_flag_d;
  tmp_0096 <= print_req_flag or print_req_flag_d;
  tmp_0097 <= '1' when binary_expr_00077 = '1' else '0';
  tmp_0098 <= '1' when binary_expr_00077 = '0' else '0';
  tmp_0099 <= '1' when binary_expr_00085 = '1' else '0';
  tmp_0100 <= '1' when binary_expr_00085 = '0' else '0';
  tmp_0101 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0102 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0103 <= tmp_0101 and tmp_0102;
  tmp_0104 <= '1' when tmp_0103 = '1' else '0';
  tmp_0105 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0106 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0107 <= tmp_0105 and tmp_0106;
  tmp_0108 <= '1' when tmp_0107 = '1' else '0';
  tmp_0109 <= '1' when print_method /= print_method_S_0000 else '0';
  tmp_0110 <= '1' when print_method /= print_method_S_0001 else '0';
  tmp_0111 <= tmp_0110 and print_req_flag_edge;
  tmp_0112 <= tmp_0109 and tmp_0111;
  tmp_0113 <= '1' when print_i_0075 < class_CODESIZE_0002 else '0';
  tmp_0114 <= print_i_0075 + X"00000001";
  tmp_0115 <= (32-1 downto 8 => print_b_0081(7)) & print_b_0081;
  tmp_0116 <= '1' when cast_expr_00084 = X"00000000" else '0';
  tmp_0117 <= not put_hex_req_flag_d;
  tmp_0118 <= put_hex_req_flag and tmp_0117;
  tmp_0119 <= put_hex_req_flag or put_hex_req_flag_d;
  tmp_0120 <= put_hex_req_flag or put_hex_req_flag_d;
  tmp_0121 <= '1' when binary_expr_00104 = '1' else '0';
  tmp_0122 <= '1' when binary_expr_00104 = '0' else '0';
  tmp_0123 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0124 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0125 <= tmp_0123 and tmp_0124;
  tmp_0126 <= '1' when tmp_0125 = '1' else '0';
  tmp_0127 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0128 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0129 <= tmp_0127 and tmp_0128;
  tmp_0130 <= '1' when tmp_0129 = '1' else '0';
  tmp_0131 <= '1' when binary_expr_00130 = '1' else '0';
  tmp_0132 <= '1' when binary_expr_00130 = '0' else '0';
  tmp_0133 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0134 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0135 <= tmp_0133 and tmp_0134;
  tmp_0136 <= '1' when tmp_0135 = '1' else '0';
  tmp_0137 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0138 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0139 <= tmp_0137 and tmp_0138;
  tmp_0140 <= '1' when tmp_0139 = '1' else '0';
  tmp_0141 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0142 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0143 <= tmp_0141 and tmp_0142;
  tmp_0144 <= '1' when tmp_0143 = '1' else '0';
  tmp_0145 <= '1' when put_hex_method /= put_hex_method_S_0000 else '0';
  tmp_0146 <= '1' when put_hex_method /= put_hex_method_S_0001 else '0';
  tmp_0147 <= tmp_0146 and put_hex_req_flag_edge;
  tmp_0148 <= tmp_0145 and tmp_0147;
  tmp_0149 <= (32-1 downto 8 => put_hex_b_0090(7)) & put_hex_b_0090;
  tmp_0150 <= (32-1 downto 28 => cast_expr_00093(31)) & cast_expr_00093(31 downto 4);
  tmp_0151 <= binary_expr_00094 and X"0000000f";
  tmp_0152 <= binary_expr_00096(32 - 24 - 1 downto 0);
  tmp_0153 <= (32-1 downto 8 => put_hex_h_0091(7)) & put_hex_h_0091;
  tmp_0154 <= (32-1 downto 8 => put_hex_h_0091(7)) & put_hex_h_0091;
  tmp_0155 <= '1' when X"00000000" <= cast_expr_00099 else '0';
  tmp_0156 <= '1' when cast_expr_00102 <= X"00000009" else '0';
  tmp_0157 <= binary_expr_00100 and binary_expr_00103;
  tmp_0158 <= (16-1 downto 8 => put_hex_h_0091(7)) & put_hex_h_0091;
  tmp_0159 <= std_logic_vector(signed(cast_expr_00107) + X"0030");
  tmp_0160 <= binary_expr_00108(16 - 8 - 1 downto 0);
  tmp_0161 <= (32-1 downto 8 => put_hex_h_0091(7)) & put_hex_h_0091;
  tmp_0162 <= cast_expr_00112 - X"0000000a";
  tmp_0163 <= binary_expr_00113 + X"00000041";
  tmp_0164 <= binary_expr_00115(32 - 24 - 1 downto 0);
  tmp_0165 <= (32-1 downto 8 => put_hex_b_0090(7)) & put_hex_b_0090;
  tmp_0166 <= (32-1 downto 8 => put_hex_h_0091(7)) & put_hex_h_0091;
  tmp_0167 <= cast_expr_00119;
  tmp_0168 <= '1' when X"00000000" <= cast_expr_00125 else '0';
  tmp_0169 <= binary_expr_00120 and X"0000000f";
  tmp_0170 <= binary_expr_00122(32 - 24 - 1 downto 0);
  tmp_0171 <= (32-1 downto 8 => put_hex_l_0117(7)) & put_hex_l_0117;
  tmp_0172 <= '1' when cast_expr_00128 <= X"00000009" else '0';
  tmp_0173 <= binary_expr_00126 and binary_expr_00129;
  tmp_0174 <= (16-1 downto 8 => put_hex_l_0117(7)) & put_hex_l_0117;
  tmp_0175 <= std_logic_vector(signed(cast_expr_00133) + X"0030");
  tmp_0176 <= binary_expr_00134(16 - 8 - 1 downto 0);
  tmp_0177 <= (32-1 downto 8 => put_hex_l_0117(7)) & put_hex_l_0117;
  tmp_0178 <= cast_expr_00138 - X"0000000a";
  tmp_0179 <= binary_expr_00139 + X"00000041";
  tmp_0180 <= binary_expr_00141(32 - 24 - 1 downto 0);
  tmp_0181 <= not init_req_flag_d;
  tmp_0182 <= init_req_flag and tmp_0181;
  tmp_0183 <= init_req_flag or init_req_flag_d;
  tmp_0184 <= init_req_flag or init_req_flag_d;
  tmp_0185 <= '1' when binary_expr_00150 = '1' else '0';
  tmp_0186 <= '1' when binary_expr_00150 = '0' else '0';
  tmp_0187 <= '1' when init_method /= init_method_S_0000 else '0';
  tmp_0188 <= '1' when init_method /= init_method_S_0001 else '0';
  tmp_0189 <= tmp_0188 and init_req_flag_edge;
  tmp_0190 <= tmp_0187 and tmp_0189;
  tmp_0191 <= '1' when init_i_0148 < class_ARRAYSIZE_0000 else '0';
  tmp_0192 <= init_i_0148 + X"00000001";
  tmp_0193 <= not step_req_flag_d;
  tmp_0194 <= step_req_flag and tmp_0193;
  tmp_0195 <= step_req_flag or step_req_flag_d;
  tmp_0196 <= step_req_flag or step_req_flag_d;
  tmp_0197 <= '1' when step_cmd_0156 = X"00000000" else '0';
  tmp_0198 <= '1' when step_cmd_0156 = X"003e" else '0';
  tmp_0199 <= '1' when step_cmd_0156 = X"003c" else '0';
  tmp_0200 <= '1' when step_cmd_0156 = X"002b" else '0';
  tmp_0201 <= '1' when step_cmd_0156 = X"002d" else '0';
  tmp_0202 <= '1' when step_cmd_0156 = X"002e" else '0';
  tmp_0203 <= '1' when step_cmd_0156 = X"002c" else '0';
  tmp_0204 <= '1' when step_cmd_0156 = X"005b" else '0';
  tmp_0205 <= '1' when step_cmd_0156 = X"005d" else '0';
  tmp_0206 <= '1';
  tmp_0207 <= '0';
  tmp_0208 <= '1' when binary_expr_00180 = '1' else '0';
  tmp_0209 <= '1' when binary_expr_00180 = '0' else '0';
  tmp_0210 <= '1' when binary_expr_00184 = '1' else '0';
  tmp_0211 <= '1' when binary_expr_00184 = '0' else '0';
  tmp_0212 <= '1' when binary_expr_00191 = '1' else '0';
  tmp_0213 <= '1' when binary_expr_00191 = '0' else '0';
  tmp_0214 <= '1' when binary_expr_00201 = '1' else '0';
  tmp_0215 <= '1' when binary_expr_00201 = '0' else '0';
  tmp_0216 <= '1';
  tmp_0217 <= '0';
  tmp_0218 <= '1' when binary_expr_00212 = '1' else '0';
  tmp_0219 <= '1' when binary_expr_00212 = '0' else '0';
  tmp_0220 <= '1' when binary_expr_00216 = '1' else '0';
  tmp_0221 <= '1' when binary_expr_00216 = '0' else '0';
  tmp_0222 <= '1' when binary_expr_00223 = '1' else '0';
  tmp_0223 <= '1' when binary_expr_00223 = '0' else '0';
  tmp_0224 <= '1' when class_io_0004_getchar_busy = '0' else '0';
  tmp_0225 <= '1' when class_io_0004_getchar_req = '0' else '0';
  tmp_0226 <= tmp_0224 and tmp_0225;
  tmp_0227 <= '1' when tmp_0226 = '1' else '0';
  tmp_0228 <= '1' when class_io_0004_putchar_busy = '0' else '0';
  tmp_0229 <= '1' when class_io_0004_putchar_req = '0' else '0';
  tmp_0230 <= tmp_0228 and tmp_0229;
  tmp_0231 <= '1' when tmp_0230 = '1' else '0';
  tmp_0232 <= '1' when step_method /= step_method_S_0000 else '0';
  tmp_0233 <= '1' when step_method /= step_method_S_0001 else '0';
  tmp_0234 <= tmp_0233 and step_req_flag_edge;
  tmp_0235 <= tmp_0232 and tmp_0234;
  tmp_0236 <= class_pc_0013 - X"00000001";
  tmp_0237 <= (16-1 downto 8 => array_access_00174(7)) & array_access_00174;
  tmp_0238 <= '1' when step_nlvl_0159 = X"00000000" else '0';
  tmp_0239 <= '1' when signed(cast_expr_00176) = X"005b" else '0';
  tmp_0240 <= binary_expr_00177 and binary_expr_00179;
  tmp_0241 <= (16-1 downto 8 => array_access_00181(7)) & array_access_00181;
  tmp_0242 <= '1' when signed(cast_expr_00183) = X"005d" else '0';
  tmp_0243 <= step_nlvl_0159 + X"00000001";
  tmp_0244 <= (16-1 downto 8 => array_access_00188(7)) & array_access_00188;
  tmp_0245 <= '1' when signed(cast_expr_00190) = X"005b" else '0';
  tmp_0246 <= step_nlvl_0159 - X"00000001";
  tmp_0247 <= class_pc_0013 - X"00000001";
  tmp_0248 <= '1' when array_access_00198 = X"00" else '0';
  tmp_0249 <= class_pc_0013 + X"00000001";
  tmp_0250 <= (16-1 downto 8 => array_access_00206(7)) & array_access_00206;
  tmp_0251 <= '1' when step_nlvl_0159 = X"00000000" else '0';
  tmp_0252 <= '1' when signed(cast_expr_00208) = X"005d" else '0';
  tmp_0253 <= binary_expr_00209 and binary_expr_00211;
  tmp_0254 <= (16-1 downto 8 => array_access_00213(7)) & array_access_00213;
  tmp_0255 <= '1' when signed(cast_expr_00215) = X"005b" else '0';
  tmp_0256 <= step_nlvl_0159 + X"00000001";
  tmp_0257 <= (16-1 downto 8 => array_access_00220(7)) & array_access_00220;
  tmp_0258 <= '1' when signed(cast_expr_00222) = X"005d" else '0';
  tmp_0259 <= step_nlvl_0159 - X"00000001";
  tmp_0260 <= (32-1 downto 8 => array_access_00231(7)) & array_access_00231;
  tmp_0261 <= cast_expr_00233 - X"00000001";
  tmp_0262 <= binary_expr_00234(32 - 24 - 1 downto 0);
  tmp_0263 <= (32-1 downto 8 => array_access_00237(7)) & array_access_00237;
  tmp_0264 <= cast_expr_00239 + X"00000001";
  tmp_0265 <= binary_expr_00240(32 - 24 - 1 downto 0);
  tmp_0266 <= class_ptr_0012 - X"00000001";
  tmp_0267 <= class_ptr_0012 + X"00000001";
  tmp_0268 <= class_pc_0013 + X"00000001";

  -- sequencers
  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        startup_method <= startup_method_IDLE;
        startup_method_delay <= (others => '0');
      else
        case (startup_method) is
          when startup_method_IDLE => 
            startup_method <= startup_method_S_0000;
          when startup_method_S_0000 => 
            startup_method <= startup_method_S_0001;
          when startup_method_S_0001 => 
            if tmp_0008 = '1' then
              startup_method <= startup_method_S_0002;
            end if;
          when startup_method_S_0002 => 
            startup_method <= startup_method_S_0002_body;
          when startup_method_S_0003 => 
            startup_method <= startup_method_S_0003_body;
          when startup_method_S_0004 => 
            startup_method <= startup_method_S_0004_body;
          when startup_method_S_0005 => 
            startup_method <= startup_method_S_0005_body;
          when startup_method_S_0006 => 
            startup_method <= startup_method_S_0006_body;
          when startup_method_S_0007 => 
            startup_method <= startup_method_S_0007_body;
          when startup_method_S_0008 => 
            startup_method <= startup_method_S_0008_body;
          when startup_method_S_0009 => 
            startup_method <= startup_method_S_0009_body;
          when startup_method_S_0010 => 
            startup_method <= startup_method_S_0010_body;
          when startup_method_S_0011 => 
            startup_method <= startup_method_S_0011_body;
          when startup_method_S_0012 => 
            startup_method <= startup_method_S_0012_body;
          when startup_method_S_0013 => 
            startup_method <= startup_method_S_0000;
          when startup_method_S_0002_body => 
            startup_method <= startup_method_S_0002_wait;
          when startup_method_S_0002_wait => 
            if class_io_0004_putchar_ext_call_flag_0002 = '1' then
              startup_method <= startup_method_S_0003;
            end if;
          when startup_method_S_0003_body => 
            startup_method <= startup_method_S_0003_wait;
          when startup_method_S_0003_wait => 
            if class_io_0004_putchar_ext_call_flag_0003 = '1' then
              startup_method <= startup_method_S_0004;
            end if;
          when startup_method_S_0004_body => 
            startup_method <= startup_method_S_0004_wait;
          when startup_method_S_0004_wait => 
            if class_io_0004_putchar_ext_call_flag_0004 = '1' then
              startup_method <= startup_method_S_0005;
            end if;
          when startup_method_S_0005_body => 
            startup_method <= startup_method_S_0005_wait;
          when startup_method_S_0005_wait => 
            if class_io_0004_putchar_ext_call_flag_0005 = '1' then
              startup_method <= startup_method_S_0006;
            end if;
          when startup_method_S_0006_body => 
            startup_method <= startup_method_S_0006_wait;
          when startup_method_S_0006_wait => 
            if class_io_0004_putchar_ext_call_flag_0006 = '1' then
              startup_method <= startup_method_S_0007;
            end if;
          when startup_method_S_0007_body => 
            startup_method <= startup_method_S_0007_wait;
          when startup_method_S_0007_wait => 
            if class_io_0004_putchar_ext_call_flag_0007 = '1' then
              startup_method <= startup_method_S_0008;
            end if;
          when startup_method_S_0008_body => 
            startup_method <= startup_method_S_0008_wait;
          when startup_method_S_0008_wait => 
            if class_io_0004_putchar_ext_call_flag_0008 = '1' then
              startup_method <= startup_method_S_0009;
            end if;
          when startup_method_S_0009_body => 
            startup_method <= startup_method_S_0009_wait;
          when startup_method_S_0009_wait => 
            if class_io_0004_putchar_ext_call_flag_0009 = '1' then
              startup_method <= startup_method_S_0010;
            end if;
          when startup_method_S_0010_body => 
            startup_method <= startup_method_S_0010_wait;
          when startup_method_S_0010_wait => 
            if class_io_0004_putchar_ext_call_flag_0010 = '1' then
              startup_method <= startup_method_S_0011;
            end if;
          when startup_method_S_0011_body => 
            startup_method <= startup_method_S_0011_wait;
          when startup_method_S_0011_wait => 
            if class_io_0004_putchar_ext_call_flag_0011 = '1' then
              startup_method <= startup_method_S_0012;
            end if;
          when startup_method_S_0012_body => 
            startup_method <= startup_method_S_0012_wait;
          when startup_method_S_0012_wait => 
            if class_io_0004_putchar_ext_call_flag_0012 = '1' then
              startup_method <= startup_method_S_0013;
            end if;
          when others => null;
        end case;
        startup_req_flag_d <= startup_req_flag;
        if (tmp_0054 and tmp_0056) = '1' then
          startup_method <= startup_method_S_0001;
        end if;
      end if;
    end if;
  end process;

  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        prompt_method <= prompt_method_IDLE;
        prompt_method_delay <= (others => '0');
      else
        case (prompt_method) is
          when prompt_method_IDLE => 
            prompt_method <= prompt_method_S_0000;
          when prompt_method_S_0000 => 
            prompt_method <= prompt_method_S_0001;
          when prompt_method_S_0001 => 
            if tmp_0060 = '1' then
              prompt_method <= prompt_method_S_0002;
            end if;
          when prompt_method_S_0002 => 
            prompt_method <= prompt_method_S_0002_body;
          when prompt_method_S_0003 => 
            prompt_method <= prompt_method_S_0003_body;
          when prompt_method_S_0004 => 
            prompt_method <= prompt_method_S_0000;
          when prompt_method_S_0002_body => 
            prompt_method <= prompt_method_S_0002_wait;
          when prompt_method_S_0002_wait => 
            if class_io_0004_putchar_ext_call_flag_0002 = '1' then
              prompt_method <= prompt_method_S_0003;
            end if;
          when prompt_method_S_0003_body => 
            prompt_method <= prompt_method_S_0003_wait;
          when prompt_method_S_0003_wait => 
            if class_io_0004_putchar_ext_call_flag_0003 = '1' then
              prompt_method <= prompt_method_S_0004;
            end if;
          when others => null;
        end case;
        prompt_req_flag_d <= prompt_req_flag;
        if (tmp_0062 and tmp_0064) = '1' then
          prompt_method <= prompt_method_S_0001;
        end if;
      end if;
    end if;
  end process;

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
            if tmp_0068 = '1' then
              read_method <= read_method_S_0002;
            end if;
          when read_method_S_0002 => 
            read_method <= read_method_S_0002_body;
          when read_method_S_0003 => 
            read_method <= read_method_S_0004;
            read_method <= read_method_S_0004;
          when read_method_S_0004 => 
            read_method <= read_method_S_0005;
            read_method <= read_method_S_0005;
          when read_method_S_0005 => 
            if tmp_0074 = '1' then
              read_method <= read_method_S_0011;
            elsif tmp_0075 = '1' then
              read_method <= read_method_S_0000;
            end if;
          when read_method_S_0007 => 
            read_method <= read_method_S_0009;
            read_method <= read_method_S_0009;
            read_method <= read_method_S_0009;
          when read_method_S_0009 => 
            read_method <= read_method_S_0004;
            read_method <= read_method_S_0004;
          when read_method_S_0011 => 
            read_method <= read_method_S_0011_body;
          when read_method_S_0012 => 
            read_method <= read_method_S_0013;
            read_method <= read_method_S_0013;
          when read_method_S_0013 => 
            read_method <= read_method_S_0014;
            read_method <= read_method_S_0014;
            read_method <= read_method_S_0014;
          when read_method_S_0014 => 
            read_method <= read_method_S_0017;
            read_method <= read_method_S_0017;
            read_method <= read_method_S_0017;
          when read_method_S_0017 => 
            read_method <= read_method_S_0018;
            read_method <= read_method_S_0018;
          when read_method_S_0018 => 
            if tmp_0080 = '1' then
              read_method <= read_method_S_0020;
            elsif tmp_0081 = '1' then
              read_method <= read_method_S_0024;
            end if;
          when read_method_S_0020 => 
            read_method <= read_method_S_0022;
            read_method <= read_method_S_0022;
            read_method <= read_method_S_0022;
          when read_method_S_0022 => 
            read_method <= read_method_S_0000;
            read_method <= read_method_S_0000;
          when read_method_S_0024 => 
            read_method <= read_method_S_0007;
            read_method <= read_method_S_0007;
            read_method <= read_method_S_0007;
          when read_method_S_0002_body => 
            read_method <= read_method_S_0002_wait;
          when read_method_S_0002_wait => 
            if prompt_call_flag_0002 = '1' then
              read_method <= read_method_S_0003;
            end if;
          when read_method_S_0011_body => 
            read_method <= read_method_S_0011_wait;
          when read_method_S_0011_wait => 
            if class_io_0004_getchar_ext_call_flag_0011 = '1' then
              read_method <= read_method_S_0012;
            end if;
          when others => null;
        end case;
        read_req_flag_d <= read_req_flag;
        if (tmp_0082 and tmp_0084) = '1' then
          read_method <= read_method_S_0001;
        end if;
      end if;
    end if;
  end process;

  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        print_method <= print_method_IDLE;
        print_method_delay <= (others => '0');
      else
        case (print_method) is
          when print_method_IDLE => 
            print_method <= print_method_S_0000;
          when print_method_S_0000 => 
            print_method <= print_method_S_0001;
          when print_method_S_0001 => 
            if tmp_0095 = '1' then
              print_method <= print_method_S_0002;
            end if;
          when print_method_S_0002 => 
            print_method <= print_method_S_0004;
            print_method <= print_method_S_0004;
            print_method <= print_method_S_0004;
          when print_method_S_0004 => 
            print_method <= print_method_S_0005;
            print_method <= print_method_S_0005;
          when print_method_S_0005 => 
            if tmp_0097 = '1' then
              print_method <= print_method_S_0011;
            elsif tmp_0098 = '1' then
              print_method <= print_method_S_0021;
            end if;
          when print_method_S_0007 => 
            print_method <= print_method_S_0009;
            print_method <= print_method_S_0009;
            print_method <= print_method_S_0009;
          when print_method_S_0009 => 
            print_method <= print_method_S_0004;
            print_method <= print_method_S_0004;
          when print_method_S_0011 => 
            print_method <= print_method_S_0023;
            print_method <= print_method_S_0023;
          when print_method_S_0023 => 
            print_method <= print_method_S_0024;
            print_method <= print_method_S_0024;
          when print_method_S_0024 => 
            print_method <= print_method_S_0012;
            print_method <= print_method_S_0012;
          when print_method_S_0012 => 
            print_method <= print_method_S_0013;
            print_method <= print_method_S_0013;
          when print_method_S_0013 => 
            print_method <= print_method_S_0014;
            print_method <= print_method_S_0014;
          when print_method_S_0014 => 
            print_method <= print_method_S_0015;
            print_method <= print_method_S_0015;
          when print_method_S_0015 => 
            if tmp_0099 = '1' then
              print_method <= print_method_S_0017;
            elsif tmp_0100 = '1' then
              print_method <= print_method_S_0019;
            end if;
          when print_method_S_0017 => 
            print_method <= print_method_S_0021;
            print_method <= print_method_S_0021;
          when print_method_S_0019 => 
            print_method <= print_method_S_0019_body;
          when print_method_S_0021 => 
            print_method <= print_method_S_0021_body;
          when print_method_S_0019_body => 
            print_method <= print_method_S_0019_wait;
          when print_method_S_0019_wait => 
            if class_io_0004_putchar_ext_call_flag_0019 = '1' then
              print_method <= print_method_S_0007;
            end if;
          when print_method_S_0021_body => 
            print_method <= print_method_S_0021_wait;
          when print_method_S_0021_wait => 
            if class_io_0004_putchar_ext_call_flag_0021 = '1' then
              print_method <= print_method_S_0000;
            end if;
          when others => null;
        end case;
        print_req_flag_d <= print_req_flag;
        if (tmp_0109 and tmp_0111) = '1' then
          print_method <= print_method_S_0001;
        end if;
      end if;
    end if;
  end process;

  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        put_hex_method <= put_hex_method_IDLE;
        put_hex_method_delay <= (others => '0');
      else
        case (put_hex_method) is
          when put_hex_method_IDLE => 
            put_hex_method <= put_hex_method_S_0000;
          when put_hex_method_S_0000 => 
            put_hex_method <= put_hex_method_S_0001;
          when put_hex_method_S_0001 => 
            if tmp_0119 = '1' then
              put_hex_method <= put_hex_method_S_0002;
            end if;
          when put_hex_method_S_0002 => 
            put_hex_method <= put_hex_method_S_0003;
            put_hex_method <= put_hex_method_S_0003;
          when put_hex_method_S_0003 => 
            put_hex_method <= put_hex_method_S_0004;
            put_hex_method <= put_hex_method_S_0004;
          when put_hex_method_S_0004 => 
            put_hex_method <= put_hex_method_S_0005;
            put_hex_method <= put_hex_method_S_0005;
          when put_hex_method_S_0005 => 
            put_hex_method <= put_hex_method_S_0006;
            put_hex_method <= put_hex_method_S_0006;
          when put_hex_method_S_0006 => 
            put_hex_method <= put_hex_method_S_0007;
            put_hex_method <= put_hex_method_S_0007;
          when put_hex_method_S_0007 => 
            put_hex_method <= put_hex_method_S_0008;
            put_hex_method <= put_hex_method_S_0008;
            put_hex_method <= put_hex_method_S_0008;
          when put_hex_method_S_0008 => 
            put_hex_method <= put_hex_method_S_0011;
            put_hex_method <= put_hex_method_S_0011;
            put_hex_method <= put_hex_method_S_0011;
          when put_hex_method_S_0011 => 
            put_hex_method <= put_hex_method_S_0012;
            put_hex_method <= put_hex_method_S_0012;
          when put_hex_method_S_0012 => 
            if tmp_0121 = '1' then
              put_hex_method <= put_hex_method_S_0014;
            elsif tmp_0122 = '1' then
              put_hex_method <= put_hex_method_S_0019;
            end if;
          when put_hex_method_S_0014 => 
            put_hex_method <= put_hex_method_S_0015;
            put_hex_method <= put_hex_method_S_0015;
          when put_hex_method_S_0015 => 
            put_hex_method <= put_hex_method_S_0016;
            put_hex_method <= put_hex_method_S_0016;
          when put_hex_method_S_0016 => 
            put_hex_method <= put_hex_method_S_0017;
            put_hex_method <= put_hex_method_S_0017;
          when put_hex_method_S_0017 => 
            put_hex_method <= put_hex_method_S_0017_body;
          when put_hex_method_S_0019 => 
            put_hex_method <= put_hex_method_S_0020;
            put_hex_method <= put_hex_method_S_0020;
          when put_hex_method_S_0020 => 
            put_hex_method <= put_hex_method_S_0021;
            put_hex_method <= put_hex_method_S_0021;
          when put_hex_method_S_0021 => 
            put_hex_method <= put_hex_method_S_0022;
            put_hex_method <= put_hex_method_S_0022;
          when put_hex_method_S_0022 => 
            put_hex_method <= put_hex_method_S_0023;
            put_hex_method <= put_hex_method_S_0023;
          when put_hex_method_S_0023 => 
            put_hex_method <= put_hex_method_S_0023_body;
          when put_hex_method_S_0025 => 
            put_hex_method <= put_hex_method_S_0026;
            put_hex_method <= put_hex_method_S_0026;
            put_hex_method <= put_hex_method_S_0026;
          when put_hex_method_S_0026 => 
            put_hex_method <= put_hex_method_S_0027;
            put_hex_method <= put_hex_method_S_0027;
            put_hex_method <= put_hex_method_S_0027;
          when put_hex_method_S_0027 => 
            put_hex_method <= put_hex_method_S_0028;
            put_hex_method <= put_hex_method_S_0028;
          when put_hex_method_S_0028 => 
            put_hex_method <= put_hex_method_S_0029;
            put_hex_method <= put_hex_method_S_0029;
          when put_hex_method_S_0029 => 
            put_hex_method <= put_hex_method_S_0032;
            put_hex_method <= put_hex_method_S_0032;
          when put_hex_method_S_0032 => 
            put_hex_method <= put_hex_method_S_0033;
            put_hex_method <= put_hex_method_S_0033;
          when put_hex_method_S_0033 => 
            put_hex_method <= put_hex_method_S_0034;
            put_hex_method <= put_hex_method_S_0034;
          when put_hex_method_S_0034 => 
            put_hex_method <= put_hex_method_S_0035;
            put_hex_method <= put_hex_method_S_0035;
          when put_hex_method_S_0035 => 
            if tmp_0131 = '1' then
              put_hex_method <= put_hex_method_S_0037;
            elsif tmp_0132 = '1' then
              put_hex_method <= put_hex_method_S_0042;
            end if;
          when put_hex_method_S_0037 => 
            put_hex_method <= put_hex_method_S_0038;
            put_hex_method <= put_hex_method_S_0038;
          when put_hex_method_S_0038 => 
            put_hex_method <= put_hex_method_S_0039;
            put_hex_method <= put_hex_method_S_0039;
          when put_hex_method_S_0039 => 
            put_hex_method <= put_hex_method_S_0040;
            put_hex_method <= put_hex_method_S_0040;
          when put_hex_method_S_0040 => 
            put_hex_method <= put_hex_method_S_0040_body;
          when put_hex_method_S_0042 => 
            put_hex_method <= put_hex_method_S_0043;
            put_hex_method <= put_hex_method_S_0043;
          when put_hex_method_S_0043 => 
            put_hex_method <= put_hex_method_S_0044;
            put_hex_method <= put_hex_method_S_0044;
          when put_hex_method_S_0044 => 
            put_hex_method <= put_hex_method_S_0045;
            put_hex_method <= put_hex_method_S_0045;
          when put_hex_method_S_0045 => 
            put_hex_method <= put_hex_method_S_0046;
            put_hex_method <= put_hex_method_S_0046;
          when put_hex_method_S_0046 => 
            put_hex_method <= put_hex_method_S_0046_body;
          when put_hex_method_S_0048 => 
            put_hex_method <= put_hex_method_S_0048_body;
          when put_hex_method_S_0017_body => 
            put_hex_method <= put_hex_method_S_0017_wait;
          when put_hex_method_S_0017_wait => 
            if class_io_0004_putchar_ext_call_flag_0017 = '1' then
              put_hex_method <= put_hex_method_S_0025;
            end if;
          when put_hex_method_S_0023_body => 
            put_hex_method <= put_hex_method_S_0023_wait;
          when put_hex_method_S_0023_wait => 
            if class_io_0004_putchar_ext_call_flag_0023 = '1' then
              put_hex_method <= put_hex_method_S_0025;
            end if;
          when put_hex_method_S_0040_body => 
            put_hex_method <= put_hex_method_S_0040_wait;
          when put_hex_method_S_0040_wait => 
            if class_io_0004_putchar_ext_call_flag_0040 = '1' then
              put_hex_method <= put_hex_method_S_0048;
            end if;
          when put_hex_method_S_0046_body => 
            put_hex_method <= put_hex_method_S_0046_wait;
          when put_hex_method_S_0046_wait => 
            if class_io_0004_putchar_ext_call_flag_0046 = '1' then
              put_hex_method <= put_hex_method_S_0048;
            end if;
          when put_hex_method_S_0048_body => 
            put_hex_method <= put_hex_method_S_0048_wait;
          when put_hex_method_S_0048_wait => 
            if class_io_0004_putchar_ext_call_flag_0048 = '1' then
              put_hex_method <= put_hex_method_S_0000;
            end if;
          when others => null;
        end case;
        put_hex_req_flag_d <= put_hex_req_flag;
        if (tmp_0145 and tmp_0147) = '1' then
          put_hex_method <= put_hex_method_S_0001;
        end if;
      end if;
    end if;
  end process;

  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        init_method <= init_method_IDLE;
        init_method_delay <= (others => '0');
      else
        case (init_method) is
          when init_method_IDLE => 
            init_method <= init_method_S_0000;
          when init_method_S_0000 => 
            init_method <= init_method_S_0001;
          when init_method_S_0001 => 
            if tmp_0183 = '1' then
              init_method <= init_method_S_0002;
            end if;
          when init_method_S_0002 => 
            init_method <= init_method_S_0005;
            init_method <= init_method_S_0005;
            init_method <= init_method_S_0005;
            init_method <= init_method_S_0005;
          when init_method_S_0005 => 
            init_method <= init_method_S_0006;
            init_method <= init_method_S_0006;
          when init_method_S_0006 => 
            if tmp_0185 = '1' then
              init_method <= init_method_S_0012;
            elsif tmp_0186 = '1' then
              init_method <= init_method_S_0015;
            end if;
          when init_method_S_0008 => 
            init_method <= init_method_S_0010;
            init_method <= init_method_S_0010;
            init_method <= init_method_S_0010;
          when init_method_S_0010 => 
            init_method <= init_method_S_0005;
            init_method <= init_method_S_0005;
          when init_method_S_0012 => 
            init_method <= init_method_S_0008;
            init_method <= init_method_S_0008;
            init_method <= init_method_S_0008;
          when init_method_S_0015 => 
            init_method <= init_method_S_0000;
          when others => null;
        end case;
        init_req_flag_d <= init_req_flag;
        if (tmp_0187 and tmp_0189) = '1' then
          init_method <= init_method_S_0001;
        end if;
      end if;
    end if;
  end process;

  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        step_method <= step_method_IDLE;
        step_method_delay <= (others => '0');
      else
        case (step_method) is
          when step_method_IDLE => 
            step_method <= step_method_S_0000;
          when step_method_S_0000 => 
            step_method <= step_method_S_0001;
          when step_method_S_0001 => 
            if tmp_0195 = '1' then
              step_method <= step_method_S_0002;
            end if;
          when step_method_S_0002 => 
            step_method <= step_method_S_0129;
            step_method <= step_method_S_0129;
          when step_method_S_0129 => 
            step_method <= step_method_S_0130;
            step_method <= step_method_S_0130;
          when step_method_S_0130 => 
            step_method <= step_method_S_0003;
            step_method <= step_method_S_0003;
          when step_method_S_0003 => 
            step_method <= step_method_S_0005;
            step_method <= step_method_S_0005;
            step_method <= step_method_S_0005;
          when step_method_S_0005 => 
            if tmp_0197 = '1' then
              step_method <= step_method_S_0122;
            elsif tmp_0198 = '1' then
              step_method <= step_method_S_0117;
            elsif tmp_0199 = '1' then
              step_method <= step_method_S_0112;
            elsif tmp_0200 = '1' then
              step_method <= step_method_S_0104;
            elsif tmp_0201 = '1' then
              step_method <= step_method_S_0096;
            elsif tmp_0202 = '1' then
              step_method <= step_method_S_0092;
            elsif tmp_0203 = '1' then
              step_method <= step_method_S_0087;
            elsif tmp_0204 = '1' then
              step_method <= step_method_S_0047;
            elsif tmp_0205 = '1' then
              step_method <= step_method_S_0009;
            else
              step_method <= step_method_S_0007;
            end if;
          when step_method_S_0007 => 
            step_method <= step_method_S_0124;
            step_method <= step_method_S_0124;
          when step_method_S_0009 => 
            if tmp_0206 = '1' then
              step_method <= step_method_S_0011;
            elsif tmp_0207 = '1' then
              step_method <= step_method_S_0042;
            end if;
          when step_method_S_0011 => 
            step_method <= step_method_S_0013;
            step_method <= step_method_S_0013;
            step_method <= step_method_S_0013;
          when step_method_S_0013 => 
            step_method <= step_method_S_0014;
            step_method <= step_method_S_0014;
          when step_method_S_0014 => 
            step_method <= step_method_S_0131;
            step_method <= step_method_S_0131;
          when step_method_S_0131 => 
            step_method <= step_method_S_0132;
            step_method <= step_method_S_0132;
          when step_method_S_0132 => 
            step_method <= step_method_S_0015;
            step_method <= step_method_S_0015;
          when step_method_S_0015 => 
            step_method <= step_method_S_0016;
            step_method <= step_method_S_0016;
            step_method <= step_method_S_0016;
          when step_method_S_0016 => 
            step_method <= step_method_S_0018;
            step_method <= step_method_S_0018;
          when step_method_S_0018 => 
            step_method <= step_method_S_0019;
            step_method <= step_method_S_0019;
          when step_method_S_0019 => 
            if tmp_0208 = '1' then
              step_method <= step_method_S_0021;
            elsif tmp_0209 = '1' then
              step_method <= step_method_S_0023;
            end if;
          when step_method_S_0021 => 
            step_method <= step_method_S_0042;
            step_method <= step_method_S_0042;
          when step_method_S_0023 => 
            step_method <= step_method_S_0133;
            step_method <= step_method_S_0133;
          when step_method_S_0133 => 
            step_method <= step_method_S_0134;
            step_method <= step_method_S_0134;
          when step_method_S_0134 => 
            step_method <= step_method_S_0024;
            step_method <= step_method_S_0024;
          when step_method_S_0024 => 
            step_method <= step_method_S_0025;
            step_method <= step_method_S_0025;
          when step_method_S_0025 => 
            step_method <= step_method_S_0026;
            step_method <= step_method_S_0026;
          when step_method_S_0026 => 
            if tmp_0210 = '1' then
              step_method <= step_method_S_0028;
            elsif tmp_0211 = '1' then
              step_method <= step_method_S_0032;
            end if;
          when step_method_S_0028 => 
            step_method <= step_method_S_0030;
            step_method <= step_method_S_0030;
            step_method <= step_method_S_0030;
          when step_method_S_0030 => 
            step_method <= step_method_S_0032;
            step_method <= step_method_S_0032;
          when step_method_S_0032 => 
            step_method <= step_method_S_0135;
            step_method <= step_method_S_0135;
          when step_method_S_0135 => 
            step_method <= step_method_S_0136;
            step_method <= step_method_S_0136;
          when step_method_S_0136 => 
            step_method <= step_method_S_0033;
            step_method <= step_method_S_0033;
          when step_method_S_0033 => 
            step_method <= step_method_S_0034;
            step_method <= step_method_S_0034;
          when step_method_S_0034 => 
            step_method <= step_method_S_0035;
            step_method <= step_method_S_0035;
          when step_method_S_0035 => 
            if tmp_0212 = '1' then
              step_method <= step_method_S_0037;
            elsif tmp_0213 = '1' then
              step_method <= step_method_S_0009;
            end if;
          when step_method_S_0037 => 
            step_method <= step_method_S_0039;
            step_method <= step_method_S_0039;
            step_method <= step_method_S_0039;
          when step_method_S_0039 => 
            step_method <= step_method_S_0009;
            step_method <= step_method_S_0009;
          when step_method_S_0042 => 
            step_method <= step_method_S_0044;
            step_method <= step_method_S_0044;
            step_method <= step_method_S_0044;
          when step_method_S_0044 => 
            step_method <= step_method_S_0045;
            step_method <= step_method_S_0045;
          when step_method_S_0045 => 
            step_method <= step_method_S_0124;
            step_method <= step_method_S_0124;
          when step_method_S_0047 => 
            step_method <= step_method_S_0137;
            step_method <= step_method_S_0137;
          when step_method_S_0137 => 
            step_method <= step_method_S_0138;
            step_method <= step_method_S_0138;
          when step_method_S_0138 => 
            step_method <= step_method_S_0048;
            step_method <= step_method_S_0048;
          when step_method_S_0048 => 
            step_method <= step_method_S_0049;
            step_method <= step_method_S_0049;
          when step_method_S_0049 => 
            if tmp_0214 = '1' then
              step_method <= step_method_S_0051;
            elsif tmp_0215 = '1' then
              step_method <= step_method_S_0085;
            end if;
          when step_method_S_0051 => 
            if tmp_0216 = '1' then
              step_method <= step_method_S_0053;
            elsif tmp_0217 = '1' then
              step_method <= step_method_S_0085;
            end if;
          when step_method_S_0053 => 
            step_method <= step_method_S_0055;
            step_method <= step_method_S_0055;
            step_method <= step_method_S_0055;
          when step_method_S_0055 => 
            step_method <= step_method_S_0056;
            step_method <= step_method_S_0056;
          when step_method_S_0056 => 
            step_method <= step_method_S_0139;
            step_method <= step_method_S_0139;
          when step_method_S_0139 => 
            step_method <= step_method_S_0140;
            step_method <= step_method_S_0140;
          when step_method_S_0140 => 
            step_method <= step_method_S_0057;
            step_method <= step_method_S_0057;
          when step_method_S_0057 => 
            step_method <= step_method_S_0058;
            step_method <= step_method_S_0058;
            step_method <= step_method_S_0058;
          when step_method_S_0058 => 
            step_method <= step_method_S_0060;
            step_method <= step_method_S_0060;
          when step_method_S_0060 => 
            step_method <= step_method_S_0061;
            step_method <= step_method_S_0061;
          when step_method_S_0061 => 
            if tmp_0218 = '1' then
              step_method <= step_method_S_0063;
            elsif tmp_0219 = '1' then
              step_method <= step_method_S_0065;
            end if;
          when step_method_S_0063 => 
            step_method <= step_method_S_0085;
            step_method <= step_method_S_0085;
          when step_method_S_0065 => 
            step_method <= step_method_S_0141;
            step_method <= step_method_S_0141;
          when step_method_S_0141 => 
            step_method <= step_method_S_0142;
            step_method <= step_method_S_0142;
          when step_method_S_0142 => 
            step_method <= step_method_S_0066;
            step_method <= step_method_S_0066;
          when step_method_S_0066 => 
            step_method <= step_method_S_0067;
            step_method <= step_method_S_0067;
          when step_method_S_0067 => 
            step_method <= step_method_S_0068;
            step_method <= step_method_S_0068;
          when step_method_S_0068 => 
            if tmp_0220 = '1' then
              step_method <= step_method_S_0070;
            elsif tmp_0221 = '1' then
              step_method <= step_method_S_0074;
            end if;
          when step_method_S_0070 => 
            step_method <= step_method_S_0072;
            step_method <= step_method_S_0072;
            step_method <= step_method_S_0072;
          when step_method_S_0072 => 
            step_method <= step_method_S_0074;
            step_method <= step_method_S_0074;
          when step_method_S_0074 => 
            step_method <= step_method_S_0143;
            step_method <= step_method_S_0143;
          when step_method_S_0143 => 
            step_method <= step_method_S_0144;
            step_method <= step_method_S_0144;
          when step_method_S_0144 => 
            step_method <= step_method_S_0075;
            step_method <= step_method_S_0075;
          when step_method_S_0075 => 
            step_method <= step_method_S_0076;
            step_method <= step_method_S_0076;
          when step_method_S_0076 => 
            step_method <= step_method_S_0077;
            step_method <= step_method_S_0077;
          when step_method_S_0077 => 
            if tmp_0222 = '1' then
              step_method <= step_method_S_0079;
            elsif tmp_0223 = '1' then
              step_method <= step_method_S_0051;
            end if;
          when step_method_S_0079 => 
            step_method <= step_method_S_0081;
            step_method <= step_method_S_0081;
            step_method <= step_method_S_0081;
          when step_method_S_0081 => 
            step_method <= step_method_S_0051;
            step_method <= step_method_S_0051;
          when step_method_S_0085 => 
            step_method <= step_method_S_0124;
            step_method <= step_method_S_0124;
          when step_method_S_0087 => 
            step_method <= step_method_S_0087_body;
          when step_method_S_0088 => 
            step_method <= step_method_S_0090;
            step_method <= step_method_S_0090;
            step_method <= step_method_S_0090;
          when step_method_S_0090 => 
            step_method <= step_method_S_0124;
            step_method <= step_method_S_0124;
          when step_method_S_0092 => 
            step_method <= step_method_S_0145;
            step_method <= step_method_S_0145;
          when step_method_S_0145 => 
            step_method <= step_method_S_0146;
            step_method <= step_method_S_0146;
          when step_method_S_0146 => 
            step_method <= step_method_S_0093;
            step_method <= step_method_S_0093;
          when step_method_S_0093 => 
            step_method <= step_method_S_0093_body;
          when step_method_S_0094 => 
            step_method <= step_method_S_0124;
            step_method <= step_method_S_0124;
          when step_method_S_0096 => 
            step_method <= step_method_S_0147;
            step_method <= step_method_S_0147;
          when step_method_S_0147 => 
            step_method <= step_method_S_0148;
            step_method <= step_method_S_0148;
          when step_method_S_0148 => 
            step_method <= step_method_S_0097;
            step_method <= step_method_S_0097;
          when step_method_S_0097 => 
            step_method <= step_method_S_0098;
            step_method <= step_method_S_0098;
          when step_method_S_0098 => 
            step_method <= step_method_S_0099;
            step_method <= step_method_S_0099;
          when step_method_S_0099 => 
            step_method <= step_method_S_0100;
            step_method <= step_method_S_0100;
          when step_method_S_0100 => 
            step_method <= step_method_S_0102;
            step_method <= step_method_S_0102;
            step_method <= step_method_S_0102;
          when step_method_S_0102 => 
            step_method <= step_method_S_0124;
            step_method <= step_method_S_0124;
          when step_method_S_0104 => 
            step_method <= step_method_S_0149;
            step_method <= step_method_S_0149;
          when step_method_S_0149 => 
            step_method <= step_method_S_0150;
            step_method <= step_method_S_0150;
          when step_method_S_0150 => 
            step_method <= step_method_S_0105;
            step_method <= step_method_S_0105;
          when step_method_S_0105 => 
            step_method <= step_method_S_0106;
            step_method <= step_method_S_0106;
          when step_method_S_0106 => 
            step_method <= step_method_S_0107;
            step_method <= step_method_S_0107;
          when step_method_S_0107 => 
            step_method <= step_method_S_0108;
            step_method <= step_method_S_0108;
          when step_method_S_0108 => 
            step_method <= step_method_S_0110;
            step_method <= step_method_S_0110;
            step_method <= step_method_S_0110;
          when step_method_S_0110 => 
            step_method <= step_method_S_0124;
            step_method <= step_method_S_0124;
          when step_method_S_0112 => 
            step_method <= step_method_S_0113;
            step_method <= step_method_S_0113;
          when step_method_S_0113 => 
            step_method <= step_method_S_0114;
            step_method <= step_method_S_0114;
          when step_method_S_0114 => 
            step_method <= step_method_S_0115;
            step_method <= step_method_S_0115;
          when step_method_S_0115 => 
            step_method <= step_method_S_0124;
            step_method <= step_method_S_0124;
          when step_method_S_0117 => 
            step_method <= step_method_S_0118;
            step_method <= step_method_S_0118;
          when step_method_S_0118 => 
            step_method <= step_method_S_0119;
            step_method <= step_method_S_0119;
          when step_method_S_0119 => 
            step_method <= step_method_S_0120;
            step_method <= step_method_S_0120;
          when step_method_S_0120 => 
            step_method <= step_method_S_0124;
            step_method <= step_method_S_0124;
          when step_method_S_0122 => 
            step_method <= step_method_S_0000;
          when step_method_S_0124 => 
            step_method <= step_method_S_0126;
            step_method <= step_method_S_0126;
            step_method <= step_method_S_0126;
          when step_method_S_0126 => 
            step_method <= step_method_S_0127;
            step_method <= step_method_S_0127;
          when step_method_S_0127 => 
            step_method <= step_method_S_0000;
          when step_method_S_0087_body => 
            step_method <= step_method_S_0087_wait;
          when step_method_S_0087_wait => 
            if class_io_0004_getchar_ext_call_flag_0087 = '1' then
              step_method <= step_method_S_0088;
            end if;
          when step_method_S_0093_body => 
            step_method <= step_method_S_0093_wait;
          when step_method_S_0093_wait => 
            if class_io_0004_putchar_ext_call_flag_0093 = '1' then
              step_method <= step_method_S_0094;
            end if;
          when others => null;
        end case;
        step_req_flag_d <= step_req_flag;
        if (tmp_0232 and tmp_0234) = '1' then
          step_method <= step_method_S_0001;
        end if;
      end if;
    end if;
  end process;


  class_io_0004_clk <= clk_sig;

  class_io_0004_reset <= reset_sig;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_io_0004_putchar_c <= (others => '0');
      else
        if startup_method = startup_method_S_0002_body and startup_method_delay = 0 then
          class_io_0004_putchar_c <= X"0a";
        elsif startup_method = startup_method_S_0003_body and startup_method_delay = 0 then
          class_io_0004_putchar_c <= X"42";
        elsif startup_method = startup_method_S_0004_body and startup_method_delay = 0 then
          class_io_0004_putchar_c <= X"72";
        elsif startup_method = startup_method_S_0005_body and startup_method_delay = 0 then
          class_io_0004_putchar_c <= X"61";
        elsif startup_method = startup_method_S_0006_body and startup_method_delay = 0 then
          class_io_0004_putchar_c <= X"69";
        elsif startup_method = startup_method_S_0007_body and startup_method_delay = 0 then
          class_io_0004_putchar_c <= X"6e";
        elsif startup_method = startup_method_S_0008_body and startup_method_delay = 0 then
          class_io_0004_putchar_c <= X"66";
        elsif startup_method = startup_method_S_0009_body and startup_method_delay = 0 then
          class_io_0004_putchar_c <= X"2a";
        elsif startup_method = startup_method_S_0010_body and startup_method_delay = 0 then
          class_io_0004_putchar_c <= X"2a";
        elsif startup_method = startup_method_S_0011_body and startup_method_delay = 0 then
          class_io_0004_putchar_c <= X"6b";
        elsif startup_method = startup_method_S_0012_body and startup_method_delay = 0 then
          class_io_0004_putchar_c <= X"0a";
        elsif prompt_method = prompt_method_S_0002_body and prompt_method_delay = 0 then
          class_io_0004_putchar_c <= X"3e";
        elsif prompt_method = prompt_method_S_0003_body and prompt_method_delay = 0 then
          class_io_0004_putchar_c <= X"20";
        elsif print_method = print_method_S_0019_body and print_method_delay = 0 then
          class_io_0004_putchar_c <= print_b_0081;
        elsif print_method = print_method_S_0021_body and print_method_delay = 0 then
          class_io_0004_putchar_c <= X"0a";
        elsif put_hex_method = put_hex_method_S_0017_body and put_hex_method_delay = 0 then
          class_io_0004_putchar_c <= cast_expr_00109;
        elsif put_hex_method = put_hex_method_S_0023_body and put_hex_method_delay = 0 then
          class_io_0004_putchar_c <= cast_expr_00116;
        elsif put_hex_method = put_hex_method_S_0040_body and put_hex_method_delay = 0 then
          class_io_0004_putchar_c <= cast_expr_00135;
        elsif put_hex_method = put_hex_method_S_0046_body and put_hex_method_delay = 0 then
          class_io_0004_putchar_c <= cast_expr_00142;
        elsif put_hex_method = put_hex_method_S_0048_body and put_hex_method_delay = 0 then
          class_io_0004_putchar_c <= X"0a";
        elsif step_method = step_method_S_0093_body and step_method_delay = 0 then
          class_io_0004_putchar_c <= array_access_00230;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_io_0004_putchar_req <= '0';
      else
        if startup_method = startup_method_S_0002_body then
          class_io_0004_putchar_req <= '1';
        elsif startup_method = startup_method_S_0003_body then
          class_io_0004_putchar_req <= '1';
        elsif startup_method = startup_method_S_0004_body then
          class_io_0004_putchar_req <= '1';
        elsif startup_method = startup_method_S_0005_body then
          class_io_0004_putchar_req <= '1';
        elsif startup_method = startup_method_S_0006_body then
          class_io_0004_putchar_req <= '1';
        elsif startup_method = startup_method_S_0007_body then
          class_io_0004_putchar_req <= '1';
        elsif startup_method = startup_method_S_0008_body then
          class_io_0004_putchar_req <= '1';
        elsif startup_method = startup_method_S_0009_body then
          class_io_0004_putchar_req <= '1';
        elsif startup_method = startup_method_S_0010_body then
          class_io_0004_putchar_req <= '1';
        elsif startup_method = startup_method_S_0011_body then
          class_io_0004_putchar_req <= '1';
        elsif startup_method = startup_method_S_0012_body then
          class_io_0004_putchar_req <= '1';
        elsif prompt_method = prompt_method_S_0002_body then
          class_io_0004_putchar_req <= '1';
        elsif prompt_method = prompt_method_S_0003_body then
          class_io_0004_putchar_req <= '1';
        elsif print_method = print_method_S_0019_body then
          class_io_0004_putchar_req <= '1';
        elsif print_method = print_method_S_0021_body then
          class_io_0004_putchar_req <= '1';
        elsif put_hex_method = put_hex_method_S_0017_body then
          class_io_0004_putchar_req <= '1';
        elsif put_hex_method = put_hex_method_S_0023_body then
          class_io_0004_putchar_req <= '1';
        elsif put_hex_method = put_hex_method_S_0040_body then
          class_io_0004_putchar_req <= '1';
        elsif put_hex_method = put_hex_method_S_0046_body then
          class_io_0004_putchar_req <= '1';
        elsif put_hex_method = put_hex_method_S_0048_body then
          class_io_0004_putchar_req <= '1';
        elsif step_method = step_method_S_0093_body then
          class_io_0004_putchar_req <= '1';
        else
          class_io_0004_putchar_req <= '0';
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_io_0004_getchar_req <= '0';
      else
        if read_method = read_method_S_0011_body then
          class_io_0004_getchar_req <= '1';
        elsif step_method = step_method_S_0087_body then
          class_io_0004_getchar_req <= '1';
        else
          class_io_0004_getchar_req <= '0';
        end if;
      end if;
    end if;
  end process;

  class_prog_0006_clk <= clk_sig;

  class_prog_0006_reset <= reset_sig;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_prog_0006_address_b <= (others => '0');
      else
        if read_method = read_method_S_0020 then
          class_prog_0006_address_b <= read_i_0054;
        elsif read_method = read_method_S_0024 then
          class_prog_0006_address_b <= read_i_0054;
        elsif print_method = print_method_S_0011 then
          class_prog_0006_address_b <= print_i_0075;
        elsif step_method = step_method_S_0002 then
          class_prog_0006_address_b <= class_pc_0013;
        elsif step_method = step_method_S_0014 then
          class_prog_0006_address_b <= class_pc_0013;
        elsif step_method = step_method_S_0023 then
          class_prog_0006_address_b <= class_pc_0013;
        elsif step_method = step_method_S_0032 then
          class_prog_0006_address_b <= class_pc_0013;
        elsif step_method = step_method_S_0056 then
          class_prog_0006_address_b <= class_pc_0013;
        elsif step_method = step_method_S_0065 then
          class_prog_0006_address_b <= class_pc_0013;
        elsif step_method = step_method_S_0074 then
          class_prog_0006_address_b <= class_pc_0013;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_prog_0006_din_b <= (others => '0');
      else
        if read_method = read_method_S_0020 then
          class_prog_0006_din_b <= X"00";
        elsif read_method = read_method_S_0024 then
          class_prog_0006_din_b <= read_b_0060;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_prog_0006_we_b <= '0';
      else
        if read_method = read_method_S_0020 then
          class_prog_0006_we_b <= '1';
        elsif read_method = read_method_S_0024 then
          class_prog_0006_we_b <= '1';
        else
          class_prog_0006_we_b <= '0';
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_prog_0006_oe_b <= '0';
      else
        if print_method = print_method_S_0024 and print_method_delay = 0 then
          class_prog_0006_oe_b <= '1';
        elsif step_method = step_method_S_0130 and step_method_delay = 0 then
          class_prog_0006_oe_b <= '1';
        elsif step_method = step_method_S_0132 and step_method_delay = 0 then
          class_prog_0006_oe_b <= '1';
        elsif step_method = step_method_S_0134 and step_method_delay = 0 then
          class_prog_0006_oe_b <= '1';
        elsif step_method = step_method_S_0136 and step_method_delay = 0 then
          class_prog_0006_oe_b <= '1';
        elsif step_method = step_method_S_0140 and step_method_delay = 0 then
          class_prog_0006_oe_b <= '1';
        elsif step_method = step_method_S_0142 and step_method_delay = 0 then
          class_prog_0006_oe_b <= '1';
        elsif step_method = step_method_S_0144 and step_method_delay = 0 then
          class_prog_0006_oe_b <= '1';
        else
          class_prog_0006_oe_b <= '0';
        end if;
      end if;
    end if;
  end process;

  class_data_0009_clk <= clk_sig;

  class_data_0009_reset <= reset_sig;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_data_0009_address_b <= (others => '0');
      else
        if init_method = init_method_S_0012 then
          class_data_0009_address_b <= init_i_0148;
        elsif step_method = step_method_S_0047 then
          class_data_0009_address_b <= class_ptr_0012;
        elsif step_method = step_method_S_0088 then
          class_data_0009_address_b <= class_ptr_0012;
        elsif step_method = step_method_S_0092 then
          class_data_0009_address_b <= class_ptr_0012;
        elsif step_method = step_method_S_0096 then
          class_data_0009_address_b <= class_ptr_0012;
        elsif step_method = step_method_S_0100 then
          class_data_0009_address_b <= class_ptr_0012;
        elsif step_method = step_method_S_0104 then
          class_data_0009_address_b <= class_ptr_0012;
        elsif step_method = step_method_S_0108 then
          class_data_0009_address_b <= class_ptr_0012;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_data_0009_din_b <= (others => '0');
      else
        if init_method = init_method_S_0012 then
          class_data_0009_din_b <= X"00";
        elsif step_method = step_method_S_0088 then
          class_data_0009_din_b <= method_result_00227;
        elsif step_method = step_method_S_0100 then
          class_data_0009_din_b <= cast_expr_00235;
        elsif step_method = step_method_S_0108 then
          class_data_0009_din_b <= cast_expr_00241;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_data_0009_we_b <= '0';
      else
        if init_method = init_method_S_0012 then
          class_data_0009_we_b <= '1';
        elsif step_method = step_method_S_0088 then
          class_data_0009_we_b <= '1';
        elsif step_method = step_method_S_0100 then
          class_data_0009_we_b <= '1';
        elsif step_method = step_method_S_0108 then
          class_data_0009_we_b <= '1';
        else
          class_data_0009_we_b <= '0';
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_data_0009_oe_b <= '0';
      else
        if step_method = step_method_S_0138 and step_method_delay = 0 then
          class_data_0009_oe_b <= '1';
        elsif step_method = step_method_S_0146 and step_method_delay = 0 then
          class_data_0009_oe_b <= '1';
        elsif step_method = step_method_S_0148 and step_method_delay = 0 then
          class_data_0009_oe_b <= '1';
        elsif step_method = step_method_S_0150 and step_method_delay = 0 then
          class_data_0009_oe_b <= '1';
        else
          class_data_0009_oe_b <= '0';
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_ptr_0012 <= (others => '0');
      else
        if init_method = init_method_S_0002 then
          class_ptr_0012 <= X"00000000";
        elsif step_method = step_method_S_0114 then
          class_ptr_0012 <= unary_expr_00243;
        elsif step_method = step_method_S_0119 then
          class_ptr_0012 <= unary_expr_00246;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        class_pc_0013 <= (others => '0');
      else
        if init_method = init_method_S_0002 then
          class_pc_0013 <= X"00000000";
        elsif step_method = step_method_S_0013 then
          class_pc_0013 <= unary_expr_00171;
        elsif step_method = step_method_S_0044 then
          class_pc_0013 <= unary_expr_00195;
        elsif step_method = step_method_S_0055 then
          class_pc_0013 <= unary_expr_00203;
        elsif step_method = step_method_S_0126 then
          class_pc_0013 <= unary_expr_00250;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        read_i_0054 <= X"00000000";
      else
        if read_method = read_method_S_0003 then
          read_i_0054 <= X"00000000";
        elsif read_method = read_method_S_0009 then
          read_i_0054 <= unary_expr_00057;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00056 <= '0';
      else
        if read_method = read_method_S_0004 then
          binary_expr_00056 <= tmp_0086;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_00057 <= (others => '0');
      else
        if read_method = read_method_S_0007 then
          unary_expr_00057 <= tmp_0087;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_postfix_preserved_00058 <= (others => '0');
      else
        if read_method = read_method_S_0007 then
          unary_expr_postfix_preserved_00058 <= read_i_0054;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        read_b_0060 <= (others => '0');
      else
        if read_method = read_method_S_0012 then
          read_b_0060 <= method_result_00061;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        method_result_00061 <= (others => '0');
      else
        if read_method = read_method_S_0011_wait then
          method_result_00061 <= class_io_0004_getchar_return;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00063 <= (others => '0');
      else
        if read_method = read_method_S_0013 then
          cast_expr_00063 <= std_logic_vector(tmp_0088);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00064 <= '0';
      else
        if read_method = read_method_S_0014 then
          binary_expr_00064 <= tmp_0090;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00066 <= (others => '0');
      else
        if read_method = read_method_S_0013 then
          cast_expr_00066 <= std_logic_vector(tmp_0089);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00067 <= '0';
      else
        if read_method = read_method_S_0014 then
          binary_expr_00067 <= tmp_0091;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00068 <= '0';
      else
        if read_method = read_method_S_0017 then
          binary_expr_00068 <= tmp_0092;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        print_flag_0073 <= '1';
      else
        if print_method = print_method_S_0002 then
          print_flag_0073 <= '1';
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        print_i_0075 <= X"00000000";
      else
        if print_method = print_method_S_0002 then
          print_i_0075 <= X"00000000";
        elsif print_method = print_method_S_0009 then
          print_i_0075 <= unary_expr_00078;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00077 <= '0';
      else
        if print_method = print_method_S_0004 then
          binary_expr_00077 <= tmp_0113;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_00078 <= (others => '0');
      else
        if print_method = print_method_S_0007 then
          unary_expr_00078 <= tmp_0114;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_postfix_preserved_00079 <= (others => '0');
      else
        if print_method = print_method_S_0007 then
          unary_expr_postfix_preserved_00079 <= print_i_0075;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        print_b_0081 <= (others => '0');
      else
        if print_method = print_method_S_0012 then
          print_b_0081 <= array_access_00082;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        array_access_00082 <= (others => '0');
      else
        if print_method = print_method_S_0024 then
          array_access_00082 <= class_prog_0006_dout_b;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00084 <= (others => '0');
      else
        if print_method = print_method_S_0013 then
          cast_expr_00084 <= tmp_0115;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00085 <= '0';
      else
        if print_method = print_method_S_0014 then
          binary_expr_00085 <= tmp_0116;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        put_hex_b_0090 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0001 then
          put_hex_b_0090 <= put_hex_b_local;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        put_hex_h_0091 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0006 then
          put_hex_h_0091 <= cast_expr_00097;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00093 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0002 then
          cast_expr_00093 <= tmp_0149;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00094 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0003 then
          binary_expr_00094 <= tmp_0150;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00096 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0004 then
          binary_expr_00096 <= tmp_0151;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00097 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0005 then
          cast_expr_00097 <= tmp_0152;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00099 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0007 then
          cast_expr_00099 <= tmp_0153;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00100 <= '0';
      else
        if put_hex_method = put_hex_method_S_0008 then
          binary_expr_00100 <= tmp_0155;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00102 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0007 then
          cast_expr_00102 <= tmp_0154;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00103 <= '0';
      else
        if put_hex_method = put_hex_method_S_0008 then
          binary_expr_00103 <= tmp_0156;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00104 <= '0';
      else
        if put_hex_method = put_hex_method_S_0011 then
          binary_expr_00104 <= tmp_0157;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00107 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0014 then
          cast_expr_00107 <= std_logic_vector(tmp_0158);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00108 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0015 then
          binary_expr_00108 <= tmp_0159;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00109 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0016 then
          cast_expr_00109 <= signed(tmp_0160);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00112 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0019 then
          cast_expr_00112 <= tmp_0161;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00113 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0020 then
          binary_expr_00113 <= tmp_0162;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00115 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0021 then
          binary_expr_00115 <= tmp_0163;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00116 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0022 then
          cast_expr_00116 <= tmp_0164;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        put_hex_l_0117 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0029 then
          put_hex_l_0117 <= cast_expr_00123;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00119 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0025 then
          cast_expr_00119 <= tmp_0165;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00120 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0026 then
          binary_expr_00120 <= tmp_0167;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00122 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0027 then
          binary_expr_00122 <= tmp_0169;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00123 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0028 then
          cast_expr_00123 <= tmp_0170;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00125 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0025 then
          cast_expr_00125 <= tmp_0166;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00126 <= '0';
      else
        if put_hex_method = put_hex_method_S_0026 then
          binary_expr_00126 <= tmp_0168;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00128 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0032 then
          cast_expr_00128 <= tmp_0171;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00129 <= '0';
      else
        if put_hex_method = put_hex_method_S_0033 then
          binary_expr_00129 <= tmp_0172;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00130 <= '0';
      else
        if put_hex_method = put_hex_method_S_0034 then
          binary_expr_00130 <= tmp_0173;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00133 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0037 then
          cast_expr_00133 <= std_logic_vector(tmp_0174);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00134 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0038 then
          binary_expr_00134 <= tmp_0175;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00135 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0039 then
          cast_expr_00135 <= signed(tmp_0176);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00138 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0042 then
          cast_expr_00138 <= tmp_0177;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00139 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0043 then
          binary_expr_00139 <= tmp_0178;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00141 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0044 then
          binary_expr_00141 <= tmp_0179;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00142 <= (others => '0');
      else
        if put_hex_method = put_hex_method_S_0045 then
          cast_expr_00142 <= tmp_0180;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        init_i_0148 <= X"00000000";
      else
        if init_method = init_method_S_0002 then
          init_i_0148 <= X"00000000";
        elsif init_method = init_method_S_0010 then
          init_i_0148 <= unary_expr_00151;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00150 <= '0';
      else
        if init_method = init_method_S_0005 then
          binary_expr_00150 <= tmp_0191;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_00151 <= (others => '0');
      else
        if init_method = init_method_S_0008 then
          unary_expr_00151 <= tmp_0192;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_postfix_preserved_00152 <= (others => '0');
      else
        if init_method = init_method_S_0008 then
          unary_expr_postfix_preserved_00152 <= init_i_0148;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        step_cmd_0156 <= (others => '0');
      else
        if step_method = step_method_S_0003 then
          step_cmd_0156 <= array_access_00157;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        array_access_00157 <= (others => '0');
      else
        if step_method = step_method_S_0130 then
          array_access_00157 <= class_prog_0006_dout_b;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        step_nlvl_0159 <= X"00000000";
      else
        if step_method = step_method_S_0003 then
          step_nlvl_0159 <= X"00000000";
        elsif step_method = step_method_S_0030 then
          step_nlvl_0159 <= unary_expr_00185;
        elsif step_method = step_method_S_0039 then
          step_nlvl_0159 <= unary_expr_00192;
        elsif step_method = step_method_S_0072 then
          step_nlvl_0159 <= unary_expr_00217;
        elsif step_method = step_method_S_0081 then
          step_nlvl_0159 <= unary_expr_00224;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_00171 <= (others => '0');
      else
        if step_method = step_method_S_0011 then
          unary_expr_00171 <= tmp_0236;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_postfix_preserved_00172 <= (others => '0');
      else
        if step_method = step_method_S_0011 then
          unary_expr_postfix_preserved_00172 <= class_pc_0013;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        array_access_00174 <= (others => '0');
      else
        if step_method = step_method_S_0132 then
          array_access_00174 <= class_prog_0006_dout_b;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00176 <= (others => '0');
      else
        if step_method = step_method_S_0015 then
          cast_expr_00176 <= std_logic_vector(tmp_0237);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00177 <= '0';
      else
        if step_method = step_method_S_0016 then
          binary_expr_00177 <= tmp_0239;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00179 <= '0';
      else
        if step_method = step_method_S_0015 then
          binary_expr_00179 <= tmp_0238;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00180 <= '0';
      else
        if step_method = step_method_S_0018 then
          binary_expr_00180 <= tmp_0240;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        array_access_00181 <= (others => '0');
      else
        if step_method = step_method_S_0134 then
          array_access_00181 <= class_prog_0006_dout_b;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00183 <= (others => '0');
      else
        if step_method = step_method_S_0024 then
          cast_expr_00183 <= std_logic_vector(tmp_0241);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00184 <= '0';
      else
        if step_method = step_method_S_0025 then
          binary_expr_00184 <= tmp_0242;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_00185 <= (others => '0');
      else
        if step_method = step_method_S_0028 then
          unary_expr_00185 <= tmp_0243;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_postfix_preserved_00186 <= (others => '0');
      else
        if step_method = step_method_S_0028 then
          unary_expr_postfix_preserved_00186 <= step_nlvl_0159;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        array_access_00188 <= (others => '0');
      else
        if step_method = step_method_S_0136 then
          array_access_00188 <= class_prog_0006_dout_b;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00190 <= (others => '0');
      else
        if step_method = step_method_S_0033 then
          cast_expr_00190 <= std_logic_vector(tmp_0244);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00191 <= '0';
      else
        if step_method = step_method_S_0034 then
          binary_expr_00191 <= tmp_0245;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_00192 <= (others => '0');
      else
        if step_method = step_method_S_0037 then
          unary_expr_00192 <= tmp_0246;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_postfix_preserved_00193 <= (others => '0');
      else
        if step_method = step_method_S_0037 then
          unary_expr_postfix_preserved_00193 <= step_nlvl_0159;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_00195 <= (others => '0');
      else
        if step_method = step_method_S_0042 then
          unary_expr_00195 <= tmp_0247;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_postfix_preserved_00196 <= (others => '0');
      else
        if step_method = step_method_S_0042 then
          unary_expr_postfix_preserved_00196 <= class_pc_0013;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        array_access_00198 <= (others => '0');
      else
        if step_method = step_method_S_0138 then
          array_access_00198 <= class_data_0009_dout_b;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00201 <= '0';
      else
        if step_method = step_method_S_0048 then
          binary_expr_00201 <= tmp_0248;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_00203 <= (others => '0');
      else
        if step_method = step_method_S_0053 then
          unary_expr_00203 <= tmp_0249;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_postfix_preserved_00204 <= (others => '0');
      else
        if step_method = step_method_S_0053 then
          unary_expr_postfix_preserved_00204 <= class_pc_0013;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        array_access_00206 <= (others => '0');
      else
        if step_method = step_method_S_0140 then
          array_access_00206 <= class_prog_0006_dout_b;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00208 <= (others => '0');
      else
        if step_method = step_method_S_0057 then
          cast_expr_00208 <= std_logic_vector(tmp_0250);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00209 <= '0';
      else
        if step_method = step_method_S_0058 then
          binary_expr_00209 <= tmp_0252;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00211 <= '0';
      else
        if step_method = step_method_S_0057 then
          binary_expr_00211 <= tmp_0251;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00212 <= '0';
      else
        if step_method = step_method_S_0060 then
          binary_expr_00212 <= tmp_0253;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        array_access_00213 <= (others => '0');
      else
        if step_method = step_method_S_0142 then
          array_access_00213 <= class_prog_0006_dout_b;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00215 <= (others => '0');
      else
        if step_method = step_method_S_0066 then
          cast_expr_00215 <= std_logic_vector(tmp_0254);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00216 <= '0';
      else
        if step_method = step_method_S_0067 then
          binary_expr_00216 <= tmp_0255;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_00217 <= (others => '0');
      else
        if step_method = step_method_S_0070 then
          unary_expr_00217 <= tmp_0256;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_postfix_preserved_00218 <= (others => '0');
      else
        if step_method = step_method_S_0070 then
          unary_expr_postfix_preserved_00218 <= step_nlvl_0159;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        array_access_00220 <= (others => '0');
      else
        if step_method = step_method_S_0144 then
          array_access_00220 <= class_prog_0006_dout_b;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00222 <= (others => '0');
      else
        if step_method = step_method_S_0075 then
          cast_expr_00222 <= std_logic_vector(tmp_0257);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00223 <= '0';
      else
        if step_method = step_method_S_0076 then
          binary_expr_00223 <= tmp_0258;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_00224 <= (others => '0');
      else
        if step_method = step_method_S_0079 then
          unary_expr_00224 <= tmp_0259;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_postfix_preserved_00225 <= (others => '0');
      else
        if step_method = step_method_S_0079 then
          unary_expr_postfix_preserved_00225 <= step_nlvl_0159;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        method_result_00227 <= (others => '0');
      else
        if step_method = step_method_S_0087_wait then
          method_result_00227 <= class_io_0004_getchar_return;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        array_access_00230 <= (others => '0');
      else
        if step_method = step_method_S_0146 then
          array_access_00230 <= class_data_0009_dout_b;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        array_access_00231 <= (others => '0');
      else
        if step_method = step_method_S_0148 then
          array_access_00231 <= class_data_0009_dout_b;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00233 <= (others => '0');
      else
        if step_method = step_method_S_0097 then
          cast_expr_00233 <= tmp_0260;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00234 <= (others => '0');
      else
        if step_method = step_method_S_0098 then
          binary_expr_00234 <= tmp_0261;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00235 <= (others => '0');
      else
        if step_method = step_method_S_0099 then
          cast_expr_00235 <= tmp_0262;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        array_access_00237 <= (others => '0');
      else
        if step_method = step_method_S_0150 then
          array_access_00237 <= class_data_0009_dout_b;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00239 <= (others => '0');
      else
        if step_method = step_method_S_0105 then
          cast_expr_00239 <= tmp_0263;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        binary_expr_00240 <= (others => '0');
      else
        if step_method = step_method_S_0106 then
          binary_expr_00240 <= tmp_0264;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cast_expr_00241 <= (others => '0');
      else
        if step_method = step_method_S_0107 then
          cast_expr_00241 <= tmp_0265;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_00243 <= (others => '0');
      else
        if step_method = step_method_S_0113 then
          unary_expr_00243 <= tmp_0266;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_postfix_preserved_00244 <= (others => '0');
      else
        if step_method = step_method_S_0112 then
          unary_expr_postfix_preserved_00244 <= class_ptr_0012;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_00246 <= (others => '0');
      else
        if step_method = step_method_S_0118 then
          unary_expr_00246 <= tmp_0267;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_postfix_preserved_00247 <= (others => '0');
      else
        if step_method = step_method_S_0117 then
          unary_expr_postfix_preserved_00247 <= class_ptr_0012;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_00250 <= (others => '0');
      else
        if step_method = step_method_S_0124 then
          unary_expr_00250 <= tmp_0268;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        unary_expr_postfix_preserved_00251 <= (others => '0');
      else
        if step_method = step_method_S_0124 then
          unary_expr_postfix_preserved_00251 <= class_pc_0013;
        end if;
      end if;
    end if;
  end process;

  startup_req_flag <= tmp_0001;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        prompt_busy <= '0';
      else
        if prompt_method = prompt_method_S_0000 then
          prompt_busy <= '0';
        elsif prompt_method = prompt_method_S_0001 then
          prompt_busy <= tmp_0061;
        end if;
      end if;
    end if;
  end process;

  prompt_req_flag <= prompt_req_local;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        prompt_req_local <= '0';
      else
        if read_method = read_method_S_0002_body then
          prompt_req_local <= '1';
        else
          prompt_req_local <= '0';
        end if;
      end if;
    end if;
  end process;

  read_req_flag <= tmp_0002;

  print_req_flag <= tmp_0003;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        put_hex_busy <= '0';
      else
        if put_hex_method = put_hex_method_S_0000 then
          put_hex_busy <= '0';
        elsif put_hex_method = put_hex_method_S_0001 then
          put_hex_busy <= tmp_0120;
        end if;
      end if;
    end if;
  end process;

  put_hex_req_flag <= put_hex_req_local;

  init_req_flag <= tmp_0004;

  step_req_flag <= tmp_0005;

  startup_req_flag_edge <= tmp_0007;

  class_io_0004_putchar_ext_call_flag_0002 <= tmp_0013;

  class_io_0004_putchar_ext_call_flag_0003 <= tmp_0017;

  class_io_0004_putchar_ext_call_flag_0004 <= tmp_0021;

  class_io_0004_putchar_ext_call_flag_0005 <= tmp_0025;

  class_io_0004_putchar_ext_call_flag_0006 <= tmp_0029;

  class_io_0004_putchar_ext_call_flag_0007 <= tmp_0033;

  class_io_0004_putchar_ext_call_flag_0008 <= tmp_0037;

  class_io_0004_putchar_ext_call_flag_0009 <= tmp_0041;

  class_io_0004_putchar_ext_call_flag_0010 <= tmp_0045;

  class_io_0004_putchar_ext_call_flag_0011 <= tmp_0049;

  class_io_0004_putchar_ext_call_flag_0012 <= tmp_0053;

  prompt_req_flag_edge <= tmp_0059;

  read_req_flag_edge <= tmp_0067;

  prompt_call_flag_0002 <= tmp_0073;

  class_io_0004_getchar_ext_call_flag_0011 <= tmp_0079;

  print_req_flag_edge <= tmp_0094;

  class_io_0004_putchar_ext_call_flag_0019 <= tmp_0104;

  class_io_0004_putchar_ext_call_flag_0021 <= tmp_0108;

  put_hex_req_flag_edge <= tmp_0118;

  class_io_0004_putchar_ext_call_flag_0017 <= tmp_0126;

  class_io_0004_putchar_ext_call_flag_0023 <= tmp_0130;

  class_io_0004_putchar_ext_call_flag_0040 <= tmp_0136;

  class_io_0004_putchar_ext_call_flag_0046 <= tmp_0140;

  class_io_0004_putchar_ext_call_flag_0048 <= tmp_0144;

  init_req_flag_edge <= tmp_0182;

  step_req_flag_edge <= tmp_0194;

  class_io_0004_getchar_ext_call_flag_0087 <= tmp_0227;

  class_io_0004_putchar_ext_call_flag_0093 <= tmp_0231;


  inst_class_io_0004 : IO
  port map(
    clk => clk,
    reset => reset,
    putchar_c => class_io_0004_putchar_c,
    putchar_busy => class_io_0004_putchar_busy,
    putchar_req => class_io_0004_putchar_req,
    getchar_return => class_io_0004_getchar_return,
    getchar_busy => class_io_0004_getchar_busy,
    getchar_req => class_io_0004_getchar_req,
    obj_tx_dout_exp => io_obj_tx_dout_exp,
    obj_rx_din_exp => io_obj_rx_din_exp
  );

  inst_class_prog_0006 : singleportram
  generic map(
    WIDTH => 8,
    DEPTH => 14,
    WORDS => 10000
  )
  port map(
    clk => clk,
    reset => reset,
    length => class_prog_0006_length,
    address_b => class_prog_0006_address_b,
    din_b => class_prog_0006_din_b,
    dout_b => class_prog_0006_dout_b,
    we_b => class_prog_0006_we_b,
    oe_b => class_prog_0006_oe_b
  );

  inst_class_data_0009 : singleportram
  generic map(
    WIDTH => 8,
    DEPTH => 14,
    WORDS => 10000
  )
  port map(
    clk => clk,
    reset => reset,
    length => class_data_0009_length,
    address_b => class_data_0009_address_b,
    din_b => class_data_0009_din_b,
    dout_b => class_data_0009_dout_b,
    we_b => class_data_0009_we_b,
    oe_b => class_data_0009_oe_b
  );


end RTL;
