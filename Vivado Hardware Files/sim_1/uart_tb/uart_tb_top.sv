`timescale 1ns / 1ps
`include "uart_inst.sv"

module uart_tb_top;

    logic clk, reset;
    //Inst clock with 10 ns period
    always #5 clk = ~clk;
    
    //Create instance(s) of virtual interface
    uart_itf uart_1_if(clk, reset, "UART 1");
    uart_itf uart_2_if(clk, reset, "UART 2");
    
    //Signal Declarations
    logic tx, rx;
        
    //Instantiate module(s)            
    uart_wrapper#(.DATA_BITS(8), .FIFO_WIDTH(8), .OVRSAMPLING(16), .DVSR_WIDTH(11)) uart_1 
                 (.clk(clk), .reset(reset), .rd_uart(uart_1_if.rd_uart), .wr_uart(uart_1_if.wr_uart), .rx(rx), .data_bit(uart_1_if.data_bit),
                 .sb_ticks(uart_1_if.sb_ticks), .parity_en(uart_1_if.parity_en), .parity_pol(uart_1_if.parity_pol), .wr_data(uart_1_if.wr_data), .dvsr(uart_1_if.dvsr),
                 .tx_full(uart_1_if.tx_full), .rx_empty(uart_1_if.rx_empty), .parity_err(uart_1_if.parity_err), .frame_err(uart_1_if.frame_err), .overflow_err(uart_1_if.overflow_err),
                 .tx(tx), .rd_data(uart_1_if.rd_data));
    
    uart_wrapper#(.DATA_BITS(8), .FIFO_WIDTH(8), .OVRSAMPLING(16), .DVSR_WIDTH(11)) uart_2
                 (.clk(clk), .reset(reset), .rd_uart(uart_2_if.rd_uart), .wr_uart(uart_2_if.wr_uart), .rx(tx), .data_bit(uart_2_if.data_bit),
                 .sb_ticks(uart_2_if.sb_ticks), .parity_en(uart_2_if.parity_en), .parity_pol(uart_2_if.parity_pol), .wr_data(uart_2_if.wr_data), .dvsr(uart_2_if.dvsr),
                 .tx_full(uart_2_if.tx_full), .rx_empty(uart_2_if.rx_empty), .parity_err(uart_2_if.parity_err), .frame_err(uart_2_if.frame_err), .overflow_err(uart_2_if.overflow_err),
                 .tx(rx), .rd_data(uart_2_if.rd_data));
                 
    /**** Test Instances *****/
    //UART specs: Data: 8, Stop: 1, Pairty: none, baud : 9600 
    uart_test uart_def_test;     
    //UART Specs: Data: 7, Stop: 1, Parity: none, baud: 9600
    uart_test test_2;
    uart_config test_2_cfg; 
    //UART Specs: Data: 7, Stop: 2, Parity: Even, baud: 115200
    uart_test test_3;
    uart_config test_3_cfg;    
    //UART Specs: Data 8, Stop: 1.5, Parity: Odd, baud: 115200  
    uart_test test_4;
    uart_config test_4_cfg; 
        
    initial begin  
        clk = 0;
        
        //Reset the circuit
        reset = 1'b1;
        #10;
        reset = 1'b0;
        
        /********* Test 1**********/
        uart_def_test = new;
        uart_def_test.run(uart_1_if, uart_2_if);
        #100; 
        
        /******** Test 2 **********/
        test_2_cfg = new(9600, 1'b1, 1'b0, 1'b0, 2'b0);
        test_2 = new(test_2_cfg);
        test_2.run(uart_1_if, uart_2_if);
        #100
        
        /********** Test 3 ***********/
        test_3_cfg = new(115200, 1'b1, 1'b1, 1'b1, 2'b10);
        test_3 = new(test_3_cfg);
        test_3.run(uart_1_if, uart_2_if);
        #100;
        
        /******** Test 4 ************/
        test_4_cfg = new(115200, 1'b0, 1'b1, 1'b0, 2'b01);
        test_4 = new(test_4_cfg);
        test_4.run(uart_1_if, uart_2_if);
        #100;
        
        //Add more tests here...
        
        $finish;     
    end 

endmodule
