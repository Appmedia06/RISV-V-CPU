module  EX_MEM
(
    input   wire            sys_clk     ,
    input   wire            sys_start   ,
    
    // input   wire            flush_i     ,  
    input   wire    [31:0]  pc_i        ,
    input   wire            zero_i      ,
    input   wire    [31:0]  ALU_result_i,
    input   wire    [31:0]  RD_data_i   ,
    input   wire    [4:0 ]  RD_addr_i   ,
    input   wire            RegWrite_i  ,
    input   wire            MemToReg_i  ,
    input   wire            MemRead_i   ,
    input   wire            MemWrite_i  ,
    input   wire    [31:0]  instr_i     ,
    input   wire    [31:0]  Offset_i    ,
    input   wire            isjump_i    ,
    
    output  reg     [31:0]  pc_o        ,
    output  reg     [31:0]  ALU_result_o,
    output  reg     [31:0]  RD_data_o   ,
    output  reg     [4:0 ]  RD_addr_o   ,
    output  reg             RegWrite_o  ,
    output  reg             MemToReg_o  ,
    output  reg             MemRead_o   ,
    output  reg             MemWrite_o  ,
    output  reg     [31:0]  instr_o     ,
    output  reg     [31:0]  Offset_o    ,
    output  reg             isjump_o 
);

always@(posedge sys_clk or negedge sys_start)
    begin
        if(~sys_start)
            begin
                pc_o         <= 1'b0;
                ALU_result_o <= 1'b0;
                RD_data_o    <= 1'b0;
                RD_addr_o    <= 1'b0;
                RegWrite_o   <= 1'b0;
                MemToReg_o   <= 1'b0;
                MemRead_o    <= 1'b0;
                MemWrite_o   <= 1'b0;
                instr_o      <= 1'b0;
                Offset_o     <= 1'b0;
                isjump_o     <= 1'b0;
            end
/*         else if(flush_i)
            begin
                pc_o         <= pc_i;
                ALU_result_o <= 1'b0;
                RD_data_o    <= 1'b0;
                RD_addr_o    <= 1'b0;
                RegWrite_o   <= 1'b0;
                MemToReg_o   <= 1'b0;
                MemRead_o    <= 1'b0;
                MemWrite_o   <= 1'b0;
                instr_o      <= 1'b0;
            end */
        else
            begin
                pc_o         <= pc_i;
                ALU_result_o <= ALU_result_i;
                RD_data_o    <= RD_data_i;
                RD_addr_o    <= RD_addr_i;
                RegWrite_o   <= RegWrite_i;
                MemToReg_o   <= MemToReg_i;
                MemRead_o    <= MemRead_i;
                MemWrite_o   <= MemWrite_i;
                instr_o      <= instr_i;
                Offset_o     <= Offset_i;
                isjump_o     <= isjump_i;
            end
    end
    
endmodule