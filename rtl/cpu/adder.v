module  adder
(
    input   wire    [31:0]  data1_i,
    input   wire    [31:0]  data2_i,
    
    output  wire    [31:0]  data_o 
);

assign  data_o = $signed(data1_i) + $signed(data2_i);

endmodule