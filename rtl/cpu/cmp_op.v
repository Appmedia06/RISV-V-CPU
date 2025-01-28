module  cmp_op
(
    input   wire    [6:0]   opcode,
    
    output  wire            need_PC
);

assign need_PC = (opcode == 7'b0010111) ? 1 : 0; // AUIPC

endmodule