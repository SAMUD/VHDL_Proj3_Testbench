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
CONSTANT Divider : INTEGER := 40;

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

		StimClock <= not StimClock after 1 ps; --real 10000  
		
		
-- Call Component


	ClockSec: component Clock
			PORT MAP(
							Reset => StimReset,
							Clock	=> StimClock,
		
							ClockFlag => StimClockFlag);
	


PROCESS 

	VARIABLE CountLoop : INTEGER := 0;

BEGIN		
		
--		assert FALSE report "Waiting Rising Edge Clock" severity Note;
--		--Waiting for a rising edge on clock
--		wait on StimClock;
--		while (StimClock/='0') loop
--			wait on StimClock;
--		end loop;
--		
--		assert FALSE report "Rising Edge Clock Found" severity Note;



		
		--1) testing if the clock divider works. To do this we will count the number of ms until the flag gets TRUE. If the number of ns is the same as expected this test is Sucessfull
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
		
		
		L1 : loop 
			exit L1 when (StimclockFlag ='1'); 
			exit L1 when (CountLoop > Divider); 
			wait on StimClock;
			wait on StimClock;
			CountLoop := CountLoop + 1;
			assert FALSE report "While loop" & integer'image(CountLoop) severity Note;
		end loop;
--		
		
		
		IF (CountLoop > Divider) THEN --TODO: show in text message after how much time we had the flag
			assert FALSE report "Flag has FAILED" severity Error;	
		ELSE
			assert FALSE report "Flag is working" severity Note;
		END IF;
		
		wait on StimClock;
		wait on StimClock;
		
		--2)
		
		--Reset Countloop
		CountLoop := 0;
		
		StimReset <= '1'; --doing reset
		
		L2 : loop
			exit L2 when (StimClockFlag='0');
			exit L2 when (CountLoop < (Divider*2));
			wait on StimClock;
			wait on StimClock;
			CountLoop := CountLoop + 1;
		end loop;
		
		IF (StimClockFlag='0') THEN --TODO: sho in text message after how much time we had the flag
			assert FALSE report "Reset is ok" severity Note;	
		ELSE
			assert FALSE report "Reset has FAILED" severity Error;
		END IF;
		
		
		
		assert FALSE report "All tests passed" severity Note;	
		wait;
		
END PROCESS;

END TestBench_Clock;


	
