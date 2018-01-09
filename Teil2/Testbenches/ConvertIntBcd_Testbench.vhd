-----------------------------------------------------------
-- 					VOLTZENLOGEL Xavier							--
--					Matrikelnummer : 179159-01 					--
-- 					29/12/2017         							--
-- 		 TestBench Counter and ConvertIntBcd			   --
-----------------------------------------------------------


-- Library Declaration -------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.all;


------------------------------
-- 			ENTITY          --
------------------------------

ENTITY ConvertIntBcd_Testbench IS

END ConvertIntBcd_Testbench;


-----------------------------
--				ARCHITECTURE	--
-----------------------------

ARCHITECTURE TestBench of ConvertIntBcd_Testbench IS


--Constant Signal
CONSTANT LoopLimit : INTEGER := 100;
	
	
--Internal Signals / Stimulate signals from the Int to Bcd Converter

	SIGNAL InputInt : INTEGER  range 0 to 6000 ;			--Input signal containing the actual time information in Deci-Sec
													
	SIGNAL StimSevenSeg1	: std_logic_vector (6 downto 0) := "0000000";
	SIGNAL StimSevenSeg2	: std_logic_vector (6 downto 0) := "0000000";	
	SIGNAL StimSevenSeg3	: std_logic_vector (6 downto 0) := "0000000";	
	SIGNAL StimSevenSeg4	: std_logic_vector (6 downto 0) := "0000000";
	
	
	
	
--Signals which contain the Numbers to test and the expected outputs
	TYPE DataExpected_Array IS ARRAY (10 downto 0) 	of std_logic_vector(6 downto 0);
	SIGNAL DataExpected : DataExpected_Array := ("1000000","0011000","0000000","1111000","0000011","0010010","0011001","0110000","0100100","1111001","1000000");
	
--Intermediate signals to transport signals inside this Entity
	SIGNAL StimSolution : std_logic_vector (6 downto 0) := "0000000";
	
	
	
--Component to Test

	COMPONENT ConvertIntBcd
		PORT(															
			InputInt		:		IN		integer range 0 to 6000 ;		--Input signal containing the actual time information in Deci-Sec												
			SevenSeg1	:		OUT	std_logic_vector (6 downto 0);	-- decoded signals to send to the 7seg
			SevenSeg2	:		OUT	std_logic_vector (6 downto 0);	
			SevenSeg3	:		OUT	std_logic_vector (6 downto 0);	
			SevenSeg4	:		OUT	std_logic_vector (6 downto 0)
			);
END COMPONENT;

----------------------------------

BEGIN
		
		
-- Call Component
							
							
	ConvertIntBcd_1: COMPONENT ConvertIntBcd
			PORT MAP(
					InputInt  => StimInputInt,											
					SevenSeg1 => StimSevenSeg1,
					SevenSeg2 => StimSevenSeg2,
					SevenSeg3 => StimSevenSeg3,
					SevenSeg4 => StimSevenSeg4 
					);	
					

PROCESS

	VARIABLE LoopCounter : INTEGER := 0;
	VARIABLE Increment : INTEGER range 0 to 10 :=0;
	
	
	
BEGIN

		
		--1) Testing the incrementation of the Min to the max value
		--2) Testing the incrementation of the Sec to the max value
		--3) Testing the incrementation of the Min and Sec and Test Clear
		--4) Testing the dekrementation of the value to zero
		
		
		StimCountBlockControl_i <= "100000"; --doing reset
		assert FALSE report "Mode Reset" severity Note;
		wait on StimClk_i; --waiting for the next rising edge
		wait on StimClk_i; 
		
		
		--1)
		
		StimCountBlockControl_i <= "001000";  --Incrementation Mode
		assert FALSE report "Mode Ready for Incrementing the Value" severity Note;
		
		
		Loop1: FOR Increment IN 0 TO 10 LOOP
		
				StimBtnMinF_i <= '1';  --Press Min Button
		
				wait on StimClk_i; 	 --waiting for the next rising edge
				wait on StimClk_i;
				
				IF StimSolution = DataExpected(Increment) THEN
					--its true. So its done
					assert FALSE  report " Min Number " & integer'image(Increment) & ": passed" severity Note;
				
				ELSE
					--not true. Report error
					assert FALSE report "Min Number " & integer'image(Increment) & " : FAILED" severity Error;
				END IF;
				
				StimBtnMinF_i <= '0';  --Release Min Button
				
				wait on StimClk_i; 	 --waiting for the next rising edge
				wait on StimClk_i;
					
				
		
		END LOOP Loop1;
	

--Finished
assert FALSE report "DONE!" severity NOTE;
wait;
	
end process;
	
END TestBench;	
		
				
		
		
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
--					
					
					
					
					
					
					
					
					
					
					
					
					
	
	
	