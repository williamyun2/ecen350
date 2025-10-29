`timescale 1ns / 1ps

// 32 registers x0..x31, 64-bit wide. x31 is XZR (always 0; writes ignored).
module RegisterFile(
    output wire [63:0] BusA, 
    output wire [63:0] BusB,
    input  wire [63:0] BusW,
    input  wire [4:0]  RA, 
    input  wire [4:0]  RB, 
    input  wire [4:0]  RW,
    input  wire        RegWr,
    input  wire        Clk
);

  // Storage: 32 registers, each 64 bits
  reg [63:0] rf [31:0];

  // Combinational read stage
  reg [63:0] a_next;
  reg [63:0] b_next;

  // Synchronous write (non-blocking). Ignore writes to x31.
  always @(posedge Clk) begin
    if (RegWr && (RW != 5'd31)) begin
      rf[RW] <= BusW;
    end
    // Optionally, keep XZR pinned to zero in storage as well:
    // rf[5'd31] <= 64'b0;
  end

  // Combinational reads (blocking). XZR reads as zero.
  // Includes same-cycle bypass (except to/from x31).
  always @* begin
    a_next = (RA == 5'd31) ? 64'b0 : rf[RA];
    b_next = (RB == 5'd31) ? 64'b0 : rf[RB];

    // Write-through bypass: if writing to same register being read this cycle
    if (RegWr && (RW == RA) && (RW != 5'd31)) a_next = BusW;
    if (RegWr && (RW == RB) && (RW != 5'd31)) b_next = BusW;
  end

  // Required #3 delay on outputs (simulation only; synthesizers ignore delays)
  assign #3 BusA = a_next;
  assign #3 BusB = b_next;

endmodule



// https://chatgpt.com/g/g-p-68fa84289bfc81918d42fdf621b4ce84-will/c/69027e05-f9cc-8322-9263-5ef860e64ef2

