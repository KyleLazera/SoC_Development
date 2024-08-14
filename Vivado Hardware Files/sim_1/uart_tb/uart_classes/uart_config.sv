`ifndef UART_CONFIG
`define UART_CONFIG

//Holds configurations for the UART tests
class uart_config;
    bit [11:0] dvsr;
    bit data_bits;
    bit parity_en;
    bit parity_pol;
    bit [1:0] stop_bits;
    
    //Constructor - with default set to data bits: 8, stop bits: 1, polarity: off
    function new(int baud_rate = 9600, bit db = 1'b0, bit parity = 1'b0, bit polarity = 1'b0, bit [1:0] sb = 2'b0);
        this.dvsr = (((100000000)/(16 * baud_rate)) - 1);
        this.data_bits = db;
        this.parity_en = parity;
        this.parity_pol = polarity;
        this.stop_bits = sb;
        
    endfunction
    
endclass : uart_config

`endif