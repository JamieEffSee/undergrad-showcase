library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity regfile is
-- 32 x 32 write-enabled register file. Two read ports, one write port.

port(	din: 		in std_logic_vector(31 downto 0);	-- single input for 32 bit data
	reset: 		in std_logic;				-- async; clears all registers
	clk: 		in std_logic;

	write: 		in std_logic;				-- synchronous (rising edge) write
	write_address : in std_logic_vector(4 downto 0);	-- write din to this address if write = 1

	read_a : 	in std_logic_vector(4 downto 0);	-- specify addresses for read ports
	read_b : 	in std_logic_vector(4 downto 0);

	out_a: 		out std_logic_vector(31 downto 0);	-- asynchronous read ports
	out_b: 		out std_logic_vector(31 downto 0));

end regfile ;


architecture myregfile of regfile is

type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);
signal reg_sig : reg_array;

begin --  arch

-- reset and synchronous write
process (clk, reset)

begin
 
if (reset = '1') then
	reg_sig <= (others => (others => '0'));

elsif (rising_edge(clk)) then
	
	if (write = '1') then
		reg_sig(conv_integer(write_address)) <= din; -- native conv_integer() function
	end if;

end if;

end process;

-- asynchronous read
process(read_a, read_b) -- removed reg_sig
begin
	out_a <= reg_sig(conv_integer(read_a)); -- native conv_integer() function
	out_b <= reg_sig(conv_integer(read_b));

end process;


-- end arch
end myregfile;




