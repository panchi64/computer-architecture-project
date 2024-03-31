// Instruction Memory module
module instruction_memory (
  input wire [8:0] A,
  output wire [31:0] I
);

  reg [7:0] mem [0:511];

  // Asynchronous read operation
  assign I = {mem[A+3], mem[A+2], mem[A+1], mem[A]};

  // Initialize memory with a text file
  initial begin
    $readmemh("instructions.txt", mem);
  end

endmodule

// Test bench for Instruction Memory
module instruction_memory_tb;

  reg [8:0] A;
  wire [31:0] I;

  instruction_memory dut (
    .A(A),
    .I(I)
  );

  // Stimulus
  initial begin
    $display("Address  Instruction");
    $display("-------------------");

    A = 0;  #10;
    $display("   %2d    0x%h", A, I);
    A = 4;  #10;
    $display("   %2d    0x%h", A, I);
    A = 8;  #10; 
    $display("   %2d    0x%h", A, I);
    A = 12; #10;
    $display("   %2d    0x%h", A, I);

    $finish;
  end


endmodule