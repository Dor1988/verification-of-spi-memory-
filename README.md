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








### scoreboard:

The scoreboard (sco) is checking the correctness of data transactions between the DUT (Device Under Test- spi_mem) and the testbench. Here's a summary of what the scoreboard is checking for each type of transaction:

1. System Reset Detection:

When the scoreboard receives a transaction with the operation type rstdut, it recognizes this as a system reset operation.
The scoreboard logs a message indicating the detection of a system reset.

2. Write Operation (writed):

When the scoreboard receives a transaction with the operation type writed, it interprets this as a write operation.
It stores the data (tr.din) received in the transaction into the appropriate location in the scoreboard array (arr) based on the address (tr.addr).
Additionally, it logs a message indicating the data write operation and the data stored in the scoreboard array for debugging purposes.

3.Read Operation (readd):

When the scoreboard receives a transaction with the operation type readd, it interprets this as a read operation.
It retrieves the data stored in the scoreboard array (arr) at the specified address (tr.addr).
The scoreboard compares the retrieved data (data_rd) with the actual data (tr.dout) received from the DUT.
If the retrieved data matches the actual data, it logs a message indicating a successful data match.
If the retrieved data does not match the actual data, it logs a message indicating a test failure along with the actual and retrieved data for debugging.

Overall, the scoreboard checks the following:
It ensures that write operations correctly store data in the DUT (spi_mem).
It verifies that read operations received the right data from DUT (spi_mem), matching the data retrieved from the scorboard array. If there is a discrepancy, it flags a test failure for further investigation.

   
