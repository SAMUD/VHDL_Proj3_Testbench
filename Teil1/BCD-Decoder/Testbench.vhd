------------------------------------------------------
--  Testbench by Samuel Daurat [178190]      --

-- This module is a testbench and will be used to test the BCD Decoder


-- Changelog:
-- Version 0.1| 12912.17
--  *initial release
------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


------------------------------------------------------
--	   ENTITY	                           			 --
------------------------------------------------------

ENTITY Testbench IS
PORT(
	reset				:	IN		std_logic;						--Mapped to SW0
	clk				:	IN		std_logic;
	
	--User buttons
	BtnMin			:	IN		std_logic;						--Mapped to Btn3
	BtnSec			:	IN		std_logic;						--Mapped to Btn2
	BtnStart			:	IN		std_logic;						--Mapped to Btn0
	BtnClear			:	IN		std_logic;						--Mapped to Btn1
	
	--Debug buttons
	BuzzerOverride	:	IN		std_logic;						--Manual activation for the Buzzer, Mapped to SW1
	--SW2				:	IN		std_logic;
	--SW3				:	IN		std_logic;
	
	-- decoded signals to send to the 7seg
	Output1			:	OUT	std_logic_vector (6 downto 0);	
	Output2			:	OUT	std_logic_vector (6 downto 0);	
	Output3			:	OUT	std_logic_vector (6 downto 0);	
	Output4			:	OUT	std_logic_vector (6 downto 0);
	
	--Debug outputs
	CountValueMainOut:OUT 	integer range 0 to 6000 := 0;					--Showing the actual count value in binary on LEDs Red 17-
	DebugLED			:	OUT 	std_logic_vector(2 downto 0) := "000";		--Showing state of state machine on LEDs Green 
	DebugLED_Control:	OUT 	std_logic_vector(5 downto 0):= "000000";	--Showing the control status from state machine to Counter
		
	--Buzzer Output
	BuzzerOut		:	OUT	std_logic
	
	);
END Testbench;

------------------------------------------------------
--        ARCHITECTURE	                  			 --
------------------------------------------------------
ARCHITECTURE simulate OF Testbench IS

--internal Signals
	SIGNAL BtnStartFalling	:	std_logic := '0'; 		--Buttons after Falling Edge detection
	SIGNAL BtnClearFalling	:	std_logic := '0';
	SIGNAL BtnMinFalling		:	std_logic := '0';
	SIGNAL BtnSecFalling		:	std_logic := '0';
	
	SIGNAL CountBlockControl:	std_logic_vector(5 downto 0) :="000000";
	SIGNAL CountBlockTelemet:	std_logic :='0';
	
	SIGNAL clk_Deci			:	std_logic;
	
	SIGNAL CountValue : integer range 0 to 6000 :=0
	

BEGIN

----------------------------------------------
--Convert Int to 7Seg	 
ConvertIntBcd_1: component ConvertIntBcd
		port map(
				InputInt => CountValue,											
				SevenSeg1 => Output1,
				SevenSeg2 => Output2,
				SevenSeg3 => Output3,
				SevenSeg4 => Output4
		);
	
END simulate;