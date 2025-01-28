module  mux3
(
    input   wire    [19:0]  data0_i ,
    input   wire    [11:0]  data1_i ,
    input   wire    [11:0]  data2_i ,
    input   wire    [1:0 ]  select_i,
    
    output  reg     [31:0]  data_o  
);

always@(*)
    begin
        case(select_i)
            
            2'b00: data_o = {{12{data0_i[19]}}, data0_i};
            
            2'b01: data_o = {{20{data1_i[11]}}, data1_i};
            
            2'b10: data_o = {{20{data2_i[11]}}, data2_i};

            default: data_o = {{12{data0_i[19]}}, data0_i};
        
        endcase
    end


endmodule