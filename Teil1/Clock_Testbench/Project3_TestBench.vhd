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

--internal Signals /stimulate signals

	SIGNAL StimClock : std_logic :='0';
	SIGNAL StimReset : std_logic :='0';
	SIGNAL StimClockFlag : std_logic := '0';
	
	SIGNAL CountLoop : INTEGER := 0;

--Component to Test
COMPONENT Clock
		PORT(		
				Reset		 :	IN std_logic;
				Clock		 : IN std_logic;

				ClockFlag : OUT std_logic);

END COMPONENT;

----------------------------------------		

BEGIN


	ClockSec: component Clock
			PORT MAP(
							Reset => StimReset,
							Clock	=> StimClock,
		
							ClockFlag => StimClockFlag);
	


PROCESS 

BEGIN		
		-- Test signal reset asynchrone
		
		StimReset <= '1' ;
		wait for 100 ms ;
		StimReset <= '0' ;
		wait for 1000 ms ;
		
		
		assert StimClockFlag = '0' report "Reset: passed" severity Note;	--The Flag is showing a 0. All good
		assert StimClockFlag /= '0' report "Reset: FAILED" severity Error;	--The Flag is showing something else.
		
		
		-- Test Flag  
		StimReset <= '1' ;
		
		while (StimClockFlag /= '1') loop
		WAIT FOR 100 ps ;
			If (CountLoop > 4294967294) THEN
				
				assert StimClockFlag = '0' report "Flag: FAILED, Time expired" severity Error;	--The Flag is showing something else.
			END IF;
			
			CountLoop <= CountLoop + 1;
			
		END LOOP;
		
		assert StimClockFlag = '1' report "Flag: passed" severity Note;	--The Flag is showing a 1. All good
		
END PROCESS;

-- Signal Quartz à 50MHz
PROCESS

BEGIN

		StimClock <= '0';
		WAIT FOR 10000 ps;  
		StimClock <= '1';
		WAIT FOR 10000 ps;   
		
		
END PROCESS;

END TestBench_Clock;


	
