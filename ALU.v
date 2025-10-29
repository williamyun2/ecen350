`timescale 1ns / 1ps

`define AND   4'b0000
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111

module ALU(
    output reg [63:0] BusW,
    input      [63:0] BusA,
    input      [63:0] BusB,
    input      [3:0]  ALUCtrl,
    output            Zero
);

    always @(*) begin
        case (ALUCtrl)
            `AND: begin
                BusW = BusA & BusB;
            end
            
            `OR: begin
                BusW = BusA | BusB;
            end
            
            `ADD: begin
                BusW = BusA + BusB;
            end
            
            `SUB: begin
                BusW = BusA - BusB;
            end
            
            `PassB: begin
                BusW = BusB;
            end
            
            default: begin
                BusW = 64'b0;
            end
        endcase
    end
    
    // Zero flag is set when BusW is all zeros
    assign Zero = (BusW == 64'b0);

endmodule
