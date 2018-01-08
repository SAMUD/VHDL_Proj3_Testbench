------------------------------------------------------
--  7Seg-Decoder by Samuel Daurat [178190]  --

-- This module decodes a 4 bit binary input to a 7seg-Display Output

-- Special cases:
--  *sending a 1111 will show a - on the 7seg-Display

-- Changelog:
-- Version 1.3RS | 04.12.17
--  *changed inputs to vector
-- Version 1.2 | 03.12.17
--  *changed outputs to vector
-- Version 1.1 | 27.11.17
--  *changed inputs to vector
--  *fixed event detection
--	 *added comments and formatted code
-- Version 1.0 | 17.10.17
--  *initial release
------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


--------------------------------------------
--	   ENTITY	                           --
--------------------------------------------
ENTITY Decoder IS
PORT(
	
													--signals between Counter and Decoder. Contains the actual counting value
													--MSB 3 2 1 0 LSB
	Input			:		IN		std_logic_vector (3 downto 0);
	
													-- decoded signals to send to the 7seg
	Output		:		OUT	std_logic_vector (6 downto 0)
	);
END Decoder;

--------------------------------------------
--        ARCHITECTURE	                    --
--------------------------------------------
ARCHITECTURE behave OF Decoder IS

BEGIN

	
	-- Output for 7seg-Display
	Output(0) <= (NOT Input(3) AND NOT Input(2) AND NOT Input(1) AND 		Input(0)) 	OR
					 (NOT Input(3) AND     Input(2) 						 AND NOT Input(0)) 	OR
					 (		Input(3) AND 	  Input(2));
			
	Output(1) <= (							  Input(2) AND NOT Input(1) AND     Input(0)) 	OR
					 (    Input(3) AND     Input(2)) 												OR
					 (  						  Input(2) AND 	 Input(1) AND NOT Input(0));
			
	Output(2) <= ( 		Input(3) AND 	  Input(2)) 												OR
					 (						 	 NOT Input(2) AND     Input(1) AND NOT Input(0));
			
	Output(3) <= (							  Input(2) AND NOT Input(1) AND NOT Input(0)) 	OR
					 (						 NOT Input(2) AND NOT Input(1) AND 		Input(0)) 	OR
					 (							  Input(2) AND 	 Input(1) AND 		Input(0));
			
	Output(4) <= 																			Input(0) 	OR
					 (							  Input(2) AND NOT Input(1) AND NOT Input(0));
			
	Output(5) <= (													 Input(1) AND 		Input(0)) 	OR
					 (NOT Input(3) AND NOT Input(2) AND 	 Input(1)) 							OR
					 (NOT Input(3) AND NOT Input(2) 						 AND 		Input(0));
			
	Output(6) <= (NOT Input(3) AND NOT Input(2) AND NOT Input(1)) 							OR
					 (NOT Input(3) AND 	  Input(2) AND 	 Input(1) AND 		Input(0));

END behave;
