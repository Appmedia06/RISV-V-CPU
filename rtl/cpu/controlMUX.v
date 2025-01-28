module  controlMUX
(
    input   wire            Hazard_i  ,
    
    input   wire    [3:0]   ALUop_i   ,
    input   wire            ALUsrc_i  ,
    input   wire            RegWrite_i,
    input   wire            MemRead_i ,
    input   wire            MemWrite_i,
    input   wire            MemToReg_i,
    input   wire    [4:0]   RegDst_i  ,
    
    output  reg     [3:0]   ALUop_o   ,
    output  reg             ALUsrc_o  ,
    output  reg             RegWrite_o,
    output  reg             MemRead_o ,
    output  reg             MemWrite_o,
    output  reg             MemToReg_o,
    output  reg     [4:0]   RegDst_o  
);

always@(*)
    begin
        case(Hazard_i)
        
        1'b1:
            begin
                ALUop_o    <= 4'b0;
                ALUsrc_o   <= 1'b0;
                RegWrite_o <= 1'b0;
                MemRead_o  <= 1'b0;
                MemWrite_o <= 1'b0;
                MemToReg_o <= 1'b0;
                RegDst_o   <= 4'b0;
            end
        
        1'b0:
            begin
                ALUop_o    <= ALUop_i;
                ALUsrc_o   <= ALUsrc_i;
                RegWrite_o <= RegWrite_i;
                MemRead_o  <= MemRead_i;
                MemWrite_o <= MemWrite_i;
                MemToReg_o <= MemToReg_i;
                RegDst_o   <= RegDst_i;
            end
        default:
            begin
                ALUop_o    <= ALUop_i;
                ALUsrc_o   <= ALUsrc_i;
                RegWrite_o <= RegWrite_i;
                MemRead_o  <= MemRead_i;
                MemWrite_o <= MemWrite_i;
                MemToReg_o <= MemToReg_i;
                RegDst_o   <= RegDst_i;
            end         
        endcase
    end

endmodule
