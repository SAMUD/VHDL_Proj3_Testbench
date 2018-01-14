------------------------------------------------------
-- BCD_zahler_Testbench  --
-- DISCHLI Arthur --
-- 08/01/18 --
-- Matrikelnummer : 179156 --
------------------------------------------------------

-- Library Declaration -------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.all;


------------------------------
-- 			ENTITY          --
------------------------------

ENTITY BCD_zahler_Testbench IS

END BCD_zahler_Testbench;


-----------------------------
--				ARCHITECTURE	--
-----------------------------

ARCHITECTURE TestBench of BCD_zahler_Testbench IS

--Constant Signal
CONSTANT LoopLimit : INTEGER := 15;

--internal Signals /stimulate signals

	SIGNAL StimReset : std_logic :='0';
	SIGNAL StimClk : std_logic :='0';
	SIGNAL StimCM : std_logic := '0';
	SIGNAL Stimb : std_logic_vector (3 downto 0) := (others => '0');
	
	SIGNAL Valid_count_Odd : std_logic := '0';
	SIGNAL Valid_count_Even : std_logic := '0';
	SIGNAL Valid_count_All : std_logic := '0';

	TYPE DataExpected_ArrayOdd IS ARRAY (6 downto 0) 	of std_logic_vector (3 downto 0);
	SIGNAL DataExpected_Odd : DataExpected_ArrayOdd := ("0000","1001","0111","0101","0011","0001","0000");	--Expecting value when odd counting
		
	TYPE DataExpected_ArrayEven IS ARRAY (5 downto 0) 	of std_logic_vector (3 downto 0);
	SIGNAL DataExpected_Even : DataExpected_ArrayEven := ("0000","1000","0110","0100","0010","0000");		--Expecting value when Even counting
	
	TYPE DataExpected_ArrayAll IS ARRAY (10 downto 0) 	of std_logic_vector (3 downto 0);
	SIGNAL DataExpected_All : DataExpected_ArrayAll := ("0000","1001","1000","0111","0110","0101","0100","0011","0010","0001","0000");	--Expecting value when Odd and Even counting
		
--Component to Test
COMPONENT BCD_zahler
------------------

		PORT(		
				Reset, Clk, CM		 :	IN std_logic;
				b : OUT std_logic_vector (3 downto 0));

END COMPONENT;

----------------------------------------		

BEGIN



-- Clock Generator 50Mhz

		StimClk <= not StimClk after 1 ps; --reality 10ns
		
		
-- Call Component


	Zahler: component BCD_Zahler
			PORT MAP(
							Reset => StimReset,
							Clk	=> StimClk,
							CM => StimCM,
							b => Stimb);
	


PROCESS 

	VARIABLE LoopCounter : INTEGER := 0;
	VARIABLE IncrementOdd : INTEGER range 0 to 6 := 0;
	VARIABLE IncrementEven : INTEGER range 0 to 5 := 0;
	VARIABLE IncrementAll : INTEGER range 0 to 10 := 0;

BEGIN		

		
		--1) testing when CM = 1 if counter count 0 1 3 5 7 9 0 ...
		--2) testing when CM = 0 if counter count 0 2 4 6 8 0 ...
		--3) testing when CM =0 then CM =1 then CM =0 then ...
		
		StimReset <= '1'; --doing reset
		assert FALSE report "Reset 1" severity Note;
		wait on StimClk; --waiting for the next rising edge
		wait on StimClk; 
		StimReset <= '0';
		assert FALSE report "Reset 0" severity Note;
		
		
