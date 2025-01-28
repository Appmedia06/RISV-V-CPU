module  pcIm_control
(
    input   wire    [6:0]   opcode,
    
    output  reg     [1:0]   pc_type
);

always@(*)
    begin
        case(opcode)
        
        7'b1101111: pc_type = 2'b00; // JAL
        
        7'b1100111: pc_type = 2'b01; // JALR
        
        7'b1100011: pc_type = 2'b10; // Branch
        
        endcase
    end

endmodule