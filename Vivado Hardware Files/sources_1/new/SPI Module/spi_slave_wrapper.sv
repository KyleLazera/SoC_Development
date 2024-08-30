`timescale 1ns / 1ps

/* This module contains the register file that acts as the "middleman" for the FPGA/SoC &
* the SPI Master. It allows the user to write software to directly access the reg file, thereby,
* allowing the user to share any data with an external SPI Master.
* The SPI Slave supports both read and write operations into the register file address. To write
* into the register file form the SPI Master, set the msb of the address to write to as 1.
* Example: if I want to write tot address 0x3, The SPI master would send 0x83, followed by the data to write 
* into the register;
* The contents of teh register file cna also be accessed by the Microblaze and the output data is structured as follows:
* bit 8: spi_ready flag
* bit 7 - 0: 8-bit data in the register file
*/
module spi_slave_reg_file
#( 
    parameter DEPTH = 16,           //Depth of the register file
    parameter WIDTH = 8             //Width of each word in the reg file
)  
(
    input clk, reset,
    //Slot Interface 
    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] reg_addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,
    //SPI Output Signals
    input logic spi_clk,
    input logic spi_mosi,
    input logic spi_cs_n,
    output logic spi_miso
);

//Signal Declarations
logic [WIDTH-1:0] slave_reg_file [DEPTH-1:0];                   //Register file 
logic wr_en;                                                    //Signal that indicates the processor is trying to write a value

logic slave_rdy, rx_done;
logic [7:0] mosi_data, write_addr;                              //Holds data from the spi master 
logic [7:0] miso_byte;                                          //Sends the value to output to the spi slave controller
logic spi_wr_en;                                                //Signal indicating when to write MOSI values into the reg file

//SPI Slave Controller
spi_slave spi_slave_controller(.clk(clk), .reset(reset),
                                .o_slave_rdy(slave_rdy), .o_rx_done(rx_done), .o_mosi_byte(mosi_data), .i_miso_byte(miso_byte),
                                .i_spi_clk(spi_clk), .i_spi_mosi(spi_mosi), .i_spi_cs_n(spi_cs_n), .o_spi_miso(spi_miso));

/*** Register File Logic ***/
always_ff @(posedge clk) begin
    if(reset) begin
        for(int i = 0; i < DEPTH; i++)
            slave_reg_file[i] <= 0;
    end
    else begin
        //If the slave is ready & wr_en is high, write into the reg file
        if(wr_en && slave_rdy)
            slave_reg_file[reg_addr[3:0]] <= wr_data[7:0];
            
        //If a transaction has complete analyze the data from the MOSI line
        if(rx_done) begin
            //If spi write flag is set, write data to the register file
            if(spi_wr_en) begin
                slave_reg_file[write_addr[3:0]] <= mosi_data;
                spi_wr_en <= 1'b0;
            end         
            //If the msb of the mosi data is set, store the address so we know where to write the data 
            //on the next transmission
            else if(mosi_data[7]) begin
                write_addr <= mosi_data;
                spi_wr_en <= 1'b1;
            end
            //If the above instances are not met, output the file value
            else
                miso_byte <= slave_reg_file[mosi_data[3:0]];
        end
    end       
end

assign wr_en = cs && write;

/**** Ouput Signals ****/
assign rd_data = {23'h0, slave_rdy, slave_reg_file[reg_addr]};

endmodule
