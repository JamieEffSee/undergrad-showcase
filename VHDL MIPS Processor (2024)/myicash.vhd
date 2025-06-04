library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity icache is

port(	add		: in std_logic_vector(4 downto 0);		-- 5 bit identifer

	instr		: out std_logic_vector(31 downto 0)   );	-- 32 bit instruction

end icache ;

architecture myicache of icache is

begin --  arch

-- reset and synchronous write
process (add)
begin
 	       --    e.g.,     |op6 |rs5 |rt5 |rd5 |sh5 |func6   R-type
case add is
	when "00000" =>
	-- add immediate: r3, r1, 2
		instr <= "00100000001000110000000000000010";

	when "00001" =>
	-- add register: r1, r3, r3
		instr <= "00000000011000110000100000100000";

	when "00010" =>
	-- logical AND: r3 <= r1.r3
		instr <= "00000000001000110001100000100100";

	when "00011" =>
	-- logical AND immediate: r3 <= r3.1111000011110000
		instr <= "00110000011000111111000011110000";

	when "00100" =>
	-- branch on equal (r3, r1, skip 2) (will fail)
		instr <= "00010000011000010000000000000010";

	when "00101" =>
	-- store word from r3 at the top of the array
		instr <= "10101100000000110000000000000000";

	when "00110" =>
	-- jump immediate (into dont care territory)
		instr <= "00001000000000000000000000001111";

	when others =>
	-- don't care territory
		instr <= "00000000000000000000000000000000";

end case;

end process;

-- end arch
end myicache;




