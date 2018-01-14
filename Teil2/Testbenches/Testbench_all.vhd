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
CONSTANT Sim_clkDivider_DividerFactor : integer := 10;
SIGNAL Sim_clkDivider_reset_i 		: std_logic :='0';
SIGNAL Sim_clkDivider_clk_out 		: std_logic :='0';
SIGNAL Sim_clkDivider_clk_out_alt 	: std_logic :='0';

-- Simulation Signals for testing Buzzer
CONSTANT Sim_Buzzer_TestTime		    : integer := 1000;
CONSTANT Sim_Buzzer_ForLoopNumber	    : integer := 10;
SIGNAL Sim_Buzzer_Enable 				: std_logic :='0';
SIGNAL Sim_Buzzer_BuzzerOut 			: std_logic :='0';

--Component to Test
component ClockDivider
GENERIC(
	Divider_in		:	IN  integer :=Sim_clkDivider_DividerFactor-1
	);
port (
	clk_in			:	IN	 std_logic;							--Clock input
	reset_i			:	IN	 std_logic;							--Setting this to 1 resets the timer and Sets Outputs to 0												
	clk_out			:	OUT std_logic;							--Will be 1 half the time
	clk_out_alt		:	OUT std_logic							--Will only be 1 for 1 clock cycle
	);
end component;

component Buzzer
port (
	clk			:	IN		std_logic;				--main 50Mhz clock input		
	Enable		:	IN		std_logic;				--Turn on buzzer												
	BuzzerOut	:	OUT	std_logic					--Output to (Hardware)-Buzzer	
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
	reset_i 		=> Sim_clkDivider_reset_i, 							
	clk_out 		=> Sim_clkDivider_clk_out,
	clk_out_alt 	=> Sim_clkDivider_clk_out_alt	
	);

-- Component Buzzer
Buzzer_1: component Buzzer PORT MAP(
	clk 			=> Sim_clk,								
	Enable 		=> Sim_Buzzer_Enable, 							
	BuzzerOut 	=> Sim_Buzzer_BuzzerOut						
	);
		
--Stimulate-process
ClockDivider_Test: PROCESS
	
	VARIABLE LoopCounter_up : INTEGER := 0;
	VARIABLE LoopCounter : INTEGER  := 0;
	VARIABLE temp : INTEGER  := 0;
	
	
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
				exit L1 when (Sim_clkDivider_clk_out = '1');
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
				exit L2 when (Sim_clkDivider_clk_out = '0');
				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter := LoopCounter + 1;
			end loop;
		
		-- counting how many clk periodes clk_out = 0	
		L3 : loop
				exit L3 when (Sim_clkDivider_clk_out = '1');
				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter_up := LoopCounter_up + 1;
			end loop;		
			
		IF (LoopCounter_up = Sim_clkDivider_DividerFactor AND LoopCounter = Sim_clkDivider_DividerFactor) THEN
			assert FALSE report "ClockDivider: Divider is working." severity NOTE;
		ELSE
			assert FALSE report "ClockDivider: Divider has failed. Expected Dividingfactor: "
								& integer'image(Sim_clkDivider_DividerFactor)
								& " We have: "
								& integer'image(LoopCounter_up)
								& " and "
								& integer'image(LoopCounter)
								 severity FAILURE;
		END IF;

		--2) Test clk_out_alt when reset = 0
		
		LoopCounter_up := 0;
		LoopCounter := 0;
		
		--waiting for a new periode to begin
		L4 : loop
			exit L4 when (Sim_clkDivider_clk_out = '1');
			exit L4 when (LoopCounter>5000);
			LoopCounter := LoopCounter +1;
			wait on Sim_clk;
			wait on Sim_clk;
		end loop;
		
		-- counting how many clk periodes clk_out_alt = 1
		L5 : loop
				exit L5 when (Sim_clkDivider_clk_out_alt = '0');
				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter := LoopCounter + 1;
			end loop;
		
		-- counting how many clk periodes clk_out_alt = 0	
		L6 : loop
				exit L6 when (Sim_clkDivider_clk_out_alt = '1');
				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter_up := LoopCounter_up + 1;
			end loop;		

		IF (LoopCounter = 1 AND LoopCounter_up = Sim_clkDivider_DividerFactor-1) THEN
		assert FALSE report "ClockDivider: Divider_alt is working." severity NOTE;
		ELSE
			assert FALSE report "ClockDivider: Divider_alt has FAILED. Expected Dividingfactor: "
								& integer'image(Sim_clkDivider_DividerFactor)
								& " We have: "
								& integer'image(LoopCounter_up)
								& " and "
								& integer'image(LoopCounter)
								 severity FAILURE;
		END IF;

		--3) Test clk_out and clk_out_alt when reset = 1 
		LoopCounter := 0; 
		Sim_clkDivider_reset_i <= '1';
		wait on Sim_clk;
		wait on Sim_clk;
		
		L7 : loop
				exit L7 when (Sim_clkDivider_clk_out_alt = '1');
				exit L7 when (Sim_clkDivider_clk_out = '1');
				exit L7 when (LoopCounter > (Sim_clkDivider_DividerFactor*3));
 				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter := LoopCounter + 1;
			end loop;		
		
		IF (LoopCounter > (Sim_clkDivider_DividerFactor*3)
		   AND Sim_clkDivider_clk_out_alt = '0' AND Sim_clkDivider_clk_out = '0') THEN
			assert FALSE report "ClockDivider: Reset is working" severity NOTE;
		ELSE
			assert FALSE report "ClockDivider: Reset has FAILED" severity FAILURE;			
		END IF;

