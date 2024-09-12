
/* This package contains all of the tasks used to simulate an I2C Master 
 * to test the i2c slave extensivley. The functions are used to generate start conditions,
 * generate stop conditions, generate the scl clock pulses & transmit data. 
*/
package i2c_master_pckg;    
    string TAG = "I2C Master";
    
    //Task to simulate a start condition from the i2c master
    task master_start(virtual i2c_slave_if vif, int i2c_prd);
        //Slight delay
        #10000;
        //Pull SDA Line Low
        vif.sda_data = 1'b0;
        //Delay for half a period
        #(i2c_prd/2);
        //Pull the scl line low
        vif.i_scl = 1'b0;
        #(i2c_prd/2);
    endtask : master_start

    //Transmit data from the i2c master simulation & wait for ACK
    task master_transmit(virtual i2c_slave_if vif, int i2c_prd, logic [7:0] data);
        //Transmit data - 8 bits
        for(int i = 0; i < 8; i++) begin
            //Transmit the data onto the sad line
            vif.sda_data = data[7-i];
            //Wait for quarter a clk period to pull scl high
            #(i2c_prd/4);
            vif.i_scl = 1'b1;
            //Wait for half a period to pull scl low
            #(i2c_prd/2);
            vif.i_scl = 1'b0;
            //Wait for the reminader of the clock period to complete
            #(i2c_prd/4);
        end  
        
        $display("[%s] Data Transmitted: %0h", TAG, data);
        //i2c master releases the line for the ACK from slave
        vif.sda_master_driver = 1'b0;
        vif.sda_data = 1'b0;
        #(i2c_prd/4);
        vif.i_scl = 1;
        #(i2c_prd/2);
        vif.i_scl = 0;
        #(i2c_prd/4); 
        vif.sda_master_driver = 1'b1; 
        
        //Small clock cycle delay
        #(i2c_prd);             
    endtask : master_transmit
    
    task master_read(virtual i2c_slave_if vif, int i2c_prd, output logic [7:0] data, bit nack);
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
            vif.sda_master_driver = 1'b0;
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

    //Generate a Stop Condition from i2c master
    task master_stop(virtual i2c_slave_if vif, int i2c_prd);
        //Stop condition
        vif.i_scl = 1'b1;
        #(i2c_prd/2);
        vif.sda_data = 1'b1;
        #(i2c_prd/2);
        //Small delay before master releases control of sda
        #10000;
        vif.sda_master_driver = 1'b0;        
    endtask : master_stop

endpackage : i2c_master_pckg