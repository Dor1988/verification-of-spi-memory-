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
  + sequencer class: send the transactions to the driver for execution.
  + Driver Class: Drives transactions to the DUT.
  + Monitor Class: Monitors the DUT's output and captures the response for verification.
  + Scoreboard Class: Compares the expected and actual outputs for verification.
  + Environment Class: contain the testbench components.
    
### 3.Testbench Top (tb):
  + Instantiates the DUT and the verification environment.
  + Drives the clock (clk) to the DUT.
  + Sets up the simulation environment and runs the verification tests.
    
This project serves as a comprehensive verification environment for validating the functionality and compliance of SPI communication protocols in hardware designs. It facilitates thorough testing and verification to ensure the reliability and correctness of SPI-based systems.


## More details about the environment:

### sequences:
1. write_data: this sequence generates a 15 write transactions, where each transaction is randomly generated based on the constraints defined in the transaction class.
2. read_data: this sequence generates a 15 read transactions, where each transaction is randomly generated based on the constraints defined in the transaction class.
3. reset_dut: this sequence generates transactions intended to perform a reset operation on the DUT.
4. writeb_readb: this sequence generates a total of 22 transactions, alternating between write and read operations, with 11 transactions of each type. Each transaction is randomly generated based on the constraints defined in the transaction class.

   
