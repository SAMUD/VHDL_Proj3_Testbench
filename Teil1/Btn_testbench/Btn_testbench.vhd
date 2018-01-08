-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


------------------------------------------------------
--	   ENTITY	                           			 --
------------------------------------------------------

ENTITY Btn_Testbench IS
END Btn_Testbench;

------------------------------------------------------
--        ARCHITECTURE	                  			 --
------------------------------------------------------
ARCHITECTURE simulate OF Btn_Testbench IS
	
	--intermediate signals to transport signals inside this Entity
	signal StimInput: 		std_logic_vector (3 downto 0) := "0000";
	signal StimSolution:		std_logic_vector (6 downto 0) := "0000000";
	signal StimClock: 		std_logic :='0';

--Component to Test
component Btn
port (
	clk :IN std_logic;								
	btn_start :IN std_logic; 						
	btn_s :IN std_logic;								
	btn_m :IN std_logic;								
	end_buzzer :IN std_logic;	
	
	start_stop :OUT std_logic;						
	inc_s :OUT std_logic;							
	inc_m :OUT std_logic;	
	);
end component;

---------------------------------------------
BEGIN

--Generate clock
StimClock <= not StimClock after 10 ns;

--Device to test 
Btn_1: component Btn
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
	
END simulate;