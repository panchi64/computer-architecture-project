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
  Out = 32'h0;
  Z = 1'b0;
  N = 1'b0;
  C = 1'b0;
  V = 1'b0;

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
      Out = A >> B[4:0];
    end

    4'b0111: begin  // Arithmetic right shift of A by lower 5 bits of B
      Out = A >>> B[4:0];
    end

    4'b1000: begin  // if (A < B) then Out=1, else Out=0 (signed)
      // Figure out if A - B triggers the N and V flags
      dif = A - B;
      Z = (dif == 32'h0);
      N = dif[31];
      C = A < B;
      V = (A[31] ^ B[31]) & (A[31] ^ dif[31]);

      if (~N & V) begin
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

    4'b1010: begin  // Bitwise AND
      Out = A & B;
      
    end

    4'b1011: begin  // Bitwise OR
      Out = A | B;
      
    end

    4'b1100: begin  // Bitwise XOR
      Out = A ^ B;
      
    end

    4'b1101: begin  // ADD
      // Dead operator
      
    end

    4'b1110: begin  // ADD
      // Dead operator
      
    end

    4'b1111: begin  // ADD
      // Dead operator
      
    end
  endcase
end

endmodule


// Test Code
`timescale 1ns/1ns

module ALU_tb;

  // Inputs
  reg [31:0] A, B;
  reg [3:0] op;

  // Outputs
  wire [31:0] Out;
  wire Z, N, C, V;

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
    op = 4'b0000;

    // Table header
    $display("%-9s%-47s%-47s%-47s%-3s%-3s%-3s%-3s", "Op Code", "A", "B", "Out", "Z", "N", "C", "V");
    $display("----------------------------------------------------------------------------------------------------------------------------------------------------------------");

    $monitor("%-9b%-33b(%d)  %-33b(%d)  %-33b(%d)  %-3b%-3b%-3b%-3b", op, A, A, B, B, Out, Out, Z, N, C, V);
    
    while (op != 4'b1111) begin
      #2;
      op = op + 1;
    end

    $finish;
  end

endmodule