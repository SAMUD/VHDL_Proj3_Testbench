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
	--TYPE DataExpected_ArrayMin IS ARRAY (10 downto 0) 	of INTEGER;
	--SIGNAL DataExpectedMin : DataExpected_ArrayMin := (0, 5400, 4800, 4200, 3600, 3000, 2400, 1800, 1200, 600, 0);
															
													
	TYPE DataExpected_ArrayMin IS ARRAY (10 downto 0) 	of	std_logic_vector (6 downto 0)		;
	SIGNAL DataExpectedMin : DataExpected_ArrayMin := ("1000000","0011000","0000000","1111000","0000011","0010010","0011001","0110000","0100100","1111001","1000000");
			
	
	--TYPE DataExpected_ArraySec IS ARRAY (60 downto 0) 	of INTEGER;
	--SIGNAL DataExpectedSec : DataExpected_ArraySec := (0, 590, 580, 570, 560, 550, 540, 530, 520, 510, 500, 490, 480, 470, 460, 450, 440, 430, 420, 410, 400, 390, 380, 370, 360, 350, 340, 330, 320, 310, 300, 290, 280, 270, 260, 250, 240, 230, 220, 210, 200, 190, 180, 170, 160, 150, 140, 130, 120, 110, 100, 90, 80, 70, 60, 50, 40, 30, 20, 10, 0);
		
	--intermediate signals to transport signals inside this Entity
	signal StimClock: 			std_logic :='0';
	signal StimReset:			std_logic :='0';
	signal StimBtnMin:			std_logic :='0';
	signal StimBtnSec:			std_logic :='0';
	signal StimBtnStart:		std_logic :='0';
	signal StimBtnClear:		std_logic :='0';
	signal StimOutput1:			std_logic_vector (6 downto 0) := "0000000";
	signal StimOutput2:			std_logic_vector (6 downto 0) := "0000000";
	signal StimOutput3:			std_logic_vector (6 downto 0) := "0000000";
	signal StimOutput4:			std_logic_vector (6 downto 0) := "0000000";
	signal StimBuzzerOut:			std_logic :='0';
	signal StimBuzzerOverride:     std_logic :='0';
	


--Component to Test
component Main
port (
	reset				:	IN		std_logic;						--Mapped to SW0
	clk					:	IN		std_logic;
	
	--User buttons
	BtnMin				:	IN		std_logic;					--Mapped to Btn3
	BtnSec				:	IN		std_logic;					--Mapped to Btn2
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
	DebugLED			:	OUT 	std_logic_vector(2 downto 0) := "000";			--Showing state of state machine on LEDs Green 
	DebugLED_Control	:	OUT 	std_logic_vector(5 downto 0):= "000000";	--Showing the control status from state machine to Counter
		
	--Buzzer Output
	BuzzerOut			:	OUT	std_logic
	);
end component;

---------------------------------------------
BEGIN

--Generate clock
StimClock <= not StimClock after 10 ps;

--Device to test (DUT)
ConvertBcd_1: component Main
		port map(
				clk => StimClock,											
				reset => StimReset,
				BtnMin => StimBtnMin,
				BtnSec => StimBtnClear,
				BtnStart => StimBtnStart,
				BtnClear => StimBtnClear,
				Output1 => StimOutput1,
				Output2 => StimOutput2,
				Output3 => StimOutput3,
				Output4 => StimOutput4,
				BuzzerOut => StimBuzzerOut,
				BuzzerOverride => StimBuzzerOverride
				

				--for now we won'tuse the debug outputs. But perhaps this can make thing easier during Testing with the Bench.
		);
		
--Stimulate-process
stimulate: PROCESS
	
	variable ErrorCounter:	integer range 0 to 100 :=0;	--Counting the number of errors during testing
	
	VARIABLE IncrementMin : INTEGER range 0 to 10 := 0;   --for loop Minutes 
	VARIABLE IncrementSec : INTEGER range 0 to 60 := 0;	--for loop Seconds

	
BEGIN

--The DUT in this case is programmed synchronous.

--finding a rising edge
wait on StimClock;
while (StimClock/='0') loop
	wait on StimClock;
end loop;

--Starting main testing unit

	--1) Test Increment Minute Button
	--2) Test Increment Sec Button
	--3) Test Reset Button
	
	
	--1)
	
		assert FALSE report "Begin Test Incrementing Min Value" severity Note;
		
		Loop1: FOR IncrementMin IN 0 TO 10 LOOP
		
				StimBtnMin <= '1';  --Press Min Button
		
				wait on StimClock; 	 --waiting for the next rising edge
				wait on StimClock;				
				
				IF (StimOutput1 = DataExpectedMin(IncrementMin)) THEN
					--its true. So its done
					assert FALSE  report "Min " & integer'image(IncrementMin) & ": passed" severity Note;
				
				ELSE
					--not true. Report error
					assert FALSE report "Min " & integer'image(IncrementMin) & " : FAILED" severity Error;
			
				END IF;
				
				StimBtnMin <= '0';  --Release Min Button
				
				wait on StimClock; 	 --waiting for the next rising edge
				wait on StimClock;
		
		END LOOP Loop1;

		assert FALSE report "Finishing Test Incrementing Min Value" severity Note;
		
		
		--2)
		
--		assert FALSE report "Begin Test Incrementing Sec Value" severity Note;
--		
--		
--		Loop2: FOR IncrementSec IN 0 TO 60 LOOP
--		
--				StimBtnSec <= '1';  --Press Sec Button
--		
--				wait on StimClock; 	 --waiting for the next rising edge
--				wait on StimClock;				
--				
--				IF StimCountValue_o = DataExpectedSec(IncrementSec) THEN
--					--its true. So its done
--					assert FALSE  report "Sec " & integer'image(IncrementSec) & ": passed" severity Note;
--				
--				ELSE
--					--not true. Report error
--					assert FALSE report "Sec " & integer'image(IncrementSec) & " : FAILED" severity Error;
--			
--				END IF;
--				
--				StimBtnSec <= '0';  --Release Sec Button
--				
--				wait on StimClock; 	 --waiting for the next rising edge
--				wait on StimClock;
--		
--		END LOOP Loop2;
--
--		assert FALSE report "Finishing Test Incrementing Sec Value" severity Note;
--	
	

--Finished
assert FALSE report "DONE! with " & integer'image(ErrorCounter) & " Errors." severity NOTE;
wait;
	
end process;
	
END simulate;