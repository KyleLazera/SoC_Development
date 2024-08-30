`timescale 1ns / 1ps

`include "spi_test.sv"

/* This testbench is used to verify the SPI Master & Slave module. It does so by connecting the SPI
 * slave and master hardware, and driving each of these modules via interfaces. The operation of the 
 * testbench is as such: 
 * 1) The register file contained within the spi slave is filled with random values
 * 2) The SPI master then generates 500 andom values that will be used to address & write into the register file
 * 3) The SPI Master transmits the values to the slave 
 * 4) The Slave outputs the value in the address specified by the Master or writes the new value into the register file
 * 5) For every write into the slave, the scoreboard also updates the copy of the register file in the testbench.
 * 6) The data receieved on the MISO line is validated by checking the software register file at teh same address that produced the MISO data.
 * 
 * To reduce the total number of files and improve readability, the related classes for the spi master and slave
 * are both in the same file. For example, the spi slave driver and spi master driver classes are both in the spi_driver file.
 * Key for the final scoreboard:
 * Succesful SPI Reads - This is the number of times when the Master sent an address with the msb set to 0, and the data returned
 *                        on the next transmission matched the generated slave register file values.
 * Failed SPI Reads - This indicates teh number of times when the SPI Master output an address to read from and the returning value 
 *                       on the next transaction DID NOT match the slave reg file value.
 * Number of Writes - This is going to indicate how many times the SPI Module sent new data to be written into the Slave Register File
*/
module spi_top_tb;
    //Signal Declarations
    logic clk, reset;
    //SPI Connections
    logic S_CLK, MOSI, MISO;
    logic [1:0] S_CS;
    
    //Inst clock with 10 ns period
    always #5 clk = ~clk;
    
    //Declare interface that will interact with the hardware
    spi_if _spi_if(clk, reset);
    spi_slave_if _spi_if_s(clk, reset);
    
    //Init hardware and connect with the interfaceS
    SPI_Wrapper#(.S(2)) spi_master(.clk(clk), .reset(reset), .cs(_spi_if.cs), .write(_spi_if.write), 
                                  .read(_spi_if.read), .reg_addr(_spi_if.reg_addr), .wr_data(_spi_if.wr_data),
                                  .rd_data(_spi_if.rd_data), .spi_clk(S_CLK), .spi_mosi(MOSI),
                                  .spi_miso(MISO), .spi_ss_n(S_CS));
                                  
   spi_slave_reg_file#(.DEPTH(16), .WIDTH(8)) spi_slave(.clk(clk), .reset(reset), .cs(_spi_if_s.cs), .write(_spi_if_s.write), 
                                  .read(_spi_if_s.read), .reg_addr(_spi_if_s.reg_addr), .wr_data(_spi_if_s.wr_data),
                                  .rd_data(_spi_if_s.rd_data), .spi_clk(S_CLK), .spi_mosi(MOSI),
                                  .spi_miso(MISO), .spi_cs_n(S_CS[0]));
                                                                

    //Init the test class
    spi_test default_test;
    
    initial begin
        clk = 0;
        //Reset the circuit
        reset = 1'b1;
        #10;
        reset = 1'b0;
        
        default_test = new(_spi_if, _spi_if_s);  
        default_test.main();
        
        $finish;
    end

endmodule
