`include "cpu_define.v"

module  ALU
(
    input   wire    [31:0]  data0_i   ,
    input   wire    [31:0]  data1_i   ,
    input   wire    [3:0 ]  ALU_Ctrl_i,
    
    output  reg     [31:0]  data_o    ,
    output  reg             zero_o      // for branch
);



always@(*)
    begin
        zero_o = (data0_i - data1_i) ? 0 : 1;
        
        case(ALU_Ctrl_i)
        `ALU_ADD:
            begin
               data_o = $signed(data0_i) + $signed(data1_i); // add
            end
        `ALU_SUB:
            begin
                data_o = $signed(data0_i) - $signed(data1_i); // sub
            end        
        `ALU_SLL:
            begin
                data_o = data0_i << data1_i; // logical left shift
            end        
        `ALU_SLT:
            begin
                data_o = ($signed(data0_i) < $signed(data1_i)) ? 1 : 0; // signed less than
            end        
        `ALU_SLTU:
            begin
                data_o = (data0_i < data1_i) ? 1 : 0; // unsigned less than
            end        
        `ALU_XOR:
            begin
               data_o = data0_i ^ data1_i; // XOR
            end        
        `ALU_SRL:
            begin
                data_o = data0_i >> data1_i; // logical right shift
            end        
        `ALU_SRA:
            begin
                data_o = $signed(data0_i) >>> data1_i; // arithmetic right shif
            end        
        `ALU_OR :
            begin
                data_o = data0_i | data1_i; // OR
            end        
        `ALU_AND:
            begin
                data_o = data0_i & data1_i; // AND
            end
        `ALU_LUI:
            begin
                data_o = data1_i;
                
            end
        
        default:
            begin
                data_o = data0_i;
            end
        endcase
    end
endmodule