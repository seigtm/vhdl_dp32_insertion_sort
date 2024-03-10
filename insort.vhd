LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

PACKAGE array_type IS
    -- 10 elements.
    TYPE array_t IS ARRAY(9 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

END PACKAGE;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

USE work.array_type.ALL;

ENTITY insort IS
    PORT (
        SIGNAL clk : IN STD_LOGIC;
        SIGNAL reset : IN STD_LOGIC;
        SIGNAL in_array : IN array_t;
        SIGNAL sorted_array : OUT array_t
    );

END insort;

ARCHITECTURE beh OF insort IS

    USE ieee.numeric_std.ALL;

BEGIN

    PROCESS (clk, reset)
        VARIABLE temp : STD_LOGIC_VECTOR (7 DOWNTO 0);
        VARIABLE var_array : array_t;
    BEGIN
        IF reset = '1' THEN
            var_array := in_array;
        ELSIF rising_edge(clk) THEN
            FOR j IN 0 TO 9 - 1 LOOP
                FOR i IN 0 TO 9 - 1 - j LOOP
                    IF unsigned(var_array(i)) > unsigned(var_array(i + 1)) THEN
                        temp := var_array(i);
                        var_array(i) := var_array(i + 1);
                        var_array(i + 1) := temp;
                    END IF;
                END LOOP;
            END LOOP;
            sorted_array <= var_array;
        END IF;
    END PROCESS;
END beh;