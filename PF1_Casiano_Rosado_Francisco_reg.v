module BinaryDecoder(
    input [4:0] SEL, 
    output reg [31:0] OUT
);

always @(*)
    case(SEL)
        5'b00000: OUT = 32'b00000000000000000000000000000000;
        5'b00001: OUT = 32'b00000000000000000000000000000001;
        5'b00010: OUT = 32'b00000000000000000000000000000010;
        5'b00011: OUT = 32'b00000000000000000000000000000011;
        5'b00100: OUT = 32'b00000000000000000000000000000100;
        5'b00101: OUT = 32'b00000000000000000000000000000101;
        5'b00110: OUT = 32'b00000000000000000000000000000110;
        5'b00111: OUT = 32'b00000000000000000000000000000111;
        5'b01000: OUT = 32'b00000000000000000000000000001000;
        5'b01001: OUT = 32'b00000000000000000000000000001001;
        5'b01010: OUT = 32'b00000000000000000000000000001010;
        5'b01011: OUT = 32'b00000000000000000000000000001011;
        5'b01100: OUT = 32'b00000000000000000000000000001100;
        5'b01101: OUT = 32'b00000000000000000000000000001101;
        5'b01110: OUT = 32'b00000000000000000000000000001110;
        5'b01111: OUT = 32'b00000000000000000000000000001111;
        5'b10000: OUT = 32'b00000000000000000000000000010000;
        5'b10001: OUT = 32'b00000000000000000000000000010001;
        5'b10010: OUT = 32'b00000000000000000000000000010010;
        5'b10011: OUT = 32'b00000000000000000000000000010011;
        5'b10100: OUT = 32'b00000000000000000000000000010100;
        5'b10101: OUT = 32'b00000000000000000000000000010101;
        5'b10110: OUT = 32'b00000000000000000000000000010110;
        5'b10111: OUT = 32'b00000000000000000000000000010111;
        5'b11000: OUT = 32'b00000000000000000000000000011000;
        5'b11001: OUT = 32'b00000000000000000000000000011001;
        5'b11010: OUT = 32'b00000000000000000000000000011010;
        5'b11011: OUT = 32'b00000000000000000000000000011011;
        5'b11100: OUT = 32'b00000000000000000000000000011100;
        5'b11101: OUT = 32'b00000000000000000000000000011101;
        5'b11110: OUT = 32'b00000000000000000000000000011110;
        5'b11111: OUT = 32'b00000000000000000000000000011111;
        default: OUT = 32'b0; // default case to ensure zero register
    endcase

endmodule

module Multiplexer(
    input [31:0] A, 
    input [31:0] B, 
    input SEL, 
    output reg [31:0] OUT
);

always @(SEL)
    case(SEL)
        1'b0: OUT = A;
        1'b1: OUT = B;
        default: OUT = 32'b0;
    endcase

endmodule

module RegisterFile(
    input [4:0] RW,
    input [4:0] RA,
    input [4:0] RB,
    input [31:0] PW,
    input CLK,
    input LE,
    output reg [31:0] PA,
    output reg [31:0] PB
);

reg [31:0] registers [0:31]; // Array to hold 32 registers

// Writing operation
always @(posedge CLK)
    if (LE && (RW != 5'b00000)) // Ensure not writing to zero register
        registers[RW] <= PW;

// Reading operation
always @*
    begin
        if (RA == 5'b00000) // Ensure not reading from zero register
            PA = 32'b0;
        else
            PA = registers[RA];

        PB = registers[RB];
    end

// Instantiating Binary Decoders for RA and RB
wire [31:0] temp_PA, temp_PB; // Declare intermediate wires
BinaryDecoder decoderA(.SEL(RA), .OUT(temp_PA));
BinaryDecoder decoderB(.SEL(RB), .OUT(temp_PB));

// Instantiating Multiplexers for selecting output based on RA and RB
wire [31:0] muxA_out, muxB_out; // Declare intermediate wires
Multiplexer muxA(.A(temp_PA), .B(32'b0), .SEL(RA == 5'b00000), .OUT(muxA_out));
Multiplexer muxB(.A(temp_PB), .B(32'b0), .SEL(RB == 5'b00000), .OUT(muxB_out));

// Assigning final values to PA and PB
always @*
begin
    if (RA == 5'b00000)
        PA = 32'b0;
    else
        PA = muxA_out;

    PB = muxB_out;
end

endmodule

// TODO: Make it work as requested. it is not looping until RW is 31
module TestBench;

    reg [4:0] RW, RA, RB;
    reg [31:0] PW;
    reg CLK, LE;

    wire [31:0] PA, PB;

    RegisterFile reg_file(
        .RW(RW),
        .RA(RA),
        .RB(RB),
        .PW(PW),
        .CLK(CLK),
        .LE(LE),
        .PA(PA),
        .PB(PB)
    );

    // Clock generation
    always #1 CLK <= ~CLK;

    // Stimulus
    initial begin
        CLK = 0;
        LE = 1;
        PW = 32'd20;
        RW = 5'd0;
        RA = 5'd0;
        RB = 5'd31;

        // Monitor to print values
        $monitor("RW=%d RA=%d RB=%d PW=%d PA=%d PB=%d", RW, RA, RB, PW, PA, PB);

        // Simulation duration
        #100 $finish;
    end

    // Stimulus generation
    always @ (posedge CLK) begin
        if (CLK % 4 == 0) begin // Every four clock cycles
            if (RA < 5'd31) begin
                RA = RA + 1;
                RB = RB + 1;
            end
            PW = PW + 1;
        end
    end

endmodule