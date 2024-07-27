`timescale 1ns / 1ps


module timer_core_tb;

//local vars
localparam COUNTER_WIDTH = 48;
localparam CTRL_REG = 5'b00;
localparam PERIOD_LOW = 5'b01;
localparam PERIOD_HIGH = 5'b10;
localparam COUNTER_LOW = 5'b11;
localparam COUNTER_HIGH = 5'b100;

//Signals 
logic clk, reset;
//Microblaze Signals
logic cs, read, write;
logic [4:0] reg_addr;
logic [31:0] wr_data;
logic [31:0] rd_data;
//Peripheral Signals
logic counter_done;

//Module Instantiation
Timer_Core#(.COUNTER_WIDTH(COUNTER_WIDTH)) uut
(
    .clk(clk),
    .reset(reset),
    .cs(cs),
    .read(read),
    .write(write),
    .reg_addr(reg_addr),
    .wr_data(wr_data),
    .rd_data(rd_data),
    .counter_done(counter_done)
);

//Init clock with 10ns period
always #5 clk = ~clk;

//Task to write to specified reegisters
task timer_write(logic [4:0] register_addr, int value);
begin
    //set cs and write 
    cs = 1;
    write = 1;
    #15;
    //Set the register value
    reg_addr = register_addr;
    #15;
    //Write the value into the address
    wr_data = value;
    #15;
    //Reset cs and write
    cs = 0;
    write = 0;
end
endtask

//task simulating a read to the counter register
task timer_read(logic [4:0] register_addr);
begin
    //Set chip select and read 
    cs = 1;
    read = 1;
    #15;
    //Select address to read from (can only read from register 3 & 4)
    reg_addr = register_addr;
    #15;
    //Reset signals
    cs = 0;
    read = 0;
end
endtask

//Testing 
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
    
    //Test 1: Timer in continous mode with defualt period
    //Set bit 1 in control register (go)
    timer_write(CTRL_REG, 32'h1);
    #10;
    timer_read(COUNTER_LOW);
    #1000;
    
    //Test 2: Stop timer, clear the value and set period - still in cont mode
    //Clear the go bit
    timer_write(CTRL_REG, 32'h0);
    #20;
    //Clear the counter register
    timer_write(CTRL_REG, 32'h2);
    #20;
    //Write into the period register
    timer_write(PERIOD_LOW, 32'h8); //Setting 80ns period
    #20;
    timer_write(PERIOD_HIGH, 32'h0);  //Clearing the higher bits for the period register
    #20;
    //Clear the period set bit and set the go bit
    timer_write(CTRL_REG, 32'h1);
    #20;
    timer_read(COUNTER_LOW);
    #1000;
    
    //Test 3: One shot timer with 80 ns period
    //Stop go and clear the counter
    timer_write(CTRL_REG, 32'h2);
    #20;
    //Set to one shot mode
    timer_write(CTRL_REG, 32'h4);
    #20;
    //Set the go bit
    timer_write(CTRL_REG, 32'h5);
   
    #100;
    
    //Test 4: Reset timer, keep in one-shot mode and change period
    //Stop go and clear the counter
    timer_write(CTRL_REG, 32'h2);
    #20;
    //Set to one shot mode
    timer_write(CTRL_REG, 32'h4);
    #20;
    //Chnage period to 300ns
    timer_write(PERIOD_LOW, 32'h1E);
    #20;
    timer_write(PERIOD_HIGH, 32'h0);
    #20;
    //Set the go bit
    timer_write(CTRL_REG, 32'h5);
    #1000;
    
    $finish;    
end

endmodule
