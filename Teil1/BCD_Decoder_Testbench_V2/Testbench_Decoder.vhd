------------------------------------------------------
--  Testbench by Samuel Daurat [178190]      --
-- This module is a testbench and will be used to test the BCD Decoder


-- Changelog:
-- Version 0.2| 30.12.17
--  *continued working
--	 *seems to be finished
-- Version 0.1| 29.12.17
--  *started work
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
	
	--Signals which contain the Numbers to test and the expected outputs
	type DataInput_Array 	is array (9 downto 0) 	of std_logic_vector(3 downto 0);
	signal DataInput : 		DataInput_Array := ("1001","1000","0111","0110","0101","0100","0011","0010","0001","0000");
	  
	type DataExpected_Array is array (9 downto 0) 	of std_logic_vector(6 downto 0);
	signal DataExpected : 	DataExpected_Array := ("0011000","0000000","1111000","0000011","0010010","0011001","0110000","0100100","1111001","1000000");
	
	--intermediate signals to transport signals inside this Entity
	signal StimInput: 								std_logic_vector (3 downto 0) := "0000";
	signal StimSolution:							std_logic_vector (6 downto 0) := "0000000";
	signal StimClock: 								std_logic :='0';

--Component to Test
component Decoder
port (
	Input			:		IN						std_logic_vector (3 downto 0);
	Output			:		OUT						std_logic_vector (6 downto 0)
	);
end component;

---------------------------------------------
BEGIN

--Generate clock
StimClock <= not StimClock after 10 ns;

--Device to test (DUT)
ConvertBcd_1: component Decoder
		port map(
				Input => StimInput,											
				Output => StimSolution
		);
		
--Stimulate-process
stimulate: PROCESS
	
	variable Increment:	integer range 0 to 9 :=0;
	
BEGIN

--The DUT in this case is programmed asynchronous. It doesn't use a clock. No need to test for clocks here in theory.
--But the clock is used to slow things down, to have someting beautiful in the Wave-Graph during simulation
--finding a rising edge
wait on StimClock;
while (StimClock/='0') loop
	wait on StimClock;
end loop;

--Starting main foor loop
for Increment in 0 to 9 loop
	
	--Sending the number
	StimInput <= DataInput(Increment); 
	
	--wait for a rising edge
	wait on StimClock;
	wait on StimClock;
	
	--now test the outputs
	IF StimSolution = DataExpected(Increment) THEN
		--its true. So its done
		assert FALSE  report " Number " & integer'image(Increment) & ": passed" severity Note;
	ELSE
		--not true. Report error
		assert FALSE report "Number " & integer'image(Increment) & " : FAILED" severity Error;
		--starting to test each bit for it's own
		IF StimSolution(0) = DataExpected(Increment)(0) THEN
			assert FALSE  report "   Position 0: passed" severity Note;
		ELSE
			assert FALSE report "  Position 0: FAILED" severity Error;
		END IF;
		IF StimSolution(1) = DataExpected(Increment)(1) THEN
			assert FALSE  report "   Position 1: passed" severity Note;
		ELSE
			assert FALSE report "  Position 1: FAILED" severity Error;
		END IF;
		IF StimSolution(2) = DataExpected(Increment)(2) THEN
			assert FALSE  report "   Position 2: passed" severity Note;
		ELSE
			assert FALSE report "  Position 2: FAILED" severity Error;
		END IF;
		IF StimSolution(3) = DataExpected(Increment)(3) THEN
			assert FALSE  report "   Position 3: passed" severity Note;
		ELSE
			assert FALSE report "  Position 3: FAILED" severity Error;
		END IF;
		IF StimSolution(4) = DataExpected(Increment)(4) THEN
			assert FALSE  report "   Position 4: passed" severity Note;
		ELSE
			assert FALSE report "  Position 4: FAILED" severity Error;
		END IF;
		IF StimSolution(5) = DataExpected(Increment)(5) THEN
			assert FALSE  report "   Position 5: passed" severity Note;
		ELSE
			assert FALSE report "  Position 5: FAILED" severity Error;
		END IF;
		IF StimSolution(6) = DataExpected(Increment)(6) THEN
			assert FALSE  report "   Position 6: passed" severity Note;
		ELSE
			assert FALSE report "  Position 6: FAILED" severity Error;
		END IF;
	END IF;
	
end loop;

--Finished
assert FALSE report "DONE!" severity NOTE;
wait;
	
end process;
	
END simulate;