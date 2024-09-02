`timescale 1ns / 1ps

`include "i2c_test.sv"
`include "i2c_m_if.sv"

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
