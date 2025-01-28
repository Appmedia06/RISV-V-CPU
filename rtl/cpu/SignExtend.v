module  SignExtend
(
    input   wire    [2:0 ]  select_i,
    input   wire    [24:0]  data_i  ,
/*     input   wire    [11:0]  data1_i ,
    input   wire    [19:0]  data2_i , */
    
    output  reg     [31:0]  data_o  
);

// data_o: 前20位是data_i的最高位重複20個，後12位是data_i
// assign data_o = (select_i) ? {{20{data1_i[11]}}, data1_i} : {{20{data0_i[11]}}, data0_i};

always@(*)
    begin
        case(select_i)
            
            // 2'b000: data_o = {{20{data1_i[11]}}, data1_i}; // L-type & I-type
            3'b000: data_o = {{20{data_i[24]}}, data_i[24:13]}; // L-type & I-type & JALR
            
            // 2'b001: data_o = {{20{data0_i[11]}}, data0_i}; // S-type
            3'b001: data_o = {{20{data_i[24]}}, data_i[24:18], data_i[4:0]}; // S-type
            
            3'b010: data_o = data_i[24:5] << 12; // LUI, AUIPC
            
            3'b011: data_o = {{20{data_i[24]}}, data_i[24], data_i[0], data_i[23:18], data_i[4:1]}; // B-type
            
            3'b100: data_o = {{20{data_i[24]}}, data_i[24], data_i[12:5], data_i[13], data_i[23:14]}; // JAL
            
            3'b101: data_o = {{20{data_i[11]}}, data_i[11:0]};
            
            default: data_o = {{20{data_i[24]}}, data_i[24:13]};
        
        endcase
    end

endmodule