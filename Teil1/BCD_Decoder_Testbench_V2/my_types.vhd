package my_types is

	type Stimulatesignal_expected is record
	  type DataInput_Array is array (9 downto 0,3 downto 0) of std_logic;
	  DataInput : DataInput_Array := ("0000", "0001", "0010","0011", "0100", "0101","0110", "0111", "1000","1001");
	  
	  type DataOutput_Array is array (9 downto 0,6 downto 0) of std_logic;
	  DataInput : DataInput_Array := ("0000001", "1001111", "0010010","0000110", "1001100", "0100100","1100000", "0001111", "0000000","0001100");
	end record;

end package;