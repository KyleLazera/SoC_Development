`ifndef _SPI_TRANS_ITEM
`define _SPI_TRANS_ITEM

/***********************************************
SPI Master Transaction Item
***********************************************/

class spi_trans_item;
    rand bit [7:0] mosi_dout;               //Data to be sent from spi master to spi slave 
    bit [7:0] miso_din;                    //Data recieved from SPI slave
    
    constraint mosi_data_const
    {
        mosi_dout[7] dist {0 := 70, 1 := 30};     //Randomize the MSB to indicate a write/read
        mosi_dout[3:0] inside {[0:15]};             //randomise the 4 lsb for the address
    }
    
    //Function that prints the randomized values to send 
    function void print_miso(string TAG);
        $display("[%s] MISO Value: %0h", TAG, miso_din);
    endfunction : print_miso
    
    //Function that prints the randomized values to send 
    function void print(string TAG);
        $display("[%s] MOSI Value: %0h", TAG, mosi_dout);
    endfunction : print    
    
endclass : spi_trans_item

/***********************************************
SPI Slave Transaction Item
***********************************************/

class spi_slave_trans_item;
    //This byte will be used to write/Initialize the spi slave register file
    rand bit [7:0] slave_reg_file [15:0];
    
    //Function to print register file contents to Tcl Console
    function void print(string TAG);
        $display("[%s] Register File Contents: ", TAG);
        for(int i = 0; i < 16; i++)
            $display("%0h", slave_reg_file[i]);
    endfunction : print
    
endclass : spi_slave_trans_item

`endif //_SPI_TRANS_ITEM
