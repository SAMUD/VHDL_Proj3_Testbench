------------------------------------------------------
-- BCD_zahler_Testbench  --
-- DISCHLI Arthur --
-- 08/01/18 --
-- Matrikelnummer : 179156 --
------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


------------------------------------------------------
--	   ENTITY	                           			 --
------------------------------------------------------

ENTITY BCD_Zahler_Testbench IS
END BCD_Zahler_Testbench;

------------------------------------------------------
--        ARCHITECTURE	                  			 --
------------------------------------------------------
ARCHITECTURE simu OF BCD_Zahler_Testbench IS

--internal Signals /stimulate signals
	signal StimClock: 		std_logic;
	signal StimReset:			std_logic;
	signal StimCM: 			std_logic;
	signal Stimb0: 			std_logic;
	signal Stimb1: 			std_logic;
	signal Stimb2: 			std_logic;
	signal Stimb3: 			std_logic;

--Component to Test
component BCD_zahler
port (
	reset,clk,CM	:IN	std_logic;
	b0,b1,b2,b3		:OUT	std_logic
	);
end component;

BEGIN

--Generate clock
StimClock <= not StimClock after 20 ns;

--Device to test 
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
	
END simu;