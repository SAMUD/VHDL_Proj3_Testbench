-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


------------------------------------------------------
--	   ENTITY	                           			 --
------------------------------------------------------

ENTITY Btn_Testbench IS
END Btn_Testbench;

------------------------------------------------------
--        ARCHITECTURE	                  			 --
------------------------------------------------------
ARCHITECTURE Btn_Test OF Btn_Testbench IS

SIGNAL Sim_Clock : std_logic :='0';
SIGNAL Sim_btn_start : std_logic :='0';
SIGNAL Sim_btn_s : std_logic :='0';
SIGNAL Sim_btn_m : std_logic :='0';
SIGNAL Sim_end_buzzer : std_logic :='0';
SIGNAL Sim_start_stop : std_logic :='0';
SIGNAL Sim_inc_s : std_logic :='0';
SIGNAL Sim_inc_m : std_logic :='0';


--Component to Test
component Btn
port (
	clk 			:IN std_logic;								
	btn_start 	:IN std_logic; 						
	btn_s			:IN std_logic;								
	btn_m 		:IN std_logic;								
	end_buzzer 	:IN std_logic;	
	
	start_stop 	:OUT std_logic;						
	inc_s			:OUT std_logic;							
	inc_m 		:OUT std_logic	
	);
end component;

---------------------------------------------
BEGIN

--Generate clock of 50 MHz
Sim_Clock <= not Sim_Clock after 10 ps; -- real 10 ns

-- Component
Btn_1: component Btn PORT MAP(
	clk 			=> Sim_Clock,								
	btn_start 	=> Sim_btn_start, 						
	btn_s			=> Sim_btn_s,								
	btn_m 		=> Sim_btn_m,								
	end_buzzer 	=> Sim_end_buzzer,	
	
	start_stop 	=> Sim_start_stop,						
	inc_s			=> Sim_inc_s,							
	inc_m 		=> Sim_inc_m	
	);
		
--Stimulate-process
Btn_Test: PROCESS	
	
BEGIN
	
	Sim_btn_start <= '1';
	Sim_btn_s <= '1';
	Sim_btn_m <= '1';
	wait on Sim_Clock; --waiting for the next rising edge
	wait on Sim_Clock; 
		
	--Test start_stop at begin
	IF (Sim_start_stop='0') THEN
		assert FALSE report "start_stop at begin is ok" severity NOTE;
	ELSE
		assert FALSE report "start_stop at begin has failed" severity NOTE;
	END IF;
	
	wait on Sim_Clock; --waiting for the next rising edge
	wait on Sim_Clock; 
	
	--Test start_stop after btn_start
	Sim_btn_start <= '0';
	
	wait on Sim_Clock; --waiting for the next rising edge
	wait on Sim_Clock; 
	
	Sim_btn_start <= '1';
	
	IF (Sim_start_stop='1') THEN
		assert FALSE report "start_stop after btn_start is ok" severity NOTE;
	ELSE
		assert FALSE report "start_stop after btn_start has failed" severity NOTE;
	END IF;
	
	--Test btn_s when start_stop = 1
	Sim_btn_s <= '0';
	
	wait on Sim_Clock; --waiting for the next rising edge
	wait on Sim_Clock; 
	
	Sim_btn_s <= '1';
	
	IF (Sim_inc_s='0') THEN
		assert FALSE report "inc_s when start_stop = 1 is ok" severity NOTE;
	ELSE
		assert FALSE report "inc_s when start_stop = 1 has failed" severity NOTE;
	END IF;
	
	--Test btn_m when start_stop = 1
	Sim_btn_m <= '0';
	
	wait on Sim_Clock; --waiting for the next rising edge
	wait on Sim_Clock; 
	
	Sim_btn_m <= '1';
	
	IF (Sim_inc_m='0') THEN
		assert FALSE report "inc_m when start_stop = 1 is ok" severity NOTE;
	ELSE
		assert FALSE report "inc_m when start_stop = 1 has failed" severity NOTE;
	END IF;
	
	-- start_stop = 0
	Sim_btn_start <= '0';
	
	wait on Sim_Clock; --waiting for the next rising edge
	wait on Sim_Clock; 
	
	Sim_btn_start <= '1';
	
	--Test btn_s when start_stop = 0	
	Sim_btn_s <= '0';
	
	wait on Sim_Clock; --waiting for the next rising edge
	wait on Sim_Clock; 
	
	Sim_btn_s <= '1';
	
	IF (Sim_inc_s='1') THEN
		assert FALSE report "inc_s when start_stop = 1 is ok" severity NOTE;
	ELSE
		assert FALSE report "inc_s when start_stop = 1 has failed" severity NOTE;
	END IF;
	
	--Test btn_m when start_stop = 0	
	Sim_btn_m <= '0';
	
	wait on Sim_Clock; --waiting for the next rising edge
	wait on Sim_Clock; 
	
	Sim_btn_m <= '1';
	
	IF (Sim_inc_m='1') THEN
		assert FALSE report "inc_m when start_stop = 1 is ok" severity NOTE;
	ELSE
		assert FALSE report "inc_m when start_stop = 1 has failed" severity NOTE;
	END IF;
	
	wait;
		
	END PROCESS;
		
END Btn_Test;