`timescale 1ns / 1ps

`define Itype   2'b00
`define Dtype   2'b01
`define CBtype  2'b10
`define Btype   2'b11

module SignExtender(
    output reg [63:0] SignExOut,
    input      [25:0] Instruction,
    input      [1:0]  SignOp
);

    always @(*) begin
        case (SignOp)
            `Itype: begin
                // I-type: 12-bit immediate [21:10], zero extend
                SignExOut = {52'b0, Instruction[21:10]};
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
