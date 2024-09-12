`timescale 1ns / 1ps

/* This wrapping circuit interfaces the i2c slave controller with the microblaze CPU.
 * The wrapping circuit allows the CPU to interact with the register file, thereby allowing
 * users to write custom software to populate the values. This means users can write software
 * that will regularly populate the register file with data from other peripherals and this data 
 * can therefore be read by an i2c master. The i2c master can also write to this register file.
 * Note : The I2C Slave register file address auto increments on burst reads but not writes.
 * Note : This i2c slave does not suppoer clock stretching.
 */ 
module i2c_slave_wrapper
#(
    parameter REG_DEPTH = 16,       //Register file depth (in words)
    parameter REG_WIDTH = 8         //Register file width (in bits)
)
(
    input clk, reset,
    //Slot Interface 
    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] reg_addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,
    /* I2C Interface */
    input logic i_scl,                           //Serial clock from i2c master
    inout tri sda                                //Serial data line    
);

//Slave address for master to interact with this module
localparam SLAVE_ADDR = 7'b0001000;
localparam ADDR_WIDTH = $clog2(REG_DEPTH);

//Init I2C slave controller
i2c_slave_controller i2c_slave(.clk(clk), .reset(reset), 
                               .i_file_data(data_out), .o_file_data(data_in), 
                               .o_i2c_data_valid(i2c_done), .o_i2c_ready(i2c_rdy), .o_rd_wr_bit(read_write),
                               .o_i2c_addr_set(slave_addr_rec), .i_scl(i_scl), .sda(sda));
 
/* Signal Declarations */
logic [REG_WIDTH-1:0] reg_file [REG_DEPTH-1:0];     //I2C slave register file
logic [REG_WIDTH-1:0] data_in, data_out;            //Registers used for the reg file to interact with i2c slave
logic [ADDR_WIDTH-1:0] addr_ptr;                    //Stores address of reg file to read/write from
logic i2c_done, i2c_rdy, read_write;                //Flags that will control how i2c controller interacts with wrapper
logic wr_en;     
logic addr_rec;                                     //indciates whether the respective address to write/read from has been recieved & slave addr                                   
logic slave_addr_rec;                               //Signal indicating slave address has been received

/** Logic to acces Reg File from processor **/
always_ff @(posedge clk) begin
    if(reset) begin
        addr_rec <= 0;
        data_out <= 0;
        addr_ptr <= 0;     
        for(int i = 0; i < REG_DEPTH; i++)
            reg_file[i] <= 0;    
    end else begin
        //Before writing a value ensure that the i2c slave is not undergoing a transaction
        if(wr_en && i2c_rdy)
            reg_file[reg_addr[3:0]] <= wr_data[7:0];   
            
        if(addr_rec && read_write)
            addr_rec <= 0; 
        
        //When a data transmission is complete check if the data was the first byte transmitted
        //which would have been the slave address
        //Note: I implemented a "flattened" if/elseif conditional statement rather than a series of
        //      nested if statements to reduce the possible the length of the critical path
        if(slave_addr_rec) begin            
            if(addr_rec && ~read_write) begin
            	reg_file[addr_ptr] <= data_in;
            	addr_rec <= 0;
            end else if(~addr_rec && read_write) begin
                addr_ptr <= addr_ptr + 1;
                addr_rec <= 1;
            end else begin
            	addr_ptr <= data_in[ADDR_WIDTH-1:0];
            	addr_rec <= 1;
            end            
        end
        
        data_out <= reg_file[addr_ptr];                
    end           
end    

//Logic to control writing into the reg file from Microblaze                           
assign wr_en = cs && write;                               
/* Ouput Logic */
assign rd_data = {22'h0, i2c_done, i2c_rdy, reg_file[reg_addr[3:0]]};

endmodule
