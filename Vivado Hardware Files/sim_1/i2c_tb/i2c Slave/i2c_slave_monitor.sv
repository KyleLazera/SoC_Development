`ifndef _I2C_SLAVE_MON
`define _I2C_SLAVE_MON

class i2c_slave_monitor;
    //Scb mailbox
    mailbox scb_mbx;
    //Virtual interface
    virtual i2c_slave_if vif;
    string TAG = "Monitor";
    int burst_ctr = 0;
    
    function new(mailbox _mbx);
        scb_mbx = _mbx;
    endfunction : new
    
    task main();
        i2c_slave_item mon_item = new;
        $display("[%s] Starting...", TAG);
        
        //Wait for the sda line to go low followed by scl line - this indciates
        //a start condition
        @(negedge vif.sda);
        @(negedge vif.i_scl);
        
        forever begin
            
            @(posedge vif.clk);
           
            $display("[%s] Start bit found", TAG);
            
            //If the burst size has been met (plus 1 for the initial address) 
            if(burst_ctr == (vif.burst_size + 1)) begin
                //Reset the burst counter
                burst_ctr = 0;
                $display("[%s] Stop/Restart Condition Detected", TAG);
                mon_item.stop_condition = 1'b1;
                //Wait for a restart condition to occur
                @(negedge vif.sda);
                @(negedge vif.i_scl);
            end else
                mon_item.stop_condition = 1'b0;
                
                //Read 8 bits + 1 ACK/NACK bit
                read_sda(mon_item);
                $display("[%s] Data Transaction Complete: %0h & stop bit: ", TAG, mon_item.d_in, mon_item.stop_condition);    
                //Transmit recieved data to the scoreboard
                scb_mbx.put(mon_item);             
                
        end
    
    endtask : main

    //Task used to probe and read the sda line 
    task read_sda(i2c_slave_item item);
        for(int i = 7; i >= 0; i--) begin
            //At the positive edge of the scl line
            @(posedge vif.i_scl);
            //Because teh i2c slave has pull up resistos, high imedpence is a logic high
            //So this conditional check is meant to handle that
            if (vif.sda === 1'bZ) 
                item.d_in[i] = 1'b1;
            else 
                item.d_in[i] = vif.sda;
  
        end
        
        $display("[%s] Item on SDA: %0h", TAG, item.d_in);
        
        //Read the ACK/NACK bit 
        @(posedge vif.i_scl);
        item.ack = vif.sda;
        //Increment burst counter
        burst_ctr++;
        
        $display("[%s] Ack: %0b", TAG, item.ack);
        
    endtask : read_sda

endclass : i2c_slave_monitor

`endif //_I2C_SLAVE_MON