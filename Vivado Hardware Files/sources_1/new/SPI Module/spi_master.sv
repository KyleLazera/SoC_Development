`timescale 1ns / 1ps


module spi_master
(
    input logic clk, reset,
    //Input signals from Wrapper Registers
    input logic [7:0] din,
    input logic [15:0] dvsr,                //This value will represent half of the period of the spi clk
    input logic start, cpha, cpol,
    //Output signals to the Wrapper
    output logic [7:0] dout,
    output logic spi_done_tick, ready,
    //SPI Signals
    input logic miso,
    output logic sclk,
    output logic mosi
);

//FSM States
typedef enum {idle,                 //Initial state 
              cpha_delay,           //Only used is clock phase is 1
              phase_0,              //Initial phase for sampling the signals
              phase_1               //Second phase for driving signals
              } state_type;

//Signal Declarations
state_type state_reg, state_next;
logic sclk_reg, sclk_next;          //Used to keep track of the SPI clocks
logic temp_clk;
logic spi_done, spi_ready;          //Holds the value of spi done & spi ready - drives the respective output signals
logic [15:0] ctr_reg, ctr_next;     //Used to count up to the dvsr value (set the spi clk period)
logic [2:0] n_reg, n_next;          //Used to count number of bits transmitted
logic [7:0] sout_reg, sin_reg;      //Shift registers to hold outgoing and incoming data
logic [7:0] sout_next, sin_next;

//SPI Clock generation Logic
assign temp_clk = (state_next == phase_1 && ~cpha) || (state_next == phase_0 && cpha);
assign sclk_next = (cpol) ? ~temp_clk : temp_clk;

//FSM Register Logic
always_ff @(posedge clk, posedge reset) begin
    if(reset) begin
        state_reg <= idle;
        ctr_reg <= 0;
        sclk_reg <= 0;
        n_reg <= 0;
        sout_reg <= 0;
        sin_reg <= 0;
    end 
    else begin
        state_reg <= state_next;
        ctr_reg <= ctr_next;
        sclk_reg <= sclk_next;
        n_reg <= n_next;
        sout_reg <= sout_next;
        sin_reg <= sin_next;      
    end
end

//Next State Logic
always_comb begin
    //Set default values for registers
    state_next = state_reg;
    ctr_next = ctr_reg;
    n_next = n_reg;
    sout_next = sout_reg;
    sin_next = sin_reg;
    //Default values for output flags 
    spi_done = 1'b0;
    spi_ready = 1'b0;
    case(state_reg) 
        idle : begin
            spi_ready = 1'b1;
            if(start) begin
                ctr_next = 0;
                sout_next = din;
                n_next = 0;
                if(cpha)
                    state_next = cpha_delay;
                else
                    state_next = phase_0;
            end
        end
        
        cpha_delay : begin
            if(ctr_reg == dvsr) begin
                state_next = phase_0;
                ctr_next = 0;
            end
            else
                ctr_next = ctr_reg + 1;
        end
        
        phase_0: begin
            if(ctr_reg == dvsr) begin       //This signals half a period is gone (rising edge)
                state_next = phase_1;
                sin_next = {sin_reg[6:0], miso};
                ctr_next = 0;
            end
            else
                ctr_next = ctr_reg + 1; 
        end 
        
        phase_1 : begin
            if(ctr_reg == dvsr) begin
                if(n_reg == 7) begin
                    spi_done = 1'b1;
                    state_next = idle;
                end    
                else begin
                    state_next = phase_0;
                    sout_next = {sout_reg[6:0], 1'b0};
                    n_next = n_reg + 1;
                    ctr_next = 0;
                end
            end
            else 
                ctr_next = ctr_reg + 1;
        end
    endcase
end

//Output logic
assign sclk = sclk_reg;
assign spi_done_tick = spi_done;
assign ready = spi_ready;
assign dout = sin_reg;
assign mosi = sout_reg[7];

endmodule
