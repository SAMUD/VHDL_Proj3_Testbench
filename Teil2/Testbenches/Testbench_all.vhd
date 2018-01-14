------------------------------------------------------
--  Testbench by Samuel Daurat, Xavier VOLTZENLOGEL, Jeremy Buchert, Arthur DISCHLI      --
-- This module is a testbench and will be used to test the complete Timer module
------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


------------------------------------------------------
--	   ENTITY	                           			 --
------------------------------------------------------

ENTITY Testbench_all IS
END Testbench_all;

------------------------------------------------------
--        ARCHITECTURE	                  			--
------------------------------------------------------
ARCHITECTURE simulate OF Testbench_all IS

--Signals for all DUT
SIGNAL Sim_clk 			: std_logic :='0';


-------------------------------------------------
-- Simulaion Signale for testing ClockDivider
CONSTANT Sim_clkDivider_DividerFactor : integer := 10;
SIGNAL Sim_clkDivider_reset_i 		: std_logic :='0';
SIGNAL Sim_clkDivider_clk_out 		: std_logic :='0';
SIGNAL Sim_clkDivider_clk_out_alt 	: std_logic :='0';

-------------------------------------------------
-- Simulation Signals for testing Buzzer
CONSTANT Sim_Buzzer_TestTime		    : integer := 1000;
CONSTANT Sim_Buzzer_ForLoopNumber	    : integer := 10;
SIGNAL Sim_Buzzer_Enable 				: std_logic :='0';
SIGNAL Sim_Buzzer_BuzzerOut 			: std_logic :='0';

-------------------------------------------------
--Simulation Signals for testing ConvertIntToBcd
CONSTANT LoopLimit : INTEGER := 100;
CONSTANT LoopLimitCountingDown : INTEGER := 1000000;
--Signals which contain the Numbers to test and the expected outputs
TYPE DataInput_ArrayMin IS ARRAY (10 downto 0) 	of INTEGER;
SIGNAL DataInputMin : DataInput_ArrayMin := (0, 5400, 4800, 4200, 3600, 3000, 2400, 1800, 1200, 600, 0);
TYPE DataInput_ArraySecLeft IS ARRAY (6 downto 0) of INTEGER;
SIGNAL DataInputSecLeft : DataInput_ArraySecLeft := (0, 500, 400, 300, 200, 100, 0);
TYPE DataInput_ArraySecRight IS ARRAY (10 downto 0) of INTEGER;
SIGNAL DataInputSecRight : DataInput_ArraySecRight := (0, 90, 80, 70, 60, 50, 40, 30, 20, 10, 0);
TYPE DataInput_ArrayDezisec IS ARRAY (10 downto 0) of INTEGER;
SIGNAL DataInputDezisec : DataInput_ArrayDezisec := (0, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0);
--Signals which contain the Numbers to test and the expected outputs
TYPE DataExpected_ArrayMin IS ARRAY (10 downto 0) 	of std_logic_vector(6 downto 0);
SIGNAL DataExpectedMin : DataExpected_ArrayMin := ("1000000","0011000","0000000","1111000","0000011","0010010","0011001","0110000","0100100","1111001","1000000");
TYPE DataExpected_ArraySecLeft IS ARRAY (6 downto 0) 	of std_logic_vector(6 downto 0);
SIGNAL DataExpectedSecLeft : DataExpected_ArraySecLeft := ("1000000","0010010","0011001","0110000","0100100","1111001","1000000");
TYPE DataExpected_ArraySecRight IS ARRAY (10 downto 0) 	of std_logic_vector(6 downto 0);
SIGNAL DataExpectedSecRight : DataExpected_ArraySecRight := ("1000000","0011000","0000000","1111000","0000011","0010010","0011001","0110000","0100100","1111001","1000000");
TYPE DataExpected_ArrayDezi IS ARRAY (10 downto 0) 	of std_logic_vector(6 downto 0);
SIGNAL DataExpectedDezisec : DataExpected_ArrayDezi := ("1000000","0011000","0000000","1111000","0000011","0010010","0011001","0110000","0100100","1111001","1000000");
--Intermediate signals to transport signals inside this Entity
SIGNAL Stim_IntBcd_InputInt : INTEGER  range 0 to 6000 ;			--Input signal containing the actual time information in Deci-Sec												
SIGNAL Stim_IntBcd_SevenSeg1	: std_logic_vector (6 downto 0) := "0000000";
SIGNAL Stim_IntBcd_SevenSeg2	: std_logic_vector (6 downto 0) := "0000000";	
SIGNAL Stim_IntBcd_SevenSeg3	: std_logic_vector (6 downto 0) := "0000000";	
SIGNAL Stim_IntBcd_SevenSeg4	: std_logic_vector (6 downto 0) := "0000000";

