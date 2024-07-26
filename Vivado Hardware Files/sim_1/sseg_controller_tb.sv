`timescale 1ns / 1ps

module sseg_controller_tb;

  logic clk, reset;
  logic cs, read, write;
  logic [4:0] reg_addr;
  logic [31:0] wr_data;
  logic [31:0] rd_data;
  logic [3:0] an;
  logic [7:0] sseg;

  // Instantiate the sseg_controller
  sseg_controller uut (
    .clk(clk),
    .reset(reset),
    .cs(cs),
    .read(read),
    .write(write),
    .reg_addr(reg_addr),
    .wr_data(wr_data),
    .rd_data(rd_data),
    .an(an),
    .sseg(sseg)
  );

  // Clock generation
  always #5 clk = ~clk;

  initial begin
    // Initialize signals
    clk = 0;
    reset = 1;
    cs = 0;
    read = 0;
    write = 0;
    reg_addr = 0;
    wr_data = 0;
    
    // Reset sequence
    #10 reset = 0;
    
    // Write a value to be displayed (example: write value to display '3')
    #10 cs = 1; write = 1; wr_data = 32'h000008DE;
    #10 cs = 0; write = 0;

    // Add more test vectors as needed
    #50 $finish;
  end

endmodule
