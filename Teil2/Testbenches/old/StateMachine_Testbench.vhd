------------------------------------------------------
-- StateMachine_Testbench  --
-- DISCHLI Arthur --
-- 10/01/18 --
-- Matrikelnummer : 179156 --
------------------------------------------------------

-- Library Declaration -------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.all;


------------------------------
-- 			ENTITY          --
------------------------------

ENTITY StateMachine_Testbench IS

END StateMachine_Testbench;


-----------------------------
--				ARCHITECTURE	--
-----------------------------

ARCHITECTURE TestBench of StateMachine_Testbench IS

--Constant Signal
CONSTANT LoopLimit : INTEGER := 5;
CONSTANT LoopLimitBuzzer : INTEGER := 6500;

--internal Signals /stimulate signals

	SIGNAL StimReset_i : std_logic :='0';
	SIGNAL StimClk_i : std_logic :='0';
	SIGNAL StimClk_Deci_i : std_logic :='0';
	SIGNAL StimBtnStartF_i : std_logic := '0';
	SIGNAL StimBtnClearF_i : std_logic := '0';
	SIGNAL StimCountBlockControl_o : std_logic_vector (5 downto 0) := (others => '0');
	
	SIGNAL StimCountBlockTelemet_i : std_logic := '0';
	
	SIGNAL ErrorStartState : std_logic := '0';
	SIGNAL ErrorStopbuzzer : std_logic := '0';
	
--Component to Test
COMPONENT StateMachine
------------------

		PORT(		
				Reset_i, Clk_i, Clk_Deci_i, BtnStartF_i, BtnClearF_i, CountBlockTelemet_i	:	IN std_logic;
				CountBlockControl_o : OUT std_logic_vector (5 downto 0));

END COMPONENT;

----------------------------------------		

BEGIN



-- Clock Generator 50Mhz

		StimClk_i <= not StimClk_i after 1 ps; --reality 10ns
		StimClk_Deci_i <= not StimClk_Deci_i after 10 ps; 
		
		
-- Call Component


	ZustandMachine: component StateMachine
			PORT MAP(
							Reset_i => StimReset_i,
							Clk_i	=> StimClk_i,
							Clk_Deci_i	=> StimClk_Deci_i,
							BtnStartF_i => StimBtnStartF_i,
							BtnClearF_i => StimBtnClearF_i,
							CountBlockTelemet_i => StimCountBlockTelemet_i,
							CountBlockControl_o => StimCountBlockControl_o);
	


PROCESS 

	VARIABLE LoopCounter : INTEGER := 0;


BEGIN		

		
		--1) testing reset / Edit counting value / clear / start / Pause Because Start / Edit counting value
		--2) testing Start / Pause Because End Counting / Buzzing / Stop Buzzer Because Start / Edit counting Value
		--3) testing Start / Pause Because End Counting / Buzzing / Stop Buzzer Because End Buzzing Time /Edit counting value

---------------------------------------		
--1)
		assert FALSE report "Step 1"severity Note;
--Reset
		
		StimReset_i <= '1'; --Executing reset
		L11 : loop
			exit L11 when (StimCountBlockControl_o="100000");  --Waiting the right value of output
			exit L11 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State reset not worked"severity Note;
		ELSE
			assert FALSE report "State Reset Worked" severity Note;
		END IF; 
		StimReset_i <= '0';
		LoopCounter:=0;
		
--Edit counting value
		
		L12 : loop
			exit L12 when (StimCountBlockControl_o="001000"); --Waiting the right value of output
			exit L12 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Edit counting value not worked"severity Note;
		ELSE
			assert FALSE report "State Edit counting value Worked" severity Note;
		END IF; 		
		LoopCounter:=0;
		
--Clear
		
		StimBtnClearF_i<='1'; --Executing clear

		L131 : loop
			exit L131 when (StimCountBlockControl_o="100000"); --Waiting the right value of output
			exit L131 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Clear not worked"severity Note;
		ELSE
			assert FALSE report "State Clear Worked" severity Note;
		END IF; 		
		StimBtnClearF_i<='0';
		LoopCounter:=0;
		
		L132 : loop
			exit L132 when (StimCountBlockControl_o="001000"); --Waiting the right value of output
			exit L132 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Edit counting value after clear not worked"severity Note;
		ELSE
			assert FALSE report "State Edit counting value after clear Worked" severity Note;
		END IF; 		
		LoopCounter:=0;
		
