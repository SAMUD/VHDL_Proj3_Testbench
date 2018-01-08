------------------------------------------------------
--  Timer by Samuel Daurat [178190]  --
------------------------------------------------------

------------------------------------------------------
--  Top Level Entity by Samuel Daurat [178190]  --


-- Changelog:
-- Version 2.0 | 
-- Version 1.1 | 05.12.17
--  *refresh interfaces
-- Version 1.0 | 27.11.17
--  *initial release
------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

--------------------------------------------
--	   ENTITY	                           --
--------------------------------------------
ENTITY SubMain IS
PORT(
	reset_i					:	IN		std_logic;	--Mapped to SW0
	clk_i						:	IN		std_logic;
	
	--User buttons
	BtnMin_i					:	IN		std_logic;	--Mapped to Btn3
	BtnSec_i					:	IN		std_logic;	--Mapped to Btn2
	BtnStart_i				:	IN		std_logic;	--Mapped to Btn0
	BtnClear_i				:	IN		std_logic;	--Mapped to Btn1
	
	
	--Debug outputs
	DebugLED_o 				: 	OUT 	std_logic_vector(2 downto 0);		--Showing state of state machine on LEDs Green 
	DebugLED_Control_o 	: 	OUT 	std_logic_vector(5 downto 0);
	Debug_clk_Deci_o		:	OUT	std_logic;
	
	--Count Value Output
	CountValue_o			:	OUT	integer range 0 to 6000;			--Current counting value in Deci-Seconds
	
	--Buzzer Output
	Buzzer_o					:	OUT	std_logic
	);
END SubMain;

--------------------------------------------
--        ARCHITECTURE	                  --
--------------------------------------------
ARCHITECTURE behave OF SubMain IS
	--constants
	CONSTANT Divide10Sec  	: INTEGER := 5000000;
	
	
	--internal Signals
	SIGNAL BtnMinFalling		:	std_logic;
	SIGNAL BtnSecFalling		:	std_logic;
	SIGNAL BtnStartFalling	:	std_logic;
	SIGNAL BtnClearFalling	:	std_logic;
	
	SIGNAL CountBlockControl:	std_logic_vector(5 downto 0);
	SIGNAL CountBlockTelemet:	std_logic;
	
	SIGNAL clk_Deci			:	std_logic;
	
	--Detecting a falling edge (when button is pressed)
	component FallingEdge
	  port(
		clk			 :		IN		std_logic;			--main 50Mhz clock input		
		Button		 :		IN		std_logic;			--Input											
		FallingOutput:		OUT	std_logic			--Output
	);
	end component;
	
	--Divides the main clock
	component ClockDivider
	  port(
														
		clk_in		:		IN		std_logic;							--Hardware clock
		Divider_in	:		IN integer range 0 to 100000005;		--Divider					
		clk_out		:		OUT	std_logic;							--divided clock
		clk_out_alt	:		OUT std_logic
	);
	end component;
	
	--Main state machine
	component StateMachine
	  port(											
			reset_i			:		IN		std_logic;
			clk_i				:		IN		std_logic;
			clk_deci_i		:		IN		std_logic;
												
			--User buttons
			BtnMinF_i		:		IN		 std_logic;
			BtnSecF_i		:		IN		 std_logic;
			BtnStartF_i		:		IN		 std_logic;
			BtnClearF_i		:		IN		 std_logic;
			
			--Outputs to other blocks
			DebugLED_o		:	OUT 	std_logic_vector(2 downto 0);
			BuzzerEnable_o	:	OUT	std_logic;
			
			--Control the Counter-Block
			CountBlockControl_o 	:OUT	std_logic_vector(5 downto 0);	--Bit0: LoadLastSavedValue (Left)
																						--Bit1: SaveActualValue
																						--Bit2: Inrement 1s
																						--Bit3: Increment 1min
																						--Bit4: Counting is enabled
																						--Bit5: Reset to 0			(Right)
			CountBlockTelemet_i 	:In	std_logic							--Bit0: Counter is at 0
	);
	end component;
	
	--Counter
	component Counter
	  port(
														
		clk_i		:		IN		 std_logic;
		clk_deci_i:		IN		std_logic;
	
		--Control the Counter-Block
		CountBlockControl_i 	:IN	std_logic_vector(5 downto 0);	--Bit5: LoadLastSavedValue (Left)
																					--Bit4: SaveActualValue
																					--Bit3: Inrement 1s
																					--Bit2: Increment 1min
																					--Bit1: Counting is enabled
																					--Bit0: Reset to 0			(Right)
		CountBlockTelemet_o 	:OUT	std_logic;							--Bit0: Counter is at 0
		CountValue_o		:OUT integer range 0 to 6000
	);
	end component;
	
	
	
BEGIN
----------------------------------------------
--Write some outputs
	Debug_clk_Deci_o <= clk_Deci;
	DebugLED_Control_o <= CountBlockControl; 


----------------------------------------------
--Falling Edge

	FallingEdge_Min : component FallingEdge
		port map(
			clk => clk_i,
			Button => BtnMin_i,
			FallingOutput => BtnMinFalling
			);
				
	FallingEdge_Sec : component FallingEdge
		port map(
			clk => clk_i,
			Button => BtnSec_i,
			FallingOutput => BtnSecFalling
			);
			
	FallingEdge_Clear : component FallingEdge
		port map(
			clk => clk_i,
			Button => BtnClear_i,
			FallingOutput => BtnClearFalling
			);
			
	FallingEdge_Start : component FallingEdge
		port map(
			clk => clk_i,
			Button => BtnStart_i,
			FallingOutput => BtnStartFalling
			);
			
----------------------------------------------
--Clock Divider

	ClockDivider_1: component ClockDivider
		  port map (
			  clk_in => clk_i,
			  Divider_in => Divide10Sec,
			  clk_out_alt => clk_Deci
		 );
			
----------------------------------------------
--State Machine
		 
	StateMachine_1: component StateMachine
		port map (
			reset_i 					=> reset_i,
			clk_i						=> clk_i,
			clk_deci_i				=> clk_Deci,
												
			BtnMinF_i				=> BtnMinFalling,
			BtnSecF_i				=> BtnSecFalling,
			BtnStartF_i				=> BtnStartFalling,
			BtnClearF_i				=> BtnClearFalling,
			
			--Outputs to other blocks
			DebugLED_o				=> DebugLED_o,
			BuzzerEnable_o			=> Buzzer_o,
			
			--Control the Counter-Block
			CountBlockControl_o	=> CountBlockControl,
			CountBlockTelemet_i	=> CountBlockTelemet
			
			);
			
--Counter
		 
	Counter_1: component Counter
		port map (
			clk_i						=> clk_i,
			clk_deci_i				=> clk_Deci,
			
			--Control the Counter-Block
			CountBlockControl_i	=> CountBlockControl,
			CountBlockTelemet_o	=> CountBlockTelemet,
			
			--CounterValue
			CountValue_o => CountValue_o
			
			);
	
			
END behave;