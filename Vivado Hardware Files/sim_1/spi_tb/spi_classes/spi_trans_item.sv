`ifndef _SPI_TRANS_ITEM
`define _SPI_TRANS_ITEM

class spi_trans_item;
    //The bits of interest for this simulation - the randomized din bit will be
    //sent from 1 spi module to another, and it should match the dout of the other spi value
    rand bit [7:0] mosi_dout;               //Data to be sent from spi master to spi slave 
    rand bit [7:0] miso_din;                //Data recieved from SPI slave
    
    //Function that prints the randomized values to send 
    function void print(string TAG);
        $display("[%s] MOSI Value: %0h, MISO Value: %0h", TAG, mosi_dout, miso_din);
    endfunction : print
    
endclass : spi_trans_item

`endif //_SPI_TRANS_ITEM
