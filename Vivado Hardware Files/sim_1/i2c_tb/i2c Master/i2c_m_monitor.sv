`ifndef _I2C_MONITOR
`define _I2C_MONITOR

`include "i2c_item_m.sv"

/*
 * This class is used to monitor the DUT signals. It is also used to transmit data 
 * to the scoreboard for final validation/comparison.
*/
class i2c_m_monitor;
    //Interface with the scoreboard
    mailbox scb_mbx;
    event mon_done;
    //Virtual interface to interact with DUT
    virtual i2c_m_if vif;
    //Class Variables
    string TAG = "Monitor";
    
    function new(mailbox _mbx, virtual i2c_m_if _vif);
        scb_mbx = _mbx;
        vif = _vif;
    endfunction : new
    
    task main();
        //Create instance of transaction item to transfer to scb
        i2c_item_m mon_item = new;
        $display("[%s] Stating...", TAG);
    
        forever begin
            //Wait for done tick
            @(vif.rd_data[10]); 
            //Wait for i2c ready indicating ack has been recieved
            @(vif.rd_data[8]);  
            //Because the I2C port is always sampling the SDA line, it will sample its own data
            //begin driven out on the sda line - therefore the data can be checked by reading this value             
            mon_item.master_out = vif.rd_data[7:0];
            mon_item.print(TAG);
            //Transmit the data item to the scoreboard
            scb_mbx.put(mon_item);   
            ->mon_done;   
        end        
    endtask : main

endclass : i2c_m_monitor


`endif //_I2C_MONITOR