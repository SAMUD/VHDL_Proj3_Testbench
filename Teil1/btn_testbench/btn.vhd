----------------------------------------------------------
-- 					BUCHERT Jérémy									--
--					Matrikelnummer : 179162-01 					--
-- 					09/01/2018         							--
-- 		           Btn					     					   --
-----------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--------------------------------------------
-- ENTITY --
--------------------------------------------
ENTITY btn IS
PORT(
	clk :IN std_logic;								-- interne 50 MHz clk
	btn_start :IN std_logic; 						-- Taste der die zahlung begindt
	btn_s :IN std_logic;								-- Taste zur regelung der Sekunden
	btn_m :IN std_logic;								-- Taste zur regelung der Minuten
	end_buzzer :IN std_logic;						-- zeigt ob der buzzer an ist (0) oder nicht (1)
	start_stop :OUT std_logic;						-- aktuelles zustand des programms (start : 1; stop : 0)
	inc_s :OUT std_logic;							-- wenn auf 1 : Sekunde + 1
	inc_m :OUT std_logic								-- wenn auf 1 : Minuten + 1
	);
END btn;

--------------------------------------------
-- ARCHITECTURE --
--------------------------------------------

ARCHITECTURE behave_btn OF btn IS

SIGNAL btn_s_mem : std_logic := '1'; 					-- Speichert der letzte zustand der Taste btn_s
SIGNAL btn_m_mem : std_logic := '1';					-- Speichert der letzte zustand der Taste btn_m
SIGNAL btn_start_mem : std_logic := '1';				-- Speichert der letzte zustand der Taste btn_start
SIGNAL end_buzzer_mem : std_logic := '1';
SIGNAL start_stop_change_s : std_logic := '0';			-- variable der das zustand von start_stop ändert


BEGIN
	
-- Registered Process --
btn_proc : PROCESS (clk)
VARIABLE start_stop_change : std_logic := '0';			-- variable der das zustand von start_stop ändert

	BEGIN
		IF (clk'EVENT AND clk='1' AND clk'LAST_VALUE='0'
		) THEN
			
			start_stop_change := start_stop_change_s;			-- start_stop
			IF ((btn_start_mem = '1' AND btn_start = '0') OR (end_buzzer_mem = '0' AND end_buzzer = '1')) THEN			
				start_stop_change := NOT (start_stop_change);		
			END IF;
			
			IF (btn_s_mem = '1' AND start_stop_change = '0' AND btn_s = '0') THEN	
				inc_s <= '1';	-- inc_s wird auf 1 gesetzt wen die Taste btn_s gedrückt ist und die counting methode auf 1 ist
		ELSE
				inc_s <= '0';
			END IF;
			
			IF (btn_m_mem = '1' AND start_stop_change = '0' AND btn_m = '0') THEN	
				inc_m <= '1'; -- inc_m wird auf 1 gesetzt wen die Taste btn_m gedrückt ist und die counting methode auf 1 ist
			ELSE
				inc_m <= '0';
			END IF;
			
			-- Speicher der aktuelle zustand der Tasten und der Variable für den folgenden Takt
			btn_start_mem <= btn_start;
			btn_s_mem <= btn_s;
			btn_m_mem <= btn_m;
			
			end_buzzer_mem <= end_buzzer;
			
			start_stop_change_s<=start_stop_change;
			start_stop<=start_stop_change;
			
		END IF;
	END PROCESS btn_proc;
	
END behave_btn;

