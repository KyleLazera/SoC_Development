`timescale 1ns / 1ps

module gpio_core_tb;

localparam DATA_WIDTH = 12;
localparam IN = 0;
localparam OUT = 1;

//Signals 
logic clk, reset;
//Microblaze Signals
logic cs, read, write;
logic [4:0] reg_addr;
logic [31:0] wr_data;
logic [31:0] rd_data;
//Peripheral Signals
logic [DATA_WIDTH-1:0] data_out;
logic [DATA_WIDTH-1:0] data_in;

//Module Inst.
gpio_core #(.DATA_WIDTH(DATA_WIDTH))  gpio_uut
(
    .clk(clk),
    .reset(reset),
    .cs(cs),
    .read(read),
    .write(write),
    .reg_addr(reg_addr),
    .wr_data(wr_data),
    .rd_data(rd_data),
    .data_out(data_out),
    .data_in(data_in)
);

//Clock Initialization - 10ns period
always #5 clk = ~clk;

//Task to set the GPIO to output mode:
task GPIO_mode(bit sel);
begin
//Set cs and write data
    cs = 1;
    write = 1;
    //Select register address 0x3 (control reg)
    reg_addr = 4'b0011;
    #10;
    //Determine if mode is input or output
    if(sel == 1)
        wr_data = 32'h1;
    else
        wr_data = 32'h0;
    #30;
    //Reset values
    write = 0;
    cs = 0;        
end
endtask

//Task simulating using output of GPIO Core
task GPIO_Output(int data);
begin
    //Set the CS and write bit 
    cs = 1;
    write = 1;
    //Set reg addr to output register
    reg_addr = 4'b0010;
    //Write data to register
    wr_data = data;
    //Delay giving some time for data propogation
    #100;
    cs = 0;
    write = 0;
end
endtask

//Todo: Create seperate task that sets GPIo to input
//Task simulating using the input of GPIO Core
task GPIO_Input(int input_data);
begin
    //Set teh cs
    cs = 1;
    read = 1;
    //Simulate input data from external source
    data_in = input_data;
    //Delay giving some time for data propogation
    #100;
    cs = 0;
    read = 0;
end
endtask

initial begin
    //Init Signals - Start with reset High
    reset = 1;
    clk = 0;
    cs = 0;
    read = 0;
    write = 0;
    reg_addr = 0;
    wr_data = 0;
    
    //Delay for 50ns and turn reset off
    #50;
    reset = 0;
    
    //Set GPIO to output mode first
    GPIO_mode(OUT);
    //Simulate random output values (Lighting Up LEDs)
    GPIO_Output(32'h80);
    GPIO_Output(32'h78);
    GPIO_Output(32'hA9);
    //Set GPIO to Input mode
    GPIO_mode(IN);
    //Simulate input values (Reading switches)
    GPIO_Input(32'h85);
    GPIO_Input(32'h48);
    GPIO_Input(32'hFF);
    $finish;
    
end


endmodule
