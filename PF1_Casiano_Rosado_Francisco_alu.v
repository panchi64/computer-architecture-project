// The ALU is a combinational circuit (the effect of the inputs can be manifested in the outputs
// almost instantly). As indicated by the truth table, the ALU takes two numbers (A and B) and performs
// operations with them. The result of the operations is an Out number and four flag bits of
// conditions (Z, N, C and V).
// • The Z bit will produce a value of one when Out is equal to zero, otherwise it will produce a zero.
// • The N bit represents the sign of the result of the operation (N = Out[31]).
// • C represents the “overflow” bit for addition or subtraction operations on unsigned numbers. You will
// called “carry” for addition and “borrow” for subtraction. For the sum of two n-bit numbers
// C is the n+1 bit of the addition result. For the subtraction of two numbers (A - B) C will be equal to 1 if A < B.
// • V represents the “overflow” bit for addition or subtraction operations on signed numbers. V is equal to 1
// when the sign of the result of addition or subtraction is not consistent with the rules of assignment of
// sign of arithmetic operations on signed numbers, otherwise equal to zero. V it is possible
// determined by a Boolean equation of the signs of A, B and Out.
// For A + B: V = ˜(A[31] ˆ B[31]) & (A[31] ˆ Out[31]).
// For A - B: V = (A[31] ˆ B[31]) & (A[31] ˆ Out[31]).
// The flag bits should only be generated for the operations indicated. The flags do not
// they need to be stored in the ALU.

module ALU(
  input [31:0] A,
  input [31:0] B,
  input [2:0] op,  // Operation code (0: Add, 1: Subtract)
  output reg [31:0] Out,
  output reg Z,
  output reg N,
  output reg C,
  output reg V
);

always @(A or B or op) begin
  case(op)
    3'b000: begin  // ADD
      Out = A + B;
      Z = (Out == 32'h0);
      N = Out[31];
      C = (Out < A) | (Out < B);  // Carry for addition
      V = ~((A[31] ^ B[31]) & (A[31] ^ Out[31]));
    end
    
    3'b001: begin  // SUB
      Out = A - B;
      Z = (Out == 32'h0);
      N = Out[31];
      C = A < B;  // Borrow for subtraction
      V = (A[31] ^ B[31]) & (A[31] ^ Out[31]);
    end
    
    default: begin
      // Undefined operation, set default values
      Out = 32'h0;
      Z = 1'b0;
      N = 1'b0;
      C = 1'b0;
      V = 1'b0;
    end
  endcase
end

endmodule
