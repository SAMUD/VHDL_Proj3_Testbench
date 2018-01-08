------------------------------------------------------
--  BCD_zahler  --
-- DISCHLI Arthur --
-- 07/11/17 --
-- Matrikelnummer : 179156 --
------------------------------------------------------
-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

--------------------------------------------
--	   ENTITY	                        --
--------------------------------------------
ENTITY BCD_zahler IS
PORT(
	reset	:IN	std_logic;
	clk	:IN	std_logic;
	CM		:IN	std_logic;
	b0		:OUT	std_logic;
	b1		:OUT	std_logic;
	b2		:OUT	std_logic;
	b3		:OUT	std_logic
	);
END BCD_zahler;

--------------------------------------------
--        ARCHITECTURE	                    --
--------------------------------------------
ARCHITECTURE behave OF BCD_zahler IS

TYPE state IS (st_0,st_1,st_2,st_3,st_4,st_5,st_6,st_7,st_8,st_9);
SIGNAL mode, nxt_mode : state;   --signal für die state machine--
SIGNAL clk_counter: INTEGER := 0; --counter für auf 0.5hz zählen--

BEGIN

-- Registered Process --
clk_proc : PROCESS (clk,reset,clk_counter)
	BEGIN
		IF (reset='1') THEN -- Active High Reset --
			mode <= st_0;
		ELSIF (clk'EVENT AND clk='1' AND clk'LAST_VALUE='0') THEN
			clk_counter <= clk_counter + 1; --Wir müssen bis auf 100 000 000 zählen (um 0.5HZ zu haben)
			IF (clk_counter > 100000000) THEN --1 bis 100000000--
				mode <= nxt_mode;	--mode changer--
				clk_counter <= 1;
			END IF;
		END IF;
	END PROCESS clk_proc;

-- Combinational Process --	
counter_proc : PROCESS (mode,nxt_mode,CM)
	BEGIN 
	CASE mode IS		--state machine für jeden zahl der BCD zahler--
	
	    	WHEN st_0 =>
			
	      	IF CM='1' THEN
				
	         	nxt_mode <= st_1;
					
	      	ELSIF CM='0' THEN 
				
	         	nxt_mode <= st_2;
					
	      	END IF;
				
			WHEN st_1 =>
				
				IF CM='1' THEN
				
	         	nxt_mode <= st_3;
					
	      	ELSIF CM='0' THEN 
				
	         	nxt_mode <= st_2;
					
	      	END IF;
				
			WHEN st_2 =>
				
				IF CM='1' THEN
				
	         	nxt_mode <= st_3;
					
	      	ELSIF CM='0' THEN 
				
	         	nxt_mode <= st_4;
					
				END IF;
				
			WHEN st_3 =>

				IF CM='1' THEN
				
	         	nxt_mode <= st_5;
					
	      	ELSIF CM='0' THEN 
				
	         	nxt_mode <= st_4;
					
				END IF;
			
			WHEN st_4 =>

				IF CM='1' THEN
				
	         	nxt_mode <= st_5;
					
	      	ELSIF CM='0' THEN 
				
	         	nxt_mode <= st_6;
					
				END IF;
				
			WHEN st_5 =>

				IF CM='1' THEN
				
	         	nxt_mode <= st_7;
					
	      	ELSIF CM='0' THEN 
				
	         	nxt_mode <= st_6;
					
				END IF;
			
			WHEN st_6 =>

				IF CM='1' THEN
				
	         	nxt_mode <= st_7;
					
	      	ELSIF CM='0' THEN 
				
	         	nxt_mode <= st_8;
					
				END IF;
			
			WHEN st_7 =>

				IF CM='1' THEN
				
	         	nxt_mode <= st_9;
					
	      	ELSIF CM='0' THEN 
				
	         	nxt_mode <= st_8;
					
				END IF;
				
			WHEN st_8 =>

				IF CM='1' THEN
				
	         	nxt_mode <= st_9;
					
	      	ELSIF CM='0' THEN 
				
	         	nxt_mode <= st_0;
					
				END IF;
				
			WHEN st_9 =>

				IF CM='1' THEN
				
	         	nxt_mode <= st_0;
					
	      	ELSIF CM='0' THEN 
				
	         	nxt_mode <= st_0;
					
				END IF;
					
	END CASE;
				
END PROCESS counter_proc;
	   
-- Output Process --
output_proc : PROCESS (mode,CM)
	BEGIN				--jeden zahl wird auf 4 bit kodiert--
	
		CASE mode IS
			when st_0 => b <= "0000";	--0--
			when st_1 => b <= "0001";	--1--
			when st_2 => b <= "0010";	--2--
			when st_3 => b <= "0011";	--3--
			when st_4 => b <= "0100";	--4--
			when st_5 => b <= "0101";	--5--
			when st_6 => b <= "0110";	--6--
			when st_7 => b <= "0111";	--7--
			when st_8 => b <= "1000";	--8--
			when st_9 => b <= "1001";	--9--
			when others => b <= "0000";	--default--
		END CASE;
			
		IF mode=st_0 THEN 
			b0<='0';
			b1<='0';
			b2<='0';
			b3<='0';	
		END IF;

		IF mode=st_1 THEN 
			b0<='1';
			b1<='0';
			b2<='0';
			b3<='0';
		END IF;

		IF mode=st_2 THEN 
			b0<='0';
			b1<='1';
			b2<='0';
			b3<='0';
		END IF;

		IF mode=st_3 THEN 
			b0<='1';
			b1<='1';
			b2<='0';
			b3<='0';	
		END IF;
		
		IF mode=st_4 THEN 
			b0<='0';
			b1<='0';
			b2<='1';
			b3<='0';
		END IF;
		
		IF mode=st_5 THEN 
			b0<='1';
			b1<='0';
			b2<='1';
			b3<='0';	
		END IF;
		
		IF mode=st_6 THEN 
			b0<='0';
			b1<='1';
			b2<='1';
			b3<='0';	
		END IF;
		
		IF mode=st_7 THEN 
			b0<='1';
			b1<='1';
			b2<='1';
			b3<='0';	
		END IF;
		
		IF mode=st_8 THEN 
			b0<='0';
			b1<='0';
			b2<='0';
			b3<='1';	
		END IF;
		
		IF mode=st_9 THEN 
			b0<='1';
			b1<='0';
			b2<='0';
			b3<='1';	
		END IF;
END PROCESS output_proc;


END ARCHITECTURE behave;