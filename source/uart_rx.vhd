----------------------------------------------------------------------------------
-- Engineer: Andrew Ang
-- Create Date: 09.09.2018 13:52:36
-- Module Name: uart_rx - Behavioral
-- Project Name: 
-- Target Devices: Pynq-Z1 
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

entity uart_rx is
    generic(
        cycles_per_bit  : integer := 868
    );
    Port (
        clock           : in std_logic;
        i_serial_in     : in std_logic;
        o_data_in       : out std_logic_vector(7 downto 0);
        o_data_valid    : out std_logic    
    );
end uart_rx;

architecture Behavioral of uart_rx is

    type state is (s_idle, s_start, s_data, s_stop);
    signal current_state            : state := s_idle;
    
    signal s_serial_in_reg          : std_logic;    -- asynchronous input, added synchroniser to remove potential metastability
    signal s_serial_in              : std_logic;    -- output from synchroniser
    
    signal s_cycle_counter          : integer range 0 to 867                := 0; -- for 100 MHz clock, there are 868 cycles/bit at 115200 baud
    signal s_bit_counter            : integer range 0 to 7                  := 0; -- sending 8 bits per uart packet    
    
    signal s_data_reg               : std_logic_vector(7 downto 0);

begin
    
    
    -- synchroniser circuit to remove metastability from asynchronous serial input
    process(clock)
    begin
        if(rising_edge(clock)) then
            s_serial_in_reg     <= i_serial_in;
            s_serial_in         <= s_serial_in_reg;
        end if;
    end process;
    
    -- main state machine
    process(clock)
    begin
        if(rising_edge(clock)) then
            case current_state is
                when s_idle     =>
                    if(s_serial_in_reg = '0') then -- start condition
                        current_state <= s_start;
                        s_cycle_counter <= s_cycle_counter + 1;
                        o_data_valid    <= '0';
                    end if;
                
                when s_start    =>
                    if(s_serial_in_reg = '0') then -- start condition
                        s_cycle_counter <= s_cycle_counter + 1;
                        if(s_cycle_counter = cycles_per_bit-1) then
                            s_cycle_counter <= 0;
                            current_state <= s_data;
                        end if;
                    else -- start condition terminated prematurley, go back to idle state 
                        current_state <= s_idle;
                        s_cycle_counter <= 0;
                    end if;
                
                when s_data     => --sample data at the middle of each bit
                    if s_cycle_counter = (cycles_per_bit-1)/2 then
                        s_data_reg(s_bit_counter)   <= s_serial_in;
                        s_cycle_counter             <= s_cycle_counter + 1;
                        s_bit_counter               <= s_bit_counter + 1;
                        if(s_bit_counter = 7) then
                            current_state           <= s_stop;
                            s_cycle_counter         <= 0; 
                        else
                            s_bit_counter           <= s_bit_counter + 1;
                        end if;
                    elsif s_cycle_counter = cycles_per_bit-1 then
                        s_cycle_counter <= 0;
                    else
                        s_cycle_counter             <= s_cycle_counter + 1;
                    end if;
                
                when s_stop     => -- on stop bit, take data out
                    if s_cycle_counter = cycles_per_bit-1 then
                        o_data_in       <= s_data_reg;
                        o_data_valid    <= '1';
                        s_cycle_counter <= 0;
                        current_state   <= s_idle;
                    else
                        s_cycle_counter <= s_cycle_counter + 1;
                    end if;
            end case;
        end if;
    end process;
    
    


end Behavioral;
