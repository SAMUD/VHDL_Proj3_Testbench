------------------------------------------------------
--  Module for Timer by Samuel Daurat [178190]      --

-- This module is the main state machine controlling
-- all the other Blocks


-- Changelog:
-- Version 1.0RS | 14.12.17
--	 *lot of changes and tests during this time
--  *commented code again
--  *had a big problem with "random working state machine" until I used
--   the State-Machine example from Quartus
-- Version 0.2 | 05.12.17
--  *refresh interfaces
-- Version 0.1 | 27.11.17
--  *initial release
------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


------------------------------------------------------
--	   ENTITY	                           			 --
------------------------------------------------------

ENTITY StateMachine IS
PORT(
		reset_i					: IN	std_logic;				--Asynchronous Reset	
		clk_i						: IN	std_logic;				--Harware Clock-Input
		clk_Deci_i				: IN	std_logic;				--Divided Clock
											
		--User buttons
		BtnStartF_i				: IN	std_logic;				--Buttons after going through FallingEdge Detection
		BtnClearF_i				: IN	std_logic;
		
		--Outputs to other blocks								--Showing the actual State on LEDs
		DebugLED_o				: OUT std_logic_vector(2 downto 0);
		
		--Control the Counter-Block							--Controlling CounterBlock
		CountBlockControl_o 	: OUT	std_logic_vector(5 downto 0);	--MSB| Bit 5-4-3-2-1-0 | LSB
																					--Bit 5 : Reset
																					--Bit 4 : Counting has started / enable
																					--Bit 3 : Ready for Incrementing the Value
																					--Bit 2 : Load last Saved Value
																					--Bit 1 : Save current Counter Value
																					--Bit 0 : Enable Buzzer
		CountBlockTelemet_i 	: IN	std_logic							--Bit 0 : Counter is at 0
	);
END StateMachine;

------------------------------------------------------
--        ARCHITECTURE	                            --
------------------------------------------------------
ARCHITECTURE behave OF StateMachine IS

TYPE 		state IS (st_reset,st_100,st_190,st_200,st_290,st_291,st_300,st_390);
SIGNAL 	mode 					: 	state;

SIGNAL 	CountValueBuzzer	:	integer range 0 to 6000 :=0;
CONSTANT BuzzerPreload 		: 	integer 						:= 600; --1 Minute of buzzing
SIGNAL 	AlreadyDone			: 	std_logic 					:='0';


BEGIN

-- Registered Process --
clk_proc : PROCESS (clk_i,reset_i)

BEGIN
		
		IF (reset_i='1') THEN  				-- Active Reset
			mode <= st_reset;
		ELSIF (rising_edge(clk_i)) THEN
												--Set the next mode each X clk-Cycles
			CASE mode IS
				WHEN st_reset => 				-- Reset mode
						mode <= st_100;
						
				WHEN st_100 =>					-- Set up time
						IF BtnStartF_i = '1' AND CountBlockTelemet_i = '0' THEN
							mode <= st_190;	--with saving
						ELSIF BtnClearF_i = '1' THEN
							mode <= st_reset;
						END IF;
						
				WHEN st_190 =>						--Pause pressed.				
						IF BtnStartF_i = '0' THEN
							mode <= st_200;
						END IF;
						
		------------------------------------
				WHEN st_200 =>
						IF CountBlockTelemet_i = '1'  THEN
							mode <= st_291;
						ELSIF BtnStartF_i = '1' THEN
							mode <= st_290;
						END IF;
						
				WHEN st_290 =>						--Pause pressed.				
						IF BtnStartF_i = '0' THEN
							mode <= st_100;
						END IF;
						
				WHEN st_291 =>						--Prepare Buzzer.				
						IF CountValueBuzzer = BuzzerPreload THEN
							mode <= st_300;
						END IF;
						
		------------------------------------
				WHEN st_300 =>
						IF  CountValueBuzzer < 2 OR BtnStartF_i = '1' THEN
							mode <= st_390;	--value load
						END IF;
						
				WHEN st_390 =>					
						IF BtnStartF_i = '0' THEN
							mode <= st_100;
						END IF;
						
				WHEN others =>
						mode <= st_reset;
							
				END CASE;
		END IF;
		
END PROCESS clk_proc;
	   
-- Output Process --
output_proc : PROCESS (clk_i)
	BEGIN
		
	   CASE mode IS
	   WHEN st_reset => 				-- Reset mode
				DebugLED_o <= "111";
				CountBlockControl_o <= "100000";	
		WHEN st_100 =>					-- Set up time
				DebugLED_o <= "100";
				CountBlockControl_o <= "001000";
		WHEN st_190 =>					-- Set up time
				DebugLED_o <= "110";
				CountBlockControl_o <= "000100";
------------------------------------
		WHEN st_200 =>
				DebugLED_o <= "010";
				CountBlockControl_o <= "010000";		
		WHEN st_290 =>	
				DebugLED_o <= "110";
				CountBlockControl_o <= "000000";		
		WHEN st_291 =>	
				DebugLED_o <= "011";
				CountBlockControl_o <= "000000";	
				CountValueBuzzer <= BuzzerPreload;
------------------------------------
		WHEN st_300 =>
				DebugLED_o <= "001";
				CountBlockControl_o <= "000001";	
				IF AlreadyDone = '0' AND clk_Deci_i = '1' THEN
					CountValueBuzzer <= CountValueBuzzer-1;
					AlreadyDone <= '1';
				END IF;
				IF AlreadyDone = '1' AND clk_Deci_i = '0' THEN
					AlreadyDone <= '0';
				END IF;
		WHEN st_390 =>
				DebugLED_o <= "101";
				CountBlockControl_o <= "000010";	
		WHEN others =>
				DebugLED_o <= "101";
				CountBlockControl_o <= "010101";
		END CASE;
			
	END PROCESS output_proc;

END behave;