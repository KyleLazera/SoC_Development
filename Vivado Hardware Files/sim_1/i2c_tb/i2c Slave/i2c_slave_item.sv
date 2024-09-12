`ifndef _I2C_ITEM_S
`define _I2C_ITEM_S

class i2c_slave_item;
    /** Varibales used for the Driver **/
    rand logic [7:0] d_in;              //Data to transmit to the i2c slave
    rand bit stop;                      //If this is 1 - stop bit, if 0 - restart condition
    rand bit read_write;                //This will control the direction of data transfer  
    rand logic [7:0] reg_file [15:0];   //Contain ranomd valaues for the register file
    rand int i2c_freq;                       //Determines the i2c clock frequency
    rand int burst_size;                     //Number of burst reads or writes
    /** Variables Used with the Scoreboard **/
    bit ack;
    bit stop_condition;
    
    //Constraint so that a stop bit is generated only 20 percent of the time & the restart condition
    //will be generated 80 percent of the time
    constraint stop_bit_const { stop dist{0 := 80, 1:= 20};}
    
    constraint burst_const 
    { 
        burst_size > 5; 
        burst_size < 20; 
    }
    
    constraint i2c_freq_const
    {
        //Min i2c freq is 50KHz
        i2c_freq >= 50000;
        //Max i2c freq is 400KHz
        i2c_freq <= 400000;
    }
    
    function print(string TAG);
        $display("[%s] d_in: %0h", TAG, d_in);
    endfunction : print
    
    function print_file(string TAG);
        $display("[%s] The Register file contents is:", TAG);
        for(int i = 0; i < 16; i++) 
            $display("%0h",reg_file[i]);
    endfunction : print_file
    
endclass : i2c_slave_item

`endif //_I2C_ITEM_S