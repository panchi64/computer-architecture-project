module ALU(
  input [31:0] A,
  input [31:0] B,
  input [3:0] op,  // Operation code (0: Add, 1: Subtract)
  output reg [31:0] Out,
  output reg Z,
  output reg N,
  output reg C,
  output reg V
);

reg [31:0] dif;

always @(A or B or op) begin
  case(op)
    4'b0000: begin  // Just B
      Out = B;
    end
    
    4'b0001: begin  // B + 4
      Out = B + 4;
    end

    4'b0010: begin  // ADD
      Out = A + B;
    end

    4'b0011: begin  // SUB
      Out = A - B;
      Z = (Out == 32'h0);
      N = Out[31];
      C = A < B;
      V = (A[31] ^ B[31]) & (A[31] ^ Out[31]);
    end

    4'b0100: begin  // (A + B) & 0xFFFFFFFE
      Out = (A + B) & 32'hFFFFFFFE;
    end

    4'b0101: begin  // Logical left shift of A by lower 5 bits of B
      Out = A << (B[4:0]);
    end

    4'b0110: begin  // Logical right shift of A by lower 5 bits of B
      Out = A >> (B[4:0]);
    end

    4'b0111: begin  // Arithmetic right shift of A by lower 5 bits of B
      Out = A >>> (B[4:0]);
    end

    4'b1000: begin  // if (A < B) then Out=1, else Out=0 (signed)
      // Figure out if A - B triggers the N and V flags
      dif = A - B;
      Z = (dif == 32'h0);
      N = dif[31];
      C = A < B;
      V = (A[31] ^ B[31]) & (A[31] ^ dif[31]);

      // Avoid overflow issues
      if (N && V) begin
        Out = 32'h1;
      end else begin
        Out = 32'h0;
      end
    end

    4'b1001: begin  // if (A < B) then Out=1, else Out=0 (unsigned)
      // Figure out if A - B triggers the N and V flags
      dif = A - B;
      Z = (dif == 32'h0);
      N = dif[31];
      C = A < B;
      V = (A[31] ^ B[31]) & (A[31] ^ dif[31]);

      // Avoid overflow issues
      if (C) begin
        Out = 32'h1;
      end else begin
        Out = 32'h0;
      end
    end

    4'1010: begin  // ADD
      Out = A + B;
      
    end

    4'1011: begin  // ADD
      Out = A + B;
      
    end

    4'1100: begin  // ADD
      Out = A + B;
      
    end

    4'1101: begin  // ADD
      Out = A + B;
      
    end

    4'b1110: begin  // ADD
      Out = A + B;
      
    end

    4'b1111: begin  // ADD
      Out = A + B;
      
    end
    
    default: begin
      // default values
      Out = 32'h0;
      Z = 1'b0;
      N = 1'b0;
      C = 1'b0;
      V = 1'b0;
    end
  endcase
end

endmodule


// Test Code
`timescale 1ns/1ns  // simulation timescale

module ALU_tb;

  // Inputs
  reg [31:0] A, B;
  reg [2:0] op;

  // Outputs
  wire [31:0] Out;
  wire Z, N, C, V;

  // Instantiate the ALU module
  ALU uut (
    .A(A),
    .B(B),
    .op(op),
    .Out(Out),
    .Z(Z),
    .N(N),
    .C(C),
    .V(V)
  );

  initial begin
    A = 32'b10011100000000000000000000111000;
    B = 32'b01110000000000000000000000000011;
    op = 4'b0000;  // ADD

     // Loop to iterate through different op values
    while (op != 4'b1111) begin
      #2;  // Wait for 2 time units
      
      $display("Test case (Op = %b):", op);
      
      op = op + 1;  // Increment op value
    end

    $finish;
  end

endmodule