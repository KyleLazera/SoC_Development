`ifndef UART_TRANS_ITEM
`define UART_TRANS_ITEM

/*UART Transaction Item - this class contains the data packet that is sent between the generator and driver 
* and the monitor and scoreboard. It holds the initial generated/randomized data to drive to the virtual interface
* and it holds the meaningful data we want to compare for the scoreboard*/
class uart_trans_item;
    rand bit [7:0] tx_data;                 //Data to transmit out via the tx pins
    bit [7:0] rd_data;                      //Data packet formed from sampling the rx pin
    bit parity_err;                         //Flag indicating mismatched parity
    bit frame_err;                          //Flag indicating a frame error
    bit overflow_err;                       //Flag indicating overflow of the rx buffer
    
    string vif_tag;                         //Tag that holds the name of the vif that passed teh data to this item
    int num_trans;                          //Holds the total number of data transmissions - used for scoreboard
    
    //Debugging funtion
    function void print(string tag ="");
        $display("T=%0t [%s] vif handle: %s, tx_data: %0h, rd_data : %0h", $time, tag, vif_tag, tx_data, rd_data);
    endfunction
    
endclass : uart_trans_item 

`endif //UART_TRANS_ITEM