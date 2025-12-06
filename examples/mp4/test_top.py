import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def my_first_test(dut):
    """Try accessing the design."""

    for _ in range(10):
        dut.clk.value = 0
        await Timer(1, unit="ns")
        dut.clk.value = 1
        await Timer(1, unit="ns")

    cocotb.log.info("dmem_wren is %s", dut.dmem_wren.value)
    assert dut.dmem_wren.value == 1

