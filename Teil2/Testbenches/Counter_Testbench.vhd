-----------------------------------------------------------
-- 					VOLTZENLOGEL Xavier							--
--					Matrikelnummer : 179159-01 					--
-- 					29/12/2017         							--
-- 		 TestBench Counter and ConvertIntBcd			   --
-----------------------------------------------------------


-- Library Declaration -------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.all;


------------------------------
-- 			ENTITY          --
------------------------------

ENTITY Counter_Testbench IS

END Counter_Testbench;


-----------------------------
--				ARCHITECTURE	--
-----------------------------

ARCHITECTURE TestBench of Counter_Testbench IS


--Constant Signal
CONSTANT LoopLimit : INTEGER := 100;
CONSTANT LoopLimitCountingDown : INTEGER := 1000000000;

--Internal Signals / Stimulate signals from the Counter

	SIGNAL StimClk_i : std_logic :='0';
	SIGNAL StimClk_Deci_i : std_logic :='0';
	SIGNAL StimCountBlockControl_i : std_logic_vector (5 downto 0) := "000000";
	
	SIGNAL StimBtnMinF_i : std_logic :='0';
	SIGNAL StimBtnSecF_i	: std_logic :='0';
	SIGNAL StimBtnMin_i	: std_logic :='0';
	SIGNAL StimBtnSec_i	: std_logic :='0';
	
	SIGNAL StimCountBlockTelemet_o : std_logic :='0';
	SIGNAL StimCountValue_o	: INTEGER range 0 to 6000;
	
	
--Signals which contain the Numbers to test and the expected outputs
	TYPE DataExpected_ArrayMin IS ARRAY (10 downto 0) 	of INTEGER;
	SIGNAL DataExpectedMin : DataExpected_ArrayMin := (0, 5400, 4800, 4200, 3600, 3000, 2400, 1800, 1200, 600, 0);
															
	TYPE DataExpected_ArraySec IS ARRAY (60 downto 0) 	of INTEGER;
	SIGNAL DataExpectedSec : DataExpected_ArraySec := (0, 590, 580, 570, 560, 550, 540, 530, 520, 510, 500, 490, 480, 470, 460, 450, 440, 430, 420, 410, 400, 390, 380, 370, 360, 350, 340, 330, 320, 310, 300, 290, 280, 270, 260, 250, 240, 230, 220, 210, 200, 190, 180, 170, 160, 150, 140, 130, 120, 110, 100, 90, 80, 70, 60, 50, 40, 30, 20, 10, 0);
		
--Component to Test
-------------------------
	COMPONENT Counter
	  PORT(
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
END COMPONENT;


----------------------------------

BEGIN

-- Clock Generator 50Mhz

	StimClk_i <= not StimClk_i after 10 ps; 	--Real Clock 10 000ps

-- Clock Dezi Generator 

	StimClk_deci_i <= not StimClk_deci_i after 100 ps; 	
		
-- Call Component

	Counter_1: COMPONENT Counter
			PORT MAP(
					clk_i => StimClk_i,
					clk_deci_i => StimClk_deci_i,
					
					--Control the Counter-Block
					CountBlockControl_i => StimCountBlockControl_i,
					CountBlockTelemet_o => StimCountBlockTelemet_o,
					CountValue_o => StimCountValue_o,
					
					--User buttons
					BtnMinF_i => StimBtnMinF_i,
					BtnSecF_i => StimBtnSecF_i,
					BtnMin_i => StimBtnMin_i,
					BtnSec_i => StimBtnSec_i 
					);					

PROCESS

	VARIABLE LoopCounter : INTEGER := 0;
	VARIABLE IncrementMin : INTEGER range 0 to 10 := 0;
	VARIABLE IncrementSec : INTEGER range 0 to 60 := 0;	

	
BEGIN

		
		--1) Testing the incrementation of the Min to the max value
		--2) Testing the incrementation of the Sec to the max value
		--3) Testing the incrementation of the Min and Sec and Test Clear
		--4) Testing the dekrementation of the value to zero
		
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------

		
		StimCountBlockControl_i <= "100000"; --doing reset
		assert FALSE report "Mode Reset" severity Note;
		wait on StimClk_i; --waiting for the next rising edge
		wait on StimClk_i; 
		
		
		--1)
		
		StimCountBlockControl_i <= "001000";  --Incrementation Mode
		assert FALSE report "Mode Ready for Incrementing the Value" severity Note;
		
		assert FALSE report "Begin Test Incrementing Min Value" severity Note;
		
		Loop1: FOR IncrementMin IN 0 TO 10 LOOP
		
				StimBtnMinF_i <= '1';  --Press Min Button
		
				wait on StimClk_i; 	 --waiting for the next rising edge
				wait on StimClk_i;				
				
				IF StimCountValue_o = DataExpectedMin(IncrementMin) THEN
					--its true. So its done
					assert FALSE  report "Min " & integer'image(IncrementMin) & ": passed" severity Note;
				
				ELSE
					--not true. Report error
					assert FALSE report "Min " & integer'image(IncrementMin) & " : FAILED" severity Error;
			
				END IF;
				
				StimBtnMinF_i <= '0';  --Release Min Button
				
				wait on StimClk_i; 	 --waiting for the next rising edge
				wait on StimClk_i;
		
		END LOOP Loop1;

		assert FALSE report "Finishing Test Incrementing Min Value" severity Note;
		

