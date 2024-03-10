# Insertion Sort Implementation on DP32 in VHDL

This repository contains VHDL source code implementing the insertion sort algorithm on a DP32.

## Implementation Details

- `insort.vhd`: Implements the insertion sort algorithm using a process triggered by clock signal
  `clk` and reset signal `reset`. The input array `in_array` is sorted and output as `sorted_array`.
- `memory.vhd`: Represents the memory structure for the DP32, including read and write operations.
  Contains an array initialized with unsorted data and the insertion sort program.

## DP32 Program Flow

- The program starts at `PROGRAM_START` and executes the insertion sort algorithm.
- It initializes registers and sets up the initial conditions for sorting.
- The outer loop (`OUTER_LOOP_START`) iterates over the array elements.
- Within each iteration, the inner loop (`INNER_LOOP_START`) compares adjacent elements and swaps
  them if necessary.
- After sorting, the program loops back to `PROGRAM_START` to ensure continuous sorting.

### Preudocode

```vhdl
PROGRAM_START:
    Set r0 to 0
    Set len to 9
    Set i to 1
    Set j to 1
    Set tmp to 0
    Set array_start_index to the memory address of array
    Set left_element to 0
    Set right_element to 0

    OUTER_LOOP_START:
        -- Start of the outer loop: for (int i{ 1 }; i < n; ++i):
        Set tmp to len - i
        If tmp equals 0, jump to PROGRAM_END


        -- Start of the inner loop: for (int j{ i }; j > 0 && x[j - 1] > x[j]; --j):
        Set j to i
        INNER_LOOP_START:
                -- j > 0 check:
            Set tmp to j
            Set tmp to tmp - 1
            If tmp is negative, jump to INNER_LOOP_END

                -- x[j - 1] > x[j] check:
            -- 1. Extract right and left elements.
            Set tmp to array_start_index + j
            Set right_element to tmp
            Set tmp to tmp - 1
            Set left_element to tmp

            -- 2. Compare them.
            If left_element <= right_element, jump to INNER_LOOP_END

            -- 3. Swap left and right array elements.
            Set tmp to array_start_index + j
            Load value of left_element to MEMORY[tmp]
            Set tmp to tmp - 1
            Load value of right_element to MEMORY[tmp]

            Set tmp to left
            Set left to right
            Set right to tmp

            -- 4. Decrement the 'j' index.
            Set j to j - 1
            If true, jump to INNER_LOOP_START


        INNER_LOOP_END:
            Set i to i + 1
            If true, jump to OUTER_LOOP_START



        PROGRAM_END:
            If true, jump to PROGRAM_START


            [array is here]
```

### Used raw commands

```vhdl
X"0700_0000",  -- r0 <- r0 & !r0
X"1001_0009",  -- r1 <- r0 + 9
X"1002_0001",  -- r2 <- r0 + 1
X"1003_0200",  -- r3 <- r2 + 0
X"1004_0000",  -- r4 <- r0 + 0
X"1005_001F",  -- r5 <- r0 + 31
X"1006_0000",  -- r6 <- r0 + 0
X"1007_0000",  -- r7 <- r0 + 0
X"0104_0102",  -- r4 <- r1 - r2
X"5009_0013",  -- if (1 = V & 0 | N & 0 | Z & 1) then PC <- PC + 19
X"1003_0200",  -- r3 <- r2 + 0
X"1004_0300",  -- r4 <- r3 + 0
X"1104_0401",  -- r4 <- r4 - 1
X"500A_000D",  -- if (1 = V & 0 | N & 1 | Z & 0) then PC <- PC + 13
X"0004_0503",  -- r4 <- r5 + r3
X"3007_0400",  -- r7 <- M[r4 + 0]
X"1104_0401",  -- r4 <- r4 - 1
X"3006_0400",  -- r6 <- M[r4 + 0]
X"1004_0600",  -- r4 <- r6 + 0
X"0104_0407",  -- r4 <- r4 - r7
X"500B_0006",  -- if (1 = V & 0 | N & 1 | Z & 1) then PC <- PC + 6
X"0004_0503",  -- r4 <- r5 + r3
X"3106_0400",  -- M[r4 + 0] <- r6
X"1104_0401",  -- r4 <- r4 - 1
X"3107_0400",  -- M[r4 + 0] <- r7
X"1103_0301",  -- r3 <- r3 - 1
X"5000_00F0",  -- if (0 = V & 0 | N & 0 | Z & 0) then PC <- PC + (-16)
X"1002_0201",  -- r2 <- r2 + 1
X"5000_00EB",  -- if (0 = V & 0 | N & 0 | Z & 0) then PC <- PC + (-21)
X"5000_00E3",  -- if (0 = V & 0 | N & 0 | Z & 0) then PC <- PC + (-29)

X"0000_0005",  -- arr[0] = 5
X"0000_0003",  -- arr[1] = 3
X"0000_0004",  -- arr[2] = 4
X"0000_0008",  -- arr[3] = 8
X"0000_0007",  -- arr[4] = 7
X"0000_0009",  -- arr[5] = 9
X"0000_0005",  -- arr[6] = 5
X"0000_0001",  -- arr[7] = 1
X"0000_0004",  -- arr[8] = 4
```

## Additional Information

- **Course**: Peter the Great St. Petersburg Polytechnic University (SPbPU), Software and hardware
  design packages.

- **Teachers**: Petrov A.V., Amosov V.V.