-------------------------------------------------
--Simulation Signals for testing Counter
SIGNAL StimClk_Deci_i : std_logic :='0';
SIGNAL StimCountBlockControl_i : std_logic_vector (5 downto 0) := "000000";
SIGNAL StimBtnMinF_i : std_logic :='0';
SIGNAL StimBtnSecF_i	: std_logic :='0';
SIGNAL StimBtnMin_i	: std_logic :='0';
SIGNAL StimBtnSec_i	: std_logic :='0';
SIGNAL StimCountBlockTelemet_o : std_logic :='0';
SIGNAL StimCountValue_o	: INTEGER range 0 to 6000;
--Signals which contain the Numbers to test and the expected outputs
TYPE DataExpected_Counter_ArrayMin IS ARRAY (10 downto 0) 	of INTEGER;
SIGNAL DataExpected_Counter_Min : DataExpected_Counter_ArrayMin := (0, 5400, 4800, 4200, 3600, 3000, 2400, 1800, 1200, 600, 0);														
TYPE DataExpected_ArraySec IS ARRAY (60 downto 0) 	of INTEGER;
SIGNAL DataExpectedSec : DataExpected_ArraySec := (0, 590, 580, 570, 560, 550, 540, 530, 520, 510, 500, 490, 480, 470, 460, 450, 440, 430, 420, 410, 400, 390, 380, 370, 360, 350, 340, 330, 320, 310, 300, 290, 280, 270, 260, 250, 240, 230, 220, 210, 200, 190, 180, 170, 160, 150, 140, 130, 120, 110, 100, 90, 80, 70, 60, 50, 40, 30, 20, 10, 0);

--Component to Test
component ClockDivider
GENERIC(
	Divider_in		:	IN  integer :=Sim_clkDivider_DividerFactor-1
	);
port (
	clk_in			:	IN	 std_logic;							--Clock input
	reset_i			:	IN	 std_logic;							--Setting this to 1 resets the timer and Sets Outputs to 0												
	clk_out			:	OUT std_logic;							--Will be 1 half the time
	clk_out_alt		:	OUT std_logic							--Will only be 1 for 1 clock cycle
	);
end component;

component Buzzer
port (
	clk			:	IN		std_logic;				--main 50Mhz clock input		
	Enable		:	IN		std_logic;				--Turn on buzzer												
	BuzzerOut	:	OUT	std_logic					--Output to (Hardware)-Buzzer	
	);
end component;

COMPONENT ConvertIntBcd
		PORT(															
			InputInt	:		IN		integer range 0 to 6000 ;		--Input signal containing the actual time information in Deci-Sec												
			SevenSeg1	:		OUT	std_logic_vector (6 downto 0);	-- decoded signals to send to the 7seg
			SevenSeg2	:		OUT	std_logic_vector (6 downto 0);	
			SevenSeg3	:		OUT	std_logic_vector (6 downto 0);	
			SevenSeg4	:		OUT	std_logic_vector (6 downto 0)
			);
			
END COMPONENT;

COMPONENT Counter
	  PORT(
			clk_i		 				:	IN		 std_logic;
			clk_deci_i					:	IN		 std_logic;
			--Control the Counter-Block
			CountBlockControl_i 		:	IN	std_logic_vector(5 downto 0);	
																				--MSB| Bit 5-4-3-2-1-0 | LSB
																				--Bit 5 : Reset
																				--Bit 4 : Counting has started / enable
																				--Bit 3 : Ready for Incrementing the Value
																				--Bit 2 : Load last Saved Value
																				--Bit 1 : Save current Counter Value
																				--Bit 0 : Enable Buzzer
			CountBlockTelemet_o 		:	OUT	std_logic;				--Bit 0 : Counter is at 0
			--Current Count Value
			CountValue_o				:	OUT integer range 0 to 6000;
			--User buttons
			BtnMinF_i					:	IN		 std_logic;
			BtnSecF_i					:	IN		 std_logic;
			BtnMin_i					:	IN		 std_logic;
			BtnSec_i					:	IN		 std_logic
			);
