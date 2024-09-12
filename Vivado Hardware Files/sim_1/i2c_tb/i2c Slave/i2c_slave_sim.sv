`timescale 1ns / 1ps

/* Note: the i2c master simulated will use a 100kHz clk, therefore period is 10000ns*/
module i2c_slave_sim;

//Signals 
logic clk, reset;
logic [7:0] i_file_data;              
logic [7:0] o_file_data;              
logic o_i2c_ready, o_i2c_done;                                  
logic i_scl;                          
tri sda;     
logic sda_driver, i2c_master_sda;                         

//Set clk with 10ns period
always #5 clk = ~clk;

//Module inst
i2c_slave_controller i2c_slave(.*);

assign sda = (sda_driver) ? i2c_master_sda : 1'bZ;

//Data to transmit from the master to the slave
task transmit_data(input logic [7:0] master_data, bit stop);
    //Set sda driver so master has bus control
    sda_driver = 1'b1;
    //Start by setting it all at 1's
    i_scl = 1'b1;
    i2c_master_sda = 1'b1;  
    #100;   
    //Start condition
    i2c_master_sda = 1'b0;
    #5000 i_scl = 1'b0;
    #5000;
    //Transmit data 
    for(int i = 0; i <= 7; i++) begin
        i2c_master_sda = master_data[7-i];
        #2500;
        i_scl = 1'b1;
        #5000;
        i_scl = 1'b0;
        #2500;
    end 
    
    //Release the line for the ACK
    sda_driver = 1'b0;
    #2500;
    i_scl = 1;
    #5000;
    i_scl = 0;
    #2500;
    
    // Check for ACK (SDA should be pulled low by the slave)
    if (sda !== 1'b0) begin
        $display("Error: No ACK received from slave.");
    end
    
    #5000;
    

    if(stop) begin
        //Stop condition
        sda_driver = 1'b1;
        i_scl = 1'b1;
        #5000;
        i2c_master_sda = 1'b1;
        #50000;
        sda_driver = 1'b0;
    end else begin
        //Restart Condition
        sda_driver = 1'b1;
        i_scl = 1'b1;
        i2c_master_sda = 1'b1;
        #50000;
    end
    
    
    //sda_driver = 1'b0;
    
endtask : transmit_data

initial begin
    //Initialize
    clk = 1'b0;
    reset = 1'b1;
    #50;
    reset = 1'b0;
    #100;
    
    transmit_data(8'hE2, 0);
    transmit_data(8'h45, 1);
    
    $finish;

end


endmodule
