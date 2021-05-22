-- street_de2.vhd
--
-- generate an VGA-image of a street scene
-- top level for DE2-35 board
--
-- FPGA Vision Remote Lab http://h-brs.de/fpga-vision-lab
-- (c) Marco Winzker, Hochschule Bonn-Rhein-Sieg, 02.05.2019
--
-- Edited by Gabriel F. Escobar, 22.05.2021
-- Adapted DE10-lite code to work on a DE2-35 board

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity street_de2 is
  port (
        CLOCK_50       : in  std_logic;                     -- input clock 50 MHz   
        KEY            : in  std_logic_vector(3 downto 0);  -- push button for reset
        VGA_VS         : out std_logic;                     -- video out (4 bit resolution)
        VGA_HS         : out std_logic;
        VGA_SYNC       : out std_logic := '0';                     
        VGA_BLANK      : out std_logic;
        VGA_CLK        : out std_logic;
        VGA_R          : out std_logic_vector(9 downto 2) := (others => '0');
        VGA_G          : out std_logic_vector(9 downto 2) := (others => '0');
        VGA_B          : out std_logic_vector(9 downto 2) := (others => '0')
  );
end street_de2;

architecture rtl of street_de2 is

  signal CLOCK_25   : std_logic;
  signal RESET      : std_logic_vector(5 downto 0);
  signal R, G, B    : std_logic_vector(7 downto 0);
  
  begin

  VGA_CLK <= CLOCK_25;
  RESET(0) <= NOT KEY(0);
  
  process
  begin
    wait until rising_edge(CLOCK_50);
    if (RESET(0) = '1') then
      CLOCK_25 <= '0';
      RESET(5 downto 1) <= (others => '1');
    else
      CLOCK_25 <= not CLOCK_25;
      RESET(5 downto 1) <= RESET(4 downto 1) & '0';
    end if;
  end process;
  
  -- generic submodule
  street: entity work.street_image
      port map (
                CLK_VGA   => CLOCK_25,
                RESET     => RESET(5),
                VS_OUT    => VGA_VS,
                HS_OUT    => VGA_HS,
                DE_OUT    => VGA_BLANK,
                R_OUT     => R,
                G_OUT     => G,
                B_OUT     => B
      );
  
  VGA_R(9 downto 2) <= R(7 downto 0);
  VGA_G(9 downto 2) <= G(7 downto 0);
  VGA_B(9 downto 2) <= B(7 downto 0);
  
  end architecture;
