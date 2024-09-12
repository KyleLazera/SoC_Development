`timescale 1ns / 1ps

/* This slave controller is responsible for recieving and interpreting data recieved from an i2c master.
 * It is based on an FSM, and interact with the wrapper module that enables it to have direct access to
 * a register file that it cna both read and write to based on the commands from the i2c master.
 */
module i2c_slave_controller
(
    input logic clk, reset,
    /* Signals to interact with Wrapper */
    input logic [7:0] i_file_data,               //Data from the register file
    output logic [7:0] o_file_data,              //Data to write to register file
    output logic o_i2c_ready,                    //Indciates the slave is not undergoing transaction  
    output logic o_i2c_data_valid,               //Indciates to wrapper when data read has completed
    output logic o_i2c_addr_set,                 //Flag indicating the slave address has been recieved
    output logic o_rd_wr_bit,                    //indciates to the wrapper whether it is a read or write operation               
    /* I2C Interface */
    input logic i_scl,                           //Serial clock from i2c master
    inout tri sda                                //Serial data line                                  
);

//Slave address for master to interact with this module
localparam SLAVE_ADDR = 7'b0001000;

//FSM State Declarations
typedef enum{IDLE,          //The initial state that the i2s slave waits in
            ADDRESS,        //State that recieves and verifies the address from the master
            SEND_ACK_1,     //Gives control of SDA to slave and drives low
            SEND_ACK_2,     //Identifies when ACK has been sent and to change state
            READ,           //Used to read incoming data on the sda line
            WRITE_1,        //Used to transmit the first 8 bits of data on the sda line
            WRITE_2,        //Used to have the slave release teh SDA line
            WRITE_3         //used to read the ACK/NACK from the master
            }state_type;
            
//Signal Declarations
state_type state_reg, state_next;               //State Machine register
/* CDC Registers */
logic i2c_scl_meta, i2c_scl_reg;                //scl registers double synchronizer
logic i2c_sda_meta, i2c_sda_reg;                //sda registers double synchronizer (sda input data)
logic sda_out, sda_o_next;                      //SDA output data register
logic i2c_clk, i2c_sda;                         //Reg to determine pos/neg edge of scl/sda
logic [2:0] bit_ctr, bit_ctr_next;              //Register to keep track of num of bits recieved/sent (counts up to 7 -> 3 bit register)
logic [7:0] shreg_in, shreg_i_next;             //Shift register to hold incoming data from sda line
logic [7:0] shreg_out, shreg_o_next;            //Shift register to hold outgoing sda data 
logic scl_posedge, scl_negedge;                 //Signals to determine positive & negative scl edge
logic sda_posedge, sda_negedge;                 //Signal to determine positive and negative edge of sda line
logic start_cond, stop_cond;                    //Signals to determine start & stop conditoins on the sda line
logic data_valid, trans_done, trans_done_next;  //Status signals for the wrapper circuit to interact with reg file

logic i2c_rdy, i2c_valid;                       //Intermediary registers to store status of i2c controller for wrapper
logic read_or_write, read_or_write_next;        //flag used to hold the read or write bit


/**** Synchronization Logic - Double Synchronizer ****/
always_ff @(posedge clk) begin
    if(reset) begin
        i2c_scl_meta <= 0;
        i2c_scl_reg <= 0;
        i2c_sda_meta <= 0;
        i2c_sda_reg <= 0;
    end else begin
        i2c_scl_meta <= i_scl;
        i2c_scl_reg <= i2c_scl_meta;
        i2c_sda_meta <= sda;
        i2c_sda_reg <= i2c_sda_meta;
    end
end

/**** SDA Control Logic ****/
//The high impedence signal is implicity a logic high due to pull up resistor beign used in the constraints
assign sda = (sda_out) ? 1'bZ : 1'b0; 

/**** FSM Current State Logic ****/
always_ff @(posedge clk) begin
    if(reset) begin
        state_reg <= IDLE;
        read_or_write <= 0;
        i2c_clk <= 0;
        i2c_sda <= 0;
        bit_ctr <= 0;
        shreg_in <= 0;
        shreg_out <= 0;
        sda_out <= 1;
        trans_done <= 0;
    end else begin
        state_reg <= state_next;
        i2c_clk <= i2c_scl_reg;
        i2c_sda <= i2c_sda_reg;
        bit_ctr <= bit_ctr_next;
        shreg_in <= shreg_i_next;
        shreg_out <= shreg_o_next;
        read_or_write <= read_or_write_next;
        sda_out <= sda_o_next;
        trans_done <= trans_done_next;
    end
end

/**** FSM Next State Logic ****/
always_comb begin
    //Default conditions
    state_next = state_reg;
    bit_ctr_next = bit_ctr;
    shreg_i_next = shreg_in;
    shreg_o_next = shreg_out;
    read_or_write_next = read_or_write;
    trans_done_next = trans_done;
    sda_o_next = sda_out;
    i2c_rdy = 1'b0;
    data_valid = 1'b0;
   
    if(start_cond) begin                        //If a start/restart condition is detected
        state_next = ADDRESS;                   //set the state machine to veridy slave address
        bit_ctr_next = 3'b111;                  //Prepare bit counter
        shreg_i_next = 8'b0;                    //Clear the input shift register
        shreg_o_next = i_file_data;             //Set the output shift register
    end
    else if(stop_cond)                    //If there is a stop condition
        state_next = IDLE;                      //Go to idle state
    else begin
        //FSM State Machine Logic
        case(state_reg)
            IDLE : begin
                i2c_rdy = 1'b1;
            end
            ADDRESS : begin
                if(scl_posedge) begin
                    //Check if we have more bits to read on the sda line
                    if(bit_ctr > 0) begin
                        shreg_i_next = {shreg_in[6:0], i2c_sda_reg};      
                        bit_ctr_next = bit_ctr - 1;                       
                    end else begin
                        //If we have recieved the full 7-bit address, validate it 
                        if(shreg_in[6:0] == SLAVE_ADDR) begin
                            read_or_write_next = i2c_sda_reg;
                            state_next = SEND_ACK_1;
               
                        end else
                            state_next = IDLE;
                    end
                end 
            end
            SEND_ACK_1 : begin 
                trans_done_next = 1'b0;                               
                //Wait for the negedge of the 8th clock tick to drive sda line low
                if(scl_negedge) begin
                    //Give slave control of the sda line & transmit ACK
                    sda_o_next = 1'b0;
                    //Reset bit ctr
                    bit_ctr_next = 3'b111;
                    data_valid = 1'b1;
                    //Determine next state based on the read/write
                    if(read_or_write)
                        state_next = WRITE_1;
                    else 
                        state_next = SEND_ACK_2;

                end                
            end
            SEND_ACK_2 : begin
                sda_o_next = 1'b0;
                //Wait for the next neg edge of teh scl clock (this will be the 9th clock tick)
                if(scl_negedge) begin
                    //Determine state based on the read/write
                    if(read_or_write)
                        state_next = WRITE_1;
                    else 
                        state_next = READ;
                end
            end
            READ : begin
                //Release sda line to master
                sda_o_next = 1'b1;
                //If an scl positive edge occurs
                if(scl_posedge) begin
                    //Sample sda line into the shift register
                    shreg_i_next = {shreg_in[6:0], i2c_sda_reg};
                    //Check if there is more data to be read
                    if(bit_ctr > 0) 
                        bit_ctr_next = bit_ctr - 1;
                    //If all bits have been read, transmit an ACK to master
                    else begin
                        state_next = SEND_ACK_1;
                        trans_done_next = 1'b1;
                    end
                end
            end
            WRITE_1 : begin
                if(scl_negedge) begin         
                    //Drive sda on teh negative clock edge                       
                    sda_o_next = shreg_out[7];
                    //Shift the shift register to the left by 1 digit
                    shreg_o_next = {shreg_out[6:0], 1'b0};
                    //Check if mroe data needs to be trasnmitted
                    if(bit_ctr > 0)
                        bit_ctr_next = bit_ctr - 1;
                    else begin
                        state_next = WRITE_2;
                        trans_done_next = 1'b1;
                    end
                end
            end
            WRITE_2 : begin
                trans_done_next = 1'b0;
                if(scl_negedge) begin
                    //Give SDA to master for ACK/NACK
                    sda_o_next = 1'b1;
                    state_next = WRITE_3; 
                end
            end
            WRITE_3 : begin
                if(scl_posedge) begin
                    data_valid = 1'b1;
                    //If sda line is high (NACK) end of transmission and retunr to IDLE
                    if(i2c_sda_reg)
                        state_next = IDLE;
                    else begin
                        state_next = WRITE_1;
                        bit_ctr_next = 3'b111; 
                        shreg_o_next = i_file_data;
                    end
                end
            end
        endcase
    end
end

//Positive and negative edge detection for sda/scl lines
assign scl_posedge = i2c_scl_reg && ~i2c_clk;
assign scl_negedge = ~i2c_scl_reg && i2c_clk;
assign sda_posedge = i2c_sda_reg && ~i2c_sda;
assign sda_negedge = ~i2c_sda_reg && i2c_sda;
//Start and stop condition logic
assign start_cond = sda_negedge && i2c_scl_reg;
assign stop_cond = sda_posedge && i2c_scl_reg;

/**** Output Logic ****/
assign o_file_data = shreg_in;
assign o_i2c_ready = i2c_rdy;
assign o_rd_wr_bit = read_or_write;
assign o_i2c_data_valid = data_valid;
assign o_i2c_addr_set = trans_done;

endmodule
