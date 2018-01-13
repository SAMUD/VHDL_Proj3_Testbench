------------------------------------------------------
--  Testbench by Samuel Daurat, Xavier VOLTZENLOGEL, Jeremy Buchert [178190]      --
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
													
	TYPE DataExpected_ArrayMin IS ARRAY (10 downto 0) 	of	std_logic_vector (6 downto 0);
	SIGNAL DataExpectedMin : DataExpected_ArrayMin := ("1000000","0011000","0000000","1111000","0000011","0010010","0011001","0110000","0100100","1111001","1000000");
			
	
	TYPE DataExpected_Array10Sec IS ARRAY (6 downto 0) of	std_logic_vector (6 downto 0);
	SIGNAL DataExpected10Sec : DataExpected_Array10Sec := ("1000000","0010010","0011001","0110000","0100100","1111001","1000000");
		
	TYPE DataExpected_ArraySec IS ARRAY (10 downto 0) of std_logic_vector (6 downto 0);
	SIGNAL DataExpectedSec : DataExpected_ArraySec := ("1000000","0011000","0000000","1111000","0000011","0010010","0011001","0110000","0100100","1111001","1000000"); 
			
		
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
	signal StimTestCountBlockControl_o : std_logic_vector(5 downto 0) := "000000";
	signal StimCountValueMainOut : integer range 0 to 6000 := 0;
	signal StimDebugLED : std_logic_vector(2 downto 0) := "000";
	signal StimDebugLED_Control : 	std_logic_vector(5 downto 0):= "000000";

--Component to Test
component Main
port (
	reset				:	IN		std_logic;						--Mapped to SW0
	clk				:	IN		std_logic;
	
	--User buttons
	BtnMin			:	IN		std_logic;					--Mapped to Btn3
	BtnSec			:	IN		std_logic;					--Mapped to Btn2
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
	--CountValueMainOut	:	OUT 	integer range 0 to 6000;					--Showing the actual count value in binary on LEDs Red 17-
	DebugLED			:	OUT 	std_logic_vector(2 downto 0);			--Showing state of state machine on LEDs Green 
	DebugLED_Control	:	OUT 	std_logic_vector(5 downto 0);	--Showing the control status from state machine to Counter
		
	--Buzzer Output
	BuzzerOut			:	OUT	std_logic
	--TestCountBlockControl_o 	: OUT	std_logic_vector(5 downto 0)
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
				BtnSec => StimBtnSec,
				BtnStart => StimBtnStart,
				BtnClear => StimBtnClear,
				Output1 => StimOutput1,
				Output2 => StimOutput2,
				Output3 => StimOutput3,
				Output4 => StimOutput4,
				BuzzerOut => StimBuzzerOut,
				BuzzerOverride => StimBuzzerOverride,
				
				--TestCountBlockControl_o => StimTestCountBlockControl_o,
				
				--CountValueMainOut	=> StimCountValueMainOut,
				
				DebugLED	=> StimDebugLED, 
				DebugLED_Control => StimDebugLED_Control
				
				--for now we won'tuse the debug outputs. But perhaps this can make thing easier during Testing with the Bench.
		);
		
