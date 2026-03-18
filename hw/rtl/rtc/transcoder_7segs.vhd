LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY transcoder_7segs IS
	PORT( A : IN std_logic_vector(3 DOWNTO 0);
			O : OUT std_logic_vector(6 DOWNTO 0)
			);
END  transcoder_7segs;

ARCHITECTURE behavioural OF transcoder_7segs IS
BEGIN
	WITH A SELECT
		O <= "1000000" WHEN "0000", -- 0
		"1111001" WHEN "0001", -- 1
		"0100100" WHEN "0010", -- 2
		"0110000" WHEN "0011", -- 3
		"0011001" WHEN "0100", -- 4
		"0010010" WHEN "0101", -- 5
		"0000010" WHEN "0110", -- 6
		"1111000" WHEN "0111", -- 7
		"0000000" WHEN "1000", -- 8
		"0010000" WHEN "1001", -- 9
		"1111111" WHEN OTHERS;
END behavioural;