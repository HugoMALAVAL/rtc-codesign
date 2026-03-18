----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    
-- Design Name: 
-- Module Name:     mux_16x1x4bit - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_16x1x4bit is
    Port (
        sel : in STD_LOGIC_VECTOR(3 downto 0);
        AD0 : in STD_LOGIC_VECTOR(3 downto 0);
        AD1 : in STD_LOGIC_VECTOR(3 downto 0);
        AD2 : in STD_LOGIC_VECTOR(3 downto 0);
        AD3 : in STD_LOGIC_VECTOR(3 downto 0);
        BD0 : in STD_LOGIC_VECTOR(3 downto 0);
        BD1 : in STD_LOGIC_VECTOR(3 downto 0);
        BD2 : in STD_LOGIC_VECTOR(3 downto 0);
        BD3 : in STD_LOGIC_VECTOR(3 downto 0);
        RD0 : in STD_LOGIC_VECTOR(3 downto 0);
        RD1 : in STD_LOGIC_VECTOR(3 downto 0);
        RD2 : in STD_LOGIC_VECTOR(3 downto 0);
        RD3 : in STD_LOGIC_VECTOR(3 downto 0);
        Y   : out STD_LOGIC_VECTOR(3 downto 0)
    );
end mux_16x1x4bit;

architecture Behavioral of mux_16x1x4bit is
begin
    with sel select
        Y <= AD0 when "0000",
             AD1 when "0001",
             AD2 when "0010",
             AD3 when "0011",
             BD0 when "0100",
             BD1 when "0101",
             BD2 when "0110",
             BD3 when "0111",
             RD0 when "1000",
             RD1 when "1001",
             RD2 when "1010",
             RD3 when "1011",
             (others => '0') when others;
end Behavioral;