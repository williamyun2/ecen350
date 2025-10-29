`timescale 1ns / 1ps

`define OPCODE_ANDREG 11'b10001010000  // Fixed: was 10001011000
`define OPCODE_ORRREG 11'b10101010000
`define OPCODE_ADDREG 11'b10001011000
`define OPCODE_SUBREG 11'b11001011000
`define OPCODE_ADDIMM 11'b1001000100?
`define OPCODE_SUBIMM 11'b1101000100?
`define OPCODE_MOVZ   11'b110100101??
`define OPCODE_B      11'b000101?????
`define OPCODE_CBZ    11'b10110100???
`define OPCODE_LDUR   11'b11111000010
`define OPCODE_STUR   11'b11111000000

module SC_Control(
    output reg       Reg2Loc,
    output reg       ALUSrc,
    output reg       MemtoReg,
    output reg       RegWrite,
    output reg       MemRead,
    output reg       MemWrite,
    output reg       Branch,
    output reg       Uncondbranch,
    output reg [3:0] ALUOp,
    output reg [1:0] SignOp,
    input  [10:0]    opcode
);

    always @(*) begin
        // Default values (all zeros for undefined opcodes)
        Reg2Loc = 1'b0;
        ALUSrc = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        Branch = 1'b0;
        Uncondbranch = 1'b0;
        ALUOp = 4'b0000;
        SignOp = 2'b00;

        casez(opcode)
            // R-format instructions (register operations)
            `OPCODE_ADDREG: begin
                Reg2Loc = 1'b0;
                ALUSrc = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0010;  // ADD
                SignOp = 2'b00;
            end

            `OPCODE_SUBREG: begin
                Reg2Loc = 1'b0;
                ALUSrc = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0110;  // SUB
                SignOp = 2'b00;
            end

            `OPCODE_ANDREG: begin
                Reg2Loc = 1'b0;
                ALUSrc = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0000;  // AND
                SignOp = 2'b00;
            end

            `OPCODE_ORRREG: begin
                Reg2Loc = 1'b0;
                ALUSrc = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0001;  // ORR
                SignOp = 2'b00;
            end

            // I-format instructions (immediate operations)
            `OPCODE_ADDIMM: begin
                Reg2Loc = 1'b0;
                ALUSrc = 1'b1;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0010;  // ADD
                SignOp = 2'b00;   // Zero extend for immediate
            end

            `OPCODE_SUBIMM: begin
                Reg2Loc = 1'b0;
                ALUSrc = 1'b1;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0110;  // SUB
                SignOp = 2'b00;   // Zero extend for immediate
            end

            // D-format instructions (load/store)
            `OPCODE_LDUR: begin
                Reg2Loc = 1'b0;
                ALUSrc = 1'b1;
                MemtoReg = 1'b1;
                RegWrite = 1'b1;
                MemRead = 1'b1;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0010;  // ADD for address calculation
                SignOp = 2'b01;   // Sign extend for D-format offset
            end

            `OPCODE_STUR: begin
                Reg2Loc = 1'b1;   // Select Rm for write data
                ALUSrc = 1'b1;
                MemtoReg = 1'b0;  // Don't care
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b1;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0010;  // ADD for address calculation
                SignOp = 2'b01;   // Sign extend for D-format offset
            end

            // CB-format instructions (conditional branch)
            `OPCODE_CBZ: begin
                Reg2Loc = 1'b1;   // Select Rt for comparison
                ALUSrc = 1'b0;
                MemtoReg = 1'b0;  // Don't care
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b1;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0111;  // Pass through for zero check
                SignOp = 2'b10;   // Sign extend for CB-format offset
            end

            // B-format instructions (unconditional branch)
            `OPCODE_B: begin
                Reg2Loc = 1'b0;   // Don't care
                ALUSrc = 1'b0;    // Don't care
                MemtoReg = 1'b0;  // Don't care
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;    // Not used for unconditional
                Uncondbranch = 1'b1;
                ALUOp = 4'b0000;  // Don't care
                SignOp = 2'b11;   // Sign extend for B-format offset
            end

            // MOVZ instruction
            `OPCODE_MOVZ: begin
                Reg2Loc = 1'b0;
                ALUSrc = 1'b1;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0111;  // Pass through B input
                SignOp = 2'b00;   // Zero extend and shift for MOVZ
            end

            // Default case: undefined opcode, all outputs remain 0
            default: begin
                Reg2Loc = 1'b0;
                ALUSrc = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0000;
                SignOp = 2'b00;
            end
        endcase
    end

endmodule