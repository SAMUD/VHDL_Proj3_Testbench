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
Sim_Clock <= not Sim_Clock after 1 ps; -- real 10 ns

-- Component
Buzzer_1: component Buzzer PORT MAP(
	clk 			=> Sim_Clock,								
	Enable 		=> Sim_Enable, 							
	
	BuzzerOut 	=> Sim_BuzzerOut						
	);
		
--Stimulate-process
Buzzer_Test: PROCESS	

VARIABLE CountLoop_up : INTEGER := 0;				-- Counter of PWM length
VARIABLE CountLoop_up_1 : INTEGER := 0;			-- Counter save of PWM length
VARIABLE CountLoop_up_2 : INTEGER := 0;			-- Counter save of PWM length
VARIABLE CountLoop_up_3 : INTEGER := 0;			-- Counter save of PWM length
VARIABLE CountLoop_error : std_logic := '0';		-- flag to detect an error in the PWM
	
BEGIN
	
	-- Initialisation of variable Enable 
	Sim_Enable <= '0';
	 
	wait on Sim_Clock; --waiting for the next rising edge
	wait on Sim_Clock; 
	
	--1) Test when Enable = 0
	--2) Test when Enable = 1
	
	--1) Test when Enable = 0
	IF (Sim_BuzzerOut = '0') THEN
		assert FALSE report "Test Buzzer when Enable = 0 is ok" severity NOTE;
	ELSE
		assert FALSE report "Test Buzzer when Enable = 0 has failed" severity NOTE;
	END IF;
	
	--2) Test when Enable = 1
	Sim_Enable <= '1';
	
	-- test for PWM of 1 Period
	while CountLoop_up < 1 loop
		CountLoop_up := 0;
		
		-- Waiting for rising edge on BuzzerOut
		L1 : loop
				exit L1 when (Sim_BuzzerOut = '1');
				exit L1 when (CountLoop_up > 60);
				wait on Sim_Clock;
				wait on Sim_Clock;
				CountLoop_up := CountLoop_up + 1;
			end loop;
		
		-- Waiting for falling edge on BuzzerOut
		CountLoop_up := 0;
		L2 : loop
				exit L2 when (Sim_BuzzerOut = '0');
				exit L2 when (CountLoop_up > 10);
				wait on Sim_Clock;
				wait on Sim_Clock;
				CountLoop_up := CountLoop_up + 1;
			end loop;
		
		-- test if PWM of 1 Period is ok 
		IF CountLoop_up = 1 THEN
			CountLoop_up_1 := CountLoop_up;
		ELSIF (CountLoop_up = 0 OR CountLoop_up > 10) THEN
			CountLoop_error := '1';
		END IF;	
		
		exit when CountLoop_error = '1';
	end loop;
	
	-- test for PWM of 2 Periods
	CountLoop_up := 0;
	while CountLoop_up < 2 loop
		CountLoop_up := 0;
		
		-- Waiting for rising edge on BuzzerOut
		L3 : loop
				exit L3 when (Sim_BuzzerOut = '1');
				exit L3 when (CountLoop_up > 60);
				wait on Sim_Clock;
				wait on Sim_Clock;
				CountLoop_up := CountLoop_up + 1;
			end loop;
		
		-- Waiting for falling edge on BuzzerOut
		CountLoop_up := 0;
		L4 : loop
				exit L4 when (Sim_BuzzerOut = '0');
				exit L4 when (CountLoop_up > 10);
				wait on Sim_Clock;
				wait on Sim_Clock;
				CountLoop_up := CountLoop_up + 1;
			end loop;
		
		-- test if PWM of 2 Periods is ok	
		IF CountLoop_up = 2 THEN
			CountLoop_up_2 := CountLoop_up;
		ELSIF (CountLoop_up = 0 OR CountLoop_up > 10) THEN
			CountLoop_error := '1';
		END IF;	
		
		exit when CountLoop_error = '1';
		
	end loop;	
	
	-- test for PWM of 3 Periods
	CountLoop_up := 0;
	while CountLoop_up < 3 loop
		CountLoop_up := 0;
		
		-- Waiting for rising edge on BuzzerOut
		L5 : loop
				exit L5 when (Sim_BuzzerOut = '1');
				exit L5 when (CountLoop_up > 60);
				wait on Sim_Clock;
				wait on Sim_Clock;
				CountLoop_up := CountLoop_up + 1;
			end loop;
			
		-- Waiting for falling edge on BuzzerOut	
		CountLoop_up := 0;
		L6 : loop
				exit L6 when (Sim_BuzzerOut = '0'); 
				exit L6 when (CountLoop_up > 10);
				wait on Sim_Clock;
				wait on Sim_Clock;
				CountLoop_up := CountLoop_up + 1;
			end loop;
		
		-- test if PWM of 3 Periods is ok	
		IF CountLoop_up = 3 THEN
			CountLoop_up_3 := CountLoop_up;
		ELSIF (CountLoop_up = 0 OR CountLoop_up > 10) THEN
			CountLoop_error := '1';
		END IF;	
		
		exit when CountLoop_error = '1';
		
	end loop;	
	
	
	IF (CountLoop_up_1 = 1 AND CountLoop_up_2 = 2 AND CountLoop_up_3 = 3 AND CountLoop_error = '0') THEN
		assert FALSE report "Test Buzzer when Enable = 1 is ok" severity NOTE;
	ELSE
		assert FALSE report "Test Buzzer when Enable = 1 has failed" severity NOTE;
	END IF;	
		
	assert FALSE report "All tests passed" severity Note;	
	wait;
		
	END PROCESS;
		
END Buzzer_Test;