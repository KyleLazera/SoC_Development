`timescale 1ns / 1ps

`include "spi_test.sv"

/* This testbench is used to verify the SPI Master module by generating random data for the MOSI and MISO lines.
 * Timing delays are applied to calculate the actual data received and transmitted. The randomized data 
 * is then compared to the calculated data, and the results are output via the scoreboard, indicating 
 * whether or not the data matches. */
module spi_top_tb;
    //Signal Declarations
    logic clk, reset;
    
    //Inst clock with 10 ns period
    always #5 clk = ~clk;
    //Declare interface that will interact with the hardware
    spi_if _spi_if(clk, reset);
    
    //Init hardware and connect with the interface
    SPI_Wrapper#(.S(2)) spi_core_1(.clk(clk), .reset(reset), .cs(_spi_if.cs), .write(_spi_if.write), 
                                  .read(_spi_if.read), .reg_addr(_spi_if.reg_addr), .wr_data(_spi_if.wr_data),
                                  .rd_data(_spi_if.rd_data), .spi_clk(_spi_if.spi_clk), .spi_mosi(_spi_if.spi_mosi),
                                  .spi_miso(_spi_if.spi_miso), .spi_ss_n());
                                                                

    //Init the test class
    spi_test default_test;
    
    initial begin
        clk = 0;
        //Reset the circuit
        reset = 1'b1;
        #10;
        reset = 1'b0;
        
        default_test = new(_spi_if);  
        default_test.main();
        
        $finish;
    end

endmodule
