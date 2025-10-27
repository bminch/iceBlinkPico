    lui x1, 0xFEDCC         # pc = 0x00, x1 = 0xFEDCC000
    addi x1, x1, 0xA98      # pc = 0x04, x1 = 0xFEDCBA98
    srli x2, x1, 4          # pc = 0x08, x2 = 0x0FEDCBA9
    srai x3, x1, 4          # pc = 0x0C, x3 = 0xFFEDCBA9
    xori x4, x3, -1         # pc = 0x10, x4 = 0x00123456
    addi x5, x0, 2          # pc = 0x14, x5 = 0x00000002
    add x6, x5, x4          # pc = 0x18, x6 = 0x00123458
    sub x7, x6, x4          # pc = 0x1C, x7 = 0x00000002
    sll x8, x4, x5          # pc = 0x20, x8 = 0x0048D158
    ori x9, x8, 7           # pc = 0x24, x9 = 0x0048D15F
    auipc x10, 0x12345      # pc = 0x28, x10 = 0x12345028
    slt x11, x3, x4         # pc = 0x2C, x11 = 0x00000001
    sltu x12, x3, x4        # pc = 0x30, x12 = 0x00000000
    jal x13, 0x28           # pc = 0x34, x13 = 0x00000038
    addi x15, x0, 10        # pc = 0x38, x15 = 0x0000000A
    beq x15, x0, 12         # pc = 0x3C
    addi x15, x15, -1       # pc = 0x40
    jal x16, -8             # pc = 0x44, x16 = 0x00000048
    bltu x3, x4, 8          # pc = 0x48
    blt x3, x4, 20          # pc = 0x4C
                            # pc = 0x50
                            # pc = 0x54
                            # pc = 0x58
    jalr x14, 0(x13)        # pc = 0x5C, x14 = 0x00000060
    addi x17, x0, 0xC0      # pc = 0x60, x17 = 0x000000C0
    sb x17, -4(x0)          # pc = 0x64
    sb x17, -3(x0)          # pc = 0x68
    sb x17, -2(x0)          # pc = 0x6C
    sb x17, -1(x0)          # pc = 0x70
    lw x18, -4(x0)          # pc = 0x70, x18 = 0xC0C0C0C0
    lw x19, -12(x0)         # pc = 0x74, x19 = micros
    lh x20, -4(x0)          # pc = 0x78, x20 = 0xFFFFC0C0
    lhu x21, -4(x0)         # pc = 0x7C, x21 = 0x0000C0C0
    lb x22, -4(x0)          # pc = 0x80, x22 = 0xFFFFFFC0
    lbu x23, -4(x0)         # pc = 0x84, x23 = 0x000000C0









