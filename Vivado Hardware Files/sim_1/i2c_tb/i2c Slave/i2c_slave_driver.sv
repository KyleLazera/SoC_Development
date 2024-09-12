`ifndef _I2C_DRIVER_S
`define _I2C_DRIVER_S

`include "i2c_slave_gen.sv"
import i2c_master_pckg::*;

class i2c_slave_driver;
    //Mailbox
    mailbox drv_mbx, scb_drv_mbx;
    event drv_done;
    //Initialize virtual interface
    virtual i2c_slave_if vif;
    //Class Variables
    string TAG = "Driver";
    bit [6:0] SLAVE_ADDR = 7'b0001000;
    int burst_ctr = 0;
    bit read;
    
    function new(mailbox _mbx, mailbox _scb_mbx,  event _evt);
        drv_mbx = _mbx;
        scb_drv_mbx = _scb_mbx;
        drv_done = _evt;
    endfunction : new
    
    task main();
        i2c_slave_item drv_item;
        bit stop_condition = 1;
        int i2c_freq;
        logic [7:0] data_out;
        $display("[%s] Starting...", TAG);
        
        /*** Populate the register file with generated values ***/
        //Fetch item from mailbox - this is to populate the register file
        drv_mbx.get(drv_item);        
        //Popuate the register file with random values
        populate_reg_file(drv_item); 
        //Set the i2c Freq 
        i2c_freq = drv_item.i2c_freq;    
        //Print the reg file for debugging
        drv_item.print_file(TAG); 
        //Send this item to the scb to have access to the register file
        scb_drv_mbx.put(drv_item);
        
        forever begin      
            //Fetch slave item from mailbox
            drv_mbx.get(drv_item);
            i2c_master(drv_item, i2c_freq);
                
            //Indciate completion of processing for generator  
            ->drv_done;
        end        
    endtask : main
    
    //This task is used to opulate the regiter file in the slave wrapper
    task populate_reg_file(i2c_slave_item item);
        for(int i = 0; i < 16; i++) begin
            //Enable the processor to write 
            vif.cs = 1'b1;
            vif.write = 1'b1;
            //Inctrement the Register address each time
            vif.reg_addr = i;
            //Write generated data into the register file
            vif.wr_data = item.reg_file[i];
            //Wait a clock cycle
            @(posedge vif.clk);
            //Clear the write lines after 1 clock edge and reset
            vif.cs = 1'b0;
            vif.write = 1'b0;
        end
    endtask : populate_reg_file
    
    //This task is used to simulate writing data from the master to the slave
    task i2c_master(i2c_slave_item item, int i2c_freq);
        int i2c_period;
        bit nack = 0;
        vif.burst_size = item.burst_size;
        
        if(burst_ctr == 0) begin
            //Pull the scl line & sda line high (initial conditions)
            vif.sda_master_driver = 1'b1;
            vif.sda_data = 1'b1;
            vif.i_scl = 1'b1;
        end
        
        //Calculate i2c period for scl clk line
        i2c_period = (1000000000/i2c_freq); 
        
        //If it is teh last burst item, set the NACK
        if(burst_ctr == (item.burst_size - 1))
            nack = 1'b1;
        
        //Init a start condition with first transmission/reception
        if(burst_ctr == 0) begin
            master_start(vif, i2c_period);
            //If we have not transmitted teh first burst, send the slave address first w/ rd/wr
            master_transmit(vif, i2c_period, {SLAVE_ADDR, item.read_write});
            read = item.read_write;
        end else begin
            
            if(!read)
                //Transmit generated data
                master_transmit(vif, i2c_period, item.d_in);
            else begin
                //Give up control of sda to slave
                vif.sda_master_driver = 1'b0;
                //read data form the slave - generate clock pulses
                master_read(i2c_period, item.d_in, nack);
                nack = 0;
            end
        end
        
        //If all bursts have been trasnmitted generate either a stop or a restart
        if(burst_ctr == item.burst_size) begin
            if(item.stop) 
                master_stop(vif, i2c_period);
            
            burst_ctr = 0;
        end
        else
            burst_ctr++;
            
    endtask : i2c_master
    
        task master_read(int i2c_prd, output logic [7:0] data, bit nack);
        //Transmit clock pulses
        for(int i = 0; i < 8; i++) begin
            //Wait for quarter a clk period to pull scl high
            #(i2c_prd/4);
            vif.i_scl = 1'b1;
            //Wait for half a period to pull scl low
            #(i2c_prd/2);
            vif.i_scl = 1'b0;
            //Wait for the reminader of the clock period to complete
            #(i2c_prd/4);
        end  
        
        //i2c master releases the line for the ACK from slave
        if(nack) begin
            vif.sda_master_driver = 1'b1;
            vif.sda_data = 1'b1;
        end else begin
            vif.sda_master_driver = 1'b1;
            vif.sda_data = 1'b0;
        end
        #(i2c_prd/4);
        vif.i_scl = 1;
        #(i2c_prd/2);
        vif.i_scl = 0;
        #(i2c_prd/4); 
        vif.sda_master_driver = 1'b1; 
        
        //Small clock cycle delay
        #(i2c_prd);             
    endtask : master_read
     
endclass : i2c_slave_driver


`endif //_I2C_DRIVER_S