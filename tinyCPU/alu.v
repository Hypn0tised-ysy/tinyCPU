module alu(
    input signed [31:0] operandA, operandB,  // 输入操作数
    input [4:0] ALUOp,                      // ALU 操作选择信号
    output reg signed [31:0] result,        // 运算结果
    output reg Zero                         // Zero 标志
);

always @(*) begin
    case (ALUOp)
        5'b00011:  begin // 加法
            result = operandA + operandB;
        end
        default: result = 32'b0; // 默认情况下结果为 0
    endcase

    Zero = (result == 0) ? 1'b1 : 1'b0;
end

endmodule
