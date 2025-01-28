module  branch_control
(
    input   wire    [2:0]   funct3,
    input   wire    [31:0]  ALU_data,
    
    output  reg             branch_estab
);

always@(*)
    begin
        case(funct3)
        
            3'b000: // BEQ
                begin
                    branch_estab = (ALU_data == 32'b0) ? 1 : 0;
                end
            3'b001: // BNE
                begin
                    branch_estab = (ALU_data != 32'b0) ? 1 : 0;
                end
            3'b100: // BLT
                begin
                    branch_estab = (ALU_data == 32'b1) ? 1 : 0;
                end   
            3'b101: // BGE
                begin
                    branch_estab = (ALU_data != 32'b1) ? 1 : 0;
                end                 
            3'b110: // BLTU
                begin
                    branch_estab = (ALU_data == 32'b1) ? 1 : 0;
                end      
            3'b111: // BGEU
                begin
                    branch_estab = (ALU_data != 32'b1) ? 1 : 0;
                end   
            default: branch_estab = 1'b0;
        
        endcase
    end

endmodule