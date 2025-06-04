library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity pcreg is
-- 32 x 1 write-enabled register file. Two read ports, one write port.

port(	d	: 	in std_logic_vector(31 downto 0);	-- single input for 32 bit data
	reset	: 	in std_logic;				-- async; clears all registers
	clk	: 	in std_logic;

	q	:	out std_logic_vector(31 downto 0)	);

end pcreg ;


architecture mypcreg of pcreg is

begin --  arch

-- reset and synchronous write
process (clk, reset)
begin
 
if (reset = '1') then
	q <= (others =>'0');

elsif (rising_edge(clk)) then
	q <= d ;

end if;
end process;

-- end arch
end mypcreg;
