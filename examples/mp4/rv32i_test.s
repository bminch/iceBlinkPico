# -------- MUL --------
addi x1, x0, 10
addi x2, x0, -3
mul  x10, x1, x2        # x10 = -30

# -------- MULH (signed × signed high bits) --------
lui  x3, 0x00010        # x3 = 0x00010000
addi x4, x0, -2         # x4 = -2
mulh x11, x3, x4        # x11 = 0xFFFFFFFF

# -------- MULHSU (signed × unsigned) --------
addi x5, x0, -2         # x5 = -2
lui  x6, 0x00010        # x6 = 65536
mulhsu x12, x5, x6      # x12 = 0xFFFFFFFF

# -------- MULHU (unsigned × unsigned) --------
lui  x7, 0x00010        # x7 = 65536
lui  x8, 0x00020        # x8 = 131072
mulhu x13, x7, x8       # x13 = 0x00000020

# -------- DIV --------
addi x9,  x0, 10
addi x14, x0, -3
div  x14, x9, x14       # x14 = -3

# -------- DIVU --------
addi x15, x0, -1        # x15 = 0xFFFFFFFF
addi x16, x0, 2
divu x15, x15, x16      # x15 = 0x7FFFFFFF

# -------- REM (signed remainder) --------
rem  x17, x9, x14      # x17 = 1  

# -------- REMU (unsigned remainder) --------
addi x18, x0, 3
remu x19, x9, x18      # x19 = 1
