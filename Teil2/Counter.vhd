------------------------------------------------------
--  Module for Timer by Samuel Daurat [178190]      --

-- This module will provide the counting methodes: "incrementing", "Saving + Recall" and "Counting" 


-- Changelog:
-- Version 1.1RS | 15.12.17
--  *added comments
--Version 0.1 | 14.12.17
--  *initial release
------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


------------------------------------------------------
--	   ENTITY	                           			 --
------------------------------------------------------
ENTITY Counter IS
PORT(
																		--Hardware clock
	clk_i		 				:	IN		 std_logic;
	clk_deci_i				:	IN		 std_logic;
	
	--Control the Counter-Block
	CountBlockControl_i 	:	IN	std_logic_vector(5 downto 0);	
																		--MSB| Bit 5-4-3-2-1-0 | LSB
																		--Bit 5 : Reset
																		--Bit 4 : Counting has started / enable
																		--Bit 3 : Ready for Incrementing the Value
																		--Bit 2 : Load last Saved Value
																		--Bit 1 : Save current Counter Value
																		--Bit 0 : Enable Buzzer
	CountBlockTelemet_o 	:	OUT	std_logic;				--Bit 0 : Counter is at 0

	--Current Count Value
	CountValue_o			:	OUT integer range 0 to 6000;
	
	--User buttons
	BtnMinF_i				:	IN		 std_logic;
	BtnSecF_i				:	IN		 std_logic;
	BtnMin_i					:	IN		 std_logic;
	BtnSec_i					:	IN		 std_logic
	
	);
END Counter;

------------------------------------------------------
--        ARCHITECTURE	                  			 --
------------------------------------------------------
ARCHITECTURE behave OF Counter IS

	SIGNAL CountValue				: integer range 0 to 6000 :=0;
	SIGNAL CountValueSaved		: integer range 0 to 6000 :=0;
	SIGNAL AlreadyIncremented 	: std_logic :='0';
	SIGNAL clk_Four				: std_logic;
	
	CONSTANT Divide4Sec  		: INTEGER := 12499999;
	
	--Divides the main clock
	component ClockDivider
	  GENERIC(
			Divider_in		:	IN  integer :=2499999			--Divider for dividing the clock. Default Value generates a 1/10th clock cycle from 50Mhz	
		);
		PORT(															
			clk_in			:	IN	 std_logic;						--Clock input
			reset_i			:	IN	 std_logic;						--Setting this to 1 resets the timer and Sets Outputs to 0
															
			clk_out			:	OUT std_logic;						--Will be 1 half the time
			clk_out_alt		:	OUT std_logic						--Will only be 1 for 1 clock cycle
		);
	end component;	

------------------------------------------------------
BEGIN

--------------------------------------
ClockDivider_1: component ClockDivider
		  generic map( 
			Divider_in => Divide4Sec)
		  port map (
			  clk_in => clk_i,
			  reset_i => BtnSec_i AND BtnMin_i,
			  clk_out_alt => clk_Four
		 );

-- Registered Process --
count_proc : PROCESS (clk_i)
	BEGIN
	
		IF (rising_edge(clk_i)) THEN
			IF CountBlockControl_i(5) = '1' THEN			--Time to reset
				CountValue <= 0;
				CountValueSaved <= 0;
				AlreadyIncremented <= '0';
				
			ELSIF CountBlockControl_i(4) = '1' THEN		--Counting is enabled
				IF clk_Deci_i = '1' AND AlreadyIncremented = '0' AND CountValue>0 THEN
					CountValue <= CountValue-1;
					AlreadyIncremented <= '1';
				END IF;
				
			ELSIF CountBlockControl_i(3) = '1' THEN  		--Increment enable
				IF (BtnMinF_i = '1' OR (BtnMin_i = '0' AND clk_Four = '1') )	THEN
					IF CountValue < 5399 THEN
						CountValue <= CountValue + 600 - (CountValue mod 10);
					ELSE
						CountValue <= CountValue - 5400 - (CountValue mod 10);
					END IF;
				END IF;
				IF (BtnSecF_i = '1' OR (BtnSec_i = '0' AND clk_Four = '1') )	THEN
					IF (CountValue-(((CountValue/10)-((CountValue/10) mod 60)))*10) < 589 THEN
						CountValue <= CountValue + 10 - (CountValue mod 10);
					ELSE
						CountValue <= CountValue - 590 - (CountValue mod 10);
					END IF;
				END IF;
				
			ELSIF CountBlockControl_i(2) = '1' THEN  		--Save Value
					CountValueSaved <= CountValue;
			ELSIF CountBlockControl_i(1) = '1' THEN  		--Restore Value
					CountValue <= CountValueSaved;
			END IF;
			
			--Reset AlreadyIncremented
			IF clk_deci_i='0'  THEN
				ALreadyIncremented <= '0';
			END IF;
			
			--Write Outputs
			CountValue_o <= CountValue;
			
			IF CountValue = 0 THEN
				CountBlockTelemet_o <= '1';
			ELSE
				CountBlockTelemet_o <= '0';
			END IF;
		
		END IF;
		
END PROCESS count_proc;

END behave;
