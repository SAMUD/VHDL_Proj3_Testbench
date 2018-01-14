------------------------------------------------------
-- Falling_Edge_Testbench  --
-- DISCHLI Arthur & Voltzenlogel Xavier--
-- 08/01/18 --
-- Matrikelnummer : 179156 & 179159--
------------------------------------------------------

-- Library Declaration -------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.all;


------------------------------
-- 			ENTITY          --
------------------------------

ENTITY Falling_Edge_Testbench IS

END Falling_Edge_Testbench;


-----------------------------
--				ARCHITECTURE	--
-----------------------------

ARCHITECTURE TestBench of Falling_Edge_Testbench IS

--Constant Signal
CONSTANT LoopLimit : INTEGER := 10;

--internal Signals /stimulate signals

	SIGNAL StimClk_i : std_logic :='0';
	SIGNAL StimButton_i : std_logic := '0';
	SIGNAL StimFalling_o : std_logic :='0';

--Component to Test
COMPONENT FallingEdge
------------------

		PORT(		
				Clk_i, Button_i		 :	IN std_logic;
				Falling_o : OUT std_logic);

END COMPONENT;

----------------------------------------		

BEGIN



-- Clock Generator 50Mhz

		StimClk_i <= not StimClk_i after 1 ps; 
		
		
-- Call Component


	FE: component FallingEdge
			PORT MAP(
							Clk_i	=> StimClk_i,
							Button_i => StimButton_i,
							Falling_o => StimFalling_o);
	


PROCESS 

	VARIABLE LoopCounter : INTEGER := 0;

BEGIN		

		
		--1) testing a falling edge on Button_i

		
		--Reset Loop Counter
		LoopCounter:=0;
		--Button_i = 1
		StimButton_i <= '1';		
		
		wait on StimClk_i;
		wait on StimClk_i;
		
		
		L1 : loop
			StimButton_i <= '0';
			exit L1 when (StimFalling_o ='1'); 
			exit L1 when (LoopCounter > Looplimit); 
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
			--assert FALSE report "While loop" & integer'image(LoopCounter) severity Note;
		end loop;
--		
		
		
		IF (LoopCounter > Looplimit) THEN
			assert FALSE report "Falling edge has failled" severity Note;	
		ELSE
			assert FALSE report "Falling edge is working" severity Note;
		END IF;
		
		
		assert FALSE report "All tests passed" severity Note;	
		wait;
		
END PROCESS;

END TestBench;