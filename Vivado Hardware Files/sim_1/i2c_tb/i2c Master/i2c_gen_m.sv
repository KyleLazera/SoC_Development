`ifndef _I2C_GEN
`define _I2C_GEN

`include "i2c_item_m.sv"

/*
 * This class is used to randomize/populate the transaction item. This transaction item is
 * then sent to the driver class so that the data can be transmitted to the hardware module.
*/
class i2c_gen_m;
    //Driver & generator interface 
    mailbox drv_mbx, gen_scb_mbx;
    event drv_done, mon_done;
    //Class vars
    string TAG = "Generator";
    
    //Redefine the constructor to populate the mailbox and event
    function new(mailbox _mbx, event _evt);
        drv_mbx = _mbx;
        drv_done = _evt;
    endfunction : new
    
    //Main task that generates tansaction item & controls data flow to & from driver
    task main();
            //Instantiate instance of transaction item
            i2c_item_m gen_item = new;    
        $display("[%s] Starting...", TAG);
        
        /* Logic to generate the transaction item values */
        for(int j = 0; j < 10; j++) begin 
            //To test a rnage of i2c clock frequencies, it is changed every 50 transmissions
            gen_item.randomize(i2c_clk_freq);
            
            for(int i = 0; i < 50; i++) begin           
                 //generate random value for the master out value
                 gen_item.randomize(master_out);
                 gen_item.randomize(restart_bit);
                 //Print the value for debugging
                 $display("[%s] Item %0d generated.", TAG, i);
                 //transmit to driver & the scoreboard for cross-checking
                 drv_mbx.put(gen_item);
                 gen_scb_mbx.put(gen_item);
                 //Wait for driver to indicate processing complete
                 @(mon_done);  
                 @(drv_done);              
            end
        end       
    endtask : main
    
endclass : i2c_gen_m

`endif //_I2C_GEN