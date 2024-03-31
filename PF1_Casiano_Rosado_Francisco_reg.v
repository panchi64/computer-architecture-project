// Register File module
module register_file (
  input wire clk,
  input wire [4:0] RA, RB, RW,
  input wire [31:0] PW,
  input wire LE,
  output wire [31:0] PA, PB
);

  reg [31:0] registers [0:31];

  // Asynchronous read operation
  assign PA = registers[RA];
  assign PB = registers[RB];

  // Synchronous write operation
  always @(posedge clk) begin
    if (LE && RW != 5'b00000)
      registers[RW] <= PW;
  end

  // Initialize register 0 to zero
  initial begin
    registers[0] = 32'b0;
  end

endmodule

// Test bench for Register File
module register_file_tb;

  reg clk;
  reg [4:0] RA, RB, RW;
  reg [31:0] PW;
  reg LE;
  wire [31:0] PA, PB;

  register_file dut (
    .clk(clk),
    .RA(RA), .RB(RB), .RW(RW),
    .PW(PW),
    .LE(LE),
    .PA(PA), .PB(PB)
  );

  // Clock generation
  always begin
    clk = 0;
    #2;
    clk = 1;
    #2;
  end

  // Stimulus
  initial begin
    LE = 1;
    PW = 20;
    RW = 0;
    RA = 0;
    RB = 31;

    $display("RW  RA  RB  PW  PA  PB");
    $display("----------------------");

    repeat (32) begin
      #4;
      $display("%2d  %2d  %2d  %2d  %2d  %2d", RW, RA, RB, PW, PA, PB);
      PW = PW + 1;
      RW = RW + 1;
      RA = RA + 1;
      RB = RB + 1;
    end

    $finish;
  end

endmodule