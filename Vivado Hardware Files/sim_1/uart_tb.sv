`timescale 1ns / 1ps

module uart_tb;

//Variable Declarations
localparam DATA_BITS = 8;
localparam DVSR_WIDTH = 11;

//Signals
logic clk, reset;
logic rd_uart, wr_uart;                    
logic rx;                                     
logic [DATA_BITS-1:0] wr_data;                
logic [DVSR_WIDTH-1:0] dvsr;                  
logic tx_full, rx_empty;                     
logic tx;                                    
logic [DATA_BITS-1:0] rd_data;                

//Module Instantiation
uart_wrapper#(.DATA_BITS(DATA_BITS), .DVSR_WIDTH(DVSR_WIDTH), .STOP_BITS(1), .FIFO_WIDTH(2), .OVRSAMPLING(16)) uart_uut (.*);

//Init clock with 10 ns period
always #5 clk = ~clk;

//Task to set the dvsr based on desired baud rate
task set_dvsr(int baud_rate);
begin
    //Equation to used to determine the dvsr
    dvsr = ((100000000)/(16 * baud_rate)) - 1;
end
endtask

//Task To write to the UART
task write_uart(input logic [DATA_BITS-1:0] input_val);
begin
    //Enable the FIFO Buffer
    wr_uart = 1;
    //Write value
    wr_data = input_val;
    #10;
    //Disable FIFO to prevent re writing the same data into it        
    wr_uart = 0;
    #30;
end
endtask

//Read from UART
task read(input logic [DATA_BITS-1:0] input_data);
begin
    rd_uart = 1;
    #10;
    for(int i =0; i < DATA_BITS; i++)
    begin
        rx = input_data[0];
        input_data = input_data >> 1;
        #(dvsr * 10);        
    end
    
    rd_uart = 0;
    #30;
end
endtask

initial begin
    //Reset the circuit and delay 
    clk = 0;
    reset = 1;
    rd_uart = 0;
    wr_uart = 0;
    rx = 0;
    wr_data = 0;
    dvsr = 0;
    #50;
    
    //Turn off reset and set the baud rate
    reset = 0;
    set_dvsr(9600);     //Dvsr should be set to 650
    #20;
    
    //Write to the UART (tx Buffer 4 values to fill it up)
    write_uart(8'h48);
    #100;
    
    write_uart(8'h34);
    #100;
    
    write_uart(8'h71);
    #100;
    
    write_uart(8'h33);
    #100;
    
    //Read from UART
    read(8'h47);
    #50;
    
    read(8'h32);
    #50;
    
    read(8'h01);
    #50;
    
    $finish;     
end
endmodule
