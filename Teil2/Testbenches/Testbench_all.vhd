------------------------------------------------------
--  Testbench by Samuel Daurat, Xavier VOLTZENLOGEL, Jeremy Buchert, Arthur DISCHLI      --
-- This module is a testbench and will be used to test the complete Timer module
------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


------------------------------------------------------
--	   ENTITY	                           			 --
------------------------------------------------------

ENTITY Testbench_all IS
END Testbench_all;

------------------------------------------------------
--        ARCHITECTURE	                  			 --
------------------------------------------------------
ARCHITECTURE simulate OF Testbench_all IS

--Signals for all DUT
SIGNAL Sim_clk 			: std_logic :='0';

-- Simulaion Signale for testing ClockDivider
CONSTANT Sim_ClockDivider_DividerFactor : integer := 10;
SIGNAL Sim_ClockDivider_reset_i 		: std_logic :='0';
SIGNAL Sim_ClockDivider_clk_out 		: std_logic :='0';
SIGNAL Sim_ClockDivider_clk_out_alt 	: std_logic :='0';

--Component to Test
component ClockDivider
GENERIC(
	Divider_in		:	IN  integer :=Sim_ClockDivider_DividerFactor-1
	);
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
Sim_clk <= not Sim_clk after 1 ps; --50Mhz normally duty-Cycle of 10ns

-- Component Clock Divider
ClockDivider_1: component ClockDivider PORT MAP(
	-->we will use the stock dividing speed for the clock
	clk_in 			=> Sim_clk,								
	reset_i 		=> Sim_ClockDivider_reset_i, 							
	clk_out 		=> Sim_ClockDivider_clk_out,
	clk_out_alt 	=> Sim_ClockDivider_clk_out_alt	
	);
		
--Stimulate-process
ClockDivider_Test: PROCESS

	VARIABLE ErrorCounter : INTEGER := 0;	--this will count the Errors.
	
	VARIABLE LoopCounter_up : INTEGER := 0;
	VARIABLE LoopCounter : INTEGER  := 0;
		
	BEGIN

		--finding a rising edge
		wait on Sim_clk;
		while (Sim_clk /= '0') loop
			wait on Sim_clk;
		end loop;

-------------------------------------------------
--Testing Clockdivider
-------------------------------------------------
		 
		--1) Test clk_out when reset = 0 
		--2) Test clk_out_alt when reset = 0
		--3) Test clk_out and clk_out_alt when reset = 1 
		
		--1) Test clk_out when reset = 0 
		
		--waiting for a new periode to begin
		L1 : loop
				exit L1 when (Sim_ClockDivider_clk_out = '1');
				exit L1 when (LoopCounter>5000);
				LoopCounter := LoopCounter +1;
				wait on Sim_clk;
				wait on Sim_clk;
			end loop;

		if LoopCounter>5000 then
			--there was no rising edge
			--fatal error. Abort all other tests
			assert FALSE report "ClockDivider: No initial rising edge found" severity FAILURE;			
			wait;
		end if ;
		LoopCounter := 0;
		
		-- counting how many clk periodes clk_out = 1
		L2 : loop
				exit L2 when (Sim_ClockDivider_clk_out = '0');
				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter := LoopCounter + 1;
			end loop;
		
		-- counting how many clk periodes clk_out = 0	
		L3 : loop
				exit L3 when (Sim_ClockDivider_clk_out = '1');
				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter_up := LoopCounter_up + 1;
			end loop;		
			
		IF (LoopCounter_up = Sim_ClockDivider_DividerFactor AND LoopCounter = Sim_ClockDivider_DividerFactor) THEN
			assert FALSE report "ClockDivider: Divider is working." severity NOTE;
		ELSE
			assert FALSE report "ClockDivider: Divider has failed. Expected Dividingfactor: "
								& integer'image(Sim_ClockDivider_DividerFactor)
								& " We have: "
								& integer'image(LoopCounter_up)
								& " and "
								& integer'image(LoopCounter)
								 severity NOTE;
			ErrorCounter := ErrorCounter +1;
		END IF;

		--2) Test clk_out_alt when reset = 0
		
		LoopCounter_up := 0;
		LoopCounter := 0;
		
		--waiting for a new periode to begin
		L4 : loop
			exit L4 when (Sim_ClockDivider_clk_out = '1');
			exit L4 when (LoopCounter>5000);
			LoopCounter := LoopCounter +1;
			wait on Sim_clk;
			wait on Sim_clk;
		end loop;
		
		-- counting how many clk periodes clk_out_alt = 1
		L5 : loop
				exit L5 when (Sim_ClockDivider_clk_out_alt = '0');
				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter := LoopCounter + 1;
			end loop;
		
		-- counting how many clk periodes clk_out_alt = 0	
		L6 : loop
				exit L6 when (Sim_ClockDivider_clk_out_alt = '1');
				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter_up := LoopCounter_up + 1;
			end loop;		

		IF (LoopCounter = 1 AND LoopCounter_up = Sim_ClockDivider_DividerFactor-1) THEN
		assert FALSE report "ClockDivider: Divider_alt is working." severity NOTE;
		ELSE
			assert FALSE report "ClockDivider: Divider_alt has FAILED. Expected Dividingfactor: "
								& integer'image(Sim_ClockDivider_DividerFactor)
								& " We have: "
								& integer'image(LoopCounter_up)
								& " and "
								& integer'image(LoopCounter)
								 severity NOTE;
			ErrorCounter := ErrorCounter +1;
		END IF;

		--3) Test clk_out and clk_out_alt when reset = 1 
		LoopCounter := 0; 
		Sim_ClockDivider_reset_i <= '1';
		wait on Sim_clk;
		wait on Sim_clk;
		
		L7 : loop
				exit L7 when (Sim_ClockDivider_clk_out_alt = '1');
				exit L7 when (Sim_ClockDivider_clk_out = '1');
				exit L7 when (LoopCounter > (Sim_ClockDivider_DividerFactor*3));
 				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter := LoopCounter + 1;
			end loop;		
		
		IF (LoopCounter > (Sim_ClockDivider_DividerFactor*3)
		   AND Sim_ClockDivider_clk_out_alt = '0' AND Sim_ClockDivider_clk_out = '0') THEN
			assert FALSE report "ClockDivider: Reset is working" severity NOTE;
		ELSE
			assert FALSE report "ClockDivider: Reset has FAILED" severity NOTE;
			ErrorCounter := ErrorCounter +1;			
		END IF;
		
		
		assert FALSE report "DONE! with " & integer'image(ErrorCounter) & " Errors." severity NOTE;
		wait;
			
	END PROCESS;
		
END simulate;