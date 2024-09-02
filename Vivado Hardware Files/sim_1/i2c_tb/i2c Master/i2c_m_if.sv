`ifndef I2C_IF
`define I2C_IF

/*
 * This interface allow for the driver, monitor & any other classes to interact with the 
 * hardware (DUT).
*/
interface i2c_m_if(input logic clk, input logic reset, inout tri scl, inout tri sda);
    //Slot Interface 
    logic cs;
    logic read;
    logic write;
    logic [4:0] reg_addr;
    logic [31:0] wr_data;
    logic [31:0] rd_data;
    
   
endinterface : i2c_m_if

`endif //I2C_IF