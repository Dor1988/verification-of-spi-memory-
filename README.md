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
  + sequence Class: uvm sequences are made up of several data items, which can be put together in different ways to create interesting scenarios.
    they are executed by an assigned sequencer which then sends data items to the driver. Hence, sequences make up the core stimuli of any verifictaion plan.
  + sequencer class: generates data transactions as class objects and sends it to the driver for execution.
  + Driver Class: Drives transactions to the DUT.
  + Monitor Class: Monitors the DUT's output and captures the response for verification.
  + Agent Class: An agent encapsulates a sequencer, driver and monitor into a single entity by instantiating and connecting the components together via tlm interfaces.
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

### driver:
+this driver component is responsible for the execution of transactions based on commands received from the testbench, driving these transactions to the DUT, and handling the necessary signaling for both write and read operations.

1.Reset Task (reset_dut):

This task is responsible for performing a system reset on the DUT.
It sets the reset signal (vif.rst) to high, waits for a clock edge, and then sets it back to low.
A message is displayed indicating the system reset.

2.Write Task (write_d):

This task is responsible for driving write transactions to the DUT.
It configures the virtual interface signals (vif) appropriately for a write operation.
It constructs the data to be written (data) from the transaction (tr) and drives it to the DUT.
The task waits for the operation to complete (vif.op_done).

3.Read Task (read_d):

This task is responsible for driving read transactions to the DUT.
It configures the virtual interface signals (vif) appropriately for a read operation.
It constructs the address to be read (data) from the transaction (tr) and drives it to the DUT.
After waiting for the DUT to indicate readiness (vif.ready), it samples the output data (vif.miso) and stores it in datard.
A message is displayed indicating the read operation and the retrieved data.


### scoreboard:

The scoreboard (sco) is checking the correctness of data transactions between the DUT (Device Under Test- spi_mem) and the testbench. Here's a summary of what the scoreboard is checking for each type of transaction:

1. System Reset Detection:

When the scoreboard receives a transaction with the operation type rstdut, it recognizes this as a system reset operation.
The scoreboard logs a message indicating the detection of a system reset.

2. Write Operation (writed):

When the scoreboard receives a transaction with the operation type writed, it interprets this as a write operation.
It stores the data (tr.din) received in the transaction into the appropriate location in the scoreboard array (arr) based on the address (tr.addr).
Additionally, it logs a message indicating the data write operation and the data stored in the scoreboard array for debugging purposes.

3. Read Operation (readd):

When the scoreboard receives a transaction with the operation type readd, it interprets this as a read operation.
It retrieves the data stored in the scoreboard array (arr) at the specified address (tr.addr).
The scoreboard compares the retrieved data (data_rd) with the actual data (tr.dout) received from the DUT.
If the retrieved data matches the actual data, it logs a message indicating a successful data match.
If the retrieved data does not match the actual data, it logs a message indicating a test failure along with the actual and retrieved data for debugging.

Overall, the scoreboard checks the following:
It ensures that write operations correctly store data in the DUT (spi_mem).
It verifies that read operations received the right data from DUT (spi_mem), matching the data retrieved from the scorboard array. If there is a discrepancy, it flags a test failure for further investigation.

   
