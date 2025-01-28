/* Shift left 1 bit */
module  Shift
(
    input   wire    [31:0]  data_i,
    
    output  wire    [31:0]  data_o
);

assign  data_o = {data_i[30:0], 1'b0};

endmodule