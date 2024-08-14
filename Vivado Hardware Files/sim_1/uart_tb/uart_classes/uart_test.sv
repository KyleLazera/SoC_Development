`ifndef UART_TEST
`define UART_TEST

`include "uart_env.sv"
`include "uart_config.sv"

//instantiate the environment and begin the test
class uart_test;
    uart_env        env;
    uart_config     uart_cfg;
    
    string TAG = "Test";
    
    //Constructor - when this class is instantiated create a new instance of environemnt & sets up test params
    function new(uart_config cfg = null);
        //If the user did not specify any params, set to default
        if(cfg == null)
            uart_cfg = new;
        else
            uart_cfg = cfg;
        
        env = new(uart_cfg);
    endfunction
       
    //call the run task in the env
    task run(virtual uart_itf uart_1, virtual uart_itf uart_2);
        $display("T=%0t [%s] Test Starting with stop_bits=%0b, baud_rate=%0d, data_bits=%0b, parity=%0b, polarity=%0b...", 
                $time, TAG, uart_cfg.stop_bits, uart_cfg.dvsr, uart_cfg.data_bits, uart_cfg.parity_en, uart_cfg.parity_pol);
        //assign the virtual interfaces
        env.uart_1_vif = uart_1;
        env.uart_2_vif = uart_2;
        //Run environemnt
        env.run();
        #100;   //Small delay to wait for simulation to complete
        $display("T=%0t [%s] Test Complete.", $time, TAG);
        display_final_score();
    endtask
    
    //Final function to display the final score
    function display_final_score();
        env.scb.display_score();
    endfunction
    
endclass : uart_test

`endif//UART_TEST