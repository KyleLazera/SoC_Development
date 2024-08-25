`ifndef _SPI_SCB
`define _SPI_SCB

`include "spi_scoreboard.sv"

class spi_scoreboard;
    //Mailbox
    mailbox scb_mbx, drv_scb_mbx;
    //Declare 2 transaction items - one for the driver and 1 for the monitor
    spi_trans_item drv_item, scb_item;
    //Global Variables
    string TAG = "Scoreboard";
    int mosi_succ = 0, mosi_fail = 0;       //Counts number of success/fails on the mosi line
    int miso_succ = 0, miso_fail = 0;       //Counts the number of success/fails on the miso line        
    
    task main();
        //Init instance of the transaction Items
        scb_item = new;
        drv_item = new;
        
        $display("[%s] Starting...", TAG);
        
        forever begin
            //Fetch data from monitor mailbox
            scb_mbx.get(scb_item);
            $display("[%s] Item calculated:", TAG);
            scb_item.print(TAG);                    
            //Fetch data from the driver mailbox
            drv_scb_mbx.get(drv_item);
            $display("[%s] Item Receieved:", TAG);
            drv_item.print(TAG);            
            //validate teh data
            validate_items(drv_item, scb_item);
        end
        
    endtask: main
    
    //This function is used to validate the transaction items by comparing the values
    //fromt he driver (these are the values we wanted to send/receieve) & the values that were
    //actually trasnmitted/recieved by the hardware
    function void validate_items(spi_trans_item item1, spi_trans_item item2);
        //Validate mosi line 
        if(item1.mosi_dout == item2.mosi_dout) 
            mosi_succ += 1;
        else if(item1.mosi_dout != item2.mosi_dout) 
            mosi_fail += 1;
                
        //validate MISO line
        if(item1.miso_din == item2.miso_din) 
            miso_succ += 1;
        else if(item1.miso_din != item2.miso_din) 
            miso_fail += 1;           
    endfunction : validate_items 
    
    function void display_score();
        $display("*********************************");
        $display("[%s] Final Scoreboard:", TAG);
        $display("Succesful Transmissions: %0d, Failed Transmissions: %0d", mosi_succ, mosi_fail);
        $display("Succesful Receptions: %0d, Failed Receptions: %0d", miso_succ, miso_fail);
    endfunction: display_score   

endclass : spi_scoreboard

`endif
