// Data Memory module
module data_memory (
  input wire clk,
  input wire [8:0] A,
  input wire [31:0] DI,
  input wire [1:0] Size,
  input wire RW,
  input wire E,
  input wire SE,
  output reg [31:0] DO
);

  reg [7:0] mem [0:511];

  // Asynchronous read operation
  always @(*) begin
    if (RW == 0 && E == 1) begin
      case (Size)
        2'b00: DO = SE ? {{24{mem[A][7]}}, mem[A]} : {24'b0, mem[A]};
        2'b01: DO = SE ? {{16{mem[A+1][7]}}, mem[A+1], mem[A]} : {16'b0, mem[A+1], mem[A]};
        default: DO = {mem[A+3], mem[A+2], mem[A+1], mem[A]};
      endcase
    end else begin
      DO = 32'bx;
    end
  end

  // Synchronous write operation
  always @(posedge clk) begin
    if (RW == 1 && E == 1) begin
      case (Size)
        2'b00: mem[A] <= DI[7:0];
        2'b01: {mem[A+1], mem[A]} <= DI[15:0];
        2'b10: {mem[A+3], mem[A+2], mem[A+1], mem[A]} <= DI;
        default: ; // No action for Size = 11
      endcase
    end
  end

  // Initialize memory with a text file
  initial begin
    $readmemh("data.txt", mem);
  end

endmodule

// Test bench for Data Memory
module data_memory_tb;

  reg clk;
  reg [8:0] A;
  reg [31:0] DI;
  reg [1:0] Size;
  reg RW;
  reg E;
  reg SE;
  wire [31:0] DO;

  data_memory dut (
    .clk(clk),
    .A(A),
    .DI(DI),
    .Size(Size),
    .RW(RW),
    .E(E),
    .SE(SE),
    .DO(DO)
  );

  // Clock generation
  always begin
    clk = 0;
    #5;
    clk = 1;
    #5;
  end

    // Stimulus
  initial begin
    $display("Read word from locations 0, 4, 8, 12:");
    $display("Address  Data       Size  R/W  E  SE");
    $display("------------------------------------");

    // Read word from locations 0, 4, 8, 12
    RW = 0; E = 1; Size = 2'b10; SE = 0;
    A = 0;  #10;
    $display("   %2d    0x%h   %b    %b   %b  %b", A, DO, Size, RW, E, SE);
    A = 4;  #10;
    $display("   %2d    0x%h   %b    %b   %b  %b", A, DO, Size, RW, E, SE);
    A = 8;  #10;
    $display("   %2d    0x%h   %b    %b   %b  %b", A, DO, Size, RW, E, SE);
    A = 12; #10;
    $display("   %2d    0x%h   %b    %b   %b  %b", A, DO, Size, RW, E, SE);

    $display("\nRead unsigned byte and halfwords:");
    $display("Address  Data       Size  R/W  E  SE");
    $display("------------------------------------");

    // Read unsigned byte and halfwords
    Size = 2'b00; A = 0;  #10;
    $display("   %2d    0x%h   %b    %b   %b  %b", A, DO, Size, RW, E, SE);
    Size = 2'b01; A = 2;  #10;
    $display("   %2d    0x%h   %b    %b   %b  %b", A, DO, Size, RW, E, SE);
    A = 4;  #10;
    $display("   %2d    0x%h   %b    %b   %b  %b", A, DO, Size, RW, E, SE);

    $display("\nRead signed byte and halfwords:");
    $display("Address  Data       Size  R/W  E  SE");
    $display("------------------------------------");

    // Read signed byte and halfwords
    SE = 1;
    Size = 2'b00; A = 0;  #10;
    $display("   %2d    0x%h   %b    %b   %b  %b", A, DO, Size, RW, E, SE);
    Size = 2'b01; A = 2;  #10;
    $display("   %2d    0x%h   %b    %b   %b  %b", A, DO, Size, RW, E, SE);
    A = 4;  #10;
    $display("   %2d    0x%h   %b    %b   %b  %b", A, DO, Size, RW, E, SE);

    $display("\nWrite byte, halfwords, and word:");
    $display("Address  Data");
    $display("------------");

    // Write byte, halfwords, and word
    RW = 1; SE = 0;
    Size = 2'b00; A = 0;  DI = 32'ha6;        #10;
    $display("   %2d    0x%h", A, DI);
    Size = 2'b01; A = 2;  DI = 32'hbbdd;      #10;
    $display("   %2d    0x%h", A, DI);
    A = 4;  DI = 32'h5419;      #10;
    $display("   %2d    0x%h", A, DI);
    Size = 2'b10; A = 8;  DI = 32'habcdef01;  #10;
    $display("   %2d    0x%h", A, DI);

    $display("\nRead word from locations 0, 4, 8 after writing:");
    $display("Address  Data       Size  R/W  E  SE");
    $display("------------------------------------");

    // Read word from locations 0, 4, 8
    RW = 0; Size = 2'b10;
    A = 0;  #10;
    $display("   %2d    0x%h   %b    %b   %b  %b", A, DO, Size, RW, E, SE);
    A = 4;  #10;
    $display("   %2d    0x%h   %b    %b   %b  %b", A, DO, Size, RW, E, SE);
    A = 8;  #10;
    $display("   %2d    0x%h   %b    %b   %b  %b", A, DO, Size, RW, E, SE);

    $finish;
  end


endmodule