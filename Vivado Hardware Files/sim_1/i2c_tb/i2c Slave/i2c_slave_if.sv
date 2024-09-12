`ifndef _I2C_SLAVE_IF
`define _I2C_SLAVE_IF

/* This is the interface to interact with the DUT in the top level testbench */

interface i2c_slave_if(input logic clk, input logic reset);
    /* Wrapper Interface */
    logic cs;
    logic read;
    logic write;
    logic [4:0] reg_addr;
    logic [31:0] wr_data;
    logic [31:0] rd_data;    
    
    /* I2C Master Interface Signals */                              
    logic i_scl;                          
    tri sda;       
     
    //Intermediary signals to drive the i2c sda line
    logic sda_master_driver, sda_data;
    int burst_size;
    //Tri state buffer enable signaling
    assign sda = (sda_master_driver) ? sda_data : 1'bZ;
    

endinterface : i2c_slave_if


`endif //_I2C_SLAVE_IF
