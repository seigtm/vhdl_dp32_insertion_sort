USE work.dp32_types.ALL, work.alu_32_types.ALL;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY memory IS
    GENERIC (Tpd : TIME := unit_delay);
    PORT (
        d_bus : INOUT bus_bit_32 BUS;
        a_bus : IN bit_32;
        read : IN STD_LOGIC;
        write : IN STD_LOGIC;
        ready : OUT STD_LOGIC);
END memory;

ARCHITECTURE behaviour OF memory IS
BEGIN
    PROCESS
        CONSTANT low_address : INTEGER := 0;
        CONSTANT high_address : INTEGER := 65535;
        TYPE memory_array IS
        ARRAY(INTEGER RANGE low_address TO high_address)OF bit_32;
        VARIABLE address : INTEGER := 0;
        VARIABLE mem : memory_array :=
        (
        -- Insertion Sort algorithm on DP32 commands.
        -- C++ reference:
        -- const auto n{ 9 };
        --
        -- for (int i{ 1 }; i < n; ++i)
        --   for (int j{ i }; j > 0 && x[j - 1] > x[j]; --j)
        --     std::swap(x[j - 1], x[j]);

        -- Initializing register with some values.
        --   r0 is always = 0.
        1 => X"0700_0000", -- r0 <- r0 & !r0 = 0.
        --   r1 is array length = 9.
        2 => X"1001_0009", -- add quick: r1 <- r0+9 = 9.
        --   r2 is 'i' index.
        3 => X"1002_0001", -- add quick: r2 <- r0+1 = 1.
        --   r3 is 'j' index.
        4 => X"1003_0200", -- add quick: r3 <- r2+0 = 1.
        --   r4 is temporary variable for swaps and conditions in if statements.
        5 => X"1004_0000", -- add quick: r4 <- r0+0 = 0.
        --   r5 points to the memory location where the array is.
        6 => X"1005_001F", -- add quick: r5 <- r0+31 = 0+31 = 31.
        --   r6 is temporary variable to store x[j-1] array element, e.g. 'left'.
        7 => X"1006_0000",
        --   r7 is temporary variable to store x[j] array element, e.g. 'right'.
        8 => X"1007_0000",

        -- Start of Intertion Sort.

        -- Start of the outer loop: for (int i{ 1 }; i < n; ++i):
        -- OUTER_LOOP_START:
            -- if (i >= n) jump to PROGRAM_END.
            9 => X"0104_0102", -- r4(tmp) = r1(len) - r2(i).
            10 => X"5009_0013", -- if (r4(tmp) == 0) (1=V&0|N&0|Z&1) then PC<-PC+(19) - jump to PROGRAM_END.

            -- Start of the inner loop: for (int j{ i }; j > 0 && x[j - 1] > x[j]; --j):
            11 => X"1003_0200", -- r3(j) = r2(i).
            -- INNER_LOOP_START:
                -- if (j <= 0) jump to the start of the outer loop.
                12 => X"1004_0300", -- r4(tmp) = r3(j).
                13 => X"1104_0401", -- r4(tmp) = r4(tmp) - 1.
                14 => X"500A_000D", -- if (r4(tmp) < 0) (j-1 < 0) (1=V&0|N&1|Z&0) then PC<-PC+(13), e.g. jump to INNER_LOOP_END.

                -- Extract left and right elements (array[j-1] and array[j]):
                15 => X"0004_0503", -- r4(tmp)    = r5(array_start_index) + r3(j).
                16 => X"3007_0400", -- r7(right) <- r4(tmp) which holds the right array element.
                17 => X"1104_0401", -- r4(tmp)    = r4(tmp) - 1
                18 => X"3006_0400", -- r6(left)  <- r4(tmp) which holds the left array element.

                -- If array[j-1] <= array[j] jmp to the end of the inner loop:
                --   in other words: if(left - right <= 0):
                19 => X"1004_0600", -- r4(tmp) = r6(left).
                20 => X"0104_0407", -- r4(tmp) = r4(tmp) - r7(right).
                21 => X"500B_0006", -- if (r4(tmp) <= 0) (1=V&0|N&1|Z&1) then PC<-PC+(6) (jump to the INNER_LOOP_END).

                -- Swap left and right array elements.
                22 => X"0004_0503", -- r4(tmp) = r5(array_start_index) + r3(j) (right element index)
                23 => X"3106_0400", -- replace in memory right element with r6(left).
                24 => X"1104_0401", -- r4(tmp) = r4(tmp) - 1.
                25 => X"3107_0400", -- replace in memory left element with r7(right).

                -- Decrement the 'j' index.
                26 => X"1103_0301", -- r3(j) <- r3(j) - 1.
                -- Continue with the inner loop.
                27 => X"5000_00F0", -- if (r0 == 0) (always true) then PC<-PC+(-16), e.g. jump to INNER_LOOP_START.
                -- End of the inner loop: for (int j{ i }; j > 0 && x[j - 1] > x[j]; --j).

                -- INNER_LOOP_END:
                    -- Increment i and jump to the beggining of the outer loop.
                    28 => X"1002_0201", -- r2(i) = r2(i) + 1.
                    29 => X"5000_00EB", -- if (r0 == 0) (always true) then PC<-PC+(-21), e.g. jump to OUTER_LOOP_START.
                    -- End of the outer loop: for (int i{ 1 }; i < n; ++i).
        
                    -- PROGRAM_END:
                    -- Endless cycle that would return us to the start of sorting algorithm to prevent data loss.
                    30 => X"5000_00E3", -- if (r0 == 0) (always true) then PC<-PC+(-29), e.g. jump to PROGRAM_START.
        -- End of Insertion Sort.


        -- Begin of array with length = 9.
        -- Before sort: [ 5, 3, 4, 8, 7, 9, 5, 1, 4 ].
        31 => X"0000_0005", -- array[0] = 5.
        32 => X"0000_0003", -- array[1] = 3.
        33 => X"0000_0004", -- array[2] = 4.
        34 => X"0000_0008", -- array[3] = 8.
        35 => X"0000_0007", -- array[4] = 7.
        36 => X"0000_0009", -- array[5] = 9.
        37 => X"0000_0005", -- array[6] = 5.
        38 => X"0000_0001", -- array[7] = 1.
        39 => X"0000_0004", -- array[8] = 4.
        -- After sort:  [ 1, 3, 4, 4, 5, 5, 7, 8, 9 ].
        -- End of array.

        OTHERS => X"0000_0000");
    BEGIN
        --
        -- put d_bus and reply into initial state
        --
        d_bus <= NULL AFTER Tpd;
        ready <= '0' AFTER Tpd;
        --
        -- wait for a command
        --
        WAIT UNTIL (read = '1') OR (write = '1');
        --
        -- dispatch read or write cycle
        --
        address := bits_to_int(a_bus);
        IF address >= low_address AND address <= high_address THEN
            -- address match for this memory
            IF write = '1' THEN
                ready <= '1' AFTER Tpd;
                WAIT UNTIL write = '0'; -- wait until end of write cycle
                mem(address) := d_bus;--'delayed(Tpd); -- sample data from Tpd ago
            ELSE -- read='1'
                d_bus <= mem(address) AFTER Tpd; -- fetch data
                ready <= '1' AFTER Tpd;
                WAIT UNTIL read = '0'; -- hold for read cycle
            END IF;
        END IF;
    END PROCESS;
END behaviour;