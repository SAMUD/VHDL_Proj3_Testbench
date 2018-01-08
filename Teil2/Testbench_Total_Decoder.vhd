------------------------------------------------------
--  Testbench by Samuel Daurat [178190]      --
-- This module is a testbench and will be used to test the complete Timer module
------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


------------------------------------------------------
--	   ENTITY	                           			 --
------------------------------------------------------

ENTITY Testbench_Decoder IS
END Testbench_Decoder;

------------------------------------------------------
--        ARCHITECTURE	                  			 --
------------------------------------------------------
ARCHITECTURE simulate OF Testbench_Decoder IS

--internal Signals /stimulate signals
	
	--Signals which contain the Numbers to test and the expected outputs
	--type DataInput_Array 	is array (9 downto 0) 	of std_logic_vector(3 downto 0);
	--signal DataInput : 		DataInput_Array := ("1001","1000","0111","0110","0101","0100","0011","0010","0001","0000");
	  
	--type DataExpected_Array is array (9 downto 0) 	of std_logic_vector(6 downto 0);
	--signal DataExpected : 	DataExpected_Array := ("0011000","0000000","1111000","0000011","0010010","0011001","0110000","0100100","1111001","1000000");
	
	--intermediate signals to transport signals inside this Entity
	signal StimClock: 			std_logic :='0';
	signal StimReset:			std_logic :='0';
	signal StimBtnMin:			std_logic :='0';
	signal StimBtnSec:			std_logic :='0';
	signal StimBtnStart:		std_logic :='0';
	signal StimBtnClear:		std_logic :='0';
	signal StimOutput1:			std_logic :='0';
	signal StimOutput2:			std_logic :='0';
	signal StimOutput3:			std_logic :='0';
	signal StimOutput4:			std_logic :='0';
	signal StimBuzzer:			std_logic :='0';
	


--Component to Test
component Main
port (
	reset				:	IN		std_logic;						--Mapped to SW0
	clk					:	IN		std_logic;
	
	--User buttons
	BtnMin				:	IN		std_logic;						--Mapped to Btn3
	BtnSec				:	IN		std_logic;						--Mapped to Btn2
	BtnStart			:	IN		std_logic;						--Mapped to Btn0
	BtnClear			:	IN		std_logic;						--Mapped to Btn1
	
	--Debug buttons
	BuzzerOverride		:	IN		std_logic;						--Manual activation for the Buzzer, Mapped to SW1
	--SW2				:	IN		std_logic;
	--SW3				:	IN		std_logic;
	
	-- decoded signals to send to the 7seg
	Output1				:	OUT	std_logic_vector (6 downto 0);	
	Output2				:	OUT	std_logic_vector (6 downto 0);	
	Output3				:	OUT	std_logic_vector (6 downto 0);	
	Output4				:	OUT	std_logic_vector (6 downto 0);
	
	--Debug outputs
	CountValueMainOut	:	OUT 	integer range 0 to 6000 := 0;					--Showing the actual count value in binary on LEDs Red 17-
	DebugLED			:	OUT 	std_logic_vector(2 downto 0) := "000";		--Showing state of state machine on LEDs Green 
	DebugLED_Control	:	OUT 	std_logic_vector(5 downto 0):= "000000";	--Showing the control status from state machine to Counter
		
	--Buzzer Output
	BuzzerOut			:	OUT	std_logic
	);
end component;

---------------------------------------------
BEGIN

--Generate clock
StimClock <= not StimClock after 10 ns;

--Device to test (DUT)
ConvertBcd_1: component Main
		port map(
				clk => StimClk,											
				reset => StimReset,
				BtnMin => StimBtnMin,
				BtnSec => StimBtnClear,
				BtnStart => StimBtnStart,
				BtnClear => StimBtnClear,
				Output1 => StimOutput1,
				Output2 => StimOutput2,
				Output3 => StimOutput3,
				Output4 => StimOutput4,
				BuzzerOut => StimBuzzerOut

				--for now we won'tuse the debug outputs. But perhaps this can make thing easier during Testing with the Bench.
		);
		
--Stimulate-process
stimulate: PROCESS
	
	variable ErrorCounter:	integer range 0 to 100 :=0;	--Counting the number of errors during testing
	
BEGIN

--The DUT in this case is programmed synchronous.

--finding a rising edge
wait on StimClock;
while (StimClock/='0') loop
	wait on StimClock;
end loop;

--Starting main testing unit


--Finished
assert FALSE report "DONE! with " & integer'image(ErrorCounter) & " Errors." severity NOTE;
wait;
	
end process;
	
END simulate;