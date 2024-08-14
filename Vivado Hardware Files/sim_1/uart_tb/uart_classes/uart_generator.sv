`ifndef UART_GENERATOR
`define UART_GENERATOR

`include "uart_trans_item.sv"

/* Used to generate random values that will be driven to the DUT using the virtual interface*/
class uart_generator;
    //Mailbox to connect generator and driver
    mailbox drv_mailbox;
    //Event to signal generator when to send a new data item to driver
    event drv_done;
    //variables to randomze variable generation
    rand int num, seed;
    //Tag
    string TAG = "Generator";
    
    //Task that ranomizes/generates values to be driven to the DUT
    task run();
        //Randomize the number of values to send - used to get a wide scope
        seed = $urandom;
        num = $urandom_range(80, 100);
        //Begin generating and sending these values to the driver
        for(int i = 0; i < 50; i++) begin
            uart_trans_item gen_item = new;
            gen_item.num_trans = 50;
            gen_item.randomize();
            //Log for debuggin
            $display("T=%0t [%s] Loop: %0d/%0d create next item.", $time, TAG, (i+1), num);
            //Send to the driver
            drv_mailbox.put(gen_item);
            //Wait until driver has completed processing before sending next signal
            @(drv_done);            
        end
        //Log completion of generation
        $display("T=%0t [%s] Complete generation of %0d items.", $time, TAG, num);
        #1000; //Small delay to let data propgate to scoreboard
    endtask : run
endclass : uart_generator

`endif //UART_GENERATOR