-------------------------------------------------
--Testing Buzzer
-------------------------------------------------

		LoopCounter_up := 0;
		LoopCounter:=0;

		--1) Test when Enable = 0
		--2) Test when Enable = 1
		
		--1) Test when Enable = 0
		L20 : loop
			exit L20 when (Sim_Buzzer_BuzzerOut /= '0');
			exit L20 when (LoopCounter>Sim_Buzzer_TestTime);
			LoopCounter := LoopCounter +1;
			wait on Sim_clk;
			wait on Sim_clk;
		end loop;

		IF (LoopCounter>Sim_Buzzer_TestTime) THEN
			assert FALSE report "Buzzer: Buzzer turns off" severity NOTE;
		ELSE
			assert FALSE report "Buzzer: Buzzer does not turn off" severity FAILURE;
		END IF;
		
		LoopCounter:=0;
		Sim_Buzzer_Enable <= '1';
		wait on Sim_clk;
		wait on Sim_clk;

		for temp in 1 to Sim_Buzzer_ForLoopNumber loop
			while LoopCounter < temp loop

				LoopCounter := 0;
				-- Waiting for rising edge on BuzzerOut
				L21 : while (Sim_Buzzer_BuzzerOut = '0' AND LoopCounter < Sim_Buzzer_TestTime)  loop
					wait on Sim_clk;
					wait on Sim_clk;
					LoopCounter := LoopCounter + 1;
				end loop ; -- L21

				-- Waiting for falling edge on BuzzerOut
				LoopCounter := 0;
				L22: while (Sim_Buzzer_BuzzerOut = '1' AND LoopCounter < Sim_Buzzer_TestTime ) loop
						wait on Sim_clk;
						wait on Sim_clk;
						LoopCounter := LoopCounter + 1;
					end loop;
				
				-- test if PWM of "NumberPeriodes" Period is ok 
				IF LoopCounter = temp THEN
					--assert FALSE report "Buzzer: PWM enabled: Step " & integer'image(temp) & " is working" severity NOTE;
				ELSIF LoopCounter > Sim_Buzzer_TestTime THEN
					assert FALSE report "Buzzer: PWM enabled: Step " & integer'image(temp) & " is NOT working. Test time exceded" severity FAILURE;
				END IF;	
				
			end loop ; -- identifier	
		end loop ; -- F20

		--Turning back off the Buzzer and finishing Buzzer tests
		assert FALSE report "Buzzer: is working" severity NOTE;		
		Sim_Buzzer_Enable <= '0';

-------------------------------------------------
--Testing 
-------------------------------------------------
			
		
assert FALSE report "DONE!" severity NOTE;
		wait;
			
	END PROCESS;
		
END simulate;