`timescale 1ns / 1ps

module NextPClogic(
    output reg [63:0] NextPC,
    input  [63:0] CurrentPC,
    input  [63:0] SignExtImm64,
    input         Branch,
    input         ALUZero,
    input         Uncondbranch
);

    always @(*) begin
        if (Uncondbranch) begin
            // Unconditional branch: PC = CurrentPC + SignExtImm64
            NextPC = CurrentPC + SignExtImm64;
        end
        else if (Branch && ALUZero) begin
            // Conditional branch taken (CBZ and ALU result is zero): PC = CurrentPC + SignExtImm64
            NextPC = CurrentPC + SignExtImm64;
        end
        else begin
            // No branch or branch not taken: PC = CurrentPC + 4
            NextPC = CurrentPC + 64'd4;
        end
    end

endmodule
