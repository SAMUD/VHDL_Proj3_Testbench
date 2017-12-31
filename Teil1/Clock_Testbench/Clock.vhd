-----------------------------------------------------------
-- 					VOLTZENLOGEL Xavier							--
--					Matrikelnummer : 179159-01 					--
-- 					29/12/2017         							--
-- 		           Clock		          					   --
-----------------------------------------------------------

-- Library Declaration -------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


------------------------------
-- 			ENTITY          --
------------------------------

ENTITY Clock IS
PORT(
		Reset							 :	IN std_logic;
		Clock				 			 : IN std_logic;
				
		ClockFlag					 : OUT std_logic);
		
END Clock;

-----------------------------
--				ARCHITECTURE	--
-----------------------------

ARCHITECTURE Clock_Arch of Clock IS

SIGNAL s_clock_comptage : INTEGER :=0; --Variable üm die Clock zu Zahlen

BEGIN

---------------------------
--      CLOCK PROZESS    --
---------------------------

clk_proc : PROCESS (Clock,Reset)
		
	BEGIN
		
		IF (Clock'EVENT AND Clock='1' AND Clock'LAST_VALUE='0' AND Reset = '1') THEN
			
			IF (s_clock_comptage > 49999999) THEN  --1sec = 49999999       Simu1 : 9;  
					s_clock_comptage <= 0;   --Die Zählvariable wird auf Null gesetzt
					ClockFlag <= '1'; 
					
			ELSE
					s_clock_comptage <= s_clock_comptage + 1;  --Inkrementierung der s_clock_comptage Variable
					ClockFlag <= '0';
			END IF;	
		END IF;
	
	
		IF (Reset = '0') THEN 			
				s_clock_comptage <= 0;	--Die Zählvariable wird auf Null gesetzt
				ClockFlag <= '0';
		END IF;
		
END PROCESS clk_proc;


END ARCHITECTURE Clock_Arch;