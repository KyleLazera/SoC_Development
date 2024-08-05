`timescale 1ns / 1ps

module fifo_controller
#(parameter ADDR_WIDTH)
(
    input logic clk, reset,
    input logic rd, wr,                 
    output logic empty, full,
    output logic [ADDR_WIDTH-1:0] w_addr,
    output logic [ADDR_WIDTH-1:0] r_addr 
);

/*********** Signal Declarations *************/
logic [ADDR_WIDTH-1:0] w_ptr_logic, w_ptr_next, w_ptr_succ;
logic [ADDR_WIDTH-1:0] r_ptr_logic, r_ptr_next, r_ptr_succ;
logic full_logic, full_next, empty_logic, empty_next;

/************ FIFO Controller Logic *************/
always_ff @(posedge clk, posedge reset)
begin
    if(reset)
    begin
        w_ptr_logic <= 0;
        r_ptr_logic <= 0;
        full_logic <= 1'b0;
        empty_logic <= 1'b1;
    end
    else
    begin
        w_ptr_logic <= w_ptr_next;
        r_ptr_logic <= r_ptr_next;
        full_logic <= full_next;
        empty_logic <= empty_next;
    end
end

//Next State Logic
always_comb
begin
    //Default values
    w_ptr_succ = w_ptr_logic + 1;               //This will hold the successive addr for the write pointer
    r_ptr_succ = r_ptr_logic + 1;               //This will holds the successive addr for the read pointer
    w_ptr_next = w_ptr_logic;
    r_ptr_next = r_ptr_logic;
    full_next = full_logic;
    empty_next = empty_logic;
    unique case({wr, rd})
        2'b01:                                  //Read from FIFO
        begin
            if(~empty_logic)                    //Make sure the FIFO is not empty
            begin
                r_ptr_next = r_ptr_succ;        //For a read signal, increment the read addr
                full_next = 1'b0;               //make sure to clear the full flag
                if(r_ptr_succ == w_ptr_logic)   //Check to see if rd addr has caught wr addr
                    empty_next = 1'b1;
            end          
        end
        2'b10:
        begin
            if(~full_logic)                     //Make sure the FIFO is not full
            begin
                w_ptr_next = w_ptr_succ;        //Inc write pointer
                empty_next = 1'b0;             //Clear the empty flag
                if(w_ptr_succ == r_ptr_logic)
                    full_next = 1'b1;
            end
        end
        2'b11:
        begin
            w_ptr_next = w_ptr_succ;
            r_ptr_next = r_ptr_succ;
        end
        default: ; //2'b00 no operation
    endcase
end

//Ouput Logic
assign w_addr = w_ptr_logic;
assign r_addr = r_ptr_logic;
assign full = full_logic;
assign empty = empty_logic;

endmodule
