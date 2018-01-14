------------------------------------------------------
--  Module for Timer by Samuel Daurat [178190]      --

-- This module will divide a clock:
-- Divider_in: 3
-- clk_in:		-_-_-_-_-_-_-_-_-_-_-_-_-_-
-- clk_out_alt:______--____--____--____--_
-- clk_out:		______------______------___

-- Information: When using normal mode, you have to divide the Divider by 2 to
-- have the correct frequency


-- Changelog:
-- Version 1.1RS | 15.12.17
--  *added generics
--  *improved code to use less space on FPGA and be better optimized
-- Version 1.0RS | 14.12.17
--	 *lot of changes and tests during this time
--  *commented code again
--  *renamed signals
--Version 0.1 | 27.11.17
--  *initial release
------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


------------------------------------------------------
--	   ENTITY	                           			 --
------------------------------------------------------
ENTITY ClockDivider IS

GENERIC(
	Divider_in		:	IN  integer :=50 --2499999				--Divider for dividing the clock. Default Value generates a 1/10th clock cycle from 50Mhz	
);											

PORT(															
	clk_in			:	IN	 std_logic;							--Clock input
	reset_i			:	IN	 std_logic;							--Setting this to 1 resets the timer and Sets Outputs to 0
													
	clk_out			:	OUT std_logic;							--Will be 1 half the time
	clk_out_alt		:	OUT std_logic							--Will only be 1 for 1 clock cycle
);

END ClockDivider;

------------------------------------------------------
--        ARCHITECTURE	                    			 --
------------------------------------------------------
ARCHITECTURE behave OF ClockDivider IS

	SIGNAL Counter: integer :=0;						--Temporary save the value, so we know where we are
	SIGNAL temp:	 std_logic :='0';

------------------------------------------------------
BEGIN

---------------------------------------
divide_proc : PROCESS (clk_in, reset_i)
	BEGIN
	
		IF (reset_i ='1') THEN										--Reset is active
			Counter <= 0;
			temp <= '0';
			clk_out_alt <= '0';
		ELSIF (rising_edge(clk_in)) THEN							--We have a rising edge on clock
			IF (Counter=Divider_in) THEN
				--We are at max value. Set back to 0
				Counter <= 0;
				temp <= NOT temp;
				clk_out_alt <= '1';									--Set the alternative output to 1
			ELSE
				Counter <= Counter+1;								--Increment the Variable by 1
				clk_out_alt <= '0';									--And set it back to 0
			END IF;
			
		END IF;
		
	END PROCESS divide_proc;

----------------------------------------
clk_out <= temp;	
	

END behave;
