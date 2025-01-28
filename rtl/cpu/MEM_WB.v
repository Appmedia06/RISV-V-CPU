module  MEM_WB
(
    input   wire            sys_clk          ,
    input   wire            sys_start        ,
    input   wire    [31:0]  ALU_result_i     ,
    input   wire    [31:0]  RD_data_i        ,
    input   wire    [4:0 ]  RD_addr_i        ,
    input   wire            RegWrite_i       ,
    input   wire            MemToReg_i       ,
    input   wire    [31:0]  DataMemReadData_i,
    input   wire    [31:0]  pc_i             ,
    input   wire            isjump_i         ,    
    
    output  reg     [31:0]  ALU_result_o     ,
    output  reg     [31:0]  RD_data_o        ,
    output  reg     [4:0 ]  RD_addr_o        ,
    output  reg             RegWrite_o       ,
    output  reg             MemToReg_o       ,
    output  reg     [31:0]  DataMemReadData_o,
    output  reg     [31:0]  pc_o             ,
    output  reg             isjump_o       
    
);

always@(posedge sys_clk or negedge sys_start)
    begin
        if(~sys_start)
            begin
                ALU_result_o      <= 1'b0;
                RD_data_o         <= 1'b0;
                RD_addr_o         <= 1'b0;
                RegWrite_o        <= 1'b0;
                MemToReg_o        <= 1'b0;
                DataMemReadData_o <= 1'b0;
                pc_o              <= 1'b0;
                isjump_o          <= 1'b0;
            end
        else
            begin
                ALU_result_o      <= ALU_result_i;
                RD_data_o         <= RD_data_i;
                RD_addr_o         <= RD_addr_i;
                RegWrite_o        <= RegWrite_i;
                MemToReg_o        <= MemToReg_i;
                DataMemReadData_o <= DataMemReadData_i;
                pc_o              <= pc_i + 32'd4; // jump rd = pc + 4
                isjump_o          <= isjump_i;
            end
    end

endmodule