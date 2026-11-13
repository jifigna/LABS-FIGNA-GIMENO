----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.10.2026 13:38:01
-- Design Name: 
-- Module Name: mux - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : Fri, 02 Oct 2026 11:38:28 GMT
-- Request id : cfwk-fed377c2-6abf97b4cc6fe

library ieee;
use ieee.std_logic_1164.all;

entity tb_mux is
end tb_mux;

architecture tb of tb_mux is

    component mux
        port (ch1_in : in std_logic_vector (5 downto 0);
              ch2_in : in std_logic_vector (5 downto 0);
              ch3_in : in std_logic_vector (5 downto 0);
              sel_in : in std_logic_vector (1 downto 0);
              ch_out : out std_logic_vector (5 downto 0));
    end component;

    signal ch1_in : std_logic_vector (5 downto 0);
    signal ch2_in : std_logic_vector (5 downto 0);
    signal ch3_in : std_logic_vector (5 downto 0);
    signal sel_in : std_logic_vector (1 downto 0);
    signal ch_out : std_logic_vector (5 downto 0);

begin

    dut : mux
    port map (ch1_in => ch1_in,
              ch2_in => ch2_in,
              ch3_in => ch3_in,
              sel_in => sel_in,
              ch_out => ch_out);

    stimuli : process
    begin
        -- ***EDIT*** Adapt initialization as needed
        ch1_in <= (others => '0');
        ch2_in <= (others => '0');
        ch3_in <= (others => '0');
        sel_in <= (others => '0');

        -- ***EDIT*** Add stimuli here

        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_mux of tb_mux is
    for tb
    end for;
end cfg_tb_mux;