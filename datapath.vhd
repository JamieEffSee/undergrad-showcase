library ieee;
use ieee.std_logic_1164.all;


entity cpu is
port(	reset_TL 		: in std_logic;
     	clk_TL   		: in std_logic;

      	rs_out, rt_out 		: out std_logic_vector(3 downto 0):= (others => '0');
    	pc_out 			: out std_logic_vector(3 downto 0):= (others => '0');
     
    	overflow_TL, zero_TL 		: out std_logic)	;
end cpu;

architecture toplevel of cpu is

-- -----------------component entities
--  ------ PC --------
component PC_TL
port(	d 		: in std_logic_vector(31 downto 0);
	reset	 	: in std_logic;
	clk 		: in std_logic;

	q		: out std_logic_vector(31 downto 0)	);
end component;

--  ------ IC --------
component IC_TL
port(	add 		: in std_logic_vector(4 downto 0);

	instr		: out std_logic_vector(31 downto 0)	);
end component;

--  ------ REGFILE --------
component REG_TL
port(	din		: 	in std_logic_vector(31 downto 0);
	reset		: 	in std_logic;
	clk		: 	in std_logic;

	write		: 	in std_logic;
	write_address	: 	in std_logic_vector(4 downto 0);

	read_a	 	: 	in std_logic_vector(4 downto 0);
	read_b	 	: 	in std_logic_vector(4 downto 0);

	out_a		: 	out std_logic_vector(31 downto 0);
	out_b		: 	out std_logic_vector(31 downto 0) );
end component;

--  ------ ALU --------
component ALU_TL
port(	x, y		: in std_logic_vector(31 downto 0);
	
	add_sub 	: in std_logic ; -- 0 = add and 1 = sub
	logic_func 	: in std_logic_vector(1 downto 0);
					-- 00 AND; 01 OR; 10 XOR; 11 NOR
	func		: in std_logic_vector(1 downto 0);
					-- 00 lui; 01 setless; 10 arith; 11 logic
	output		: out std_logic_vector(31 downto 0);
	overflow	: out std_logic;
	zero		: out std_logic 	);
end component;

--  ------ DC --------
component DC_TL
port(	d_in		: in std_logic_vector(31 downto 0);		
	add		: in std_logic_vector(4 downto 0);	
	reset		: in std_logic;				
	clk		: in std_logic;				
	data_write	: in std_logic;				

	d_out		: out std_logic_vector(31 downto 0)	);
end component;

--  ------ SIGN EXT --------
component SIGNEX_TL
port(	raw		: in std_logic_vector(15 downto 0);
	func_signex	: in std_logic_vector(1 downto 0);

	extend		: out std_logic_vector(31 downto 0)	);
end component;

--  ------ NEXT_ADDR --------
component NEXTADD_TL
port(	rt, rs		: 	in std_logic_vector(31 downto 0);
	pc		:	in std_logic_vector(31 downto 0);
	target_address	: in std_logic_vector(25 downto 0);
	branch_type	:	in std_logic_vector(1 downto 0);
	pc_sel		:	in std_logic_vector(1 downto 0);
	
	next_pc		:	out std_logic_vector(31 downto 0)	);
end component;

--  -----------------interconnection signals
--  ------ PC --------
signal pc_q_32 : std_logic_vector(31 downto 0);
signal pc_select : std_logic_vector(1 downto 0) := "00";

--  ------ IC --------
signal ic_instr : std_logic_vector(31 downto 0);

--  ------ REGFILE --------
signal reg_add_in: std_logic_vector(4 downto 0) := (others => '0');
signal reg_mux_in: std_logic_vector(31 downto 0);
signal reg_out_a : std_logic_vector(31 downto 0);
signal reg_out_b : std_logic_vector(31 downto 0);
signal reg_write, reg_dst : std_logic := '0';
signal reg_mux_s : std_logic := '0';

--  ------ ALU --------
signal alu_mux_in: std_logic_vector(31 downto 0);
signal alu_output : std_logic_vector(31 downto 0);
signal branch_sig : std_logic_vector(1 downto 0) := "00";
signal alu_func, alu_logic : std_logic_vector(1 downto 0) := "00";
signal addsub_sig : std_logic := '0';
signal alu_mux_s : std_logic := '0';

--  ------ DC --------
signal dc_d_out : std_logic_vector(31 downto 0);
signal dc_write : std_logic := '0';

--  ------ SIGNEX --------
signal se_extend : std_logic_vector(31 downto 0);

--  ------ NEXT_ADDR --------
signal na_next_pc : std_logic_vector(31 downto 0);

--  ------ CONTROL_SIGNALS --------
signal op_ct, func_ct : std_logic_vector(5 downto 0) := (others => '0');
signal cpu_ct : std_logic_vector(13 downto 0); 

-- -----------------declare config specs
for U1 : PC_TL use entity WORK.pcreg(mypcreg);
for U2 : IC_TL use entity WORK.icache(myicache);
for U3 : REG_TL use entity WORK.regfile(myregfile);
for U4 : ALU_TL use entity WORK.alu(myalu);
for U5 : DC_TL use entity WORK.dcache(mydcache);
for U6 : SIGNEX_TL use entity WORK.signex(myextend);
for U7 : NEXTADD_TL use entity WORK.nextaddr(mynxtadd);


-- -----------------concurrent statements
begin -- arch