--Stimulate-process
stimulate: PROCESS
	
	variable ErrorCounter:	integer range 0 to 100 :=0;	--Counting the number of errors during testing
	
	VARIABLE IncrementMin : INTEGER range 0 to 10 := 0;   	--for increment Minutes
	VARIABLE IncrementMin10 : INTEGER range 0 to 10 :=0;		--for loop 10 Minutes
	VARIABLE Increment10Sec : INTEGER range 0 to 6 := 0;	--for increment 10 Seconds
	VARIABLE IncrementSec : INTEGER range 0 to 10 := 0;		--for increment Seconds
	VARIABLE IncrementSec60 : INTEGER range 0 to 60 := 0;	--for loop 60 Seconds
	
	VARIABLE IncrementClock : INTEGER range 0 to 100 := 0; -- for 100 Clock Period
	
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
	--4) Test Start/Stop
	--5) Test Decrementation
	
	
	--1)
	
		ErrorCounter := 0;
	
		assert FALSE report "Begin Test Incrementing Min Value" severity Note;
		
		LOOP1 : FOR IncrementMin10 IN 0 TO 10 LOOP
		
				StimBtnMin <= '1';  --Press Min Button
		
				wait on StimClock; 	 --waiting for the next rising edge
				wait on StimClock;				
				
				IF (StimOutput1 = DataExpectedMin(IncrementMin)) THEN
					--its true. So its done
					assert FALSE  report "Min " & integer'image(IncrementMin) & ": passed" severity Note;
				
				ELSE
					--not true. Report error
					assert FALSE report "Min " & integer'image(IncrementMin) & " : FAILED" severity Error;
					ErrorCounter := ErrorCounter + 1;
				END IF;
				
				StimBtnMin <= '0';  --Release Min Button
				
				wait on StimClock; 	 --waiting for the next rising edge
				wait on StimClock;
				
				IncrementMin := IncrementMin + 1;
				
				IF IncrementMin > 9 THEN
						IncrementMin := 0;
				END IF;
		
		END LOOP Loop1;

		assert FALSE report "Finishing Test Incrementing Min Value" severity Note;
		
		
		--2)
		
		assert FALSE report "Begin Test Incrementing Sec Value" severity Note;
		
		
		Loop2: FOR IncrementSec60 IN 0 TO 60 LOOP
		
				StimBtnSec <= '1';  --Press Sec Button
				
				wait on StimClock; 	 --waiting for the next rising edge
				wait on StimClock;				
				
				
							
				IF StimOutput3 = DataExpectedSec(IncrementSec) AND StimOutput2 = DataExpected10Sec(Increment10Sec) THEN
					--its true. So its done
					assert FALSE  report integer'image(Increment10Sec) & integer'image(IncrementSec) & " Sec " & ": passed" severity Note;
				
				ELSE
					--not true. Report error
					assert FALSE report integer'image(Increment10Sec) & integer'image(IncrementSec) & " Sec " & " : FAILED" severity Error;
					ErrorCounter := ErrorCounter + 1;	
				END IF;				
				
				StimBtnSec <= '0';  --Release Sec Button
				
				IncrementSec := IncrementSec + 1;
				
				If IncrementSec > 9 THEN
					IncrementSec := 0;
					Increment10Sec := Increment10Sec + 1;
					IF Increment10Sec > 5 THEN
						Increment10Sec := 0;
					END IF;
				END IF;
				
				wait on StimClock; 	 --waiting for the next rising edge
				wait on StimClock;
		
		END LOOP Loop2;

		assert FALSE report "Finishing Test Incrementing Sec Value" severity Note;
	
	
		--3) 
		
		assert FALSE report "Begin Test Reset" severity Note;
	
		assert FALSE report "Increment Sec" severity Note;
		
		StimBtnSec <= '1';  --Press Sec Button
				
		wait on StimClock; 	 --waiting for the next rising edge
		wait on StimClock;
		
		StimBtnSec <= '0';  --Release Sec Button
		
		assert FALSE report "Increment Min" severity Note;	
		
		StimBtnMin <= '1';  --Press Sec Button
				
		wait on StimClock; 	 --waiting for the next rising edge
		wait on StimClock;
		
		StimBtnMin <= '0';  --Release Sec Button
		
		assert FALSE report "Reset" severity Note;
		
		StimReset <= '1';  --Press Reset Button
		
		wait on StimClock; 	 --waiting for the next rising edge
		wait on StimClock;
		
		wait on StimClock; 	 --waiting for the next rising edge
		wait on StimClock;
		
		wait on StimClock; 	 --waiting for the next rising edge
		wait on StimClock;
		
		StimReset <= '0';  --Release Reset Button
		
		IF StimOutput4 = "1000000" AND StimOutput3 = "1000000" AND StimOutput2 = "1000000" AND StimOutput1 = "1000000" THEN
			--its true. So its done
			assert FALSE  report "Reset : passed" severity Note;
				
		ELSE
			--not true. Report error
			assert FALSE report "Reset : FAILED" severity Error;
			ErrorCounter := ErrorCounter + 1;			
		END IF;				
			
		
		--4)
	
		assert FALSE report "Begin Test Start Stop" severity Note;
		
		assert FALSE report "Increment Min" severity Note;
		
		StimBtnMin <= '1';  --Press Sec Button
				
		wait on StimClock; 	 --waiting for the next rising edge
		wait on StimClock;
		
		StimBtnMin <= '0';  --Release Sec Button
		
		assert FALSE report "Start" severity Note;
		
		StimBtnStart <= '1';		--Press Start Button
		
		wait on StimClock; 	 --waiting for the next rising edge
		wait on StimClock;
		
		StimBtnStart <= '0'; --Release Start Button
		
		Loop3: FOR IncrementClock IN 0 TO 1000 LOOP
								
				wait on StimClock; 	 --waiting for the next rising edge
				wait on StimClock;
		
		END LOOP Loop3;
		
		StimBtnStart <= '1';	--Press Start Button
		
		wait on StimClock; 	 --waiting for the next rising edge
		wait on StimClock;
		
		StimBtnStart <= '0';	--Release Start Button
		
		Loop4: FOR IncrementClock IN 0 TO 10 LOOP
								
				wait on StimClock; 	 --waiting for the next rising edge
				wait on StimClock;
		
		END LOOP Loop4;
		
		
		IF StimOutput4 = "1000000" AND StimOutput3 = "0010010" AND StimOutput2 = "1000000" AND StimOutput1 = "1000000" THEN
			--its true. So its done
			assert FALSE  report "Start Stop function : passed" severity Note;
				
		ELSE
			--not true. Report error
			assert FALSE report "Start Stop function : FAILED" severity Error;
			ErrorCounter := ErrorCounter + 1;			
		END IF;
		
