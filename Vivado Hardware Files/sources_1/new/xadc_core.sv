`timescale 1ns / 1ps

/* This module is a wrapping circuit for an XADC IP Core. It enables the user to
* access the data from the XADC core using software which is run by the Microblaze.
* Architecture of the XADC Core:
* Register 0 - 3:  Analog channel 0 - 3 data value
* Register 4: on-chip temperature reading
* Register 5: on chip-internal voltage reading
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
logic [4:0] channel;        //Holds the output channel
logic [6:0] daddr_in;       //Register address to access in the XADC status/control reg
logic eoc, rdy;             
logic [15:0] adc_data;      //Ouput data form the ADC
//Registers for the analog channels 
logic [15:0] adc0_out_reg, adc1_out_reg, adc2_out_reg, adc3_out_reg;
logic [15:0] tmp_out_reg, vcc_out_reg;
logic [31:0] r_data;        //Output data to the processor

//XADC Module Instantiation
xadc_fpro xadc_unit (
    .dclk_in(clk),                  // input wire dclk_in
    .reset_in(reset),               // input wire reset_in
    .di_in(16'h0000),               // input wire [15 : 0] di_in
    .daddr_in(daddr_in),            // input wire [6 : 0] daddr_in
    .den_in(eoc),                   // input wire den_in
    .dwe_in(1'b0),                  // input wire dwe_in
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

assign daddr_in = {2'b00, channel};

always_ff@(posedge clk) begin
    if(reset) begin
        //If reset is high, reset all register values to 0
        adc0_out_reg <= 0;
        adc1_out_reg <= 0;
        adc2_out_reg <= 0;
        adc3_out_reg <= 0;
        tmp_out_reg <= 0;
        vcc_out_reg <= 0;
    end
    else begin
        //Decoding logic for the register values
        if(rdy && (channel == 5'b10110))
            adc0_out_reg <= adc_data;
        if(rdy && (channel == 5'b11110))
            adc1_out_reg <= adc_data;
        if(rdy && (channel == 5'b10111))
            adc2_out_reg <= adc_data;
        if(rdy && (channel == 5'b11111))
            adc3_out_reg <= adc_data;
        if(rdy && (channel == 5'b00000))
            tmp_out_reg <= adc_data;
        if(rdy && (channel == 5'b00001))
            vcc_out_reg <= adc_data;
    end
end

//Multiplexing/output logic
always_comb begin
    case(reg_addr[2:0])
        3'b000: r_data <= {16'h0000, adc0_out_reg};
        3'b001: r_data <= {16'h0000, adc1_out_reg};
        3'b010: r_data <= {16'h0000, adc2_out_reg};
        3'b011: r_data <= {16'h0000, adc3_out_reg};
        3'b100: r_data <= {16'h0000, tmp_out_reg};
        default: r_data <= {16'h0000, vcc_out_reg};
    endcase
end

//Output logic
assign rd_data = r_data;

endmodule
