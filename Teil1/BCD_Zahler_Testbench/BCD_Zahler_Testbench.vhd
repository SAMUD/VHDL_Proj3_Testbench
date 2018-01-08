------------------------------------------------------
-- BCD_zahler_Testbench  --
-- DISCHLI Arthur --
-- 08/01/18 --
-- Matrikelnummer : 179156 --
------------------------------------------------------

-- Library Declaration -------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.all;


------------------------------
-- 			ENTITY          --
------------------------------

ENTITY BCD_zahler_Testbench IS

END BCD_zahler_Testbench;


-----------------------------
--				ARCHITECTURE	--
-----------------------------

ARCHITECTURE TestBench of BCD_zahler_Testbench IS

--Constant Signal
CONSTANT LoopLimit : INTEGER := 120;

--internal Signals /stimulate signals

	SIGNAL StimReset : std_logic :='0';
	SIGNAL StimClk : std_logic :='0';
	SIGNAL StimCM : std_logic := '0';
	SIGNAL Stimb : std_logic_vector (3 downto 0) := "0000";

--Component to Test
COMPONENT BCD_zahler
------------------

		PORT(		
				Reset, Clk, CM		 :	IN std_logic;
				b : OUT std_logic_vector (3 downto 0));

END COMPONENT;

----------------------------------------		

BEGIN



-- Clock Generator 50Mhz

		StimClk <= not StimClk after 1 ps; 
		
		
-- Call Component


	Zahler: component BCD_Zahler
			PORT MAP(
							Reset => StimReset,
							Clk	=> StimClk,
							CM => StimCM,
							b => Stimb);
	


PROCESS 

	VARIABLE LoopCounter : INTEGER := 0;

BEGIN		

		
		--1) testing when CM = 1 if counter count 0 1 3 5 7 9 0 ...
		--2) testing when CM = 0 if counter count 0 2 4 6 8 0 ...
		
		StimReset <= '1'; --doing reset
		assert FALSE report "Reset 1" severity Note;
		wait on StimClk; --waiting for the next rising edge
		wait on StimClk; 
		StimReset <= '0';
		assert FALSE report "Reset 0" severity Note;
		
		
		--1)
		
		--Reset Loop Counter
		LoopCounter:=0;
		--CM = 1
		StimCM <= '1';		
		
		
		L1 : loop 
			exit L1 when (Stimb ="1001"); 
			exit L1 when (LoopCounter > Looplimit); 
			wait on StimClk;
			wait on StimClk;
			LoopCounter := LoopCounter + 1;
			--assert FALSE report "While loop" & integer'image(LoopCounter) severity Note;
		end loop;
--		
		
		
		IF (LoopCounter > Looplimit) THEN
			assert FALSE report "Counting 0 1 3 5 7 9 has failled" severity Note;	
		ELSE
			assert FALSE report "Counting 0 1 3  5 7 9 is working" severity Note;
		END IF;
		
		wait on StimClk;
		wait on StimClk;
		
		--2)
		
		--Reset Countloop
		LoopCounter := 0;
		--CM = 0
		StimCM <= '0';
		
		L2 : loop
			exit L2 when (Stimb="1000");
			exit L2 when (LoopCounter < LoopLimit);
			wait on StimClk;
			wait on StimClk;
			LoopCounter := LoopCounter + 1;
		end loop;
		
		IF (LoopCounter > Looplimit) THEN
			assert FALSE report "Counting 0 2 4 6 8 has failled" severity Note;	
		ELSE
			assert FALSE report "Counting 0 2 4 6 8 is working" severity Note;
		END IF;
		
		
		
		assert FALSE report "All tests passed" severity Note;	
		wait;
		
END PROCESS;

END TestBench;