`timescale 1ns / 1ps

/*
 * This module designs a basic I2C master module that is driven by a software driver. The I2C module
 * does not support features such as clock stretching or arbitration.
*/
module i2c_master
(
    input logic clk, reset,
    /* Processor Interface */
    input logic [7:0] din,                  //Value to transmit on the SDA line from master
    input logic [15:0] dvsr,                //Used to set the i2c clk period
    input logic [2:0] cmd,                  //Controls the flow of the I2C
    input logic wr_i2c,                     
    output logic ready, done_tick, ack,     //Status flags
    output logic [7:0] dout,                //Value from the I2C Slave
    /* I2C Interface */
    inout tri sda,
    output tri scl    
);

/* Constants */
//These commands are sent from the software driver and control the flow of the FSM
localparam START_CMD    = 3'b000;
localparam WR_CMD       = 3'b001;
localparam RD_CMD       = 3'b010;
localparam STOP_CMD     = 3'b011;
localparam RESET_CMD    = 3'b100;

//FSM State Declarations
typedef enum{idle,          //Initial State before transaction begins
             start1,        //First phase of start - pulls sda line low
             start2,        //Second phase of start - pulls scl line low
             hold,          //intermediary state before a new command is sent
             restart,       //Used to indicate a restart condition
             data1,         //Initial phase to drive data on the SDA line
             data2,         //2nd phase to set the scl line high
             data3,         //3rd phase to sample the SDA line
             data4,         //4th phase to drive scl low and drive new data
             data_end,      //Final phase for data reception, pulls line low before going back to hold
             stop1,         //Initial stop phase to set SCl high
             stop2          //Final stop state to set SDA high
             }state_type;
             
/* Signal Declarations */
state_type state_reg, state_next;
logic [15:0] ctr_reg, ctr_next;         //Reg used to count up to dvsr (set the I2C clk period)
logic [15:0] qtr, half;                 //Hold value to count to for quarter & half of the I2C clock period (quarter -> used for data phase & half -> used ffor start/stop)
logic [8:0] tx_reg, tx_next;            //TX shift reg
logic [8:0] rx_reg, rx_next;            //RX shift reg
logic [2:0] cmd_reg, cmd_next;          //Stores command to drive I2C
logic [3:0] bit_reg, bit_next;          //Counts number of bit transmissions
logic sda_reg, scl_reg;                 //Buffers for scl & sda line
logic sda_out, scl_out, data_phase;
logic done_tick_i, ready_i;
logic tri_ctrl;                         //Controls the output of the tri-state buffer
logic nack;

/* SDA & SCL Output Logic */
always_ff @(posedge clk) begin
    if(reset) begin
        //Both SDA and SCL Lines start high
        sda_reg <= 1'b1;
        scl_reg <= 1'b1;
    end 
    else begin
        sda_reg <= sda_out;
        scl_reg <= scl_out;
    end  
end

//SCL Line Logic - use the FPGA I/O tristate buffer which has pull up resistor
assign scl = (scl_reg) ? 1'bZ : 1'b0;  

//SDA Line Logic
//The tri state buffer must be disabled (sda line is recieveing data from slave) if either of the following conditions are met:
//          1)We are currently in the data phase (read or write), we are reading, and we have not recieved all 8 bits of data yet
//          2) We are in data phase, we are writing, and we have recieved all 8 data bits (waiting to recieve ACK)
assign tri_ctrl = (data_phase && (cmd_reg == RD_CMD) && bit_reg < 8) ||
                   (data_phase && (cmd_reg == WR_CMD) && (bit_reg == 8));
                   
assign sda = (tri_ctrl || sda_reg) ? 1'bZ : 1'b0;
//Output logic for the processor interface
assign dout = rx_reg[8:1];
assign ack = rx_reg[0];                   
assign nack = din[0];

/* FSMD/I2C Transmission Logic */
always_ff @(posedge clk) begin
    if(reset) begin
        state_reg <= idle;
        ctr_reg <= 0;
        tx_reg <= 0;
        rx_reg <= 0;
        cmd_reg <= 0;
        bit_reg <= 0;
    end
    else begin
        state_reg <= state_next;
        ctr_reg <= ctr_next;
        tx_reg <= tx_next;
        rx_reg <= rx_next;
        cmd_reg <= cmd_next;
        bit_reg <= bit_next;        
    end
end

always_comb begin
    //Default statements 
    state_next = state_reg;
    tx_next = tx_reg;
    rx_next = rx_reg;
    ctr_next = ctr_reg + 1;
    cmd_next = cmd_reg;
    bit_next = bit_reg;
    //Initialize Flag Values
    done_tick_i = 1'b0;
    ready_i = 1'b0;
    sda_out = 1'b1;
    scl_out = 1'b1;
    data_phase = 1'b0;
    case(state_reg) 
        idle : begin
            ready_i = 1'b1;         
            if(wr_i2c && (cmd == START_CMD)) begin      //A start condition signaled
                state_next = start1;
                ctr_next = 0;
            end
        end
        start1 : begin
            sda_out = 1'b0;                             //Pull SDA Line low to init start signal on I2c
            if(ctr_reg == half) begin                   //Wait for half an I2C clock period
                ctr_next = 0;
                state_next = start2;
            end
        end
        start2 : begin
            scl_out = 1'b0;                            //Pull SCL line low to complete start condition
            sda_out = 1'b0;
            if(ctr_reg == qtr) begin                   //Wait for quarter of an I2C clock period
                ctr_next = 0;
                state_next = hold;
            end
        end
        hold : begin
            ready_i = 1'b1;
            sda_out = 1'b0;
            scl_out = 1'b0;
            if(wr_i2c) begin                            //If the signal from software is to write
                cmd_next = cmd;                         //Store the command from software
                ctr_next = 0;
                case(cmd) 
                    RESET_CMD, START_CMD:               
                        state_next = restart;
                    STOP_CMD:
                        state_next = stop1;
                    default: begin                      //This condition covers the write and read commands
                       state_next = data1;
                       bit_next = 0;
                       tx_next = {din, nack};
                    end
                endcase
            end
        end
        data1 : begin
            sda_out = tx_reg[8];                        //Drive the MSB on the SDA line
            data_phase = 1'b1;                          //Set dataphase flag (this is used for control of tri state buffers)
            scl_out = 1'b0;                             //Pull spi clock low
            if(ctr_reg == qtr) begin
                ctr_next = 0;
                state_next = data2;
            end
        end
        data2 : begin
            sda_out = tx_reg[8];
            data_phase = 1'b1;
            if(ctr_reg == qtr) begin
                ctr_next = 0;
                state_next = data3;
                rx_next = {rx_reg[7:0], sda};           //Sample the SDA line at this point (For reading data)
            end
        end
        data3 : begin
            sda_out = tx_reg[8];
            data_phase = 1'b1;
            if(ctr_reg == qtr) begin
                ctr_next = 0;
                state_next = data4;
            end
        end
        data4 : begin
            sda_out = tx_reg[8];
            scl_out = 1'b0;                                 //Pull scl clock low again
            data_phase = 1'b1;
            if(ctr_reg == qtr) begin
                ctr_next = 0;
                if(bit_reg == 8) begin                      //If all 9 bits have been transmitted/receieved
                    state_next = data_end;
                    done_tick_i = 1'b1;
                end
                else begin
                    state_next = data1;
                    bit_next = bit_reg + 1;                 //increment number of bits recieved
                    tx_next = {tx_reg[7:0], 1'b0};          //Shift the tx value one to the left to update MSb
                end
            end
        end
        data_end : begin
            sda_out = 1'b0;                                 //Pull sda line low
            scl_out = 1'b0;                                 //Pull scl line low
            if(ctr_reg == qtr) begin
                ctr_next = 0;
                state_next = hold;
            end
        end
        restart : begin
            if(ctr_reg == half) begin
                ctr_next = 0;
                state_next = start1;
            end
        end
        stop1 : begin
            sda_out = 1'b0;                                 //Keep sda low but let scl go high
            if(ctr_reg == half) begin
                ctr_next = 0;
                state_next = stop2;
            end
        end
        default : begin                                     //This covers the stop2 condition and all others
            if(ctr_reg == half)
                state_next = idle; 
        end 
    endcase
end

//Intemrmediate Signals
assign qtr = dvsr;
assign half = {qtr[14:0], 1'b0};        //half = qtr * 2
//Ouput logic
assign done_tick = done_tick_i;
assign ready = ready_i;

              
endmodule
