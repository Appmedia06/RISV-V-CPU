/* Shift left 12 bit */
module  Shift12
(
    input   wire    [31:0]  data_i,
    
    output  wire    [31:0]  data_o
);

assign  data_o = {data_i[19:0], 12{1'b0}};

endmodule