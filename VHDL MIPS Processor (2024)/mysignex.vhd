library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity signex is
-- 16-bit to 32-bit sign extender

port(	raw		: 	in std_logic_vector(15 downto 0);	
	func_signex	: 	in std_logic_vector(1 downto 0);	
	extend		:	out std_logic_vector(31 downto 0)	);

end signex ;

architecture myextend of signex is

begin --  arch

-- select output
process(raw, func_signex)
begin
	if (func_signex = "00") then			-- lui
		extend <= raw(15 downto 0) & "0000000000000000" ;

	elsif (func_signex = "01") then		-- slti	
		if raw(15) = '1' then
			extend <= "1111111111111111" & raw(15 downto 0);
		else
			extend <= "0000000000000000" & raw(15 downto 0);
		end if;

	elsif (func_signex = "10") then		-- arith
		if raw(15) = '1' then
			extend <= "1111111111111111" & raw(15 downto 0);
		else
			extend <= "0000000000000000" & raw(15 downto 0);
		end if;

	else					-- logical
		extend <= "0000000000000000" & raw(15 downto 0);
	end if;
end process;

-- end arch
end myextend;
