`timescale 1ns / 1ps

/*
*This will be a 48 bit counter that allows the user to input a period (default is (2^48) - 1)) as well as contains 
* one-shot and continous mode.
* Architecture:
* This counter module will have 6 registers, each with 32-bit width:
* Control Register (Register 0): Will control the peripheral:
*       Bit 0: go -> counter enable bit (when high counter begins counting)
*       Bit 1: clr -> clears the counter value to 0
*       Bit 2: mode -> when high counter is in one-shot mode and when low counter is in continous mode 
* Lower Period Reg (Register 1): lower 32 bits of programmable period
* Upper Period Reg (Period 2): upper 16 bits of programmable period
* Lower Counter Reg (Period 3): lower 32 bits of counter
* Upper Counter Reg (Period 4): upper 16 bits of counter
* 
* Note: When using this counter, all specs must be initialized BEFORE starting the timer (setting go bit)
* Note: Default operation of the peripheral is a continous timer with period of (2^48) - 1
*/
module Timer_Core
#(parameter COUNTER_WIDTH = 48)
(
    input logic clk, reset,
    //Slot Interface 
    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] reg_addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,
    //Peripheral Output Signals
    output logic counter_done
);

/****************** Signal Declerations ******************/
//Registers
logic [COUNTER_WIDTH-1:0] counter_reg, period_reg;
logic ctrl_go, ctrl_mode;
//Signals 
logic wr_en;
logic clr, go, mode;

assign wr_en = write & cs;

/***************** Counter Logic ************************/
always_ff @(posedge clk, posedge reset)
begin
    if(reset)
        counter_reg <= 0;
    else
        if(clr)
            counter_reg <= 0;
        else if(go)
            if(mode)
                counter_reg <= (counter_reg == period_reg) ? counter_reg : counter_reg + 1;
            else
                counter_reg <= (counter_reg == period_reg) ? 0 : counter_reg + 1;        
end

/****************** Period Register Logic ******************/
always_ff @(posedge clk, posedge reset)
begin
    if(reset)
        begin
            period_reg <= 48'hFFFFFFFFFFFF;
        end
    else
        if(wr_en)
            begin
                case(reg_addr[1:0])
                    2'b01: period_reg[31:0] <= wr_data;
                    2'b10: period_reg[COUNTER_WIDTH-1:32] <= wr_data[15:0];
                    default: ;
                endcase
            end  
end

/***************** Control Register Logic ****************/
always_ff @(posedge clk, posedge reset)
begin
    if(reset)
        begin
            ctrl_go <= 0;
            ctrl_mode <= 0;
        end
    else
        if(wr_en && reg_addr == 5'b0)
            begin
                ctrl_go <= wr_data[0];
                ctrl_mode <= wr_data[2];
            end                             
end

//Declare all signals for the control register
assign clr = wr_en && wr_data[1] && (reg_addr == 5'b0);
assign go = ctrl_go;
assign mode = ctrl_mode;

/**************** Output Logic *********************/
assign counter_done = (counter_reg == period_reg);
assign rd_data = (reg_addr == 5'b11) ? counter_reg[31:0] : 
                 (reg_addr == 5'b100) ? {16'h0000, counter_reg[COUNTER_WIDTH-1:32]} : 0;

endmodule