-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------		
		
		
		--Fill the seconds table
		
--		Loop2: FOR IncrementSec IN 0 TO 59 LOOP
--		
--			DataExpected_ArraySec(IncrementSec) := (10 * IncrementSec);
--		
--		END LOOP Loop2;	
--		
--		DataExpected_ArraySec(60) := 0;
		
		
		StimCountBlockControl_i <= "100000"; --doing reset
		assert FALSE report "Mode Reset" severity Note;
		wait on StimClk_i; --waiting for the next rising edge
		wait on StimClk_i; 
		
		
		--2)
		
		StimCountBlockControl_i <= "001000";  --Incrementation Mode
		assert FALSE report "Mode Ready for Incrementing the Value" severity Note;
		
		assert FALSE report "Begin Test Incrementing Sec Value" severity Note;
		
		
		Loop2: FOR IncrementSec IN 0 TO 60 LOOP
		
				StimBtnSecF_i <= '1';  --Press Sec Button
		
				wait on StimClk_i; 	 --waiting for the next rising edge
				wait on StimClk_i;				
				
				IF StimCountValue_o = DataExpectedSec(IncrementSec) THEN
					--its true. So its done
					assert FALSE  report "Sec " & integer'image(IncrementSec) & ": passed" severity Note;
				
				ELSE
					--not true. Report error
					assert FALSE report "Sec " & integer'image(IncrementSec) & " : FAILED" severity Error;
			
				END IF;
				
				StimBtnSecF_i <= '0';  --Release Sec Button
				
				wait on StimClk_i; 	 --waiting for the next rising edge
				wait on StimClk_i;
		
		END LOOP Loop2;

		assert FALSE report "Finishing Test Incrementing Sec Value" severity Note;
		
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
		
		StimCountBlockControl_i <= "100000"; --doing reset
		assert FALSE report "Mode Reset" severity Note;
		wait on StimClk_i; --waiting for the next rising edge
		wait on StimClk_i; 
		
		--3)
		
		StimCountBlockControl_i <= "001000";  --Incrementation Mode
		assert FALSE report "Mode Ready for Incrementing the Value" severity Note;
		
		assert FALSE report "Begin Incrementing Sec Value" severity Note; 
		
		Loop3: FOR IncrementSec IN 0 TO 20 LOOP
		
				StimBtnSecF_i <= '1';  --Press Sec Button
		
				wait on StimClk_i; 	 --waiting for the next rising edge
				wait on StimClk_i;				
				
				StimBtnSecF_i <= '0';  --Release Sec Button
				
				wait on StimClk_i; 	 --waiting for the next rising edge
				wait on StimClk_i;
		
		END LOOP Loop3;

		assert FALSE report "Finishing Incrementing Sec Value" severity Note;
		
		assert FALSE report "Begin Incrementing Min Value" severity Note; 
		
		Loop4: FOR IncrementMin IN 0 TO 5 LOOP
		
				StimBtnMinF_i <= '1';  --Press Min Button
		
				wait on StimClk_i; 	 --waiting for the next rising edge
				wait on StimClk_i;				
				
				StimBtnMinF_i <= '0';  --Release Min Button
				
				wait on StimClk_i; 	 --waiting for the next rising edge
				wait on StimClk_i;
		
		END LOOP Loop4;

		assert FALSE report "Finishing Incrementing Sec Value" severity Note;
		
		assert FALSE report "Test Clear Button" severity Note;
		
		StimCountBlockControl_i <= "100000"; --doing reset

		Loop5: LOOP
				exit Loop5 when ((StimCountValue_o = 0) OR (StimCountBlockTelemet_o = '1'));
				exit Loop5 when (LoopCounter > Looplimit);
				wait on StimClk_i;
				wait on StimClk_i;
				LoopCounter := LoopCounter + 1;
			
		END LOOP;
