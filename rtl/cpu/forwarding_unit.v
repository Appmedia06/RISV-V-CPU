module  forwarding_unit
(
    input   wire    [4:0]   ID_EX_RS_i       ,
    input   wire    [4:0]   ID_EX_RT_i       ,
    input   wire    [4:0]   EX_MEM_RD_i      ,
    input   wire    [4:0]   MEM_WB_RD_i      ,
    input   wire            EX_MEM_RegWrite_i,
    input   wire            MEM_WB_RegWrite_i,
    
    output  reg     [1:0]   ForwardA_o       ,
    output  reg     [1:0]   ForwardB_o       
);

/* 
    P.137
    Detect hazard
    1. 是否有寫入暫存器 RegWrite
    2. RD != 0
    3. 目前指令的RD和之後指令的RS or RT是否相同
    
    Forward:
        10: EX Hazard(間格1):  從MEM的RD當source
        01: MEM Hazard(間格2): 從WB的RD當source
*/

always@(*)
    begin
        
        // ForwardA_o
        ForwardA_o = 2'b00;
        
        if(EX_MEM_RegWrite_i && EX_MEM_RD_i != 5'b00000 && EX_MEM_RD_i == ID_EX_RS_i)
            ForwardA_o = 2'b10;
        else if(MEM_WB_RegWrite_i && MEM_WB_RD_i != 5'b00000 && MEM_WB_RD_i == ID_EX_RS_i)
            ForwardA_o = 2'b01;
            
        // ForwardB_o
        ForwardB_o = 2'b00;
        
        if(EX_MEM_RegWrite_i && EX_MEM_RD_i != 5'b00000 && EX_MEM_RD_i == ID_EX_RT_i)
            ForwardB_o = 2'b10;
        else if(MEM_WB_RegWrite_i && MEM_WB_RD_i != 5'b00000 && MEM_WB_RD_i == ID_EX_RT_i)
            ForwardB_o = 2'b01;
    end
    

endmodule