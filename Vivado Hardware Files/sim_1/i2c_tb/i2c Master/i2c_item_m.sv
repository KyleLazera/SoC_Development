`ifndef _I2C_ITEM
`define _I2C_ITEM

/*
 * Transaction item that will be populated by the generator and transmitted to the driver.
 * Used to randomize values for the I2C Master.
*/
class i2c_item_m;
    rand bit [7:0] master_out;
    rand int i2c_clk_freq;
    rand bit restart_bit;           //This raqndomized bit dictates whteher to do a restart conditions vs a stop condition
    
    //Constraint to ensure the clock frequency for i2c is no higher than 3.4MHz 
    constraint i2c_clk_const
    {
        i2c_clk_freq > 0;
        i2c_clk_freq <= 3400000;
    }
    
    //Function used for debugging & flow control
    function void print(string tag);
        $display("[%s] Master output value: %0h", tag, master_out);
    endfunction : print
    
endclass : i2c_item_m

`endif //_I2C_ITEM