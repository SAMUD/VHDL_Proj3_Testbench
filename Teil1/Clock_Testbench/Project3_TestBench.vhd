-----------------------------------------------------------
-- 					VOLTZENLOGEL Xavier							--
--					Matrikelnummer : 179159-01 					--
-- 					29/12/2017         							--
-- 		           TestBench Clock	     					   --
-----------------------------------------------------------

-- Library Declaration -------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.all;


------------------------------
-- 			ENTITY          --
------------------------------

ENTITY Project3_TestBench IS

END Project3_TestBench;


-----------------------------
--				ARCHITECTURE	--
-----------------------------

ARCHITECTURE TestBench_Clock of Project3_TestBench IS

--Constant Signal
CONSTANT LoopLimit : INTEGER := 40;

--internal Signals /stimulate signals

	SIGNAL StimClock : std_logic :='0';
	SIGNAL StimReset : std_logic :='0';
	SIGNAL StimClockFlag : std_logic := '0';


--Component to Test
COMPONENT Clock
------------------

		PORT(		
				Reset		 :	IN std_logic;
				Clock		 : IN std_logic;

				ClockFlag : OUT std_logic);

END COMPONENT;

----------------------------------------		

BEGIN



-- Clock Generator 50Mhz

		StimClock <= not StimClock after 1 ps; --reality 10000ps  
		
		
-- Call Component


	ClockSec: component Clock
			PORT MAP(
							Reset => StimReset,
							Clock	=> StimClock,
		
							ClockFlag => StimClockFlag);
	


PROCESS 

	VARIABLE CountLoop : INTEGER := 0;

BEGIN		


		
		--1) testing if the clock divider works. 
		--2) testing if the flags keeps 0 if we set the reset to TRUE
		
		StimReset <= '1'; --doing reset
		assert FALSE report "Reset 1" severity Note;
		wait on Stimclock; --waiting for the next rising edge
		wait on StimClock; 
		StimReset <= '0';
		assert FALSE report "Reset 0" severity Note;
		
		
		--1)
		
		--Reset Countloop
		CountLoop := 0;		
		
		-- loop for the flag detection
		L1 : loop 
			exit L1 when (StimclockFlag ='1'); 
			exit L1 when (CountLoop > LoopLimit); 
			wait on StimClock;  --waiting for the next rising edge
			wait on StimClock;
			CountLoop := CountLoop + 1;
			assert FALSE report "While loop" & integer'image(CountLoop) severity Note;
		end loop;
--		
		
		
		IF (CountLoop > LoopLimit) THEN 
			assert FALSE report "Flag has FAILED" severity Error;	
		ELSE
			assert FALSE report "Flag is working" severity Note;
		END IF;
		
		wait on StimClock;  --waiting for the next rising edge
		wait on StimClock;
		
		--2)
		
		--Reset Countloop
		CountLoop := 0;
		
		StimReset <= '1'; --doing reset
		
		--loop for the reset detection
		L2 : loop
			exit L2 when (StimClockFlag='0');
			exit L2 when (CountLoop > (LoopLimit);
			wait on StimClock;	--waiting for the next rising edge
			wait on StimClock;
			CountLoop := CountLoop + 1;
		end loop;
		
		IF (StimClockFlag='0') THEN 
			assert FALSE report "Reset is ok" severity Note;	
		ELSE
			assert FALSE report "Reset has FAILED" severity Error;
		END IF;
		
		
		
		assert FALSE report "All tests passed" severity Note;	
		wait;
		
END PROCESS;

END TestBench_Clock;


	
