`timescale 1ns / 1ps

/* This module is a wrapping circuit for an XADC IP Core. It enables the user to
* access the data from the XADC core using software which is run by the Microblaze.
* This core enables both reading and writing to teh XADC core, however, due to the difference in 
* address space between teh XADC core (7-bit) and the reg_addr width (5-bit) the user can only read from
* the analog input channels (0x10 to 0x1f) and can only write to the config registers (0x40 to 0x4f)
*/
module xadc_core
(
    input logic clk, reset,
    //Slot Interface
    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] reg_addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,
    //External Signals
    input logic [3:0] adc_p,        //Adc positive port
    input logic [3:0] adc_n         //Adc negative port
);

//Signal Declarations
logic wr_en, rd_en;
logic [4:0] channel;        //Holds the output channel
logic [6:0] daddr_in;       //Register address to access in the XADC status/control reg
logic eoc, rdy;             
logic [15:0] adc_data;      //Ouput data form the ADC
logic rdy_reg;
logic [31:0] r_data;        //Output data to the processor

//XADC Module Instantiation
xadc_fpro xadc_unit (
    .dclk_in(clk),                  // input wire dclk_in
    .reset_in(reset),               // input wire reset_in
    .di_in(wr_data[15:0]),               // input wire [15 : 0] di_in
    .daddr_in(daddr_in),            // input wire [6 : 0] daddr_in
    .den_in(eoc | rd_en | wr_en),   // input wire den_in
    .dwe_in(write),                  // input wire dwe_in
    .drdy_out(rdy),                 // output wire drdy_out
    .do_out(adc_data),              // output wire [15 : 0] do_out
    .vp_in(1'b0),                   // input wire vp_in
    .vn_in(1'b0),                   // input wire vn_in
    .vauxp6(adc_p[0]),              // input wire vauxp6
    .vauxn6(adc_n[0]),              // input wire vauxn6
    .vauxp7(adc_p[2]),              // input wire vauxp7
    .vauxn7(adc_n[2]),              // input wire vauxn7
    .vauxp14(adc_p[1]),             // input wire vauxp14
    .vauxn14(adc_n[1]),             // input wire vauxn14
    .vauxp15(adc_p[3]),             // input wire vauxp15
    .vauxn15(adc_n[3]),             // input wire vauxn15
    .channel_out(channel),          // output wire [4 : 0] channel_out
    .eoc_out(eoc),                  // output wire eoc_out
    .alarm_out(),                   // output wire alarm_out
    .eos_out(),                     // output wire eos_out
    .busy_out()                     // output wire busy_out
);

//Intermediary signals
assign daddr_in = (wr_en) ? {2'b10, reg_addr} : {2'b00, reg_addr};
assign wr_en = write & cs;
assign rd_en = read & cs;

always_ff@(posedge clk) begin
    if(reset) 
        rdy_reg <= 0;
    else
        rdy_reg <= rdy;
end

assign r_data = {15'h0, adc_data, rdy_reg};

//Output logic
assign rd_data = r_data;

endmodule