--		
		IF (LoopCounter > Looplimit) THEN
			assert FALSE report "Clear Button has FAILED" severity Error;	
		ELSE
			assert FALSE report "Clear Button : passed" severity Note;
		END IF;
		
		assert FALSE report "Finishing Test Clear Mode" severity Note;
		
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------

StimCountBlockControl_i <= "001000";  --Incrementation Mode
		assert FALSE report "Mode Ready for Incrementing the Value" severity Note;
		
		assert FALSE report "Begin Incrementing Sec Value" severity Note; 
		
		Loop6: FOR IncrementSec IN 0 TO 20 LOOP
		
				StimBtnSecF_i <= '1';  --Press Sec Button
		
				wait on StimClk_i; 	 --waiting for the next rising edge
				wait on StimClk_i;				
				
				StimBtnSecF_i <= '0';  --Release Sec Button
				
				wait on StimClk_i; 	 --waiting for the next rising edge
				wait on StimClk_i;
		
		END LOOP Loop6;

		assert FALSE report "Finishing Incrementing Sec Value" severity Note;
		
		assert FALSE report "Begin Incrementing Min Value" severity Note; 
		
		Loop7: FOR IncrementMin IN 0 TO 1 LOOP
		
				StimBtnMinF_i <= '1';  --Press Min Button
		
				wait on StimClk_i; 	 --waiting for the next rising edge
				wait on StimClk_i;				
				
				StimBtnMinF_i <= '0';  --Release Min Button
				
				wait on StimClk_i; 	 --waiting for the next rising edge
				wait on StimClk_i;
		
		END LOOP Loop7;

		assert FALSE report "Finishing Incrementing Min Value" severity Note;
		
		
		assert FALSE report "Test Counting Down" severity Note;
		
		StimCountBlockControl_i <= "010000"; --Mode Counting Down

		LoopCounter := 0;
		
		Loop8: LOOP
				exit Loop8 when ((StimCountValue_o = 0) AND (StimCountBlockTelemet_o = '1'));
				exit Loop8 when (LoopCounter > LoopLimitCountingDown);
				wait on StimClk_i;
				wait on StimClk_i;
				LoopCounter := LoopCounter + 1;
			
		END LOOP;
--		
		IF (LoopCounter > LoopLimitCountingDown) THEN
			assert FALSE report "Counting Down has FAILED" severity Error;	
		ELSE
			assert FALSE report "Counting Down : passed" severity Note;
		END IF;
		
		assert FALSE report "Finishing Test Counting Down" severity Note;

		
		
--Finished
assert FALSE report "All Tests DONE!" severity NOTE;
wait;
	
end process;
	
END TestBench;	
		
	