------------------------------------------------------
--  Module for Timer by Samuel Daurat [178190]      --

-- This is a complete Module to make a PWM buzzer
-- The buzzer will sound with an increasing volume in an intervall of 4sec
-- The module needs Version 1.0RS of ClockDivider.vhd


-- Changelog:
-- Version 1.0RS | 14.12.17
--	 *lot of changes and tests during this time
--  *commented code again
--  *renamed signals
--  *initial release for the public
--Version 0.1 | 27.11.17
--  *started coding
------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


------------------------------------------------------
--	   ENTITY	                           			 --
------------------------------------------------------
ENTITY Buzzer IS
PORT(
	
	clk			:		IN		std_logic;						--main 50Mhz clock input		
	Enable		:		IN		std_logic;						--Turn on buzzer
													
	BuzzerOut	:		OUT	std_logic						--Output to (Hardware)-Buzzer
	
	);
END Buzzer;

------------------------------------------------------
--        ARCHITECTURE	                            --
------------------------------------------------------
ARCHITECTURE behave OF Buzzer IS

	CONSTANT Period  : INTEGER := 50 ;						--We will have 1000 possible PWM-Steps.
	CONSTANT Divide100Sec  		: INTEGER := 400; 			--CONSTANT for Clock Divider to have 4sec.
	--Note: increased speed by 1000. original value is 400000
--	Information: the first ideo was to increase the second counted value from 0 to 1000 in 4sec.
--	The problem is, that in the range from 500 to 1000 the Buzzer-Volume does almost not change.
--	Solution: only count from 0 to 500 and divide the counting speed by 2.
--	If you want to count from 0 to 1000 change the Clock divider back to 200000.
																			
	SIGNAL	clk_PWM				:	std_logic;					--Divided clock
	
	SIGNAL	CountedValue : INTEGER range 0 to 1001; 		--Counter for clk --> Counting from 0 to 1000
	SIGNAL	CountedValue2nd : INTEGER range 0 to 1001;	--Counter for clk_PWM --> Counting from 0 to 500	
	
	--Divides the main clock
	component ClockDivider
	  GENERIC(
			Divider_in		:	IN  integer								--Divider for dividing the clock. Default Value generates a 1/10th clock cycle from 50Mhz	
		);
		PORT(															
			clk_in			:	IN	 std_logic;							--Clock input
			reset_i			:	IN	 std_logic;							--Setting this to 1 resets the timer and Sets Outputs to 0
															
			clk_out			:	OUT std_logic;							--Will be 1 half the time
			clk_out_alt		:	OUT std_logic							--Will only be 1 for 1 clock cycle
		);
	end component;	

------------------------------------------------------	
BEGIN

--call clock-Divider
	ClockDivider_PWM: component ClockDivider
		 generic map( 
			Divider_in => Divide100Sec)
		 port map (
			  clk_in => clk,
			  reset_i => '0', --Reset off here
			  clk_out_alt => clk_PWM
		 );

-- counting the main Value for PWM
	Counting : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			
			CountedValue <= CountedValue+1;					--Increase the Counter
		
			IF CountedValue > Period THEN
				--set the counter back to 0 if e are at "Period" (1000)
				CountedValue <= 0;
			END IF;		
		
		END IF;
	END PROCESS Counting;
	
-- counting the second PWM value and taking care of "Enable"
	CountingAgain : PROCESS (clk_PWM)
	BEGIN
		IF (clk_PWM'EVENT AND clk_PWM='1' AND clk_PWM'LAST_VALUE='0') THEN
	
			CountedValue2nd <= CountedValue2nd + 1;		--Increase the Counter
			
			IF CountedValue2nd > (Period/2) OR Enable = '0' THEN--we use Period/2 to only count up to 500
				--set the counter back to 0 if e are at "Period/2" or if we turn of enable
				CountedValue2nd <= 0;
			END IF;
		
		END IF;
	END PROCESS CountingAgain;
	
-- compare and write Output
	Compare : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			
			IF CountedValue2nd > CountedValue THEN
				BuzzerOut <= '1';
			ELSE
				BuzzerOut <= '0';
			END IF;	
		
		END IF;		
	END PROCESS Compare;
	
END behave;




