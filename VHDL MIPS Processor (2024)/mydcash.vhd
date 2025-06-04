library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity dcache is
-- 1 x 32 write-enabled register file. Two read ports, one write port.

port(	d_in		: in std_logic_vector(31 downto 0);	
	add		: in std_logic_vector(4 downto 0);	
	reset		: in std_logic;				
	clk		: in std_logic;				
	data_write	: in std_logic;				

	d_out		: out std_logic_vector(31 downto 0));

end dcache ;


architecture mydcache of dcache is

type mem_array is array(0 to 31) of std_logic_vector(31 downto 0);
signal mem_sig : mem_array;

begin --  arch

-- reset and synchronous write
process (d_in, clk, reset, add, data_write)
begin
 
if (reset = '1') then
	for n in mem_sig'range loop
		mem_sig(n) <= (others => '0');
	end loop;

elsif (rising_edge(clk)) then
	if (data_write = '1') then
		mem_sig(conv_integer(add)) <= d_in;
	end if;

end if;
end process;

-- asynchronous read
d_out <= mem_sig(conv_integer(add)); -- native conv_integer() function

-- end arch
end mydcache;




