# SoC Developement
This project focuses on System on Chip (SoC) development and the integration of hardware and software. Utilizing the MicroBlaze MCS softcore processor on an Atrix-7 Basys 3 development board, this project demonstrates my independent work in designing and integrating various peripherals and custom code to drive these peripherals. While the project draws inspiration from the textbook "FPGA Prototyping with SystemVerilog" by Pong P. Chu and utilizes some base peripherals, the majority have been independently developed by me.

## Peripheral Description
Each peripheral was designed in SystemVerilog using RTL methodology and verified through functional verification techniques. For more advanced peripherals, such as the UART, SPI Master and Slave, and I2C Master and Slave, a comprehensive testbench architecture was employed. This architecture included drivers, generators, monitors, scoreboards, and other components to ensure thorough test coverage and address potential edge cases. The testbench architecture is illustrated below.

![sv_testbench_arch](https://github.com/user-attachments/assets/a600b3f6-5812-4f28-bf09-36981ca18c26)

The peripherals were stored in a Memory-Mapped Input/Output (MMIO) system and accessed by the MicroBlaze softcore processor via a custom bus topology. Below are the peripherals and their associated features.

### System Timer
The System Timer peripheral provides the processor with an external timer that can produce a tick after a specified period. It supports the following features:
  1) Adjustable period set by the user via software.
  2) Continuous counting mode.
  3) One-shot mode.

### GPIO Core
The GPIO Core is a general-purpose I/O module that allows interaction with external devices using switches and LEDs on the Basys3 FPGA board. It supports bidirectional data flow and is designed with a tri-state buffer.

### Seven-Segment Contorller
The Seven-Segment Controller provides control over the 7-segment display on the Basys3 board. Using drivers written in C, users can easily utilize the API to display data on the screen.

### PWM Core
The PWM Core allows users to control PWM outputs on multiple channels. It features:
  1) Support for up to 16 channels.
  2) Configurable resolution via software.
  3) Independent duty cycle settings for each channel.

### XADC Core
The XADC Core wraps the built-in XADC IP, enabling users to select ADC channels for reading. In this project, it is connected to the onboard temperature and voltage ADC channels.

### UART Core
The UART Core is one of the communication cores used in this project. It facilitates debugging and direct communication between the MicroBlaze processor and a serial port. The core includes a baud rate generator, transmit (TX) and receive (RX) controllers, and FIFOs for buffering. Key features include:
  1) Configurable number of data bits (7 bits/8 bits).
  2) Configurable parity (enable/odd/even).
  3) Configurable number of stop bits (1/1.5/2).
  4) Oversampling set to 16.
  5) Error flags indicating:
       i) Frame Errors.
       ii) Parity Errors.
       iii) Overflow Errors.

#### Verification
The UART module was verified by instantiating two DUTs connected via TX and RX lines. Each DUT had its own interface with generators, drivers, and monitors. The UART DUTs communicated in full duplex mode, and a self-checking testbench compared data from one UART module with data received by the second UART module to ensure they matched.

### SPI Core
The SPI Core includes both master and slave modules for data transmission and reception. The SPI master interacts with external devices, while the SPI slave features a register file that allows an external SPI master to interact with data from the MicroBlaze. The SPI Core includes: SPI Master:
SPI Master:
  1) Configurable clock polarity.
  2) Configurable clock phase.
  3) Configurable divisor to control SPI clock speed.
  4) Supports multi-slave configuration.
SPI Slave:
  1) Supports clock phase/polarity of 0.
  2) Supports both read and write operations from the SPI master into the register file.

#### Verification
Similar to the UART module, the SPI core was tested by interfacing SPI master and slave modules in the testbench. The testbench included a register file that tracked transmitted data. The monitor wrote data into the register file on detected writes and compared read values from the SPI Slave with the register file. For onboard verification, the SPI Master interfaced with an external ADXL345 accelerometer and displayed the data via UART. Additionally, SPI Master ports were directly connected to the SPI slave ports on the Basys3 board, with signals analyzed using a logic analyzer to verify correct operation.

### I2C Core
The I2C Core contains both an I2C Master and an I2C Slave. The I2C Slave includes a register file accessible via software drivers. The I2C Master is controlled by software commands for actions such as generating start conditions, transmitting and reading data, and sending stop or restart conditions. Features include:
I2C Master:
  1) Configurable clock speed
  2) Does not support arbitration or clock stretching
I2C Slave:
  1) Does not support clock stretching
  2) Read and write operations from the i2c slave into the register file.

#### Verification 
Unlike the SPI and UART modules, the I2C Master and Slave were verified separately. In each testbench, either the master or slave I2C module was simulated and interacted with the DUT. The self-checking testbench monitored data on the SDA line and compared it with the expected data to ensure correctness. For on-board verification, the I2C Master interfaced with an external ADXL345 accelerometer. Similar to the SPI module, the I2C Master and Slave ports were connected, and a basic program was tested using a logic analyzer. Images of teh logic anaylzer test is included below.

##### I2C Master Read Data

![Screenshot 2024-09-12 102613](https://github.com/user-attachments/assets/3272a511-37ce-4920-af30-e0acd60d225c)

##### I2C Master Write Data

![I2C Logic Analyzer 1](https://github.com/user-attachments/assets/4e59a045-442e-495f-8a5f-45008458c705)

