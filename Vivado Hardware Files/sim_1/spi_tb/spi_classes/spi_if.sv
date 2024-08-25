`ifndef _SPI_IF
`define _SPI_IF

//Holds the spi master controller interface
interface spi_if(input logic clk, input logic reset);
    //Slot Interface 
    logic cs;
    logic read;
    logic write;
    logic [4:0] reg_addr;
    logic [31:0] wr_data;
    logic [31:0] rd_data;
    //SPI Signals
    logic spi_clk;
    logic spi_mosi;
    logic [1:0] spi_ss_n;
    logic spi_miso;
endinterface : spi_if

`endif  //_SPI_IF