END COMPONENT;

---------------------------------------------
BEGIN

--Generate clock of 50 MHz
Sim_clk <= not Sim_clk after 1 ps; --50Mhz normally duty-Cycle of 10ns
-- Clock Dezi Generator 
StimClk_deci_i <= not StimClk_deci_i after 100 ps; 	

-- Component Clock Divider
ClockDivider_1: component ClockDivider PORT MAP(
	-->we will use the stock dividing speed for the clock
	clk_in 			=> Sim_clk,								
	reset_i 		=> Sim_clkDivider_reset_i, 							
	clk_out 		=> Sim_clkDivider_clk_out,
	clk_out_alt 	=> Sim_clkDivider_clk_out_alt	
	);

-- Component Buzzer
Buzzer_1: component Buzzer PORT MAP(
	clk 			=> Sim_clk,								
	Enable 		=> Sim_Buzzer_Enable, 							
	BuzzerOut 	=> Sim_Buzzer_BuzzerOut						
	);

-- Component ConvertIntToBcd	
ConvertIntBcd_1: COMPONENT ConvertIntBcd
		PORT MAP(
				InputInt  => Stim_IntBcd_InputInt,											
				SevenSeg1 => Stim_IntBcd_SevenSeg1,
				SevenSeg2 => Stim_IntBcd_SevenSeg2,
				SevenSeg3 => Stim_IntBcd_SevenSeg3,
				SevenSeg4 => Stim_IntBcd_SevenSeg4 
				);	

