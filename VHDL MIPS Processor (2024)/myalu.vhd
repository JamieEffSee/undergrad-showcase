library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity alu is
port(x, y 		: in std_logic_vector(31 downto 0);
	-- INPUTS
	add_sub 	: in std_logic ; -- 0 = add and 1 = sub
	logic_func 	: in std_logic_vector(1 downto 0);
		-- 00 AND; 01 OR; 10 XOR; 11 NOR
	func 		: in std_logic_vector(1 downto 0);
		-- 00 lui; 01 setless; 10 arith; 11 logic
	output		: out std_logic_vector(31 downto 0);
	overflow	: out std_logic;
	zero		: out std_logic );

end alu;

architecture myalu of alu is

signal adder_out, logic_out : std_logic_vector(31 downto 0);

begin


-- ADDER
process(add_sub, x, y)
begin
	if (add_sub = '0') then
		adder_out <= x + y;
	else
		adder_out <= x - y;
	end if;
end process;
-- END ADDER


-- LOGIC
process(logic_func, x, y)
begin
	if (logic_func = "00") then
		logic_out <= x and y;
	elsif (logic_func = "01") then
		logic_out <= x or y;
	elsif (logic_func = "10") then
		logic_out <= x xor y;
	else
		logic_out <= x nor y;
	end if;
end process;
-- END LOGIC

-- - - - - -OUTPUTS

-- MUXOUT
with func select
output <=	y when "00",  -- lui
		"0000000000000000000000000000000" & adder_out(31) when "01", -- slt
		adder_out when "10",
		logic_out when others;

-- CHECK ZERO
with adder_out select
zero <=	'1' when "00000000000000000000000000000000",
	'0' when others;

-- OVERFLOW
-- overflow <= (x(31) and y(31)) and (not adder_out(31)) ; -- v1
with add_sub select
overflow <=	(not(x(31)) and not(y(31)) and adder_out(31)) or (x(31) and y(31) and not(adder_out(31))) when '0',
		(not(x(31)) and y(31) and adder_out(31)) or (x(31) and not(y(31)) and not(adder_out(31))) when others;

end myalu;
