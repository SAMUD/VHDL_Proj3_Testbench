------------------------------------------------------
--  Module for Timer by Samuel Daurat [178190]      --

-- This module decodes an Int to show it on 4 7Seg-Displays like the follow:
-- Minutes | Sec Sec | Deci-Sec
-- The module needs Version 1.3RS of Decoder.vhd


-- Changelog:
-- Version 1.0RS | 4.12.17
--  *initial release
------------------------------------------------------

-- Library Declaration --
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;


------------------------------------------------------
--	   ENTITY	                           			 --
------------------------------------------------------
ENTITY ConvertIntBcd IS
PORT(
		
	
	InputInt		:	IN		integer range 0 to 6000 ;			--Input signal containing the actual time information in Deci-Sec
													
	SevenSeg1	:	OUT	std_logic_vector (6 downto 0) :=  (others => '0');	-- decoded signals to send to the 7seg
	SevenSeg2	:	OUT	std_logic_vector (6 downto 0) :=  (others => '0');	
	SevenSeg3	:	OUT	std_logic_vector (6 downto 0) :=  (others => '0');	
	SevenSeg4	:	OUT	std_logic_vector (6 downto 0) :=  (others => '0')
	
	);
END ConvertIntBcd;

------------------------------------------------------
--        ARCHITECTURE	                            --
------------------------------------------------------
ARCHITECTURE behave OF ConvertIntBcd IS
																				--signals between Counter and Decoder. Contains the actual counting value
																				--MSB 3 2 1 0 LSB
	SIGNAL Minutes	:	std_logic_vector (3 downto 0);	--Minutes
	SIGNAL SecTen	:	std_logic_vector (3 downto 0);	--Seconds*10
	SIGNAL Sec		:	std_logic_vector (3 downto 0); 	--Seconds
	SIGNAL SecDeci	:	std_logic_vector (3 downto 0); 	--DeciSeconds
	
	--call Decoder.vhd
	component Decoder
	  port(
		Input			:		IN		std_logic_vector (3 downto 0);	-- Input to Decode for 7seg
		Output		:		OUT	std_logic_vector (6 downto 0)		-- decoded signals to send to the 7seg
	);
	end component;

------------------------------------------------------
BEGIN


-- sorting and extracting the times from the big int
	sort_proc : PROCESS (InputInt)
	BEGIN
	
		SecDeci <= std_logic_vector( to_unsigned( InputInt mod 10, 				SecDeci'length) 	);
		Sec 	  <= std_logic_vector( to_unsigned( (InputInt mod 100)/10, 		SecDeci'length)   );
		SecTen  <= std_logic_vector( to_unsigned( (InputInt mod 600)/100, 	SecDeci'length)   );
		Minutes <= std_logic_vector( to_unsigned( ((InputInt/10)-((InputInt/10) mod 60))/60, 	SecDeci'length)   );
		--Information: Those modulos and Divisions are perhaps not the best thing todo on an FPGA. But for now
		--we have still plenty of free memory/logic and it's much easier to understand the code like this than having
		--a big bunch of IF statements (first version had this.)

		
	END PROCESS sort_proc;
	
--And now write the variables to the seven segment	
	Decoder_Min: component Decoder
		port map(
			Input => Minutes,
			Output => SevenSeg1
		);	
	Decoder_SecTen: component Decoder
		port map(
			Input  => SecTen,
			Output => SevenSeg2
		);	
	Decoder_Sec: component Decoder
		port map(
			Input  => Sec,
			Output => SevenSeg3
		);
	Decoder_SecDeci: component Decoder
		port map(
			Input  => SecDeci,
			Output => SevenSeg4
		);
	
END behave;
