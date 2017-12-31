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
		
		--now wait until we get a flag=1
		while (StimclockFlag='0' ) loop --TODO: add a condition to get out of the loop and fail the test if we waited to long (ex counter like in clock divider)
			wait on StimClock;
		end loop;
		assert FALSE report "Flag is working" severity Note;	--TODO: we need to check after how much time we exited the loop above to see if we divided correctly.
		
		--2)
		
		StimReset <= '1'; --doing reset
		while (StimClock/='0') loop
			wait on StimClock;
		end loop;
		
		while (StimclockFlag='0' ) loop --TODO: add a condition to get out of the loop and fail the test if we waited to long (ex counter like in clock divider)
			wait on StimClock;
		end loop;
		
		
		
		
		-- Test signal reset asynchrone
		
		
		
		
		--
		StimReset <= '1' ;
		wait for 100 ms ;
		StimReset <= '0' ;
		
		
		
		wait for 1 s ;
		
		
		assert StimClockFlag = '0' report "Reset: passed" severity Note;	--The Flag is showing a 0. All good
		assert StimClockFlag /= '0' report "Reset: FAILED" severity Error;	--The Flag is showing something else.
		
		
		-- Test Flag  
		StimReset <= '1' ;
		
		while (ClockFlag /= '1') loop
		WAIT FOR 100 ps ;
			If (CountLoop > 4294967294) THEN
				
				assert StimClockFlag = '0' report "Flag: FAILED, Time expired" severity Error;	--The Flag is showing something else.
			END IF;
			
			CountLoop := CountLoop + 1;
			
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


	