--5) doing final decrementation test

assert FALSE report "Starting decrementation test" severity NOTE;

StimBtnStart <= '1'; --Press Start Button
wait on StimClock; 	 --waiting for the next rising edge
wait on StimClock;   --falling edge
StimBtnStart <= '0'; --Release Start Button
	
while StimOutput4 /= "1000000" AND StimOutput3 /= "1000000" AND StimOutput2 /= "1000000" AND StimOutput1 /= "1000000" loop
	wait on StimClock; 	 --waiting for the next rising edge
	wait on StimClock;   --falling edge
end loop;

if StimBuzzerOut = '1' then
	assert FALSE report "We are at 0. Buzzer is enabled" severity NOTE;
else
	assert FALSE report "We are at 0. Buzzer is NOT enabled" severity NOTE;
	ErrorCounter := ErrorCounter + 1;					
end if ;

--Finished
assert FALSE report "DONE! with " & integer'image(ErrorCounter) & " Errors." severity NOTE;
wait;


end process;

END simulate;
			
--5) doing final decrementation test

	assert FALSE report "Starting decrementation test" severity NOTE;

	StimBtnStart <= '1'; --Press Start Button
	wait on StimClock; 	 --waiting for the next rising edge
	wait on StimClock;   --falling edge
	StimBtnStart <= '0'; --Release Start Button
		
	while StimOutput4 /= "1000000" AND StimOutput3 /= "1000000" AND StimOutput2 /= "1000000" AND StimOutput1 /= "1000000" loop
		wait on StimClock; 	 --waiting for the next rising edge
		wait on StimClock;   --falling edge
	end loop;

	if StimBuzzerOut = '1' then
		assert FALSE report "We are at 0. Buzzer is enabled" severity NOTE;
	else
		assert FALSE report "We are at 0. Buzzer is NOT enabled" severity NOTE;
		ErrorCounter := ErrorCounter + 1;					
	end if ;

--Finished
assert FALSE report "DONE! with " & integer'image(ErrorCounter) & " Errors." severity NOTE;
wait;

	
end process;
	
END simulate;