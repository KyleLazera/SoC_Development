`ifndef UART_IF_SV
`define UART_IF_SV

//Uart interface that will interact with the DUT
interface uart_itf(input logic clk, input logic reset, string name);
    //Configurable signals that adjust the params of the UART
    logic data_bit;
    logic [1:0] sb_ticks;
    logic parity_en;
    logic parity_pol;
    logic [10:0] dvsr;
    //Control Signals used to control flow of UART 
    logic rd_uart;
    logic wr_uart;
    //Data Signals - holds data to transmit and receieve
    logic [7:0] wr_data;
    logic [7:0] rd_data;
    //Flag or error signals
    logic tx_full;
    logic rx_empty;
    logic parity_err;
    logic frame_err;
    logic overflow_err;
  
   //Interface handle tag - used to distinguish between the two interfaces
   string vif_tag = name;
   //Number of data transmissions
   int num_trans;
endinterface

`endif // UART_IF_SV