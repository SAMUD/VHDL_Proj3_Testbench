-----------------------------------------------------------
-- 					VOLTZENLOGEL Xavier							--
--					Matrikelnummer : 179159-01 					--
-- 					9/01/2018         							--
-- 		 TestBench Counter and ConvertIntBcd			   --
-----------------------------------------------------------

-- Must be test in Gate Level Simulation

-- Library Declaration -------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.all;


------------------------------
-- 			ENTITY          --
------------------------------

ENTITY ConvertIntBcd_Testbench IS

END ConvertIntBcd_Testbench;


-----------------------------
--				ARCHITECTURE	--
-----------------------------

ARCHITECTURE TestBench of ConvertIntBcd_Testbench IS


--Constant Signal
CONSTANT LoopLimit : INTEGER := 100;
	
	
--Internal Signals / Stimulate signals from the Int to Bcd Converter

	
	
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
	
	SIGNAL StimClock:	std_logic :='0';
	
	
	
	SIGNAL StimInputInt : INTEGER  range 0 to 6000 ;			--Input signal containing the actual time information in Deci-Sec
													
	SIGNAL StimSevenSeg1	: std_logic_vector (6 downto 0) := "0000000";
	SIGNAL StimSevenSeg2	: std_logic_vector (6 downto 0) := "0000000";	
	SIGNAL StimSevenSeg3	: std_logic_vector (6 downto 0) := "0000000";	
	SIGNAL StimSevenSeg4	: std_logic_vector (6 downto 0) := "0000000";
	
	
--Component to Test

	COMPONENT ConvertIntBcd
		PORT(															
			InputInt		:		IN		integer range 0 to 6000 ;		--Input signal containing the actual time information in Deci-Sec												
			SevenSeg1	:		OUT	std_logic_vector (6 downto 0);	-- decoded signals to send to the 7seg
			SevenSeg2	:		OUT	std_logic_vector (6 downto 0);	
			SevenSeg3	:		OUT	std_logic_vector (6 downto 0);	
			SevenSeg4	:		OUT	std_logic_vector (6 downto 0)
			);
			
END COMPONENT;


--	COMPONENT Decoder
--		  PORT(
--			Input			:		IN		std_logic_vector (3 downto 0);	-- Input to Decode for 7seg
--			Output		:		OUT	std_logic_vector (6 downto 0)		-- decoded signals to send to the 7seg
--		);
--END COMPONENT;

----------------------------------

BEGIN
		
--Generate clock
	StimClock <= not StimClock after 10 ps;
		
		
-- Call Component							
							
	ConvertIntBcd_1: COMPONENT ConvertIntBcd
			PORT MAP(
					InputInt  => StimInputInt,											
					SevenSeg1 => StimSevenSeg1,
					SevenSeg2 => StimSevenSeg2,
					SevenSeg3 => StimSevenSeg3,
					SevenSeg4 => StimSevenSeg4 
					);	
	
--	Decoder_Min: COMPONENT Decoder
--			PORT MAP(
--				Input => StimInputInt,
--				Output => StimSevenSeg1
--			);	
--	Decoder_SecTen: COMPONENT Decoder
--			PORT MAP(
--				Input  => StimInputInt,
--				Output => StimSevenSeg2
--			);	
--	Decoder_Sec: COMPONENT Decoder
--			PORT MAP(
--				Input  => StimInputInt,
--				Output => StimSevenSeg2
--			);
--	Decoder_SecDeci: COMPONENT Decoder
--			PORT MAP(
--				Input  => StimInputInt,
--				Output => StimSevenSeg2
--			);

PROCESS

	VARIABLE LoopCounter : INTEGER := 0;
	VARIABLE Increment : INTEGER range 0 to 9 := 0;
	
	
	
