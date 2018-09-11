----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.09.2018 14:42:31
-- Design Name: 
-- Module Name: uart_rx_tb - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_rx_tb is
end uart_rx_tb;

architecture Behavioral of uart_rx_tb is
    
    component uart_rx is
    port(
        clock           : in std_logic;
        i_serial_in     : in std_logic;
        o_data_in       : out std_logic_vector(7 downto 0);
        o_data_valid    : out std_logic  
    );
    end component uart_rx;
    
    signal tb_clock            : std_logic;
    signal tb_serial_in        : std_logic;
    signal tb_data_in          : std_logic_vector(7 downto 0);
    signal tb_data_valid       : std_logic;
    
    constant clk_period : time := 10ns;

begin
    
    uut: uart_rx port map(
        clock           => tb_clock,
        i_serial_in     => tb_serial_in,
        o_data_in       => tb_data_in,
        o_data_valid    => tb_data_valid    
    );
    
    clk_process :process
    begin
         tb_clock <= '1';
         wait for clk_period/2;
         tb_clock <= '0';
         wait for clk_period/2;
    end process;
    
    stim_proc: process
    begin
        wait for clk_period*2;
        tb_serial_in <= '0'; -- start bit;
        
        wait for clk_period*868;
        tb_serial_in <= '1';
        
        wait for clk_period*868;
        tb_serial_in <= '1';
        
        wait for clk_period*868;
        tb_serial_in <= '1';
        
        wait for clk_period*868;
        tb_serial_in <= '1';
        
        wait for clk_period*868;
        tb_serial_in <= '0';
        
        wait for clk_period*868;
        tb_serial_in <= '1';

        wait for clk_period*868;
        tb_serial_in <= '0';

        wait for clk_period*868;
        tb_serial_in <= '1';
        
        wait for clk_period*868; -- stop bit
        tb_serial_in <= '1';
        
        wait;
                
        
    end process;


end Behavioral;