--Component Counter
Counter_1: COMPONENT Counter
		PORT MAP(
				clk_i => Sim_clk,
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
		
--Stimulate-process
ClockDivider_Test: PROCESS
	
	VARIABLE LoopCounter_up : INTEGER := 0;
	VARIABLE LoopCounter : INTEGER  := 0;
	VARIABLE temp : INTEGER  := 0;
	VARIABLE ErrorCounter : INTEGER :=0;
	
	
	BEGIN

		--finding a rising edge
		wait on Sim_clk;
		while (Sim_clk /= '0') loop
			wait on Sim_clk;
		end loop;
	
-------------------------------------------------
--Testing Clockdivider
-------------------------------------------------
		 
		--1) Test clk_out when reset = 0 
		--2) Test clk_out_alt when reset = 0
		--3) Test clk_out and clk_out_alt when reset = 1 
		
		--1) Test clk_out when reset = 0 
		
		--waiting for a new periode to begin
		L1 : loop
				exit L1 when (Sim_clkDivider_clk_out = '1');
				exit L1 when (LoopCounter>5000);
				LoopCounter := LoopCounter +1;
				wait on Sim_clk;
				wait on Sim_clk;
			end loop;

		if LoopCounter>5000 then
			--there was no rising edge
			--fatal error. Abort all other tests
			assert FALSE report "ClockDivider: No initial rising edge found" severity FAILURE;			
			wait;
		end if ;
		LoopCounter := 0;
		
		-- counting how many clk periodes clk_out = 1
		L2 : loop
				exit L2 when (Sim_clkDivider_clk_out = '0');
				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter := LoopCounter + 1;
			end loop;
		
		-- counting how many clk periodes clk_out = 0	
		L3 : loop
				exit L3 when (Sim_clkDivider_clk_out = '1');
				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter_up := LoopCounter_up + 1;
			end loop;		
			
		IF (LoopCounter_up = Sim_clkDivider_DividerFactor AND LoopCounter = Sim_clkDivider_DividerFactor) THEN
			assert FALSE report "ClockDivider: Divider is working." severity NOTE;
		ELSE
			assert FALSE report "ClockDivider: Divider has failed. Expected Dividingfactor: "
								& integer'image(Sim_clkDivider_DividerFactor)
								& " We have: "
								& integer'image(LoopCounter_up)
								& " and "
								& integer'image(LoopCounter)
								 severity FAILURE;
		END IF;

		--2) Test clk_out_alt when reset = 0
		
		LoopCounter_up := 0;
		LoopCounter := 0;
		
		--waiting for a new periode to begin
		L4 : loop
			exit L4 when (Sim_clkDivider_clk_out = '1');
			exit L4 when (LoopCounter>5000);
			LoopCounter := LoopCounter +1;
			wait on Sim_clk;
			wait on Sim_clk;
		end loop;
		
		-- counting how many clk periodes clk_out_alt = 1
		L5 : loop
				exit L5 when (Sim_clkDivider_clk_out_alt = '0');
				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter := LoopCounter + 1;
			end loop;
		
		-- counting how many clk periodes clk_out_alt = 0	
		L6 : loop
				exit L6 when (Sim_clkDivider_clk_out_alt = '1');
				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter_up := LoopCounter_up + 1;
			end loop;		

		IF (LoopCounter = 1 AND LoopCounter_up = Sim_clkDivider_DividerFactor-1) THEN
		assert FALSE report "ClockDivider: Divider_alt is working." severity NOTE;
		ELSE
			assert FALSE report "ClockDivider: Divider_alt has FAILED. Expected Dividingfactor: "
								& integer'image(Sim_clkDivider_DividerFactor)
								& " We have: "
								& integer'image(LoopCounter_up)
								& " and "
								& integer'image(LoopCounter)
								 severity FAILURE;
		END IF;

		--3) Test clk_out and clk_out_alt when reset = 1 
		LoopCounter := 0; 
		Sim_clkDivider_reset_i <= '1';
		wait on Sim_clk;
		wait on Sim_clk;
		
		L7 : loop
				exit L7 when (Sim_clkDivider_clk_out_alt = '1');
				exit L7 when (Sim_clkDivider_clk_out = '1');
				exit L7 when (LoopCounter > (Sim_clkDivider_DividerFactor*3));
 				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter := LoopCounter + 1;
			end loop;		
		
		IF (LoopCounter > (Sim_clkDivider_DividerFactor*3)
		   AND Sim_clkDivider_clk_out_alt = '0' AND Sim_clkDivider_clk_out = '0') THEN
			assert FALSE report "ClockDivider: Reset is working" severity NOTE;
		ELSE
			assert FALSE report "ClockDivider: Reset has FAILED" severity FAILURE;			
		END IF;

-------------------------------------------------
--Testing Buzzer
-------------------------------------------------

		LoopCounter_up := 0;
		LoopCounter:=0;

		--1) Test when Enable = 0
		--2) Test when Enable = 1
		
		--1) Test when Enable = 0
		L20 : loop
			exit L20 when (Sim_Buzzer_BuzzerOut /= '0');
			exit L20 when (LoopCounter>Sim_Buzzer_TestTime);
			LoopCounter := LoopCounter +1;
			wait on Sim_clk;
			wait on Sim_clk;
		end loop;

		IF (LoopCounter>Sim_Buzzer_TestTime) THEN
			assert FALSE report "Buzzer: Buzzer turns off" severity NOTE;
		ELSE
			assert FALSE report "Buzzer: Buzzer does not turn off" severity FAILURE;
		END IF;
		
		LoopCounter:=0;
		Sim_Buzzer_Enable <= '1';
		wait on Sim_clk;
		wait on Sim_clk;

		for temp in 1 to Sim_Buzzer_ForLoopNumber loop
			while LoopCounter < temp loop

				LoopCounter := 0;
				-- Waiting for rising edge on BuzzerOut
				L21 : while (Sim_Buzzer_BuzzerOut = '0' AND LoopCounter < Sim_Buzzer_TestTime)  loop
					wait on Sim_clk;
					wait on Sim_clk;
					LoopCounter := LoopCounter + 1;
				end loop ; -- L21

				-- Waiting for falling edge on BuzzerOut
				LoopCounter := 0;
				L22: while (Sim_Buzzer_BuzzerOut = '1' AND LoopCounter < Sim_Buzzer_TestTime ) loop
						wait on Sim_clk;
						wait on Sim_clk;
						LoopCounter := LoopCounter + 1;
					end loop;
				
				-- test if PWM of "NumberPeriodes" Period is ok 
				IF LoopCounter = temp THEN
					--assert FALSE report "Buzzer: PWM enabled: Step " & integer'image(temp) & " is working" severity NOTE;
				ELSIF LoopCounter > Sim_Buzzer_TestTime THEN
					assert FALSE report "Buzzer: PWM enabled: Step " & integer'image(temp) & " is NOT working. Test time exceded" severity FAILURE;
				END IF;	
				
			end loop ; -- identifier	
		end loop ; -- F20

		--Turning back off the Buzzer and finishing Buzzer tests
		assert FALSE report "Buzzer: is working" severity NOTE;		
		Sim_Buzzer_Enable <= '0';