-- -----------------controller
-- Function: look at opcode and func extend from instruction and generate control signals
-- ---
-- Format is: |sig(bits)| :
-- { reg_write(1) | reg_dst(1) | reg_in_src(1) | alu_src(1) | add_sub(1) | data_write(1) |
-- logic_func(2) | func(2) | branch_type(2) | pc_sel(2) }(14)
-- let "Don't care" signals be set to 0 by default
-- ---
process(ic_instr, clk_TL, reset_TL, op_ct, func_ct, cpu_ct)
begin
	op_ct <= ic_instr(31 downto 26); 	-- opcode
	func_ct <= ic_instr(5 downto 0);	-- func extend

	case op_ct is
		-- ALU arith, logic, j_reg
		when "000000" =>
			if (func_ct = "100000") then
				-- ALU add
				cpu_ct <= "11100000100000";

			elsif (func_ct = "100010") then
				-- ALU subtract
				cpu_ct <= "11101000100000";

			elsif (func_ct = "101010") then
				-- ALU set less than
				cpu_ct <= "11100000010000";

			elsif (func_ct = "100100") then
				-- ALU logical AND
				cpu_ct <= "11101000110000";

			elsif (func_ct = "100101") then
				-- ALU logical OR
				cpu_ct <= "11100001110000";

			elsif (func_ct = "100110") then
				-- ALU logical XOR
				cpu_ct <= "11100010110000";

			elsif (func_ct = "100111") then
				-- ALU logical NOR
				cpu_ct <= "11100011110000";

			elsif (func_ct = "001000") then
				-- ALU JR
				cpu_ct <= "00000000000010";
			else	 
			-- end when: ALU
			end if;
		
		when "000001" =>
			-- branch-less-than-zero
			cpu_ct <= "00000000001100";

		when "000010" =>
			-- unconditional jump
			cpu_ct <= "00000000000001";

		when "000100" =>
			-- branch-on-equal
			cpu_ct <= "00000000000100";

		when "000101" =>
			-- branch-on-not-equal
			cpu_ct <= "00000000001000";

		when "001000" =>
			-- add (immediate)
			cpu_ct <= "10110000100000";

		when "001010" =>
			-- set-less-than (immediate)
			cpu_ct <= "10110000010000";

		when "001100" =>
			-- logical AND (immediate)
			cpu_ct <= "10110000110000";

		when "001101" =>
			-- logical OR (immediate)
			cpu_ct <= "10110001110000";

		when "001110" =>
			-- logical XOR (immediate)
			cpu_ct <= "10110010110000";

		when "001111" =>
			-- load upper intermediate
			cpu_ct <= "10110000000000";

		when "100011" =>
			-- load word (mem)
			cpu_ct <= "10010010100000";

		when "101011" =>
			-- store word (mem)
			cpu_ct <= "00010100100000";

		when others =>
	-- control signals have been generated
	end case;

	-- now link the control signals to the interconnects
	pc_select <= cpu_ct(1 downto 0);
	branch_sig <= cpu_ct(3 downto 2);
	alu_func <= cpu_ct(5 downto 4);
	alu_logic <= cpu_ct(7 downto 6);
	dc_write <= cpu_ct(8);
	addsub_sig <= cpu_ct(9);
	alu_mux_s <= cpu_ct(10);
	reg_mux_s <= cpu_ct(11);
	reg_dst <= cpu_ct(12);
	reg_write <= cpu_ct(13);

end process;
-- end controller


--  -----------------port maps
--  ------ Components --------
U1: PC_TL port map(d => na_next_pc, reset => reset_TL, clk => clk_TL, q => pc_q_32);

U2 : IC_TL port map(add => pc_q_32(4 downto 0), instr => ic_instr);

U3 : REG_TL port map(din => reg_mux_in, reset => reset_TL, clk => clk_TL, write => reg_write,
			write_address => reg_add_in, read_a => ic_instr(25 downto 21),
			read_b => ic_instr(20 downto 16), out_a => reg_out_a, out_b => reg_out_b);

U4 : ALU_TL port map(x => reg_out_a, y => alu_mux_in, add_sub => addsub_sig, logic_func => alu_logic,
			func => alu_func, output => alu_output, overflow => overflow_TL,
			zero => zero_TL);

U5 : DC_TL port map(d_in => reg_out_b, add => alu_output(4 downto 0), reset => reset_TL, clk => clk_TL, 			data_write => dc_write, d_out => dc_d_out);

U6 : SIGNEX_TL port map(raw => ic_instr(15 downto 0), func_signex => alu_func, extend => se_extend);

U7 : NEXTADD_TL port map(rs => reg_out_a, rt => reg_out_b, pc => pc_q_32, target_address => ic_instr(25 			downto 0), branch_type => branch_sig, pc_sel => pc_select, next_pc => na_next_pc);

--  ------ MUXES --------
reg_add_in <= 	ic_instr(20 downto 16) when (reg_dst = '0') else
		ic_instr(15 downto 11) when (reg_dst = '1');

reg_mux_in <=	alu_output when (reg_mux_s = '1') else
		dc_d_out when (reg_mux_s = '0');

alu_mux_in <=	se_extend when (alu_mux_s = '1') else
		reg_out_b when (alu_mux_s = '0');

rs_out	<=	reg_out_a(3 downto 0);
rt_out	<=	reg_out_b(3 downto 0);
pc_out	<=	pc_q_32(3 downto 0);

end toplevel;