--Start

		StimBtnStartF_i<='1'; --Executing start
		
		L141 : loop
			exit L141 when (StimCountBlockControl_o="000100"); --Waiting the right value of output
			exit L141 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Load last Saved Value not worked"severity Note;
			ErrorStartState<='1';
		END IF;		
		StimBtnStartF_i<='0';
		LoopCounter:=0;		
		
		L142 : loop
			exit L142 when (StimCountBlockControl_o="010000"); --Waiting the right value of output
			exit L142 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Counting has started / enable not worked"severity Note;
			ErrorStartState<='1';
		END IF;
		IF ErrorStartState='1' THEN
			assert FALSE report "Error State Start not worked"severity Note;
			ErrorStartState<='0';
		ELSE
			assert FALSE report "State Start worked"severity Note;
			ErrorStartState<='0';
		END IF; 		
		LoopCounter:=0;
		
--Pause Because Start	
		
		StimBtnStartF_i<='1'; --Executing a pause
		
		L15 : loop
			exit L15 when (StimCountBlockControl_o="000000"); --Waiting the right value of output
			exit L15 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Pause not worked"severity Note;
		ELSE
			assert FALSE report "State Pause worked"severity Note;
		END IF;		
		LoopCounter:=0;

--Edit counting value

		StimBtnStartF_i<='0'; --Unpressing btn start to go to edit counting value	
		
		L16 : loop
			exit L16 when (StimCountBlockControl_o="001000"); --Waiting the right value of output
			exit L16 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Edit counting value after pause because start not worked"severity Note;
		ELSE
			assert FALSE report "State Edit counting value after pause because start worked"severity Note;
		END IF;		
		LoopCounter:=0;
		
		assert FALSE report "End Step 1"severity Note;
	
---------------------------------------	
--2)
		
		assert FALSE report "Step 2"severity Note;
		
--Start		
		
		StimBtnStartF_i<='1'; --Executing start
		
		L211 : loop
			exit L211 when (StimCountBlockControl_o="000100"); --Waiting the right value of output
			exit L211 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Load last Saved Value not worked"severity Note;
			ErrorStartState<='1';
		END IF;		
		StimBtnStartF_i<='0';
		LoopCounter:=0;		
		
		L212 : loop
			exit L212 when (StimCountBlockControl_o="010000"); --Waiting the right value of output
			exit L212 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Counting has started / enable not worked"severity Note;
			ErrorStartState<='1';
		END IF;
		IF ErrorStartState='1' THEN
			assert FALSE report "Error State Start not worked"severity Note;
			ErrorStartState<='0';
		ELSE
			assert FALSE report "State Start worked"severity Note;
			ErrorStartState<='0';
		END IF;		
		LoopCounter:=0;		
		
--Pause Because End counting	
		
		StimCountBlockTelemet_i<='1'; --Executing a pause
		
		L22 : loop
			exit L22 when (StimCountBlockControl_o="000000"); --Waiting the right value of output
			exit L22 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Pause not worked"severity Note;
		ELSE
			assert FALSE report "State Pause worked"severity Note;
		END IF;		
		LoopCounter:=0;		
		StimCountBlockTelemet_i<='0';
		
--Buzzing

		L23 : loop
			exit L23 when (StimCountBlockControl_o="000001"); --Waiting the right value of output
			exit L23 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Buzzing not worked"severity Note;
		ELSE
			assert FALSE report "State Buzzing worked"severity Note;
		END IF;		
		LoopCounter:=0;

--Stop Buzzer Because Start
		
		StimBtnStartF_i<='1'; --Executing stop buzzer
		
		L24 : loop
			exit L24 when (StimCountBlockControl_o="000010"); --Waiting the right value of output
			exit L24 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Save current Counter Value not worked"severity Note;
			ErrorStopbuzzer<='1';
		END IF;		
		StimBtnStartF_i<='0';
		LoopCounter:=0;		