BEGIN

		
		--1) Testing the SevenSeg for the Minute 
		--2) Testing the SevenSeg for the Second Left
		--3) Testing the SevenSeg for the Second Right
		--4) Testing the SevenSeg for the Dezisecond
		
		
		--The DUT in this case is programmed asynchronous. It doesn't use a clock. No need to test for clocks here in theory.
		--But the clock is used to slow things down, to have someting beautiful in the Wave-Graph during simulation
		--finding a rising edge
		wait on StimClock;
		while (StimClock/='0') loop
			wait on StimClock;
		end loop;	
		
		
		
		--1)
		
		assert FALSE report "Test all possibilities of the minute SevenSeg" severity Note;
		
		
		Loop1: FOR Increment IN 0 TO 9 LOOP
		
			--Sending the number
			StimInputInt <= DataInputMin(Increment); 
		
			--wait for a rising edge
			wait on StimClock;
			wait on StimClock;
				
				IF StimSevenSeg1 = DataExpectedMin(Increment) THEN
					--its true. So its done
					assert FALSE  report " Min Number " & integer'image(Increment) & ": passed" severity Note;
				
				ELSE
					--not true. Report error
					assert FALSE report "Min Number " & integer'image(Increment) & " : FAILED" severity Error;
				END IF;		
		
		END LOOP Loop1;
	
		assert FALSE report "Finishing Test all possibilities of the minute SevenSeg" severity Note;

-----------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------
		
		--2)
		
		assert FALSE report "Test all possibilities of the SevenSeg for the Second Left" severity Note;
		
		
		Loop2: FOR Increment IN 0 TO 5 LOOP
		
			--Sending the number
			StimInputInt <= DataInputSecLeft(Increment); 
		
			--wait for a rising edge
			wait on StimClock;
			wait on StimClock;
				
				IF StimSevenSeg2 = DataExpectedSecLeft(Increment) THEN
					--its true. So its done
					assert FALSE  report " Sec Left Number " & integer'image(Increment) & ": passed" severity Note;
				
				ELSE
					--not true. Report error
					assert FALSE report "Sec Left Number " & integer'image(Increment) & " : FAILED" severity Error;
				END IF;		
		
		END LOOP Loop2;
	
		assert FALSE report "Test all possibilities of the SevenSeg for the Second Left" severity Note;
		
-----------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------
		
		--3)
		
		assert FALSE report "Test all possibilities of the SevenSeg for the Second Right" severity Note;
		
		
		Loop3: FOR Increment IN 0 TO 9 LOOP
		
			--Sending the number
			StimInputInt <= DataInputSecRight(Increment); 
		
			--wait for a rising edge
			wait on StimClock;
			wait on StimClock;
				
				IF StimSevenSeg3 = DataExpectedSecRight(Increment) THEN
					--its true. So its done
					assert FALSE  report " Sec Right Number " & integer'image(Increment) & ": passed" severity Note;
				
				ELSE
					--not true. Report error
					assert FALSE report "Sec Right Number " & integer'image(Increment) & " : FAILED" severity Error;
				END IF;		
		
		END LOOP Loop3;
	
		assert FALSE report "Test all possibilities of the SevenSeg for the Second Right" severity Note;

-----------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------
		
		--4)
		
		assert FALSE report "Test all possibilities of the SevenSeg for the Deziseconde" severity Note;
		
		
		Loop4: FOR Increment IN 0 TO 9 LOOP
		
			--Sending the number
			StimInputInt <= DataInputDezisec(Increment); 
		
			--wait for a rising edge
			wait on StimClock;
			wait on StimClock;
		
				IF StimSevenSeg4 = DataExpectedDezisec(Increment) THEN
					--its true. So its done
					assert FALSE  report " Deziseconde Number " & integer'image(Increment) & ": passed" severity Note;
				
				ELSE
					--not true. Report error
					assert FALSE report "Deziseconde Number " & integer'image(Increment) & " : FAILED" severity Error;
				END IF;		
		
		END LOOP Loop4;
	
		assert FALSE report "Test all possibilities of the SevenSeg for the Deziseconde" severity Note;

		
--Finished
assert FALSE report "DONE!" severity NOTE;
wait;
	
end process;
	
END TestBench;	
		
					
					
					
	
	
	