-------------------------------------------------
--Testing ConvertIntToBcd
-------------------------------------------------

		--1) Testing the SevenSeg for the Minute 
		--2) Testing the SevenSeg for the Second Left
		--3) Testing the SevenSeg for the Second Right
		--4) Testing the SevenSeg for the Dezisecond
		
		wait on Sim_clk;
		while (Sim_clk/='0') loop
			wait on Sim_clk;
		end loop;	
		
		--1)

		Loop30: FOR temp IN 0 TO 9 LOOP
			--Sending the number
			Stim_IntBcd_InputInt <= DataInputMin(temp); 
		
			--wait for a rising edge
			wait on Sim_clk;
			wait on Sim_clk;
				
			IF Stim_IntBcd_SevenSeg1 = DataExpectedMin(temp) THEN
				--assert FALSE  report "ConvertIntBcd: Min Number " & integer'image(temp) & ": passed" severity Note;
			ELSE
				assert FALSE report "ConvertIntBcd: Min Number " & integer'image(temp) & " : FAILED" severity Error;
				ErrorCounter := ErrorCounter+1;
			END IF;		
		
		END LOOP Loop30;
		assert FALSE report "ConvertIntBcd: Finished test all possibilities of the minute SevenSeg" severity Note;
		
		--2)

		Loop31: FOR temp IN 0 TO 5 LOOP
		
			--Sending the number
			Stim_IntBcd_InputInt <= DataInputSecLeft(temp); 
		
			--wait for a rising edge
			wait on Sim_clk;
			wait on Sim_clk;
				
			IF Stim_IntBcd_SevenSeg2 = DataExpectedSecLeft(temp) THEN
				--assert FALSE  report "ConvertIntBcd: Sec Left Number " & integer'image(temp) & ": passed" severity Note;
			ELSE
				assert FALSE report "ConvertIntBcd: Sec Left Number " & integer'image(temp) & " : FAILED" severity Error;
				ErrorCounter := ErrorCounter+1;
			END IF;		
		
		END LOOP Loop31;
		assert FALSE report "ConvertIntBcd: Finished test all possibilities of the SevenSeg for the Second*10" severity Note;
		
		--3)

		Loop32: FOR temp IN 0 TO 9 LOOP
		
			--Sending the number
			Stim_IntBcd_InputInt <= DataInputSecRight(temp); 
		
			--wait for a rising edge
			wait on Sim_clk;
			wait on Sim_clk;
				
			IF Stim_IntBcd_SevenSeg3 = DataExpectedSecRight(temp) THEN
				--assert FALSE  report "ConvertIntBcd: Sec Right Number " & integer'image(temp) & ": passed" severity Note;
			
			ELSE
				assert FALSE report "ConvertIntBcd: Sec Right Number " & integer'image(temp) & " : FAILED" severity Error;
				ErrorCounter := ErrorCounter+1;				
			END IF;		
		
		END LOOP Loop32;
		assert FALSE report "ConvertIntBcd: Finished test all possibilities of the SevenSeg for the Seconds" severity Note;
		
		--4)

		Loop33: FOR temp IN 0 TO 9 LOOP
		
			--Sending the number
			Stim_IntBcd_InputInt <= DataInputDezisec(temp); 
		
			--wait for a rising edge
			wait on Sim_clk;
			wait on Sim_clk;
		
			IF Stim_IntBcd_SevenSeg4 = DataExpectedDezisec(temp) THEN
				--assert FALSE  report "ConvertIntBcd: Deziseconde Number " & integer'image(temp) & ": passed" severity Note;
			
			ELSE
				assert FALSE report "ConvertIntBcd: Deziseconde Number " & integer'image(temp) & " : FAILED" severity Error;
				ErrorCounter := ErrorCounter+1;				
				
			END IF;		
		
		END LOOP Loop33;
		assert FALSE report "ConvertIntBcd: Finished test all possibilities of the SevenSeg for the Deziseconde" severity Note;

		if ErrorCounter /= 0 then
			assert FALSE report "ConvertIntBcd: Error inside" severity FAILURE;				
		end if ;

