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

ENTITY Main IS
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
END Main;

------------------------------------------------------
--        ARCHITECTURE	                  			 --
------------------------------------------------------
ARCHITECTURE behave OF Main IS

--internal Signals
	SIGNAL BtnStartFalling	:	std_logic := '0'; 		--Buttons after Falling Edge detection
	SIGNAL BtnClearFalling	:	std_logic := '0';
	SIGNAL BtnMinFalling		:	std_logic := '0';
	SIGNAL BtnSecFalling		:	std_logic := '0';
	
	SIGNAL CountBlockControl:	std_logic_vector(5 downto 0) :="000000";
	SIGNAL CountBlockTelemet:	std_logic :='0';
	
	SIGNAL clk_Deci			:	std_logic;
	
	SIGNAL CountValue : integer range 0 to 6000 :=0;

--Divides the main clock
	component ClockDivider
	  GENERIC(
			Divider_in		:	IN  integer :=2500				--Divider for dividing the clock. Default Value generates a 1/10th clock cycle from 50Mhz	
			--Note: Clock increased by a factor of ca. 1000. original value is 2499999
		);

		PORT(															
			clk_in			:	IN	 std_logic;							--Clock input
			reset_i			:	IN	 std_logic;							--Setting this to 1 resets the timer and Sets Outputs to 0												
			clk_out			:	OUT std_logic;							--Will be 1 half the time
			clk_out_alt		:	OUT std_logic							--Will only be 1 for 1 clock cycle
		);
	end component;	
	
--Main state machine
	component StateMachine
	  port(											
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
		CountBlockTelemet_i 	: IN	std_logic	
	);
	end component;
	
	
--Detecting a falling edge (when button is pressed)
	component FallingEdge
	  port(
		clk_i				:	IN		std_logic;						--main 50Mhz clock input
		Button_i			:	IN		std_logic;						--Input for the Button												
		Falling_o		:	OUT	std_logic						--Signal output
	);
	end component;
	
--Counter
	component Counter
	  port(
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
	end component;

--Converting time int to show on the 7seg-Display
	component ConvertIntBcd
	  port(															
		InputInt		:		IN			integer range 0 to 6000 ;		--Input signal containing the actual time information in Deci-Sec												
		SevenSeg1	:		OUT	std_logic_vector (6 downto 0);	-- decoded signals to send to the 7seg
		SevenSeg2	:		OUT	std_logic_vector (6 downto 0);	
		SevenSeg3	:		OUT	std_logic_vector (6 downto 0);	
		SevenSeg4	:		OUT	std_logic_vector (6 downto 0)
	);
	end component;
	
--Buzzer ontrol with increasing volume each 4 seconds
	component Buzzer
	  port(
		clk			:		IN		std_logic;
		Enable		:		IN		std_logic;										
		BuzzerOut	:		OUT	std_logic
	);
	end component;
	

BEGIN

----------------------------------------------
--Write some debug outputs
	--DebugLED_Control <= CountBlockControl;
	--CountValueMainOut <= CountValue;

----------------------------------------------
--State machine
	StateMachine_1: component StateMachine
		port map (
			reset_i 					=> reset,
			clk_i						=> clk,
			clk_Deci_i				=>clk_Deci,
												
			BtnStartF_i				=> BtnStartFalling,
			BtnClearF_i				=> BtnClearFalling,
			
			--Outputs to other blocks
			--DebugLED_o				=> DebugLED,
			
			--Control the Counter-Block
			CountBlockControl_o	=> CountBlockControl,
			CountBlockTelemet_i	=> CountBlockTelemet		
			);
			
----------------------------------------------
--Falling Edge		
	FallingEdge_Clear : component FallingEdge
		port map(
			clk_i => clk,
			Button_i => BtnClear,
			Falling_o => BtnClearFalling
			);
			
	FallingEdge_Start : component FallingEdge
		port map(
			clk_i => clk,
			Button_i => BtnStart,
			Falling_o => BtnStartFalling
			);
			
	FallingEdge_Min : component FallingEdge
		port map(
			clk_i => clk,
			Button_i => BtnMin,
			Falling_o => BtnMinFalling
			);
	
	FallingEdge_Sec : component FallingEdge
		port map(
			clk_i => clk,
			Button_i => BtnSec,
			Falling_o => BtnSecFalling
			);

----------------------------------------------
--Falling Edge
	Counter_1 : component Counter
		port map(
			clk_i		  => clk,
			clk_deci_i=>clk_Deci,
			
			--Control the Counter-Block
			CountBlockControl_i 	=> CountBlockControl,
			CountBlockTelemet_o 	=> CountBlockTelemet,
			CountValue_o		=> CountValue,
			
			--User buttons
			BtnMinF_i		=>BtnMinFalling,
			BtnSecF_i		=>BtnSecFalling,
			BtnMin_i			=>BtnMin,
			BtnSec_i			=>BtnSec
			);
			

----------------------------------------------
--Clock Divider
	ClockDivider_1: component ClockDivider
		  port map (
			  clk_in => clk,
			  reset_i => '0',
			  clk_out => clk_Deci
	);

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
		
----------------------------------------------
--Buzzer	
Buzzer_1	:component Buzzer
		port map(
		clk => clk,
		Enable => CountBlockControl(0) OR BuzzerOverride,
		BuzzerOut => BuzzerOut
	);
	
END behave;