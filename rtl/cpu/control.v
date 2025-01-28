`include "cpu_define.v"

module  control
(
    input   wire    [6:0]   op_i       , // opcode
    input   wire    [2:0]   funct3_i   ,
    input   wire    [6:0]   funct7_i   ,
                                       
    output  reg     [3:0]   ALUop_o    , // ALU  operation
    output  reg             ALUsrc_o   , // mux diff input
    output  reg             RegWrite_o , // enable to write into register
    output  reg             MemRead_o  , // enable to read Memory
    output  reg             MemWrite_o , // enable to write into Memory
    output  reg             MemToReg_o , // mux diff input
    output  reg     [2:0]   immSelect_o  // select immediate signedExtend
);

/*
    control line:
        ALUop     : ALU opcode
        ALUsrc    : source by immediate or not
        RegWrite  : Register should be writed
        MemRead   : Memory Read
        MemWrite  : Memory Write
        immSelect : Select the signedExtend of immediate between different type
*/

/*
    ALU_op:
        0000: Load-type & Store-type: add
        0001: Branch                : by funct3
        0010: R-type                : by {funct7, funct3}
        0011: I-type                : by funct3
        0100: LUI
        0101: AUIPC
        0110: JAL
        0111: JALR
*/

always@(*)
    begin
        case(op_i)
        // R-type
        `INS_TYPE_R_M: 
            begin
                ALUop_o     = 4'b0010;
                ALUsrc_o    = 1'b0;
                RegWrite_o  = 1'b1;
                MemRead_o   = 1'b0;
                MemWrite_o  = 1'b0;
                MemToReg_o  = 1'b0;
                immSelect_o = 3'b000;
            end
        // I-type
        `INS_TYPE_I:
            begin
                ALUop_o     = 4'b0011;
                ALUsrc_o    = 1'b1;
                RegWrite_o  = 1'b1;
                MemRead_o   = 1'b0;
                MemWrite_o  = 1'b0;
                MemToReg_o  = 1'b0;
                immSelect_o = 3'b000;                
            end
        `INS_LUI:
            begin
                ALUop_o     = 4'b0100;
                ALUsrc_o    = 1'b1; 
                RegWrite_o  = 1'b1;
                MemRead_o   = 1'b0;
                MemWrite_o  = 1'b0;
                MemToReg_o  = 1'b0;
                immSelect_o = 3'b010;                
            end
        `INS_AUIPC:
            begin
                ALUop_o     = 4'b0101;
                ALUsrc_o    = 1'b1; 
                RegWrite_o  = 1'b1;
                MemRead_o   = 1'b0;
                MemWrite_o  = 1'b0;
                MemToReg_o  = 1'b0;
                immSelect_o = 3'b010;                 
            end
        `INS_JAL: // jump_o ?
            begin
                ALUop_o     = 4'b0000;
                ALUsrc_o    = 1'b1;
                RegWrite_o  = 1'b1;
                MemRead_o   = 1'b0;
                MemWrite_o  = 1'b0;
                MemToReg_o  = 1'b0;
                immSelect_o = 3'b100;                
            end 
        `INS_JALR:
            begin
                ALUop_o     = 4'b0000;
                ALUsrc_o    = 1'b1;
                RegWrite_o  = 1'b1;
                MemRead_o   = 1'b0;
                MemWrite_o  = 1'b0;
                MemToReg_o  = 1'b0;
                immSelect_o = 3'b000;                    
            end  
        `INS_TYPE_BRANCH:
            begin
                ALUop_o     = 4'b0001;
                ALUsrc_o    = 1'b0;
                RegWrite_o  = 1'b0;
                MemRead_o   = 1'b0;
                MemWrite_o  = 1'b0;
                MemToReg_o  = 1'b0;
                immSelect_o = 3'b011;                 
            end 
        `INS_TYPE_LOAD:
            begin
                ALUop_o     = 4'b0000;
                ALUsrc_o    = 1'b1;
                RegWrite_o  = 1'b1;
                MemRead_o   = 1'b1;
                MemWrite_o  = 1'b0;
                MemToReg_o  = 1'b1;
                immSelect_o = 3'b000;                  
            end 
        `INS_TYPE_SAVE:
            begin
                ALUop_o     = 4'b0000;
                ALUsrc_o    = 1'b1;
                RegWrite_o  = 1'b0;
                MemRead_o   = 1'b0;
                MemWrite_o  = 1'b1;
                MemToReg_o  = 1'b0;
                immSelect_o = 3'b001;  
            end 
        `INS_TYPE_CSR:
            begin
                ALUop_o     = 3'b110;
                ALUsrc_o    = 1'b1;
                RegWrite_o  = 1'b1;
                MemRead_o   = 1'b0;
                MemWrite_o  = 1'b1;
                MemToReg_o  = 1'b0;
                immSelect_o = 2'b00;                  
            end    
        default
            begin
                ALUop_o     = 4'b0000;
                ALUsrc_o    = 1'b0;
                RegWrite_o  = 1'b0;
                MemRead_o   = 1'b0;
                MemWrite_o  = 1'b0;
                MemToReg_o  = 1'b0;
                immSelect_o = 3'b000;  
            end
        endcase
    end
endmodule