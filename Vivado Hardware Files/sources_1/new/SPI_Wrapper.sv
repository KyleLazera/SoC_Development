`timescale 1ns / 1ps

/*
* This is the wrapping circuit for the SPI Module and allows interaction with the Microblaze MCS.
* The architecture of this core is as follows:
* Register 0x00: (ready only)
*   bit 8: SPI ready Status
*   bit 7 - 0: 8-bit value recieved 
* Register 0x1: (Write only)
*   bit S - 0: slave select signals to control S slave devices
* Register 0x2: (write only) - Writing into this register also starts the SPI 
*   bit 7 - 0: 8 bit value to write to the SPI slave
* Register 0x3: (write only)
*   bit 17: clock phase value
*   bit 16: clock polarity value
*   bit 15 - 0: dvsr value
*/
module SPI_Wrapper
#(parameter S = 2)      //# of slave devices to acces
(
    input logic clk, reset,
    //Slot Interface 
    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] reg_addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,
    //SPI Signals
    output logic spi_clk,
    output logic spi_mosi,
    output logic [S-1:0] spi_ss_n,
    input logic spi_miso
);

//Signal Declaration
logic wr_en, wr_ss, wr_spi, wr_ctrl;
logic [17:0] ctrl_reg;
logic [7:0] spi_out;
logic [S-1:0] ss_n_reg;
logic spi_ready;

//Module Instantiation
spi_master spi_master_controller (.clk(clk), .reset(reset), .din(wr_data[7:0]),
                                          .dvsr(ctrl_reg[15:0]), .start(wr_spi), .cpha(ctrl_reg[17]),
                                          .cpol(ctrl_reg[16]), .dout(spi_out), .spi_done_tick(), .ready(spi_ready),
                                          .miso(spi_miso), .mosi(spi_mosi), .sclk(spi_clk));

always_ff @(posedge clk, posedge reset) begin
    if(reset) begin
        ctrl_reg <= 17'h00200;      //Setting default dvsr to 512 (50KHz spi clk)
        ss_n_reg <= {S{1'b1}};      //Set all slave select bits to 1 (deassert)
    end
    else begin
        //If wr_ctrl is high, write data to the control reg
        if(wr_ctrl)
            ctrl_reg <= wr_data[17:0];
        //If wr_ss is high write data to slave select
        if(wr_ss)
            ss_n_reg <= wr_data[S-1:0];
    end
end

//Write enable Logic
assign wr_en = cs && write;
assign wr_ss = wr_en && (reg_addr == 5'b00001);
assign wr_spi = wr_en && (reg_addr == 5'b00010);
assign wr_ctrl = wr_en && (reg_addr == 5'b00011);
//Slave select output logic
assign spi_ss_n = ss_n_reg;
//Read output logic
assign rd_data = {23'h0, spi_ready, spi_out};

endmodule
