`timescale 1ns / 1ps


module uart_tb;

typedef enum logic [4:0]
             {CTRL_REG = 5'b00000,
              STATUS_REG = 5'b00001,
              READ_REG = 5'b00010, 
              WRITE_REG = 5'b00011
              }uart_reg;

//Variable Declarations
localparam DATA_BITS = 8;       //Max number of data bits
localparam DVSR_WIDTH = 11;     //Max dvsr width
localparam CLK_PERIOD = 10;     //Clock period in ns

//variables for setting UART specs
localparam PARITY_EN = 32'h00000800;
localparam PARITY_DISABLE = 32'h0;
localparam PARITY_EVEN = 32'h00001000;
localparam PARITY_ODD = 32'h00;
localparam DATA_BITS_7 = 32'h00008000;
localparam DATA_BITS_8 = 32'h00000000;
localparam STOP_BITS_1 = 32'h00000000;
localparam STOP_BITS_1_5 = 32'h00002000;
localparam STOP_BITS_2 = 32'h00004000;

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

/***************************************** Tasks **********************************/

//Task used to read teh status register
task rd_status_reg();
begin
    logic [31:0] reg_val;
    
    @(posedge clk);
    cs = 1;
    reg_addr = STATUS_REG;
    read = 1;
    @(posedge clk);
    reg_val = rd_data;
    $display("Status reg: %b", reg_val);
    cs = 0;
    read = 0;
    reg_addr = READ_REG;
    
    if(reg_val & 32'h1)
        $display("Parity Error.");
end
endtask

//task to set the data width for the UART
//When setting this value make sure to take into account the dvsr vaue
task set_ctrl_reg(input logic [31:0] width);
begin
    //Clear the control reg input
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

//Signals processor to remove/read data from the rx FIFO Buffer
task read_uart(output logic [DATA_BITS-1:0] data);
begin
    @(posedge clk);
    cs = 1;
    read = 1;
    reg_addr = READ_REG;
    data = rd_data;
    $display("Data read: %h", data);
    @(posedge clk);
    cs = 0;
    read = 0;
end
endtask

//Task to simulate sending data via the rx pin to the uart
task send_rx_data(int num_data, int stop_bits, int parity, input logic [DATA_BITS-1:0] rx_data);
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
    
    //If parity input is high, then generate a random parity bit (1 or 0)
    if(parity)
    begin
        rx = $urandom_range(0,1);
        #(dvsr * 10 * 16);
    end
    
    //Send the stop bit
    rx = 1;
    #(dvsr * 10 * 16 * stop_bits);
    
    #100; rd_status_reg();            //Right after data frame has been sent, check to see if there are any status reg errors
    
end
endtask

//Task to validate the Tx Data
task test_tx_data(int num_data, output logic [8:0] tx_data);
begin
    //Add initial delay so we sample after the start bits (start sampling on the first data bit)
    #(dvsr * 10 * 23);
    
    for(int i = 0; i < num_data; i++)
    begin
        tx_data[i] = tx;
        #(dvsr * 10 * 16);
    end
end
endtask

/*********************************** Test bench ***************************************/

//Testing UUT
initial begin
    //variable declaration
    logic [DATA_BITS-1:0] rx_data;
    logic [31:0] ctrl_reg_val, status_reg;
    logic [8:0] tx_data;

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
    
    /************************** Writing - Test Case 1 ****************************/
    /********UART Specs: 7 Data Bits, Even Parity, 1.5 Stop Bits*********/
    set_ctrl_reg((ctrl_reg_val | DATA_BITS_7 | STOP_BITS_1_5 | PARITY_EN | PARITY_EVEN)); 
    
    write_uart(8'h33);
    test_tx_data(8, tx_data);
    assert(tx_data[7:0] == 8'b00110011) else $fatal("Data tx mismatch: value expected 8'b00110011, value was %b", tx_data);//Include parity in this value to test
    #(dvsr * 160 * 2);  //Ensure enough time for all stop bits to be sent (max 2 stop bits and 32 ticks)
    
    write_uart(8'h7B);
    test_tx_data(8, tx_data);
    assert(tx_data[7:0] == 8'b01111011) else $fatal("Data tx mismatch: value expected 8'b01111011, value was %b", tx_data);
    #(dvsr * 160 * 2);  
    
    write_uart(8'h12);
    test_tx_data(8, tx_data);
    assert(tx_data[7:0] == 8'b00010010) else $fatal("Data tx mismatch: value expected 8'b00010010, value was %b", tx_data);
    #(dvsr * 160 * 2); 

    write_uart(8'h45);
    test_tx_data(8, tx_data);
    assert(tx_data[7:0] == 8'b11000101) else $fatal("Data tx mismatch: value expected 8'b11000101, value was %b", tx_data);
    #(dvsr * 160 * 2);  

    
    /********UART Specs: 8 data bits, odd parity, 2 stop bits********/
    set_ctrl_reg((ctrl_reg_val | DATA_BITS_8 | STOP_BITS_2 | PARITY_EN | PARITY_ODD));
    
    write_uart(8'hAC);
    test_tx_data(9, tx_data);
    assert(tx_data == 9'b110101100) else $fatal("Data tx mismatch: value expected 9'b110101100, value was %b", tx_data);
    #(dvsr * 160 * 2);  
    
    write_uart(8'h91);
    test_tx_data(9, tx_data);
    assert(tx_data == 9'b010010001) else $fatal("Data tx mismatch: value expected 9'b010010001, value was %b", tx_data);
    #(dvsr * 160 * 2);  
    
    write_uart(8'hD7);
    test_tx_data(9, tx_data);
    assert(tx_data == 9'b111010111) else $fatal("Data tx mismatch: value expected 9'b111010111, value was %b", tx_data);
    #(dvsr * 160 * 2);  
    
    write_uart(8'h86);
    test_tx_data(9, tx_data);
    assert(tx_data == 9'b010000110) else $fatal("Data tx mismatch: value expected 9'b010000110, value was %b", tx_data);
    #(dvsr * 160 * 2);  
    
    /***********UART Specs: 8 data bits, No Parity, 1 stop bits***********/
    set_ctrl_reg((ctrl_reg_val | DATA_BITS_8 | STOP_BITS_1 | PARITY_DISABLE));
    
    write_uart(8'hBD);
    test_tx_data(8, tx_data);
    assert(tx_data[7:0] == 8'hBD) else $fatal("Data tx mismatch: value expected 8'hBD , value was %h", tx_data);
    #(dvsr * 160 * 2);  
    
    write_uart(8'h18);
    test_tx_data(8, tx_data);
    assert(tx_data[7:0] == 8'h18) else $fatal("Data tx mismatch: value expected 8'h18, value was %h", tx_data);
    #(dvsr * 160 * 2);  
    
    write_uart(8'h94);
    test_tx_data(8, tx_data);
    assert(tx_data[7:0] == 8'h94) else $fatal("Data tx mismatch: value expected 8'h94, value was %h", tx_data);
    #(dvsr * 160 * 2);  
    
    write_uart(8'h34);
    test_tx_data(8, tx_data);
    assert(tx_data[7:0] == 8'h34) else $fatal("Data tx mismatch: value expected 8'34, value was %h", tx_data);
    #(dvsr * 160 * 2);  
    
    /************************** Reading - Test Case 2 ****************************/
    /************ UART Specs: 8 data bits, 2 stop bits, No Parity *********/
    set_ctrl_reg((ctrl_reg_val | DATA_BITS_8 | STOP_BITS_2 | PARITY_DISABLE));
    
    send_rx_data(8, 2, 0, 8'h32);
    #((dvsr * 10) * (DATA_BITS + 2)); // Wait for the entire frame to be sent
    read_uart(rx_data);
    assert(rx_data == 8'h32) else $fatal("Data rx mismatch: expected 8'h32, got %h", rx_data);
    
    send_rx_data(8, 2, 0, 8'h57);
    #((dvsr * 10) * (DATA_BITS + 2));
    read_uart(rx_data);
    assert(rx_data == 8'h57) else $fatal("Data rx mismatch: expected 8'h57, got %h", rx_data);
    
    send_rx_data(8, 2, 0, 8'hA5);
    #((dvsr * 10) * (DATA_BITS + 2));
    read_uart(rx_data);
    assert(rx_data == 8'hA5) else $fatal("Data rx mismatch: expected 8'h32, got %h", rx_data);
    
    /********** UART Specs: 7 data bits, 1.5 stop bits, no parity ***********/
    set_ctrl_reg((ctrl_reg_val | DATA_BITS_7 | STOP_BITS_1_5));
    
    send_rx_data(7, 1.5, 0, 8'h41);
    #((dvsr * 10) * (DATA_BITS + 2));
    read_uart(rx_data);
    assert(rx_data == 7'h41) else $fatal("Data rx mismatch: expected 8'h41, got %h", rx_data);
    
    send_rx_data(7, 1.5, 0, 8'h67);
    #((dvsr * 10) * (DATA_BITS + 2)); 
    read_uart(rx_data);
    assert(rx_data == 7'h67) else $fatal("Data rx mismatch: expected 8'h67, got %h", rx_data);
    
    send_rx_data(7, 1.5, 0, 8'h3A);
    #((dvsr * 10) * (DATA_BITS + 2));
    read_uart(rx_data);
    assert(rx_data == 7'h3A) else $fatal("Data rx mismatch: expected 8'h3A, got %h", rx_data); 
        
    /********** UART Specs: 7 data bits, 1 stop bit, even parity ***********/
    //Note: when using parity, we must simulate a parity bit being sent
    set_ctrl_reg((ctrl_reg_val | DATA_BITS_7 | STOP_BITS_1 | PARITY_EN | PARITY_EVEN));
    
    send_rx_data(7, 1, 1, 8'h49);
    #((dvsr * 10) * (DATA_BITS + 2)); 
    read_uart(rx_data);
    assert(rx_data == 7'h49) else $fatal("Data rx mismatch: expected 8'h49, got %h", rx_data);
    
    send_rx_data(7, 1, 1, 8'h58);
    #((dvsr * 10) * (DATA_BITS + 2));
    read_uart(rx_data);
    assert(rx_data == 7'h58) else $fatal("Data rx mismatch: expected 8'h58, got %h", rx_data);
    
    send_rx_data(7, 1, 1, 8'h79);
    #((dvsr * 10) * (DATA_BITS + 2)); 
    read_uart(rx_data);
    assert(rx_data == 7'h79) else $fatal("Data rx mismatch: expected 8'h79, got %h", rx_data);
   
    //Send multiple bytes of data before reading them
    //7 data bits and 1 stop bits
    set_ctrl_reg((ctrl_reg_val | DATA_BITS_7 | STOP_BITS_1 | PARITY_EN | PARITY_ODD)); 
       
    send_rx_data(7, 1, 1, 8'h79);
    #((dvsr * 10) * (DATA_BITS + 2)); 
     
    send_rx_data(7, 1, 1, 8'h12);
    #((dvsr * 10) * (DATA_BITS + 2)); 
     
    send_rx_data(7, 1, 1, 8'h6B);
    #((dvsr * 10) * (DATA_BITS + 2)); 
   
    send_rx_data(7, 1, 1, 8'h01);
    #((dvsr * 10) * (DATA_BITS + 2));        
    
    //Read from the UARt to clear the FIFO
    read_uart(rx_data);
    assert(rx_data == 8'h79) else $fatal("Data rx mismatch: expected 8'h79, got %h", rx_data);
    
    read_uart(rx_data);
    assert(rx_data == 8'h12) else $fatal("Data rx mismatch: expected 8'h12, got %h", rx_data);
    
    read_uart(rx_data);
    assert(rx_data == 8'h6B) else $fatal("Data rx mismatch: expected 8'h6B, got %h", rx_data);
    
    read_uart(rx_data);
    assert(rx_data == 8'h01) else $fatal("Data rx mismatch: expected 8'h01, got %h", rx_data); 
    
    //Overflow error check - fill up the rx fifo and try to write in more data before reading
    set_ctrl_reg((ctrl_reg_val | DATA_BITS_8 | STOP_BITS_1));
    
    //FIFO can hold up to 4 bytes of data
    for(int i = 0; i <  6; i++)
    begin
        send_rx_data(8, 1, 0, 8'h1);
        #((dvsr * 10) * (DATA_BITS + 2));
    end  
    
    //Frame Error Check - Sending 8 bits instead of 7
    set_ctrl_reg((ctrl_reg_val | DATA_BITS_7 | STOP_BITS_1));
        
    send_rx_data(8, 1, 0, 8'h73);
    #((dvsr * 10) * (DATA_BITS + 2));
    read_uart(rx_data);
    assert(rx_data == 7'h73) else $fatal("Data rx mismatch: expected 8'h73, got %h", rx_data);
    
    send_rx_data(8, 1, 0, 8'h62);
    #((dvsr * 10) * (DATA_BITS + 2)); 
    read_uart(rx_data);
    assert(rx_data == 7'h62) else $fatal("Data rx mismatch: expected 8'h62, got %h", rx_data);  
    
    $finish;     
end
endmodule