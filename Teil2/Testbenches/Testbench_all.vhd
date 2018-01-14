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
-- Simulation Signals for testing ConvertIntToBcd
CONSTANT LoopLimit : INTEGER := 100;
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

---------------------------------------------
BEGIN

--Generate clock of 50 MHz
Sim_clk <= not Sim_clk after 1 ps; --50Mhz normally duty-Cycle of 10ns

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
				assert FALSE  report "ConvertIntBcd: Min Number " & integer'image(temp) & ": passed" severity Note;
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
				assert FALSE  report "ConvertIntBcd: Sec Left Number " & integer'image(temp) & ": passed" severity Note;
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
				assert FALSE  report "ConvertIntBcd: Sec Right Number " & integer'image(temp) & ": passed" severity Note;
			
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
				assert FALSE  report "ConvertIntBcd: Deziseconde Number " & integer'image(temp) & ": passed" severity Note;
			
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
--Testing ConvertIntToBcd
-------------------------------------------------

			
		
assert FALSE report "DONE!" severity NOTE;
		wait;
			
	END PROCESS;
		
END simulate;