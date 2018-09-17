# Simple tests for an adder module
import cocotb
from cocotb.triggers import Timer
from cocotb.result import TestFailure
from adder_model import adder_model
import random

@cocotb.test()
def uart_tx_test(dut):
    dut._log.info("Running UART TX test!")
    for cycle in range(10):
        dut.clock = 0
        yield Timer(1000)
        dut.clock = 1
        yield Timer(1000)
    dut._log.info("Running test!")
    

