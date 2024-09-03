`timescale 1ns / 1ps

`include "i2c_test.sv"
`include "i2c_m_if.sv"

/*
 * Based off the design of the I2C Master, verifying both reading and writing capabilities is challenging due to the sda
 * line being tied to the GPIO I/O line which is has a pull-up resistor. This was difficult to mimic in the testbench.
 * This testbench therefore only tests the ability of the i2c master to write values out to teh SDA line, and software will
 * be used to test the reading capabilities.
 * Note: To get a correct reading value from the self-checking testebench, 2 lines in the RTL code must be adjusted. Line 82
 * & 73 need to have Z changed to 1. These are set to Z for the reason described above (High impledence when on a pull up resistor
 * defaults to a logic 1) but for simulation this is not the case.
*/
module i2c_master_tb_top;

    //Signals for the I2C Interface
    logic clk, reset;
    
    //Set the clock period to 10ns
    always #5 clk = ~clk;
    
    //Instantiate Interface
    i2c_m_if i2c_master(clk, reset);
      
    //Instantiate DUT with the interface signals
    i2c_master_core i2c_m_dut(.clk(clk), .reset(reset), .cs(i2c_master.cs), .read(i2c_master.read),
                              .write(i2c_master.write), .reg_addr(i2c_master.reg_addr), .wr_data(i2c_master.wr_data),
                              .rd_data(i2c_master.rd_data), .sda(i2c_master.sda), .scl(i2c_master.scl));
    
    //Declare Test class
    i2c_test i2c_master_test;
    
    //Declare Test class
    i2c_test i2c_master_test;    
    
    initial begin
        //Initialize signals for testbench
        clk = 1'b0;      
        //Reset the hardware test first
        reset = 1'b1;
        #50;
        reset = 1'b0;
        #10;
                          
        //Initialize instance of test class
        i2c_master_test = new(i2c_master);
        i2c_master_test.main();
        
        $finish;
    end
    
 

endmodule
