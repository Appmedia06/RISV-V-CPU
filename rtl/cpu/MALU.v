`include "cpu_define.v"

module  MALU
(
    input   wire    [31:0]  data0_i   ,
    input   wire    [31:0]  data1_i   ,
    input   wire    [3:0 ]  ALU_Ctrl_i,
    input   wire            is_M_i    , // is RV32M instruction
    
    output  reg     [31:0]  data_o    
);

reg     [63:0]  product;
reg     [31:0]  unsigned_data0;
reg     [31:0]  unsigned_data1;

reg     [63:0]  negative_product;

always@(*)
    begin
        if(is_M_i)
            product = unsigned_data0 * unsigned_data1;
        else
            product = 64'b0;
    end
    
always@(*)
    begin
        case(ALU_Ctrl_i)
        
        `MALU_MUL:
            begin
                unsigned_data0 = (data0_i[31]) ? ((~data0_i) + 1'b1) : data0_i;
                unsigned_data1 = (data1_i[31]) ? ((~data1_i) + 1'b1) : data1_i;
                if(data0_i[31] ^ data1_i[31])
                    begin
                        negative_product = ~product + 1'b1;
                        data_o = negative_product[31:0];
                    end
                else
                    begin
                        data_o = product[31:0];
                    end
            end
            
        `MALU_MULH:
            begin
                unsigned_data0 = (data0_i[31]) ? ((~data0_i) + 1'b1) : data0_i;
                unsigned_data1 = (data1_i[31]) ? ((~data1_i) + 1'b1) : data1_i;
                if(data0_i[31] ^ data1_i[31])
                    begin
                        negative_product = ~product + 1'b1;
                        data_o = negative_product[63:32];
                    end
                else
                    begin
                        data_o = product[63:32];
                    end
            end
            
        `MALU_MULHSU:
            begin
                unsigned_data0 = (data0_i[31]) ? ((~data0_i) + 1'b1) : data0_i;
                unsigned_data1 = data1_i;
                if(data0_i[31])
                    begin
                        negative_product = ~product + 1'b1;
                        data_o = negative_product[63:32];
                    end
                else
                    begin
                        data_o = product[63:32];
                    end
            end
            
        `MALU_MULHU:
            begin
                unsigned_data0 = data0_i;
                unsigned_data1 = data1_i;
                data_o = product[63:32];
            end
        endcase
    end

endmodule