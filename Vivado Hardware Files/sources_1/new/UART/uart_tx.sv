`timescale 1ns / 1ps

/*
* This module is a uart transmitter module. It transmits the data from the processor to the
* external world.
*/
module uart_tx
#(
    parameter DATA_BITS,    //Max number of data bits
              OVRSAMPLING
)              
(
    input logic clk, reset,
    input logic s_tick,                 //Input tick from baud_rate generator
    input logic tx_start,               //Signals the module to begin transmitting data
    input logic [3:0] d_bits,           //Amount of data to transmit
    input logic [5:0] stop_ticks,       //Number of stop ticks to count num of stop bits
    input logic parity_en,              //Enable or disable parity
    input logic parity_pol,             //Determine whether polarity is even or odd (1 = even, 0 = odd)
    input logic [DATA_BITS-1:0] din,    //Data to be transmitted
    output logic tx_done,               //Flag indicating tx complete
    output logic tx                     //Bit to transmit
);

/*********** Varibale declerations ***************/
//State Machine decleration
typedef enum {idle,                 //Initial starting state 
              start,                //State to send the tx=0 (start bit)
              data,                 //State to send the data 
              parity,               //State used to send the parity bit - only used if parity is enabled
              stop} state_type;     //State to send teh stop bit

/*********** Signal Declarations ******************/
state_type state_reg, state_next;
logic [5:0] s_reg, s_next;                      //Keeps count of the number of ticks
logic [2:0] n_reg, n_next;                      //Keeps count of the number of bits sent
logic [DATA_BITS-1:0] b_reg, b_next;            //Stores the data to transmit
logic tx_reg, tx_next;                          //Stores the specific bit within the b_reg to send
logic parity_bit;                               //Output of the parity circuit
logic par_din_xor, parity_temp;                 //Temporary wires used to store intermediary values in the parity combinational circuit

/********** Transmitter Logic ********************/
always_ff @(posedge clk, posedge reset)
begin
    if(reset)
    begin
        state_reg <= idle;
        s_reg <= 0;
        n_reg <= 0;
        b_reg <= 0;
        tx_reg <= 1'b1;                         //Initially set to 1(idle)
    end
    else
    begin
        state_reg <= state_next;
        s_reg <= s_next;
        n_reg <= n_next;
        b_reg <= b_next;
        tx_reg <= tx_next;
    end
end

//FSMD next-state logic 
always_comb
begin
    //Default values
    state_next = state_reg;
    s_next = s_reg;
    n_next = n_reg;
    b_next = b_reg;
    tx_next = tx_reg;
    tx_done = 1'b0;
    //FSM Logic
    case (state_reg)
        idle:
        begin
            tx_next = 1'b1;             //The output bit is high - signaling the idle state
            if(tx_start)                //if tx_start signal is high, begin the data transmission             
            begin
                state_next = start;
                s_next = 0;
                b_next = din;
            end
        end
        start:
        begin
            tx_next = 1'b0;             //Set the tx bit to 0, indicating the start bit 
            if(s_tick)
            begin
                if(s_reg == 15)         //Send teh start bit for the duration of 16 ticks
                begin
                    state_next = data;
                    s_next = 0;
                    n_next = 0;
                end
                else
                    s_next = s_reg + 1;
            end
        end
        data:
        begin
            tx_next = b_reg[0];                 //Send the least sig bit
            if(s_tick)
            begin
                if(s_reg == 15)                 //If data has been sent for 15 ticks                
                begin
                    s_next = 0;                 //Reset the tick counter
                    b_next = b_reg >> 1;        //Shift the data register to the right 
                    if(n_reg == (d_bits-1))     //if all data bits have been sent                 
                        state_next = (parity_en) ? parity : stop;      //Swicth to stop state
                    else
                        n_next = n_reg + 1;    //increment num of data bits transmitted
                end
                else
                    s_next = s_reg + 1;
            end                           
        end
        parity:
        begin
            tx_next = parity_bit;
            if(s_tick)
                if(s_reg == 15)
                begin
                    state_next = stop;
                    s_next = 0;
                end
                else
                    s_next = s_reg + 1;
        end
        stop:
        begin
            tx_next = 1'b1;                     //Set high to indicate a stop signal
            if(s_tick)
            begin
                if(s_reg == (stop_ticks - 1))        //If the stop bit has been sent for the correct period
                begin
                    state_next = idle;
                    tx_done = 1'b1;
                end
                else
                    s_next = s_reg + 1;
            end
        end
    endcase
end

//Combinational Logic for Parity circuit
always_comb
begin
    //XOR the first 6 data in bits
    par_din_xor = (din[0] ^ din[1]) ^ (din[2] ^ din[3]) ^ (din[4] ^ din[5]);
    //Depending on the number of data bits - either XOR the 7th and 8th data with the above wire
    //Or XOR the above wire with the 7th data input - option depends upon msb of the d_bits wire
    parity_temp = par_din_xor ^ ((d_bits[3]) ? (din[6] ^ din[7]) : (din[6]));
    //Determine whether the parity bit is even or odd
    parity_bit = (parity_pol) ? parity_temp : ~parity_temp;
end

//Ouput logic
assign tx = tx_reg;

endmodule
