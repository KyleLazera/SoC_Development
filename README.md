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
The XADC Core wraps the built-in XADC IP, enabling users to select ADC channels for reading. In this project, it is connected to the onboard temperature and voltage ADC channels. To test this, the temperature is continously printed to the UART port, which can be seen in the SPI verification console.

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

For the on-chip verification, a simple program was developed that would transmit and recieve UART data from the FPGA to the serial comm port (PuTTY was used). The UART would have a counter initialized to 0 that would print "Hello from UART #x" where x is the value of the counter. This counter would increment with each iteration. The user could also write to the UART by typing in a value and the UART would echo this value. If the user did not input a value it would display a -1. Below are two images of teh serial com port and their associated settings as well as the input and output values of these tests.

##### Test 1: 9600, 8 Bits, 1 Stop Bits, Even Parity
![Screenshot 2024-09-21 075106](https://github.com/user-attachments/assets/e31af6c8-8f4d-4e58-a657-c5af6f87a0d8)
![Screenshot 2024-09-21 075413](https://github.com/user-attachments/assets/aac1f228-0749-4a45-8b06-df665a4daf99)
##### Test 2: 115200, 7 Bits, 2 Stop Bits, Odd Parity
![Screenshot 2024-09-21 075622](https://github.com/user-attachments/assets/c57b7587-b318-49b5-b2a3-c7e01a14353f)
![Screenshot 2024-09-21 080151](https://github.com/user-attachments/assets/9e5fd958-fd65-48f5-994f-d6f8c6765615)


### SPI Core
The SPI Core includes both master and slave modules for data transmission and reception. The SPI master interacts with external devices, while the SPI slave features a register file that allows an external SPI master to interact with data from the MicroBlaze. The SPI Core includes:
##### SPI Master:
  1) Configurable clock polarity.
  2) Configurable clock phase.
  3) Configurable divisor to control SPI clock speed.
  4) Supports multi-slave configuration.
##### SPI Slave:
  1) Supports clock phase/polarity of 0.
  2) Supports both read and write operations from the SPI master into the register file.

#### Verification
Similar to the UART module, the SPI core was tested by interfacing SPI master and slave modules in the testbench. The testbench included a register file that tracked transmitted data. The monitor wrote data into the register file on detected writes and compared read values from the SPI Slave with the register file. For onboard verification, the SPI Master interfaced with an external ADXL345 accelerometer and displayed the data via UART. Additionally, SPI Master ports were directly connected to the SPI slave ports on the Basys3 board, with signals analyzed using a logic analyzer to verify correct operation.

Below are samples gathered from a logic analyzer of my SPI modules communication:
![Screenshot 2024-09-20 165234](https://github.com/user-attachments/assets/9c8abce6-5dbd-4148-b76c-a8ecd7c773f8)
![Screenshot 2024-09-20 165220](https://github.com/user-attachments/assets/dbe12ce7-b5e0-4f3d-bfd8-e27471ad8e27)

Additionally, the image below is the serial console which displays teh functionality of one of teh test programs. In this program, the SPI Master reads data from a pre-populated SPI Slave register file. It then increments each value by 1 on each loop of the program.
![Screenshot 2024-09-20 165319](https://github.com/user-attachments/assets/65844dfe-042c-4e5d-b3cb-c38b092b9e13)


### I2C Core
The I2C Core contains both an I2C Master and an I2C Slave. The I2C Slave includes a register file accessible via software drivers. The I2C Master is controlled by software commands for actions such as generating start conditions, transmitting and reading data, and sending stop or restart conditions. Features include:
##### I2C Master:
  1) Configurable clock speed
  2) Does not support arbitration or clock stretching
##### I2C Slave:
  1) Does not support clock stretching
  2) Read and write operations from the i2c slave into the register file.

#### Verification 
Unlike the SPI and UART modules, the I2C Master and Slave were verified separately. In each testbench, either the master or slave I2C module was simulated and interacted with the DUT. The self-checking testbench monitored data on the SDA line and compared it with the expected data to ensure correctness. For on-board verification, the I2C Master interfaced with an external ADXL345 accelerometer. Similar to the SPI module, the I2C Master and Slave ports were connected, and a basic program was tested using a logic analyzer. Images of teh logic anaylzer test is included below.

##### I2C Master Read Data

![Screenshot 2024-09-12 102613](https://github.com/user-attachments/assets/3272a511-37ce-4920-af30-e0acd60d225c)

##### I2C Master Write Data

![I2C Logic Analyzer 1](https://github.com/user-attachments/assets/4e59a045-442e-495f-8a5f-45008458c705)

