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
	type DataInput_Array is array (9 downto 0) of std_logic_vector(3 downto 0);
	signal DataInput : DataInput_Array := ("0000", "0001", "0010","0011", "0100", "0101","0110", "0111", "1000","1001");
	  
	type DataExpected_Array is array (9 downto 0) of std_logic_vector(6 downto 0);
	signal DataExpected : DataExpected_Array := ("0000001", "1001111", "0010010","0000110", "1001100", "0100100","1100000", "0001111", "0000000","0001100");
	
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
wait on StimClock;
while (StimClock/='0') loop
	wait on StimClock;
end loop;

StimInput <= DataInput(0); --Sending a 0
wait on StimClock;
wait on StimClock;
IF StimSolution = DataExpected(0) THEN
	--its true. So its done
	assert FALSE  report "Number 0: passed" severity Note;
ELSE
	--not true. Report error
	assert FALSE report "Number 0: FAILED" severity Error;
END IF;
wait on StimClock;

--StimInput<="0001"; --Sending a 1
--wait on StimClock;
--assert StimSolution = "1001111" report "Number 1: passed" severity Note;	--The Seven-Seg is showing a 1. All good
--assert StimSolution /= "1001111" report "Number 1: FAILED" severity Error;	--The Seven-Seg is showing something else.
--wait on StimClock;
--
--StimInput<="0010"; --Sending a 2
--wait on StimClock;
--assert StimSolution = "0010010" report "Number 2: passed" severity Note;	--The Seven-Seg is showing a 2. All good
--assert StimSolution /= "0010010" report "Number 2: FAILED" severity Error;	--The Seven-Seg is showing something else.
--wait on StimClock;
--
--StimInput<="0011"; --Sending a 3
--wait on StimClock;
--assert StimSolution = "0000110" report "Number 3: passed" severity Note;	--The Seven-Seg is showing a 3. All good
--assert StimSolution /= "0000110" report "Number 3: FAILED" severity Error;	--The Seven-Seg is showing something else.
--wait on StimClock;
--
--StimInput<="0100"; --Sending a 4
--wait on StimClock;
--assert StimSolution /= "1001100" report "Number 4: passed" severity Note;	--The Seven-Seg is showing a 4. All good
--assert StimSolution = "1001100" report "Number 4: FAILED" severity Error;	--The Seven-Seg is showing something else.
--wait on StimClock;
--
--StimInput<="0101"; --Sending a 5
--wait on StimClock;
--assert StimSolution /= "0100100" report "Number 5: passed" severity Note;	--The Seven-Seg is showing a 5. All good
--assert StimSolution = "0100100" report "Number 5: FAILED" severity Error;	--The Seven-Seg is showing something else.
--wait on StimClock;
--
--StimInput<="0110"; --Sending a 6
--wait on StimClock;
--assert StimSolution /= "1100000" report "Number 6: passed" severity Note;	--The Seven-Seg is showing a 6. All good
--assert StimSolution = "1100000" report "Number 6: FAILED" severity Error;	--The Seven-Seg is showing something else.
--wait on StimClock;
--
--StimInput<="0111"; --Sending a 7
--wait on StimClock;
--assert StimSolution /= "0001111" report "Number 7: passed" severity Note;	--The Seven-Seg is showing a 7. All good
--assert StimSolution = "0001111" report "Number 7: FAILED" severity Error;	--The Seven-Seg is showing something else.
--wait on StimClock;
--
--StimInput<="1000"; --Sending a 8
--wait on StimClock;
--assert StimSolution /= "0000000" report "Number 8: passed" severity Note;	--The Seven-Seg is showing a 8. All good
--assert StimSolution = "0000000" report "Number 8: FAILED" severity Error;	--The Seven-Seg is showing something else.
--wait on StimClock;
--
--StimInput<="1001"; --Sending a 9
--wait on StimClock;
--assert StimSolution /= "0001100" report "Number 9: passed" severity Note;	--The Seven-Seg is showing a 9. All good
--assert StimSolution = "1110011" report "Number 9: FAILED" severity Error;	--The Seven-Seg is showing something else.
--wait on StimClock;

--Finished
assert FALSE report "DONE!" severity NOTE;
wait;
	
end process;
	
END simulate;