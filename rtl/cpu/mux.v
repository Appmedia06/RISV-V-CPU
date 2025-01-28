module  mux
(
    input   wire    [31:0]  data0_i ,
    input   wire    [31:0]  data1_i ,
    input   wire            select_i,
    
    output  wire    [31:0]  data_o  
);

assign  data_o = (select_i) ? data1_i : data0_i;

endmodule