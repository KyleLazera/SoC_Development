`timescale 1ns / 1ps

`include "i2c_slave_driver.sv"

module i2c_slave_top_tb;

    //Signals
    logic clk, reset;
    
    //Initialize interafce for hardware
    i2c_slave_if i2c_slave_vif(clk, reset);
    
    //Initialize hardware & connect with the interface signals
    i2c_slave_wrapper i2c_slave(.clk(clk), .reset(reset), .cs(i2c_slave_vif.cs),
                                .read(i2c_slave_vif.read), .write(i2c_slave_vif.write), .reg_addr(i2c_slave_vif.reg_addr),
                                .wr_data(i2c_slave_vif.wr_data), .rd_data(i2c_slave_vif.rd_data), .i_scl(i2c_slave_vif.i_scl),
                                .sda(i2c_slave_vif.sda));
                         
    //Initialize clock signal to 10ns period
    always #5 clk = ~clk;
    
    //Init the test instance and pass the virtual interface
    i2c_slave_test i2c_test;  
    
    initial begin
        //Reset/initialization Conditions
        clk = 0;
        reset = 1;
        #100;
        reset = 0;
        #50;
        
        i2c_test = new(i2c_slave_vif);
        i2c_test.main();
        
        $finish;
    end                       

endmodule
