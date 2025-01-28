`include "cpu_define.v"

module  ALU_control
(
    input   wire    [9:0]   funct_i   , // {funct7, funct3}
    input   wire    [3:0]   ALUop_i   ,
    
    output  reg     [3:0]   ALU_Ctrl_o
);



always@(*)
    begin
        case(ALUop_i)
        
        // Load & Store & JAL & JALR
        4'b0000:
            begin
                ALU_Ctrl_o = `ALU_ADD;
            end
        // Branch
        4'b0001:
            begin
                case(funct_i[2:0]) // funct3
                `INS_BEQ : ALU_Ctrl_o = `ALU_SUB ;
                `INS_BNE : ALU_Ctrl_o = `ALU_SUB ;
                `INS_BLT : ALU_Ctrl_o = `ALU_SLT ;
                `INS_BGE : ALU_Ctrl_o = `ALU_SLT ;
                `INS_BLTU: ALU_Ctrl_o = `ALU_SLTU;
                `INS_BGEU: ALU_Ctrl_o = `ALU_SLTU;
                endcase
            end
        // R-type & M-type
        4'b0010:
            begin
                case(funct_i)
                // R-type
                `INS_ADD : ALU_Ctrl_o = `ALU_ADD ;
                `INS_SUB : ALU_Ctrl_o = `ALU_SUB ;
                `INS_SLL : ALU_Ctrl_o = `ALU_SLL ;
                `INS_SLT : ALU_Ctrl_o = `ALU_SLT ;
                `INS_SLTU: ALU_Ctrl_o = `ALU_SLTU;
                `INS_XOR : ALU_Ctrl_o = `ALU_XOR ;
                `INS_SRL : ALU_Ctrl_o = `ALU_SRL ;
                `INS_SRA : ALU_Ctrl_o = `ALU_SRA ;
                `INS_OR  : ALU_Ctrl_o = `ALU_OR  ;
                `INS_AND : ALU_Ctrl_o = `ALU_AND ;
                // M-type
                `INS_MUL    : ALU_Ctrl_o = `MALU_MUL   ;
                `INS_MULH   : ALU_Ctrl_o = `MALU_MULH  ;
                `INS_MULHSU : ALU_Ctrl_o = `MALU_MULHSU;
                `INS_MULHU  : ALU_Ctrl_o = `MALU_MULHU ;
                `INS_DIV    : ALU_Ctrl_o = `MALU_DIV   ;
                `INS_DIVU   : ALU_Ctrl_o = `MALU_DIVU  ;
                `INS_REM    : ALU_Ctrl_o = `MALU_REM   ;
                `INS_REMU   : ALU_Ctrl_o = `MALU_REMU  ;
                endcase
            end
        // I-type
        4'b0011:
            begin
                case(funct_i[2:0]) // funct3
                `INS_ADDI     : ALU_Ctrl_o = `ALU_ADD ;
                `INS_SLTI     : ALU_Ctrl_o = `ALU_SLT ;
                `INS_SLTIU    : ALU_Ctrl_o = `ALU_SLTU;
                `INS_XORI     : ALU_Ctrl_o = `ALU_XOR ;
                `INS_ORI      : ALU_Ctrl_o = `ALU_OR  ;
                `INS_ANDI     : ALU_Ctrl_o = `ALU_AND ;
                `INS_SLLI     : ALU_Ctrl_o = `ALU_SLL ;
                `INS_SRLI_SRAI: ALU_Ctrl_o = `ALU_SRL ;
                endcase
            end
        // LUI
        4'b0100:
            begin
                ALU_Ctrl_o = `ALU_LUI ;
            end
        // AUIPC
        4'b0101:
            begin
                ALU_Ctrl_o = `ALU_ADD ;
            end
        // CSR
        4'b0110:
            begin
                ALU_Ctrl_o = `ALU_ADD ;
            end
        default:
            begin
                ALU_Ctrl_o = `ALU_ADD ;
            end 
        endcase
    end


endmodule