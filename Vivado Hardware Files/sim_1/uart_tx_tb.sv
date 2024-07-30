`timescale 1ns / 1ps

/*Testbench to test the uart transmission module*/
module uart_tx_tb;

//Variables
localparam DATA_BITS = 8;

//Signal declarations
logic clk, reset;
logic s_tick;              
logic tx_start;               
logic [DATA_BITS-1:0] din;    
logic tx_done;              
logic tx;                

//Module Instantiation
uart_tx#(.DATA_BITS(DATA_BITS), .STOP_BITS(1), .OVRSAMPLING(16)) uut (.*);

baud_gen#(.DVSR_WIDTH(11)) baud_uut(.*, .dvsr(650), .tick(s_tick));

//Clock with 10ns period
always #5 clk = ~clk;


//Task to send data 
task write_uart(input logic [DATA_BITS-1:0] in_val);
begin
    tx_start = 1'b1;
    din = in_val;
    #((6500 * 16) * (DATA_BITS + 2));
    tx_start = 0;
end
endtask

initial begin
    //Initialize with a reset
    clk = 0;
    reset = 1;
    tx_start = 0;
    s_tick = 0;
    din = 0;
    #50;
    
    //Clear reset bit
    reset = 0;
    #20;
    
    //Simulate a series of writes to the UART
    write_uart(8'h48);
    #100;
    
    write_uart(8'h34);
    #100;
    
    write_uart(8'h71);
    #100;
    
    write_uart(8'h33);
    #100;
    
    $finish;
end

endmodule
