----------------------------------------------------------
-- 					BUCHERT Jérémy									--
--					Matrikelnummer : 179162-01  					--
-- 					09/01/2018         							--
-- 		         TestBench Clock_Divider					   --
-----------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


------------------------------------------------------
--	   ENTITY	                           			 --
------------------------------------------------------

ENTITY ClockDivider_Testbench IS
END ClockDivider_Testbench;

------------------------------------------------------
--        ARCHITECTURE	                  			 --
------------------------------------------------------
ARCHITECTURE ClockDivider_Test OF ClockDivider_Testbench IS

-- Simulaion Signale
SIGNAL Sim_clk_in : std_logic :='0';
SIGNAL Sim_reset_i : std_logic :='0';
SIGNAL Sim_clk_out : std_logic :='0';
SIGNAL Sim_clk_out_alt : std_logic :='0';

--Component to Test
component ClockDivider
port (
	clk_in			:	IN	 std_logic;							--Clock input
	reset_i			:	IN	 std_logic;							--Setting this to 1 resets the timer and Sets Outputs to 0
													
	clk_out			:	OUT std_logic;							--Will be 1 half the time
	clk_out_alt		:	OUT std_logic							--Will only be 1 for 1 clock cycle
	
	);
end component;

---------------------------------------------
BEGIN

--Generate clock of 50 MHz
Sim_clk_in <= not Sim_clk_in after 10 ps; -- real 10 ns

-- Component
ClockDivider_1: component ClockDivider PORT MAP(
	clk_in 			=> Sim_clk_in,								
	reset_i 			=> Sim_reset_i, 							
	
	clk_out 			=> Sim_clk_out,
	clk_out_alt 	=> Sim_clk_out_alt	
	);
		
--Stimulate-process
ClockDivider_Test: PROCESS	

	VARIABLE CountLoop_up : INTEGER := 0;
	VARIABLE CountLoop_down : INTEGER := 0;
		
	BEGIN
		
		-- Initialisation of variable reset 
		Sim_reset_i <= '0';
		
		wait on Sim_clk_in;
		wait on Sim_clk_in;
		 
		--1) Test clk_out when reset = 0 
		--2) Test clk_out_alt when reset = 0
		--3) Test clk_out and clk_out_alt when reset = 1 
		
		--1) Test clk_out when reset = 0 
		
		--waiting for a new periode to begin
		L1 : loop
				exit L1 when (Sim_clk_out = '1');
				wait on Sim_clk_in;
				wait on Sim_clk_in;
			end loop;
		
		-- counting how many clk periodes clk_out = 1
		L2 : loop
				exit L2 when (Sim_clk_out = '0');
				wait on Sim_clk_in;
				wait on Sim_clk_in;
				CountLoop_up := CountLoop_up + 1;
			end loop;
		
		-- counting how many clk periodes clk_out = 0	
		L3 : loop
				exit L3 when (Sim_clk_out = '1');
				wait on Sim_clk_in;
				wait on Sim_clk_in;
				CountLoop_down := CountLoop_down + 1;
			end loop;		
			
		IF (CountLoop_up = 7 AND CountLoop_down = 7) THEN
			assert FALSE report "Test clk_out when reset = 0 is ok" severity NOTE;
		ELSE
			assert FALSE report "Test clk_out when reset = 0  has failed" severity NOTE;
		END IF;
		
		--2) Test clk_out_alt when reset = 0
		
		CountLoop_up := 0;
		CountLoop_down := 0;
		
		--waiting for a new periode to begin
		L4 : loop
				exit L4 when (Sim_clk_out_alt = '1');
				wait on Sim_clk_in;
				wait on Sim_clk_in;
			end loop;
		
		-- counting how many clk periodes clk_out_alt = 1
		L5 : loop
				exit L5 when (Sim_clk_out_alt = '0');
				wait on Sim_clk_in;
				wait on Sim_clk_in;
				CountLoop_up := CountLoop_up + 1;
			end loop;
		
		-- counting how many clk periodes clk_out_alt = 0	
		L6 : loop
				exit L6 when (Sim_clk_out_alt = '1');
				wait on Sim_clk_in;
				wait on Sim_clk_in;
				CountLoop_down := CountLoop_down + 1;
			end loop;		

		IF (CountLoop_up = 1 AND CountLoop_down = 6) THEN
			assert FALSE report "Test clk_out_alt when reset = 0 is ok" severity NOTE;
		ELSE
			assert FALSE report "Test clk_out_alt when reset = 0  has failed" severity NOTE;
		END IF;
			
		--3) Test clk_out and clk_out_alt when reset = 1  
		
		wait on Sim_clk_in;
		wait on Sim_clk_in;
			
		Sim_reset_i <= '1';
		
		L7 : loop
				exit L7 when (Sim_clk_out_alt = '1');
				exit L7 when (Sim_clk_out = '1');
				exit L7 when (CountLoop_up > 15);
 				wait on Sim_clk_in;
				wait on Sim_clk_in;
				CountLoop_up := CountLoop_up + 1;
			end loop;		
		
		IF (CountLoop_up > 15 AND Sim_clk_out_alt = '0' AND Sim_clk_out = '0') THEN
			assert FALSE report "Test clk_out_alt and clk_out when reset = 1 is ok" severity NOTE;
		ELSE
			assert FALSE report "Test clk_out_alt and clk_out when reset = 1  has failed" severity NOTE;
		END IF;
		
		assert FALSE report "All tests passed" severity Note;	
		wait;
			
	END PROCESS;
		
END ClockDivider_Test;