--Edit counting Value
		
		L25 : loop
			exit L25 when (StimCountBlockControl_o="001000"); --Waiting the right value of output
			exit L25 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Edit counting Value not worked"severity Note;
			ErrorStopbuzzer<='1';
		END IF;
		IF ErrorStopbuzzer='1' THEN
			assert FALSE report "Error State stop buzzer not worked"severity Note;
			ErrorStopbuzzer<='0';
		ELSE
			assert FALSE report "State stop buzzer worked"severity Note;
			ErrorStopbuzzer<='0';
		END IF;		
		LoopCounter:=0;		
		
		assert FALSE report "End Step 2"severity Note;

---------------------------------------		
--3)
		
		assert FALSE report "Step 3"severity Note;
		
--Start		
		
		StimBtnStartF_i<='1'; --Executing start
		
		L311 : loop
			exit L311 when (StimCountBlockControl_o="000100"); --Waiting the right value of output
			exit L311 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Load last Saved Value not worked"severity Note;
			ErrorStartState<='1';
		END IF;		
		StimBtnStartF_i<='0';
		LoopCounter:=0;		
		
		L312 : loop
			exit L312 when (StimCountBlockControl_o="010000"); --Waiting the right value of output
			exit L312 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Counting has started / enable not worked"severity Note;
			ErrorStartState<='1';
		END IF;
		IF ErrorStartState='1' THEN
			assert FALSE report "Error State Start not worked"severity Note;
			ErrorStartState<='0';
		ELSE
			assert FALSE report "State Start worked"severity Note;
			ErrorStartState<='0';
		END IF;		
		LoopCounter:=0;		
		
--Pause Because End counting	
		
		StimCountBlockTelemet_i<='1'; --Executing a pause
		
		L32 : loop
			exit L32 when (StimCountBlockControl_o="000000"); --Waiting the right value of output
			exit L32 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Pause not worked"severity Note;
		ELSE
			assert FALSE report "State Pause worked"severity Note;
		END IF;		
		LoopCounter:=0;		
		StimCountBlockTelemet_i<='0';
		
--Buzzing

		L33 : loop
			exit L33 when (StimCountBlockControl_o="000001"); --Waiting the right value of output
			exit L33 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Buzzing not worked"severity Note;
		ELSE
			assert FALSE report "State Buzzing worked"severity Note;
		END IF;		
		LoopCounter:=0;

--Stop Buzzer Because End Buzzing Time
		
		L34 : loop
			exit L34 when (StimCountBlockControl_o="000010"); --Waiting the right value of output
			exit L34 when (LoopCounter > LoopLimitBuzzer);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimitBuzzer) THEN
			assert FALSE report "Error State Save current Counter Value not worked"severity Note;
			ErrorStopbuzzer<='1';
		END IF;
		LoopCounter:=0;		

--Edit counting Value
		
		L35 : loop
			exit L35 when (StimCountBlockControl_o="001000"); --Waiting the right value of output
			exit L35 when (LoopCounter > LoopLimit);		-- to prevent infinit loop
			wait on StimClk_i;
			wait on StimClk_i;
			LoopCounter := LoopCounter + 1;
		end loop;
		IF (LoopCounter > LoopLimit) THEN
			assert FALSE report "Error State Edit counting Value not worked"severity Note;
			ErrorStopbuzzer<='1';
		END IF;
		IF ErrorStopbuzzer='1' THEN
			assert FALSE report "Error State Stop Buzzer Because End Buzzing Time not worked"severity Note;
			ErrorStopbuzzer<='0';
		ELSE
			assert FALSE report "State Stop Buzzer Because End Buzzing Time worked"severity Note;
			ErrorStopbuzzer<='0';
		END IF;		
		LoopCounter:=0;		
		
		assert FALSE report "End Step 3"severity Note;	
---------------------------------------
		
		wait on StimClk_i;
		wait on StimClk_i;
		
		
		assert FALSE report "All tests executed" severity Note;	
		wait;
		
END PROCESS;

END TestBench;