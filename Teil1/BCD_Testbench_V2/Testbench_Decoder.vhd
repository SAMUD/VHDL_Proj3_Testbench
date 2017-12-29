------------------------------------------------------
--  Testbench by Samuel Daurat [178190]      --

-- This module is a testbench and will be used to test the BCD Decoder


-- Changelog:
-- Version 0.1| 29.12.17
--  *initial release
------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


------------------------------------------------------
--	   ENTITY	                           			 --
------------------------------------------------------

ENTITY Testbench_Decoder IS
END Testbench_Decoder;

------------------------------------------------------
--        ARCHITECTURE	                  			 --
------------------------------------------------------
ARCHITECTURE simulate OF Testbench_Decoder IS

--internal Signals /stimulate signals
	signal StimInput: 		std_logic_vector (3 downto 0) := "0000";
	signal StimSolution:		std_logic_vector (6 downto 0) := "0000000";
	signal StimClock: 		std_logic :='0';
	
--Component to Test
component Decoder
port (
	Input			:		IN		std_logic_vector (3 downto 0);
	Output		:		OUT	std_logic_vector (6 downto 0)
	);
end component;

---------------------------------------------
BEGIN

--Generate clock
StimClock <= not StimClock after 10ns;

--Device to test 
ConvertBcd_1: component Decoder
		port map(
				Input => StimInput,											
				Output => StimSolution
		);
		
--Stimulate-process
stimulate: PROCESS 
BEGIN

--The DUT in this case is programmed asynchronous. It doesn't use a clock. No need to test for clocks here
--wait on StimClock;
--while (StimClock/='0') loop
--	wait on StimClock;
--end loop;

StimInput<="0000"; --Sending a 0
wait for 20 ns; 
assert StimSolution = "0000001" report "Number 0 has     passed" severity Note;	--The Seven-Seg is showing a 0. All good
assert StimSolution /= "0000001" report "Number 0 has NOT passed" severity Error;	--The Seven-Seg is showing something else.

StimInput<="0001"; --Sending a 1
wait for 20 ns; 
assert StimSolution = "1001111" report "Number 1 has     passed" severity Note;	--The Seven-Seg is showing a 0. All good
assert StimSolution /= "1001111" report "Number 1 has NOT passed" severity Error;	--The Seven-Seg is showing something else.

StimInput<="0010"; --Sending a 2
wait for 20 ns; 
assert StimSolution = "0010010" report "Number 2 has     passed" severity Note;	--The Seven-Seg is showing a 0. All good
assert StimSolution /= "0010010" report "Number 2 has NOT passed" severity Error;	--The Seven-Seg is showing something else.

StimInput<="0011"; --Sending a 3
wait for 20 ns; 
assert StimSolution = "0000110" report "Number 3 has     passed" severity Note;	--The Seven-Seg is showing a 0. All good
assert StimSolution /= "0000110" report "Number 3 has NOT passed" severity Error;	--The Seven-Seg is showing something else.

StimInput<="0100"; --Sending a 4
wait for 20 ns; 
assert StimSolution = "1001100" report "Number 4 has     passed" severity Note;	--The Seven-Seg is showing a 0. All good
assert StimSolution /= "1001100" report "Number 4 has NOT passed" severity Error;	--The Seven-Seg is showing something else.

StimInput<="0101"; --Sending a 5
wait for 20 ns; 
assert StimSolution = "0100100" report "Number 5 has     passed" severity Note;	--The Seven-Seg is showing a 0. All good
assert StimSolution /= "0100100" report "Number 5 has NOT passed" severity Error;	--The Seven-Seg is showing something else.

StimInput<="0110"; --Sending a 6
wait for 20 ns; 
assert StimSolution = "1100000" report "Number 6 has     passed" severity Note;	--The Seven-Seg is showing a 0. All good
assert StimSolution /= "1100000" report "Number 6 has NOT passed" severity Error;	--The Seven-Seg is showing something else.

StimInput<="0111"; --Sending a 7
wait for 20 ns; 
assert StimSolution = "0001111" report "Number 7 has     passed" severity Note;	--The Seven-Seg is showing a 0. All good
assert StimSolution /= "0001111" report "Number 7 has NOT passed" severity Error;	--The Seven-Seg is showing something else.

StimInput<="1000"; --Sending a 8
wait for 20 ns; 
assert StimSolution = "0000000" report "Number 8 has     passed" severity Note;	--The Seven-Seg is showing a 0. All good
assert StimSolution /= "0000000" report "Number 8 has NOT passed" severity Error;	--The Seven-Seg is showing something else.

StimInput<="1001"; --Sending a 9
wait for 20 ns; 
assert StimSolution = "0001100" report "Number 9 has     passed" severity Note;	--The Seven-Seg is showing a 0. All good
assert StimSolution /= "1110011" report "Number 9 has NOT passed" severity Error;	--The Seven-Seg is showing something else.

--Finished
assert TRUE report "DONE!" severity NOTE;
wait;
	
end process;
	
END simulate;