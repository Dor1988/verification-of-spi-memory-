# verification of spi memory

## Description
This repository contains a UVM verification environment designed to verify a Serial Peripheral Interface (SPI) communication protocol. The project consists of a Dut-device under test and various testbench components.

## Key Features

### 1.spi_mem module:
  + This is the device under test.
  + Models the behavior of the SPI slave device.
  + Receives data from the Driver and responds accordingly.
  + Implements a state machine.
    
### 2.Testbench Components::
  + Transaction Class: Defines the transaction format for SPI communication.
  + sequence Class: Generates transactions and send them to the sequencer.
  + sequencer class: 
  + Driver Class: Drives transactions to the DUT.
  + Monitor Class: Monitors the DUT's output and captures the response for verification.
  + Scoreboard Class: Compares the expected and actual outputs for verification.
  + Environment Class: Orchestrates the testbench components and provides the virtual interface (spi_if) to the DUT.
  + 
### 3.Testbench Top (tb):
  +Instantiates the DUT and the verification environment.
  +Drives the clock (clk) to the DUT.
  +Sets up the simulation environment and runs the verification tests.
