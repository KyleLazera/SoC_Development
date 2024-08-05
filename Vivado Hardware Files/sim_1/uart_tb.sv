`timescale 1ns / 1ps


module uart_tb;

typedef enum logic [4:0]
             {CTRL_REG = 5'b00000,
              READ_REG = 5'b00010, 
              WRITE_REG = 5'b00011
              }uart_reg;

//Variable Declarations
localparam DATA_BITS = 8;       //Max number of data bits - used for calculating delays
localparam DVSR_WIDTH = 11;
localparam CLK_PERIOD = 10;

//variables for setting UART specs
localparam DATA_BITS_7 = 32'h00008000;
localparam DATA_BITS_8 = 32'h00000000;

//Input Signals
logic clk, reset;
//Slot Interface
logic cs;
logic read;
logic write;
logic [4:0] reg_addr;
logic [31:0] wr_data;
logic [31:0] rd_data;
//UART Signals
logic tx;
logic rx;      

logic [10:0] dvsr;           

//Module Instantiation
uart_core #(.FIFO_DEPTH(2)) uart_uut(.*);

//Instantiate Clock module
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

//task to set the data width for the UART
//When setting this value make sure to take into account the dvsr vaue
task set_data_width(input logic [31:0] width);
begin
    cs = 1;
    write = 1;
    reg_addr = CTRL_REG;
    wr_data = width;
    @(posedge clk);
    cs = 0;
    write = 0;
end
endtask

//Task to set the dvsr based off desired baud rate
task set_baud(int baud_rate, output logic [31:0] dvsr_val);
begin
    //Caluclate dvsr based off baud rate
    dvsr_val = (100000000/(16 * baud_rate)) - 1;
    dvsr = dvsr_val;
    //Set cs & write pin & write into dvsr register
    @(posedge clk);
    reg_addr = CTRL_REG;
    cs = 1;
    write = 1;
    wr_data = dvsr_val;
    //disable cs and write pin
    @(posedge clk);
    cs = 0;
    write = 0;
end    
endtask

//Task To write data to UART (simulating tx from processor to the serial port)
task write_uart(input logic [DATA_BITS-1:0] data);
begin
    //Enable the write & cs and set the correct addr
    @(posedge clk);
    cs = 1;
    write = 1;
    reg_addr = WRITE_REG;
    wr_data = data;
    @(posedge clk);
    cs = 0;
    write = 0;
end
endtask

//Read from UART
task read_uart(output logic [DATA_BITS-1:0] data);
begin
    @(posedge clk);
    cs = 1;
    read = 1;
    reg_addr = READ_REG;
    data = rd_data;
    @(posedge clk);
    cs = 0;
    read = 0;
end
endtask

//Task to simulate sending data via the rx pin to the uart
task send_rx_data(int num_data, input logic [DATA_BITS-1:0] rx_data);
begin
    //Initialize the start bit of the frame
    rx = 0;
    //Wait for a baud period - oversampling is set to 16 so we need 16 ticks
    #(dvsr * 10 * 16);
    
    //Send the data start with the lsb
    for(int i = 0; i < num_data; i++)
    begin
        rx = rx_data[i];
        #(dvsr * 10 * 16);
    end
    
    //Send the stop bit
    rx = 1;
    #(dvsr * 10);
end
endtask

//Testing UUT
initial begin
    //variable declaration
    logic [DATA_BITS-1:0] rx_data;
    logic [31:0] ctrl_reg_val;

    //Reset the circuit and delay 
    reset = 1;
    cs = 0;
    read = 0;
    write = 0;
    rx = 1; // rx must start high to indicate idle
    wr_data = 0;
    dvsr = 0;
    #50;
    
    //Turn off reset and set the baud rate
    reset = 0;
    set_baud(9600, ctrl_reg_val);     
    #20;
    
    /************************** Writing - Test Case 1 ****************************
    //Write 7 bits of data to the UART
    set_data_width((ctrl_reg_val | DATA_BITS_7));
    write_uart(8'h33);
    #(dvsr * 1600); //Random value to send all the data
    write_uart(8'h7B);
    #(dvsr * 1600); //Random value to send all the data
    write_uart(8'h12);
    #(dvsr * 1600); //Random value to send all the data
    write_uart(8'h45);
    #(dvsr * 1600); //Random value to send all the data
    
    /************************* Writing - Test Case 2 *****************************
    //Swicth back to 8 data bits to send
    set_data_width((ctrl_reg_val & ~DATA_BITS_7));
    write_uart(8'hAC);
    #(dvsr * 1600); //Random value to send all the data
    write_uart(8'h91);
    #(dvsr * 1600); //Random value to send all the data
    
    /************************** Reading - Test Case 1 ****************************/
    //Send data via the rx pin & read the data after a small delay
    //Read 8 Bits of data 
    send_rx_data(8, 8'h32);
    #((dvsr * 10) * (DATA_BITS + 2)); // Wait for the entire frame (1 start bit + 8 data bits + 1 stop bit)
    read_uart(rx_data);
    assert(rx_data == 8'h32) else $fatal("Data mismatch: expected 8'h32, got %h", rx_data);
    
    send_rx_data(8, 8'h57);
    #((dvsr * 10) * (DATA_BITS + 2)); // Wait for the entire frame (1 start bit + 8 data bits + 1 stop bit)
    read_uart(rx_data);
    assert(rx_data == 8'h57) else $fatal("Data mismatch: expected 8'h57, got %h", rx_data);
    
    send_rx_data(8, 8'hA5);
    #((dvsr * 10) * (DATA_BITS + 2)); // Wait for the entire frame (1 start bit + 8 data bits + 1 stop bit)
    read_uart(rx_data);
    assert(rx_data == 8'hA5) else $fatal("Data mismatch: expected 8'h32, got %h", rx_data);
    
    //Read 7 bits of data 
    set_data_width((ctrl_reg_val | DATA_BITS_7));
    
    send_rx_data(7, 8'h41);
    #((dvsr * 10) * (DATA_BITS + 2)); // Wait for the entire frame (1 start bit + 8 data bits + 1 stop bit)
    read_uart(rx_data);
    assert(rx_data == 7'h41) else $fatal("Data mismatch: expected 8'h41, got %h", rx_data);
    
    send_rx_data(7, 8'h67);
    #((dvsr * 10) * (DATA_BITS + 2)); // Wait for the entire frame (1 start bit + 8 data bits + 1 stop bit)
    read_uart(rx_data);
    assert(rx_data == 7'h67) else $fatal("Data mismatch: expected 8'h67, got %h", rx_data);
    
    send_rx_data(7, 8'h3A);
    #((dvsr * 10) * (DATA_BITS + 2)); // Wait for the entire frame (1 start bit + 8 data bits + 1 stop bit)
    read_uart(rx_data);
    assert(rx_data == 7'h3A) else $fatal("Data mismatch: expected 8'h3A, got %h", rx_data);
    
    /************************* Reading - Test case 2 ******************************/
    //Send muldtiple bytes of data before reading them
    send_rx_data(7,8'h79);
    #((dvsr * 10) * (DATA_BITS + 2)); // Wait for the entire frame (1 start bit + 8 data bits + 1 stop bit)    
    send_rx_data(7, 8'h12);
    #((dvsr * 10) * (DATA_BITS + 2)); // Wait for the entire frame (1 start bit + 8 data bits + 1 stop bit)    
    send_rx_data(7, 8'h6B);
    #((dvsr * 10) * (DATA_BITS + 2)); // Wait for the entire frame (1 start bit + 8 data bits + 1 stop bit)    
    send_rx_data(7, 8'h01);
    #((dvsr * 10) * (DATA_BITS + 2)); // Wait for the entire frame (1 start bit + 8 data bits + 1 stop bit)                
    
    //Read from the UARt to clear the FIFO
    read_uart(rx_data);
    assert(rx_data == 8'h79) else $fatal("Data mismatch: expected 8'h79, got %h", rx_data);
    read_uart(rx_data);
    assert(rx_data == 8'h12) else $fatal("Data mismatch: expected 8'h12, got %h", rx_data);
    read_uart(rx_data);
    assert(rx_data == 8'h6B) else $fatal("Data mismatch: expected 8'h6B, got %h", rx_data);
    read_uart(rx_data);
    assert(rx_data == 8'h01) else $fatal("Data mismatch: expected 8'h01, got %h", rx_data);           
    
    $finish;     
end
endmodule
