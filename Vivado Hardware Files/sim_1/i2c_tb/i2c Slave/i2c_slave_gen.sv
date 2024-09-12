`ifndef _12C_GEN_S
`define _12C_GEN_S

`include "i2c_slave_item.sv"

/* generates the data to transmit via the SDA line from the i2c master simulation */
class i2c_slave_gen;
    //Mailbox & events
    mailbox drv_mbx;
    event drv_done;
    //Class variables
    string TAG = "Generator";
    
    function new(mailbox _mbx, event _evt);
        drv_mbx = _mbx;
        drv_done = _evt;
    endfunction : new
    
    task main();
        i2c_slave_item reg_item = new;
        $display("[%s] Starting...", TAG);
        
        //generate data for the random reg file & i2c frequency
        reg_item.randomize();
        //Send to the driver
        drv_mbx.put(reg_item);
        
        //Undergo 50 total transmissions with each transmission having multiple bursts
        for(int i = 0; i < 50; i++) begin
            //Init the Slave Item
            i2c_slave_item gen_item = new;
            //Generate a random number of bursts and a stop/restart and a read/write 
            //for thos bursts
            gen_item.randomize();
        
            $display("[%s] Burst Size: %0d", TAG, gen_item.burst_size);
        
            for(int j = 0; j < gen_item.burst_size; j++) begin
                //generate the data to randomize
                gen_item.randomize(d_in, read_write);
                //Send to the driver
                drv_mbx.put(gen_item);
                //Wait for driver to complete processing
                @(drv_done);
            end
        end
    endtask : main

endclass : i2c_slave_gen

`endif  //_12C_GEN_S