--1)
		
		--Reset Loop Counter
		LoopCounter:=0;
		--CM = 1
		StimCM <= '1';		
		
		
		L1 : FOR IncrementOdd IN 0 TO 6 loop		--Loop to test all expecting value when odd counting
			
			L11 : loop
				exit L11 when (Stimb = DataExpected_Odd(IncrementOdd)); --wait to the expected value
				exit L11 when (LoopCounter > Looplimit);			--to prevent infinit loop
				wait on StimClk;
				wait on StimClk;
				LoopCounter := LoopCounter + 1;
			end loop;
			
			--output message depending on result of test
			IF (LoopCounter > Looplimit) THEN
				assert FALSE report "Expected: " & integer'image(to_integer(unsigned(DataExpected_Odd(IncrementOdd)))) & " but became: " & integer'image(to_integer(unsigned((Stimb))))severity Note;
				Valid_count_Odd <='1';
			ELSE
				assert FALSE report integer'image(to_integer(unsigned(DataExpected_Odd(IncrementOdd)))) &" Worked" severity Note;
			END IF;
			
			wait on StimClk;
			wait on StimClk;
			LoopCounter := 0;
			
		end loop;
	
		
		--Output message depending on the successfull of odd counting
		IF Valid_count_Odd='1' THEN
			assert FALSE report "Counting 0 1 3 5 7 9 has failled" severity Note;	
		ELSE
			assert FALSE report "Counting 0 1 3  5 7 9 is working" severity Note;
		END IF;
		
		wait on StimClk;
		wait on StimClk;
		
--2)
		
		--Reset Countloop
		LoopCounter := 0;
		--CM = 0
		StimCM <= '0';
		
		L2 : FOR IncrementEven IN 0 TO 5 loop		--Loop to test all expecting value when Even counting
			
			L21 : loop
				exit L21 when (Stimb = DataExpected_Even(IncrementEven)); 	--wait to the expected value
				exit L21 when (LoopCounter > Looplimit);			--to prevent infinit loop
				wait on StimClk;
				wait on StimClk;
				LoopCounter := LoopCounter + 1;
			end loop;
			
			--output message depending on result of test
			IF (LoopCounter > Looplimit) THEN
				assert FALSE report "Expected: " & integer'image(to_integer(unsigned(DataExpected_Even(IncrementEven)))) & " but became: " & integer'image(to_integer(unsigned((Stimb))))severity Note;
				Valid_count_Even <='1';
			ELSE
				assert FALSE report integer'image(to_integer(unsigned(DataExpected_Even(IncrementEven)))) &" Worked" severity Note;
			END IF;
			
			wait on StimClk;
			wait on StimClk;
			LoopCounter := 0;
			
		end loop;
	
		
		--Output message depending on the successfull of Even counting
		IF Valid_count_Even='1' THEN
			assert FALSE report "Counting 0 2 4 6 8 0 has failled" severity Note;	
		ELSE
			assert FALSE report "Counting 0 2 4 6 8 0 is working" severity Note;
		END IF;
		
		wait on StimClk;
		wait on StimClk;
		
		
--3)
		
		--Reset Countloop
		LoopCounter := 0;
		--CM = 0
		StimCM <= '0';
		
		L3 : FOR IncrementAll IN 0 TO 10 loop	--Loop to test all expecting value when alternaly odd and Even counting
			
			L31 : loop
				exit L31 when (Stimb = DataExpected_All(IncrementAll)); --wait to the expected value
				exit L31 when (LoopCounter > Looplimit);			--to prevent infinit loop
				wait on StimClk;
				wait on StimClk;
				LoopCounter := LoopCounter + 1;
			end loop;
			
			--output message depending on result of test
			IF (LoopCounter > Looplimit) THEN
				assert FALSE report "Expected: " & integer'image(to_integer(unsigned(DataExpected_All(IncrementAll)))) & " but became: " & integer'image(to_integer(unsigned((Stimb))))severity Note;
				Valid_count_All <='1';
			ELSE
				assert FALSE report integer'image(to_integer(unsigned(DataExpected_All(IncrementAll)))) &" Worked" severity Note;
			END IF;
			
			wait on StimClk;
			wait on StimClk;
			LoopCounter := 0;
			
			IF ((IncrementAll mod 2) =0) THEN
				StimCM <='1';
			ELSE
				StimCM <='0';
			END IF;
			
		end loop;
	
		
		--Output message depending on the successfull of alternaly Even and odd counting
		IF Valid_count_All='1' THEN
			assert FALSE report "Counting 0 1 2 3 4 5 6 7 8 9 0 has failled" severity Note;	
		ELSE
			assert FALSE report "Counting 0 1 2 3 4 5 6 7 8 9 0 is working" severity Note;
		END IF;
		
		wait on StimClk;
		wait on StimClk;
		
		
		assert FALSE report "All tests executed" severity Note;	
		wait;
		
END PROCESS;

END TestBench;