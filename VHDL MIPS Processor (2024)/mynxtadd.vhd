library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity nextaddr is
-- next address unit

port(	rt, rs 		: 	in std_logic_vector(31 downto 0);
	pc		:	in std_logic_vector(31 downto 0);
	target_address	:	in std_logic_vector(25 downto 0);
	branch_type	:	in std_logic_vector(1 downto 0);
	pc_sel		:	in std_logic_vector(1 downto 0);
	
	next_pc		:	out std_logic_vector(31 downto 0)	);

end nextaddr;

architecture mynxtadd of nextaddr is

signal pad : std_logic_vector(15 downto 0);
signal branch_int : std_logic_vector(31 downto 0);

begin -- arch

-- helper processes: padding
process(target_address)
begin

if (target_address(15) = '0') then
	pad <= (others => '0');
else
	pad <= (others => '1');
end if;
end process;

process(pad)
begin
branch_int <= pad & target_address(15 downto 0);
end process;

-- craft pc_prep
process(branch_type, pc, pc_sel, branch_int, rs, rt)
begin

case pc_sel is
	
	when "00" => 			-- pc_sel: no unconditional
			
		case branch_type is
			when "00" => 			-- branch: straightline
				next_pc <= pc + 1;

			when "01" => 			-- branch: beq			
			if (rs = rt) then
				next_pc <= pc + 1 + branch_int;
			else
				next_pc <= pc + 1;
			end if;

			when "10" => 			-- branch: bne
			if (rs /= rt) then
				next_pc <= pc + 1 + branch_int;
			else
				next_pc <= pc + 1;
			end if;

			when "11" => 			-- branch: bltz
			if (rs(31) = '1') then
				next_pc <= pc + 1 + branch_int;
			else
				next_pc <= pc + 1;
			end if;			

			when others =>			-- branch: catch bad input
				next_pc <= pc + 1;
			
		end case; -- branch type

	when "01" => 			-- pc_sel: unconditional
			next_pc <= "000000" & target_address;

	when "10" => 			-- pc_sel: jump reg
			next_pc <= rs;

	when others => 			-- pc_sel: catch errors
			next_pc <= pc + 1;
end case; -- pcsel

end process; -- main assign

-- end arch
end mynxtadd;