-------------------------------------------------
--Testing Counter
-------------------------------------------------
		--1) Testing the incrementation of the Min to the max value
		--2) Testing the incrementation of the Sec to the max value
		--3) Testing the incrementation of the Min and Sec and Test Clear
		--4) Testing the dekrementation of the value to zero
		
		StimCountBlockControl_i <= "100000"; --doing reset
		wait on Sim_clk; --waiting for the next rising edge
		wait on Sim_clk; 

		--1)

		StimCountBlockControl_i <= "001000";  --Incrementation Mode
		--assert FALSE report "Counter: Mode Ready for Incrementing the Value" severity Note;
		assert FALSE report "Counter: Begin Test Incrementing Min Value" severity Note;

		Loop40: FOR temp IN 0 TO 10 LOOP
				StimBtnMinF_i <= '1';  --Press Min Button
				wait on Sim_clk; 	 --waiting for the next rising edge
				wait on Sim_clk;				
				
				IF StimCountValue_o = DataExpected_Counter_Min(temp) THEN
					--assert FALSE  report "Counter: Min " & integer'image(temp) & ": passed" severity Note;
				ELSE
					assert FALSE report "Counter: Min " & integer'image(temp) & " : FAILED" severity Error;
					ErrorCounter := ErrorCounter+1;					
				END IF;
				
				StimBtnMinF_i <= '0';  --Release Min Button
				
				wait on Sim_clk; 	 --waiting for the next rising edge
				wait on Sim_clk;

		END LOOP Loop40;
		--assert FALSE report "Counter: Finishing Test Incrementing Min Value" severity Note;

		StimCountBlockControl_i <= "100000"; --doing reset
		--assert FALSE report "Counter: Mode Reset" severity Note;
		wait on Sim_clk; --waiting for the next rising edge
		wait on Sim_clk; 


		--2)

		StimCountBlockControl_i <= "001000";  --Incrementation Mode
		--assert FALSE report "Counter: Mode Ready for Incrementing the Value" severity Note;
		assert FALSE report "Counter: Begin Test Incrementing Sec Value" severity Note;

		Loop41: FOR temp IN 0 TO 60 LOOP

				StimBtnSecF_i <= '1';  --Press Sec Button
				wait on Sim_clk; 	 --waiting for the next rising edge
				wait on Sim_clk;				
				
				IF StimCountValue_o = DataExpectedSec(temp) THEN
					--assert FALSE  report "Counter: Sec " & integer'image(temp) & ": passed" severity Note;
				ELSE
					assert FALSE report "Counter: Sec " & integer'image(temp) & " : FAILED" severity Error;
					ErrorCounter := ErrorCounter+1;	
				END IF;
				
				StimBtnSecF_i <= '0';  --Release Sec Button
				wait on Sim_clk; 	 --waiting for the next rising edge
				wait on Sim_clk;

		END LOOP Loop41;
		--assert FALSE report "Counter: Finishing Test Incrementing Sec Value" severity Note;

		StimCountBlockControl_i <= "100000"; --doing reset
		--assert FALSE report "Counter: Mode Reset" severity Note;
		wait on Sim_clk; --waiting for the next rising edge
		wait on Sim_clk; 

		--3)

		StimCountBlockControl_i <= "001000";  --Incrementation Mode
		--assert FALSE report "Counter: Mode Ready for Incrementing the Value" severity Note;
		--assert FALSE report "Counter: Begin Incrementing Sec Value" severity Note; 

		Loop42: FOR temp IN 0 TO 20 LOOP

				StimBtnSecF_i <= '1';  --Press Sec Button
				wait on Sim_clk; 	 --waiting for the next rising edge
				wait on Sim_clk;				
	
				StimBtnSecF_i <= '0';  --Release Sec Button
				wait on Sim_clk; 	 --waiting for the next rising edge
				wait on Sim_clk;

		END LOOP Loop42;

		--assert FALSE report "Counter: Finishing Incrementing Sec Value" severity Note;
		--assert FALSE report "Counter: Begin Incrementing Min Value" severity Note; 

		Loop43: FOR temp IN 0 TO 5 LOOP

				StimBtnMinF_i <= '1';  --Press Min Button
				wait on Sim_clk; 	 --waiting for the next rising edge
				wait on Sim_clk;				
				
				StimBtnMinF_i <= '0';  --Release Min Button
				wait on Sim_clk; 	 --waiting for the next rising edge
				wait on Sim_clk;

		END LOOP Loop43;

		--assert FALSE report "Counter: Finishing Incrementing Sec Value" severity Note;
		assert FALSE report "Counter: Test Clear Button" severity Note;

		StimCountBlockControl_i <= "100000"; --doing reset

		Loop44: LOOP
				exit Loop44 when ((StimCountValue_o = 0) OR (StimCountBlockTelemet_o = '1'));
				exit Loop44 when (LoopCounter > Looplimit);
				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter := LoopCounter + 1;
			
		END LOOP Loop44;
		--		
		IF (LoopCounter > Looplimit) THEN
			assert FALSE report "Counter: Clear Button has FAILED" severity Error;
			ErrorCounter := ErrorCounter + 1;	
		ELSE
			--assert FALSE report "Counter: Clear Button : passed" severity Note;
		END IF;
		--assert FALSE report "Counter: Finishing Test Clear Mode" severity Note;

		StimCountBlockControl_i <= "001000";  --Incrementation Mode
		--assert FALSE report "Counter: Mode Ready for Incrementing the Value" severity Note;
		--assert FALSE report "Counter: Begin Incrementing Sec Value" severity Note; 

		Loop45: FOR temp IN 0 TO 2 LOOP

				StimBtnSecF_i <= '1';  --Press Sec Button
				wait on Sim_clk; 	 --waiting for the next rising edge
				wait on Sim_clk;				
				
				StimBtnSecF_i <= '0';  --Release Sec Button
				wait on Sim_clk; 	 --waiting for the next rising edge
				wait on Sim_clk;

		END LOOP Loop45;
		--assert FALSE report "Counter: Finishing Incrementing Sec Value" severity Note;
		--assert FALSE report "Counter: Begin Incrementing Min Value" severity Note; 

		--Loop46: FOR temp IN 0 TO 1 LOOP

				--StimBtnMinF_i <= '1';  --Press Min Button
				--wait on Sim_clk; 	 --waiting for the next rising edge
				--wait on Sim_clk;				
				
				--StimBtnMinF_i <= '0';  --Release Min Button
				--wait on Sim_clk; 	 --waiting for the next rising edge
				--wait on Sim_clk;

		--END LOOP Loop46;

		--assert FALSE report "Counter: Finishing Incrementing Min Value" severity Note;
		assert FALSE report "Counter: Test Counting Down" severity Note;

		StimCountBlockControl_i <= "010000"; --Mode Counting Down
		LoopCounter := 0;

		Loop47: LOOP
				exit Loop47 when ((StimCountValue_o = 0) AND (StimCountBlockTelemet_o = '1'));
				exit Loop47 when (LoopCounter > LoopLimitCountingDown);
				wait on Sim_clk;
				wait on Sim_clk;
				LoopCounter := LoopCounter + 1;
		END LOOP Loop47;

		IF (LoopCounter > LoopLimitCountingDown) THEN
			assert FALSE report "Counter: Counting Down has FAILED" severity Error;
			ErrorCounter := ErrorCounter + 1;					
		ELSE
			assert FALSE report "Counter: Counting Down : passed" severity Note;
		END IF;
		--assert FALSE report "Counter: Finishing Test Counting Down" severity Note;

		if ErrorCounter /= 0 then
			assert FALSE report "Counter: Error inside" severity FAILURE;				
		end if ;

			
		
assert FALSE report "DONE with 0 Errors!" severity NOTE;
		wait;
			
	END PROCESS;
		
END simulate;