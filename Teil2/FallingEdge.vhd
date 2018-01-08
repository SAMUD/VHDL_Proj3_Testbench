------------------------------------------------------
--  Module for Timer by Samuel Daurat [178190]      --

-- This module will detect falling edges. --> Button pressed on the board.
-- Button_i: 	------_______-----
-- Falling_o:	______-___________


-- Changelog:
-- Version 1.0RS | 14.12.17
--	 *lot of changes and tests during this time
--  *commented code again
--  *renamed signals
-- Version 0.9 | 06.12.17
--  *added comments
-- Version 0.2 | 05.12.17
--  *initial release
------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


------------------------------------------------------
--	   ENTITY	                           			 --
------------------------------------------------------
ENTITY FallingEdge IS
PORT(
	
	clk_i				:	IN		std_logic;						--main 50Mhz clock input
	Button_i			:	IN		std_logic;						--Input for the Button
													
	Falling_o		:	OUT	std_logic						--Signal output
	
	);
END FallingEdge;

------------------------------------------------------
--        ARCHITECTURE	                            --
------------------------------------------------------
ARCHITECTURE behave OF FallingEdge IS

	SIGNAL	SavedValue : std_logic :='0';					--Save the last Value of Button to compare

------------------------------------------------------
BEGIN

	Check : PROCESS (clk_i)								
	BEGIN
	
        IF (clk_i = '1' AND clk_i'EVENT) THEN			--Save the actual value in Saved Value 
			SavedValue<=Button_i;
        END IF;
		  
		  Falling_o<= (NOT Button_i) AND SavedValue ;   --When Button is pressed and the saved value is still
																		--"button not pressed", generate an output signal
	END PROCESS Check;
	
END behave;