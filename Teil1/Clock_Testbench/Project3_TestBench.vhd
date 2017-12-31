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
------------------------------

		PORT(		
				Reset		 :	IN std_logic;
				Clock		 : IN std_logic;

				ClockFlag : OUT std_logic);

END COMPONENT;

----------------------------------------		

BEGIN

--Generate clock
StimClock <= not StimClock after 1 ns;

--call Component
ClockSec: component Clock
			PORT MAP(
							Reset => StimReset,
							Clock	=> StimClock,
		
							ClockFlag => StimClockFlag);
	

PROCESS 

BEGIN		
		
		
		--Waiting for a rising edge on clock
		wait on StimClock;
		while (StimClock/='0') loop
			wait on StimClock;
		end loop;
		
		
		--1) testing if the clock divider works. To do this we will count the number of ms until the flag gets TRUE. If the number of ns is the same as expected this test is Sucessfull
		--2) testing if the flags keeps 0 if we set the reset to TRUE
		
		StimReset <= '1'; --doing reset
		wait on Stimclock; --waiting for the next rising edge
		wait on StimClock; 
		StimReset <= '0';
		
		--1)
		
		--Reset Countloop
		CountLoop <= 0;
		
		--now wait until we get a flag=1
		while (StimclockFlag='0' OR CountLoop < 4294967294 ) loop
			wait on StimClock;
			CountLoop := CountLoop + 1;
		end loop;
		
		IF (CountLoop > 4294967294) THEN --TODO: sho in text message after how much time we had the flag
			assert FALSE report "Flag has FAILED" severity Note;	
		ELSE
			assert FALSE report "Flag is working" severity Note;
		END IF;
		
		--2)
		
		--Reset Countloop
		CountLoop <= 0;
		
		StimReset <= '1'; --doing reset
		while (StimClockFlag='0' OR CountLoop < (4294967294*2) ) loop
			wait on StimClock;
		end loop;
		
		IF (StimClockFlag='0') THEN --TODO: sho in text message after how much time we had the flag
			assert FALSE report "Reset is ok" severity Note;	
		ELSE
			assert FALSE report "Reset has FAILED" severity Note;
		END IF;
		
		
		
		assert FALSE report "All tests passed" severity Note;	
		wait;
		
END PROCESS;

---- Signal Quartz à 50MHz
--PROCESS
--
--BEGIN
--
--		StimClock <= '0';
--		WAIT FOR 10000 ps;  
--		StimClock <= '1';
--		WAIT FOR 10000 ps;   
--		
--		
--END PROCESS;

END TestBench_Clock;


	
