`ifndef _I2C_DRV
`define _I2C_DRV

`include "i2c_item_m.sv"
`include "i2c_m_if.sv"

/*
 * This class interfaces with teh DUT and drives data from teh generator (transaction item)
 * into the hardware module via a virtual interface.
*/
class i2c_m_driver;
    //interface with generator
    mailbox drv_mbx;
    event drv_done;
    //virtual interface to interface w/ DUT
    virtual i2c_m_if vif;
    //Class variables
    localparam DVSR_REG = 0;
    localparam RD_REG = 0;
    localparam WR_REG = 1;
    
    enum logic [2:0]{START = 3'b000,
                     WR_CMD = 3'b001,
                     RD_CMD = 3'b010,
                     STOP = 3'b011,
                     RESTART = 3'b100
                     }i2c_cmd;
    
    string TAG = "Driver";
    
    //Constructor
    function new(mailbox _mbx, event _evt, virtual i2c_m_if _vif);
        drv_mbx = _mbx;
        drv_done = _evt;
        vif = _vif;
    endfunction : new
    
    task main();
        //Init instance of transaction item to recieve generator data
        i2c_item_m rec_item;
        $display("[%s] Starting...", TAG);
        
        /* Logic to drive data to the interface/DUT */
        forever begin
            if(vif.rd_data[8]) begin
            //Fetch data from the generator
            drv_mbx.get(rec_item);   
            $display("[%s] Item recieved", TAG);  
            rec_item.print(TAG);       
            //Set the dvsr based on randomly generated i2c clk freq
            set_dvsr(rec_item.i2c_clk_freq);
            //Begin data transaction
            write_data(rec_item.master_out, rec_item);
            //Signal the generator the driver has complete processing
            ->drv_done;  
            end          
        end
        
    endtask : main
    
    //Task that is used to set the dvsr for the i2c clk 
    //The dvsr is calculated using teh following formula: dvsr = (fsys)/(4 * fi2c)
    task set_dvsr(int i2c_freq); 
        /* Calculate dvsr value */
        logic [15:0] dvsr_val;
        dvsr_val = 100000000/(4 * i2c_freq);
        /* Write data into the I2C Module */
        vif.cs = 1'b1;
        vif.write = 1'b1;
        vif.reg_addr = DVSR_REG;
        vif.wr_data = {16'h0, dvsr_val};
        @(posedge vif.clk);        
        vif.cs = 1'b0;
        vif.write = 1'b0;        
    endtask : set_dvsr
    
    //TODO: More modular and restart condition must be taken into account
    //Task that sends instructions for the I2C master an how it should operate
    task write_data(input logic [7:0] data_byte, i2c_item_m rec_item);
        /* Initialize a Start Condition for the I2C Master */
        vif.cs = 1'b1;
        vif.read = 1'b0;
        vif.write = 1'b1;
        vif.reg_addr = WR_REG;
        vif.wr_data = {21'h0, START,  8'b0};
        @(posedge vif.clk);
        vif.write = 1'b0;
        vif.read = 1'b0;
        @(posedge vif.clk);       
        //Wait until the I2C Master is ready (start condition generated)
        @(vif.rd_data[8]);                
        //Once i2c has completed start condition, transmit the data
        vif.read = 1'b0;
        vif.write = 1'b1;
        //Todo: This area should have a check to see if we are reading/writing data 
        vif.reg_addr = WR_REG;
        vif.wr_data = {21'h0, WR_CMD, data_byte};
        @(posedge vif.clk);
        //Once again wait unitl i2c has completed data transmission/reception
        vif.write = 1'b0;
        vif.read = 1'b1;
        @(posedge vif.clk);
        @(vif.rd_data[8])
        @(posedge vif.clk);
        vif.read = 1'b0;
        vif.write = 1'b1;
        //Send the restart command or stop command based on random value
        vif.reg_addr = WR_REG;
        if(rec_item.restart_bit) 
            vif.wr_data = {21'h0, RESTART, 8'b0}; 
        else 
            vif.wr_data = {21'h0, STOP, 8'b0};                   
                
    endtask : write_data
    
endclass : i2c_m_driver


`endif //I2C_DRV