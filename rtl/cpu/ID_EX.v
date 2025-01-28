module  ID_EX
(
    input   wire            sys_clk        ,
    input   wire            sys_start      ,
    
    input   wire            flush_i        , 
    input   wire    [31:0]  instr_i        ,
    input   wire    [31:0]  pc_i           ,
    // input   wire    [31:0]  pcEX_i         ,
    input   wire    [31:0]  RD_data0_i     ,
    input   wire    [31:0]  RD_data1_i     ,
    input   wire    [31:0]  SignExtended_i ,
    input   wire    [4:0 ]  RegDst_i       ,
    input   wire    [31:0]  Offset_i       ,
                              
    input   wire    [3:0 ]  ALUop_i        ,
    input   wire            ALUsrc_i       ,
    input   wire            RegWrite_i     ,
    input   wire            MemToReg_i     ,
    input   wire            MemRead_i      ,
    input   wire            MemWrite_i     ,
    input   wire            PC_branch_sel_i,
    
    input   wire    [4:0 ]  RS_addr_i      ,
    input   wire    [4:0 ]  RT_addr_i      ,
    input   wire            isdiv_i        ,
    
    output  reg     [31:0]  instr_o        ,
    output  reg     [31:0]  pc_o           ,
    // output  reg     [31:0]  pcEX_o         ,
    output  reg     [31:0]  RD_data0_o     ,
    output  reg     [31:0]  RD_data1_o     ,
    output  reg     [31:0]  SignExtended_o ,
    output  reg     [4:0 ]  RegDst_o       , 
    output  reg     [31:0]  Offset_o       ,
    
    output  reg     [3:0 ]  ALUop_o        ,
    output  reg             ALUsrc_o       ,
    output  reg             RegWrite_o     ,
    output  reg             MemToReg_o     ,
    output  reg             MemRead_o      ,
    output  reg             MemWrite_o     ,
    output  reg             PC_branch_sel_o,
    
    output  reg     [4:0 ]  RS_addr_o      ,
    output  reg     [4:0 ]  RT_addr_o      ,
    output  reg             isdiv_o        
);

always@(posedge sys_clk or negedge sys_start)
    begin   
        if(~sys_start)
            begin
                instr_o         <= 1'b0;
                pc_o            <= 1'b0;
                // pcEX_o          <= 1'b0;
                RD_data0_o      <= 1'b0;
                RD_data1_o      <= 1'b0;
                SignExtended_o  <= 1'b0;
                RegDst_o        <= 1'b0;
                Offset_o        <= 1'b0;
                ALUop_o         <= 4'b0;
                ALUsrc_o        <= 1'b0;
                RegWrite_o      <= 1'b0;
                MemToReg_o      <= 1'b0;
                MemRead_o       <= 1'b0;
                MemWrite_o      <= 1'b0;
                PC_branch_sel_o <= 1'b0;

                RS_addr_o       <= 1'b0;
                RT_addr_o       <= 1'b0;
                isdiv_o         <= 1'b0;
            end
        else if(flush_i)
            begin
                instr_o         <= 1'b0;
                pc_o            <= pc_i;
                // pcEX_o          <= 1'b0;
                RD_data0_o      <= 1'b0;
                RD_data1_o      <= 1'b0;
                SignExtended_o  <= 1'b0;
                RegDst_o        <= 1'b0;
                Offset_o        <= 1'b0;
                
                ALUop_o         <= 4'b0;
                ALUsrc_o        <= 1'b0;
                RegWrite_o      <= 1'b0;
                MemToReg_o      <= 1'b0;
                MemRead_o       <= 1'b0;
                MemWrite_o      <= 1'b0;
                PC_branch_sel_o <= 1'b0;

                RS_addr_o       <= 1'b0;
                RT_addr_o       <= 1'b0;
                isdiv_o         <= 1'b0;
            end
        else
            begin
                instr_o         <= instr_i;
                pc_o            <= pc_i;
                // pcEX_o          <= pcEX_i; 
                RD_data0_o      <= RD_data0_i;
                RD_data1_o      <= RD_data1_i;
                SignExtended_o  <= SignExtended_i;
                RegDst_o        <= RegDst_i;
                Offset_o        <= Offset_i;

                ALUop_o         <= ALUop_i;
                ALUsrc_o        <= ALUsrc_i;
                RegWrite_o      <= RegWrite_i;
                MemToReg_o      <= MemToReg_i;
                MemRead_o       <= MemRead_i;
                MemWrite_o      <= MemWrite_i;
                PC_branch_sel_o <= PC_branch_sel_i;
                
                RS_addr_o       <= RS_addr_i;
                RT_addr_o       <= RT_addr_i;
                isdiv_o         <= isdiv_i;
            end 
    end
endmodule