/* load-use data hazard */
module  hazard_detection
(
    input   wire    [4:0]   IF_ID_RS1_i    ,
    input   wire    [4:0]   IF_ID_RS2_i    ,
    input   wire    [4:0]   ID_EX_RD_i     ,
    input   wire            ID_EX_MemRead_i,
    
    output  wire            Hazard_o     
);

assign  Hazard_o = (ID_EX_MemRead_i && (ID_EX_RD_i == IF_ID_RS1_i || ID_EX_RD_i == IF_ID_RS2_i)) ? 1'b1 : 1'b0;

endmodule