----------------------------------------------------------
-- 					BUCHERT Jérémy									--
--					Matrikelnummer : 179162-01  					--
-- 					09/01/2018         							--
-- 		         TestBench Buzzer    						   --
-----------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


------------------------------------------------------
--	   ENTITY	                           			 --
------------------------------------------------------

ENTITY Buzzer_Testbench IS
END Buzzer_Testbench;

------------------------------------------------------
--        ARCHITECTURE	                  			 --
------------------------------------------------------
ARCHITECTURE Buzzer_Test OF Buzzer_Testbench IS

-- Simulaion Signale
SIGNAL Sim_Clock : std_logic :='0';
SIGNAL Sim_Enable : std_logic :='0';
SIGNAL Sim_BuzzerOut : std_logic :='0';


--Component to Test
component Buzzer
port (
	clk			:		IN		std_logic;						--main 50Mhz clock input		
	Enable		:		IN		std_logic;						--Turn on buzzer
													
	BuzzerOut	:		OUT	std_logic						--Output to (Hardware)-Buzzer	
	);
end component;

---------------------------------------------
BEGIN

--Generate clock of 50 MHz
Sim_Clock <= not Sim_Clock after 10 ps; -- real 10 ns

-- Component
Buzzer_1: component Buzzer PORT MAP(
	clk 			=> Sim_Clock,								
	Enable 		=> Sim_Enable, 							
	
	BuzzerOut 	=> Sim_BuzzerOut						
	);
		
--Stimulate-process
Buzzer_Test: PROCESS	
	
BEGIN
	
	-- Initialisation of variable Enable 
	Sim_Enable <= '0';
	 
	wait on Sim_Clock; --waiting for the next rising edge
	wait on Sim_Clock; 
	
	--1) Test when Enable = 0
	--2) 
	
	IF (Sim_BuzzerOut = '0') THEN
		assert FALSE report "Test Buzzer when Enable = 0 is ok" severity NOTE;
	ELSE
		assert FALSE report "Test Buzzer when Enable = 0 has failed" severity NOTE;
	END IF;
	
	Sim_Enable <= '1';
	
	assert FALSE report "All tests passed" severity Note;	
	wait;
		
	END PROCESS;
		
END Buzzer_Test;