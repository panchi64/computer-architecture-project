module SOH (
    input S2, S1, S0,
    input [31:0] PB,
    input [11:0] imm12_I,
    input [11:0] imm12_S,
    input [19:0] imm20,
    input [31:0] PC,
    output reg [31:0] N
);

always @* begin
    N = 32'b0;
    
    case ({S2, S1, S0})
        3'b000: N = PB;
        3'b001: N = { {20{imm12_I[11]}}, imm12_I };
        3'b010: N = { {20{imm12_S[11]}}, imm12_S };
        3'b011: N = { imm20, 12'b000000000000 };
        3'b100: N = PC;
    endcase
end

endmodule

module SOH_tb;
    reg S2, S1, S0;
    reg [31:0] PB, PC;
    reg [11:0] imm12_I, imm12_S;
    reg [19:0] imm20;
    wire [31:0] N;

    reg [2:0] counter;

    SOH uut (
        .S2(S2),
        .S1(S1),
        .S0(S0),
        .PB(PB),
        .imm12_I(imm12_I),
        .imm12_S(imm12_S),
        .imm20(imm20),
        .PC(PC),
        .N(N)
    );

    initial begin

        // Assign other inputs with values
        PB = 32'b00000100001100011111111111101010;
        imm12_I = 12'b110000001100;
        imm12_S = 12'b011100001111;
        imm20 = 20'b11101100010001001111;
        PC = 32'b11000100001100011111111111101010;

        $display("S2 S1 S0   N");
        $display("-------------------------------------------");

        // Display the input values and corresponding output N
        $monitor("%b  %b  %b    %b", S2, S1, S0, N);


        // Iterate through all possible combinations of S inputs
        for (counter = 0; counter < 5; counter = counter + 1) begin
            {S2, S1, S0} = counter[2:0];

            #2;
        end

        $finish;
    end
endmodule