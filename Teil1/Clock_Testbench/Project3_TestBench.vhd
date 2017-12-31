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
	--SIGNAL Stim_s_clock_comptage : INTEGER := 0;


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

-- signal reset asynchrone
PROCESS 

BEGIN		

		StimReset <= '1' ;
		wait for 1000 ps ;
		StimReset <= '0' ;
		wait for 100 ps ;
		StimReset <= '1' ;
		WAIT FOR 1000 ps ;
		StimReset <= '0' ;
		WAIT FOR 100 ps ;
		StimReset <= '1' ;
		WAIT FOR 100 ps ;
		
		assert StimClockFlag = '1' report "Flag: passed" severity Note;	--The Flag is showing a 1. All good
		assert StimClockFlag /= '1' report "Flag: FAILED" severity Error;	--The Flag is showing something else.

		
		--Finished
		assert TRUE report "DONE!" severity NOTE;
		wait;
		
END PROCESS;

-- Signal Quartz à 50MHz
PROCESS

BEGIN

		StimClock <= '0';
		WAIT FOR 10 ps;   --Real 10000ps
		StimClock <= '1';
		WAIT FOR 10 ps;   --Real 10000ps
		
		
END PROCESS;

END TestBench_Clock;


	
