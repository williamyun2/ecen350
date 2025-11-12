`timescale 1ns / 1ps

`define Itype   2'b00
`define Dtype   2'b01
`define CBtype  2'b10
`define Btype   2'b11

module SignExtender(
    output reg [63:0] SignExOut,
    input      [31:0] Instruction,  // Changed from [25:0] to get hw field for MOVZ
    input      [1:0]  SignOp
);

    reg [1:0] hw;  // Hardware shift field for MOVZ
    reg [15:0] imm16;  // 16-bit immediate for MOVZ

    always @(*) begin
        case (SignOp)
            `Itype: begin
                // Check if this is MOVZ (opcode 110100101)
                if (Instruction[31:23] == 9'b110100101) begin
                    // MOVZ: Extract hw and imm16, then shift accordingly
                    hw = Instruction[22:21];
                    imm16 = Instruction[20:5];
                    
                    case (hw)
                        2'b00: SignExOut = {48'b0, imm16};           // Shift 0 (bits 15:0)
                        2'b01: SignExOut = {32'b0, imm16, 16'b0};    // Shift 16 (bits 31:16)
                        2'b10: SignExOut = {16'b0, imm16, 32'b0};    // Shift 32 (bits 47:32)
                        2'b11: SignExOut = {imm16, 48'b0};           // Shift 48 (bits 63:48)
                        default: SignExOut = 64'b0;
                    endcase
                end else begin
                    // Regular I-type: 12-bit immediate [21:10], zero extend
                    SignExOut = {52'b0, Instruction[21:10]};
                end
            end
            
            `Dtype: begin
                // D-type: 9-bit immediate [20:12], sign extend
                SignExOut = {{55{Instruction[20]}}, Instruction[20:12]};
            end
            
            `CBtype: begin
                // CB-type: 19-bit immediate [23:5], sign extend, shift left by 2
                SignExOut = {{43{Instruction[23]}}, Instruction[23:5], 2'b00};
            end
            
            `Btype: begin
                // B-type: 26-bit immediate [25:0], sign extend, shift left by 2
                SignExOut = {{36{Instruction[25]}}, Instruction[25:0], 2'b00};
            end
            
            default: begin
                SignExOut = 64'b0;
            end
        endcase
    end

endmodule