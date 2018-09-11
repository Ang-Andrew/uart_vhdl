----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.09.2018 13:54:25
-- Design Name: 
-- Module Name: uart_tx - Behavioral
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

entity uart_tx is
    generic(
        cycles_per_bit  : integer := 868
    );
    Port ( 
        clock               : in std_logic;
        reset               : in std_logic;
        i_data_in           : in std_logic_vector(7 downto 0);
        i_data_valid        : in std_logic;
        o_data_done         : out std_logic;
        o_serial_out        : out std_logic;
        o_busy              : out std_logic
    );
end uart_tx;

architecture Behavioral of uart_tx is
    
    type state is (s_idle, s_start, s_data, s_stop);
    signal current_state        : state := s_idle;
    
    signal s_cycle_counter      : integer range 0  to cycles_per_bit        := 0;
    signal s_bit_counter        : integer range 0 to 7                      := 0;
    
    signal s_data_in_reg        : std_logic_vector(7 downto 0);
    

begin
    
    -- main state machine process
    process(clock)
    begin
        if(rising_edge(clock)) then
            if(reset = '1') then
                s_cycle_counter <= 0;
                s_bit_counter <= 0;
                current_state <= s_idle;
                o_data_done <= '0';
            else
                case current_state is
                    when s_idle =>
                        if(i_data_valid = '1') then
                            current_state <= s_start;
                            s_cycle_counter <= s_cycle_counter + 1;
                            o_serial_out <= '0';
                            o_busy <= '1';
                            o_data_done <= '0';
                            s_data_in_reg <= i_data_in;
                        end if;
                    
                    when s_start =>
                        if(s_cycle_counter = cycles_per_bit - 1) then
                            s_cycle_counter <= 0;
                            current_state <= s_data;
                        else
                            s_cycle_counter <= s_cycle_counter + 1;
                        end if;
                    
                    when s_data =>
                        o_serial_out <= i_data_in(s_bit_counter);
                        
                        if(s_cycle_counter = cycles_per_bit - 1) then
                            s_cycle_counter <= 0;
                            if(s_bit_counter = 7) then
                                current_state <= s_stop;
                            else
                                s_bit_counter <= s_bit_counter + 1;
                            end if;
                        else
                            s_cycle_counter <= s_cycle_counter + 1;
                        end if;
                    
                    when s_stop =>
                        o_serial_out <= '1';
                        o_data_done <= '1';
                        o_busy <= '0';
                end case;
            end if;
        end if;
    end process;


end Behavioral;
